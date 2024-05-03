use std::{collections::HashMap, sync::Arc};

use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Transaction};

use aggregator::{util::*, Pipeline, PipelineAggregationResult, PipelineError};
use sqlx_postgres::Postgres;
use tokio::sync::RwLock;

use crate::{TARGET_EVENTS, MAX_BATCH_SIZE, update_batch_size, DEFAULT_BATCH_SIZE};

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(1);

// Basis point amounts multiplied by 10, to enable 2.5 bps indexing.
const BPSS_TIMES_TEN: [i32;8] = [0, 25, 50, 100, 250, 500, 1000, 2000];

const BPS_DIVISOR: i32 = 10_000;

const BPS_TIMES_TEN_DIVISOR: i32 = 10 * BPS_DIVISOR;

const ASK: bool = true;

pub struct OrderHistoryPipelines {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
    state: Option<SpreadsState>,
    last_prices: HashMap<BigDecimal, Option<BigDecimal>>,
    batch_size: BigDecimal,
}

impl OrderHistoryPipelines {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
            state: None,
            last_prices: Default::default(),
            // Start with a very small batch size.
            // This way, if the aggregator is restarting after a crash due to too many events in
            // ram, it will not just crash again.
            batch_size: BigDecimal::from(DEFAULT_BATCH_SIZE),
        }
    }
}

// The first element is market_id, the second one is order_id.
// This allows us to uniquely identify an order.
type OrderKey = (BigDecimal, BigDecimal);

#[derive(Clone)]
struct SpreadsState {
    orders: HashMap<OrderKey, Order>,
    last_txn_indexed: BigDecimal,
}

impl Default for SpreadsState {
    fn default() -> Self {
        Self {
            orders: HashMap::new(),
            last_txn_indexed: BigDecimal::zero(),
        }
    }
}

#[derive(PartialEq, Eq, Hash)]
struct LiquidityKey {
    group_id: i32,
    bps_times_ten: i32,
}

struct LiquidityValue {
    /// Effective value of base locked in asks, quoted in ticks.
    /// Price taken as the last fill price at the time of calculation.
    base: BigDecimal,
    /// Amount of quote locked in bids, quoted in ticks.
    quote: BigDecimal,
}

#[derive(Clone)]
struct Order {
    market_id: BigDecimal,
    order_id: BigDecimal,
    size: BigDecimal,
    side: bool,
    price: BigDecimal,
    user: Option<String>,
}

struct Fill {
    market_id: BigDecimal,
    maker_order_id: BigDecimal,
    taker_order_id: BigDecimal,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    size: BigDecimal,
    price: BigDecimal,
}

fn handle_fill(fill: &Fill, orders: &mut HashMap<OrderKey, Order>, index: &mut usize) {
    *index += 1;
    let order_key_maker = (fill.market_id.clone(), fill.maker_order_id.clone());
    if let Some(order) = orders.get_mut(&order_key_maker) {
        order.size -= fill.size.clone();
        if order.size.is_zero() {
            orders.remove(&order_key_maker);
        }
    }
    let order_key_taker = (fill.market_id.clone(), fill.taker_order_id.clone());
    if let Some(order) = orders.get_mut(&order_key_taker) {
        order.size -= fill.size.clone();
        if order.size.is_zero() {
            orders.remove(&order_key_taker);
        }
    }
}

struct Change {
    market_id: BigDecimal,
    order_id: BigDecimal,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    new_size: BigDecimal,
}

fn handle_change(change: &Change, orders: &mut HashMap<OrderKey, Order>, index: &mut usize) {
    *index += 1;
    let order_key = (change.market_id.clone(), change.order_id.clone());
    if let Some(order) = orders.get_mut(&order_key) {
        order.size = change.new_size.clone();
        if order.size.is_zero() {
            orders.remove(&order_key);
        }
    }
}

impl OrderHistoryPipelines {
    /// Given a previous state (and the last transaction version included in that state), computes
    /// the new state at the given timestamp.
    async fn get_state_from_timestamp_with_state<'a>(
        &mut self,
        timestamp: &DateTime<Utc>,
        transaction: &mut Transaction<'a, Postgres>,
    ) -> Result<(), PipelineError> {
        let SpreadsState {
            orders,
            last_txn_indexed: txn_version_of_state,
        } = self.state.get_or_insert(Default::default());
        loop {
            // Get the biggest transaction version that happened before the given timestamp.
            let txn_version = sqlx::query_file!(
                "sqlx_queries/order_history_pipelines/get_max_txn_version_before_timestamp.sql",
                timestamp
            )
            .fetch_one(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?
            .txn_version
            .unwrap_or(BigDecimal::zero());

            if txn_version == *txn_version_of_state {
                return Ok(());
            }

            // Limit the number of transactions that will be processed in one batch. Not limiting this
            // could cause out of memory issues.
            let txn_version =
                (txn_version_of_state.clone() + &self.batch_size).min(txn_version);

            // Get all place events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let places = sqlx::query_file_as!(
                Order,
                "sqlx_queries/order_history_pipelines/get_place_limit_order_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version,
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

            // Get all fill events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let fills = sqlx::query_file_as!(
                Fill,
                "sqlx_queries/order_history_pipelines/get_fill_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

            // Get all change events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let changes = sqlx::query_file_as!(
                Change,
                "sqlx_queries/order_history_pipelines/get_change_order_size_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

            // Get all cancel events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let cancels = sqlx::query_file!(
                "sqlx_queries/order_history_pipelines/get_cancel_order_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

            let n_events = places.len() + fills.len() + changes.len() + cancels.len();
            update_batch_size(&mut self.batch_size, n_events);

            // Insert all places as orders into the state.
            for place in places {
                orders.insert((place.market_id.clone(), place.order_id.clone()), place);
            }

            // Remove all orders that have been cancelled.
            for cancel in cancels {
                orders.remove(&(cancel.market_id, cancel.order_id));
            }

            // Handle fills and changes chronologically.
            let mut fills_index = 0;
            let mut changes_index = 0;
            for _ in 0..(fills.len() + changes.len()) {
                let fill = fills.get(fills_index);
                let change = changes.get(changes_index);
                let (f, c) = match (fill, change) {
                    (Some(fill), Some(change)) => {
                        if (fill.txn_version.clone(), fill.event_idx.clone())
                            < (change.txn_version.clone(), change.event_idx.clone())
                        {
                            (Some(fill), None)
                        } else {
                            (None, Some(change))
                        }
                    }
                    (None, None) => unreachable!(),
                    other => other,
                };
                match (f, c) {
                    (Some(fill), None) => {
                        self.last_prices
                            .insert(fill.market_id.clone(), Some(fill.price.clone()));
                        handle_fill(fill, orders, &mut fills_index);
                    }
                    (None, Some(change)) => {
                        handle_change(change, orders, &mut changes_index);
                    }
                    _ => unreachable!(),
                };
            }

            *txn_version_of_state = txn_version;
        }
    }
}

/// Returns the min ask and max bid per market from a given state.
fn get_spreads_from_state<'a>(
    state: &SpreadsState,
) -> (
    HashMap<BigDecimal, BigDecimal>,
    HashMap<BigDecimal, BigDecimal>,
) {
    let mut min_asks: HashMap<BigDecimal, BigDecimal> = Default::default();
    let mut max_bids: HashMap<BigDecimal, BigDecimal> = Default::default();

    for element in state.orders.values() {
        if element.side == ASK {
            if let Some(min) = min_asks.get(&element.market_id) {
                if *min > element.price {
                    min_asks.insert(element.market_id.clone(), element.price.clone());
                }
            } else {
                min_asks.insert(element.market_id.clone(), element.price.clone());
            }
        } else {
            if let Some(max) = max_bids.get(&element.market_id) {
                if *max < element.price {
                    max_bids.insert(element.market_id.clone(), element.price.clone());
                }
            } else {
                max_bids.insert(element.market_id.clone(), element.price.clone());
            }
        }
    }

    (min_asks, max_bids)
}

/// Returns the amount of base and quote per group per BPS times ten from a given state.
///
/// hashmap type:
///
/// - key: (group_id, bps_times_ten)
/// - value: (base_amount, quote_amount)
async fn get_liquidities_from_state<'a>(
    addr_to_gr: &HashMap<String, i32>,
    market_id_to_gr: &HashMap<BigDecimal, i32>,
    transaction: &Arc<RwLock<Transaction<'a, Postgres>>>,
    state: &SpreadsState,
    last_prices: &mut HashMap<BigDecimal, Option<BigDecimal>>,
) -> Result<HashMap<LiquidityKey, LiquidityValue>, PipelineError> {
    let mut liquidities: HashMap<LiquidityKey, LiquidityValue> = Default::default();

    let orders = &state.orders;

    if orders.is_empty() {
        return Ok(liquidities);
    }

    for bps_times_ten in BPSS_TIMES_TEN {
        for order in orders.values() {
            let price = if let Some(price) = get_cached_last_price(
                &order.market_id,
                &state.last_txn_indexed,
                transaction,
                last_prices,
            )
            .await?
            {
                price
            } else {
                continue;
            };
            let delta = &price * &BigDecimal::from(bps_times_ten) / BPS_TIMES_TEN_DIVISOR;
            if bps_times_ten == 0 || (order.price > &price - &delta && order.price < &price + &delta) {
                if let Some(group_id) = market_id_to_gr.get(&order.market_id) {
                    add_to_map(&mut liquidities, &order, *group_id, bps_times_ten, &price)?;
                }
                if let Some(group_id) = &order
                    .user
                    .clone()
                    .map(|addr| addr_to_gr.get(&addr))
                    .flatten()
                {
                    add_to_map(&mut liquidities, &order, **group_id, bps_times_ten, &price)?;
                }
            }
        }
    }

    Ok(liquidities)
}

fn add_to_map<'a>(
    map: &mut HashMap<LiquidityKey, LiquidityValue>,
    order: &Order,
    group_id: i32,
    bps_times_ten: i32,
    price: &BigDecimal,
) -> Result<(), PipelineError> {
    if order.side == ASK {
        map.entry(LiquidityKey { group_id, bps_times_ten: bps_times_ten })
            .and_modify(|e| e.base += &order.size * &order.price)
            .or_insert(LiquidityValue {
                base: &order.size * price,
                quote: BigDecimal::zero(),
            });
    } else {
        map.entry(LiquidityKey { group_id, bps_times_ten: bps_times_ten })
            .and_modify(|e| e.quote += &order.size * price)
            .or_insert(LiquidityValue {
                base: BigDecimal::zero(),
                quote: &order.size * &order.price,
            });
    }
    Ok(())
}

async fn get_cached_last_price<'a>(
    market_id: &BigDecimal,
    txn_version: &BigDecimal,
    transaction: &Arc<RwLock<Transaction<'a, Postgres>>>,
    last_prices: &mut HashMap<BigDecimal, Option<BigDecimal>>,
) -> Result<Option<BigDecimal>, PipelineError> {
    if let Some(price) = last_prices.get(market_id) {
        Ok(price.clone())
    } else {
        let price = {
            let mut tx = transaction.write().await;
            let price = sqlx::query_file!(
                "sqlx_queries/order_history_pipelines/get_price.sql",
                market_id,
                txn_version
            )
            .fetch_optional(&mut tx as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
            price
        };

        if let Some(price) = price {
            last_prices.insert(market_id.clone(), Some(price.price.clone()));
            Ok(Some(price.price))
        } else {
            last_prices.insert(market_id.clone(), None);
            Ok(None)
        }
    }
}

fn generate_timestamps(start: DateTime<Utc>, end: DateTime<Utc>) -> Vec<DateTime<Utc>> {
    let intervals = (end - start).num_minutes() as usize;
    let mut timestamps = Vec::with_capacity(intervals);
    for i in 0..intervals {
        timestamps.push(start + chrono::Duration::minutes(i as i64 + 1));
    }
    timestamps
}

#[async_trait::async_trait]
impl Pipeline for OrderHistoryPipelines {
    fn model_name(&self) -> String {
        String::from("OrderHistoryPipelines")
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::from_std(TIMEOUT).unwrap()
                < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        let last_indexed_timestamp = sqlx::query_file!(
            "sqlx_queries/order_history_pipelines/get_last_indexed_timestamp.sql"
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(to_pipeline_error)?;

        if last_indexed_timestamp.is_none() {
            sqlx::query_file!(
                "sqlx_queries/order_history_pipelines/init_last_indexed_timestamp.sql"
            )
            .execute(&self.pool)
            .await
            .map_err(to_pipeline_error)?;
        }
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(TIMEOUT)
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let mut transaction = create_repeatable_read_transaction(&self.pool).await?;
        let address_to_group =
            sqlx::query_file!("sqlx_queries/order_history_pipelines/get_liquidity_groups.sql")
                .fetch_all(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?
                .into_iter()
                .map(|e| (e.address, e.group_id));
        let address_to_group = HashMap::from_iter(address_to_group);

        sqlx::query_file!("sqlx_queries/order_history_pipelines/insert_new_liquidity_groups.sql")
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        let market_id_to_group =
            sqlx::query_file!("sqlx_queries/order_history_pipelines/get_liquidity_group_all.sql")
                .fetch_all(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?
                .into_iter()
                .map(|e| (e.market_id, e.group_id));
        let market_id_to_group = HashMap::from_iter(market_id_to_group);

        let last_indexed_timestamp = sqlx::query_file!(
            "sqlx_queries/order_history_pipelines/get_last_indexed_timestamp.sql"
        )
        .fetch_optional(&mut transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?
        .map(|e| e.time);
        // This can happen if no limit orders have been posted yet.
        let last_indexed_timestamp = if let Some(last_indexed_timestamp) = last_indexed_timestamp {
            last_indexed_timestamp
        } else {
            return Ok(());
        };

        let latest_event_timestamp = sqlx::query_file!(
            "sqlx_queries/order_history_pipelines/get_latest_event_timestamp.sql"
        )
        .fetch_one(&mut transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?
        .time;
        let latest_event_timestamp = if let Some(latest_event_timestamp) = latest_event_timestamp {
            latest_event_timestamp
        } else {
            return Ok(());
        };

        let timestamps = generate_timestamps(last_indexed_timestamp, latest_event_timestamp);

        for timestamp in &timestamps {
            self.get_state_from_timestamp_with_state(timestamp, &mut transaction)
                .await?;
            if let Some(state) = &self.state {
                transaction = calculate_spreads_and_liquidities(
                    &address_to_group,
                    &market_id_to_group,
                    &mut self.last_prices,
                    state,
                    timestamp,
                    transaction,
                )
                .await?;
            }
        }
        {
            if let Some(last) = timestamps.last() {
                sqlx::query_file!(
                    "sqlx_queries/order_history_pipelines/update_last_indexed_timestamp.sql",
                    last,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
            }
        }
        transaction.commit().await.map_err(to_pipeline_error)?;
        Ok(())
    }
}

async fn calculate_spreads_and_liquidities(
    address_to_group: &HashMap<String, i32>,
    market_id_to_group: &HashMap<BigDecimal, i32>,
    last_prices: &mut HashMap<BigDecimal, Option<BigDecimal>>,
    state: &SpreadsState,
    timestamp: &DateTime<Utc>,
    transaction: Transaction<'static, Postgres>,
) -> Result<Transaction<'static, Postgres>, PipelineError> {
    let tx = Arc::new(RwLock::new(transaction));
    let (res1, res2) = tokio::join! {
        liquidities(&address_to_group, &market_id_to_group, last_prices, state, timestamp, tx.clone()),
        spreads(state, timestamp, tx.clone())
    };
    res1?;
    res2?;
    Ok(Arc::into_inner(tx).unwrap().into_inner())
}

async fn spreads<'a>(
    state: &SpreadsState,
    timestamp: &DateTime<Utc>,
    transaction: Arc<RwLock<Transaction<'a, Postgres>>>,
) -> Result<(), PipelineError> {
    let (min_asks, max_bids) = get_spreads_from_state(state);
    let mut markets = min_asks.keys().chain(max_bids.keys()).collect::<Vec<_>>();
    markets.sort();
    markets.dedup();
    for market in markets {
        let mut tx = transaction.write().await;
        sqlx::query_file!(
            "sqlx_queries/order_history_pipelines/insert_spread.sql",
            market,
            timestamp,
            min_asks.get(market),
            max_bids.get(market),
        )
        .execute(&mut tx as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?;
    }
    Ok(())
}

async fn liquidities<'a>(
    address_to_group: &HashMap<String, i32>,
    market_id_to_group: &HashMap<BigDecimal, i32>,
    last_prices: &mut HashMap<BigDecimal, Option<BigDecimal>>,
    state: &SpreadsState,
    timestamp: &DateTime<Utc>,
    transaction: Arc<RwLock<Transaction<'a, Postgres>>>,
) -> Result<(), PipelineError> {
    let liquidities = get_liquidities_from_state(
        address_to_group,
        market_id_to_group,
        &transaction,
        state,
        last_prices,
    )
    .await?;
    for (key, value) in liquidities {
        let mut tx = transaction.write().await;
        sqlx::query_file!(
            "sqlx_queries/order_history_pipelines/insert_liquidity.sql",
            key.group_id,
            key.bps_times_ten,
            timestamp,
            value.base,
            value.quote,
        )
        .execute(&mut tx as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?;
    }
    Ok(())
}
