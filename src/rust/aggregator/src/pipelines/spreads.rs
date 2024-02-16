use std::collections::HashMap;

use anyhow::bail;
use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Transaction};

use aggregator::{util::*, Pipeline, PipelineAggregationResult, PipelineError};
use sqlx_postgres::Postgres;

use crate::MAX_BATCH_SIZE;

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(1);

const ASK: bool = true;

pub struct Spreads {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
    state: Option<SpreadsState>,
}

impl Spreads {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
            state: None,
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

#[derive(Clone)]
struct Order {
    market_id: BigDecimal,
    order_id: BigDecimal,
    size: BigDecimal,
    side: bool,
    price: BigDecimal,
}

struct Fill {
    market_id: BigDecimal,
    maker_order_id: BigDecimal,
    taker_order_id: BigDecimal,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    size: BigDecimal,
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

impl Spreads {
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
                "sqlx_queries/spreads/get_max_txn_version_before_timestamp.sql",
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
                (txn_version_of_state.clone() + BigDecimal::from(MAX_BATCH_SIZE)).min(txn_version);

            // Get all place events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let places = sqlx::query_file_as!(
                Order,
                "sqlx_queries/spreads/get_place_limit_order_events_between_txn_versions.sql",
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
                "sqlx_queries/spreads/get_fill_events_between_txn_versions.sql",
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
                "sqlx_queries/spreads/get_change_order_size_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

            // Get all cancel events that happened between the last transaction included in the previous
            // state and the last transaction that happened before the given timestamp.
            let cancels = sqlx::query_file!(
                "sqlx_queries/spreads/get_cancel_order_events_between_txn_versions.sql",
                *txn_version_of_state,
                txn_version
            )
            .fetch_all(transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;

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
    fn get_spreads_from_state<'a>(
        &self,
    ) -> anyhow::Result<(
        HashMap<BigDecimal, BigDecimal>,
        HashMap<BigDecimal, BigDecimal>,
    )> {
        let mut min_asks: HashMap<BigDecimal, BigDecimal> = Default::default();
        let mut max_bids: HashMap<BigDecimal, BigDecimal> = Default::default();

        if let Some(state) = &self.state {
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

            Ok((min_asks, max_bids))
        } else {
            bail!("State is not yet computed.")
        }
    }
}
#[async_trait::async_trait]
impl Pipeline for Spreads {
    fn model_name(&self) -> String {
        String::from("Spreads")
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::from_std(TIMEOUT).unwrap()
                < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(TIMEOUT)
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let mut transaction = create_repeatable_read_transaction(&self.pool).await?;
        let last_indexed_timestamp =
            sqlx::query_file!("sqlx_queries/spreads/get_last_indexed_timestamp.sql")
                .fetch_optional(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
        if last_indexed_timestamp.is_none() {
            sqlx::query_file!("sqlx_queries/spreads/init_last_indexed_timestamp.sql")
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
        }
        let last_indexed_timestamp =
            sqlx::query_file!("sqlx_queries/spreads/get_last_indexed_timestamp.sql")
                .fetch_optional(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
        if last_indexed_timestamp.is_none() {
            return Ok(());
        }
        let last_indexed_timestamp = last_indexed_timestamp.unwrap().time;
        let latest_event_timestamp =
            sqlx::query_file!("sqlx_queries/spreads/get_latest_event_timestamp.sql")
                .fetch_one(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?
                .time;
        let latest_event_timestamp = if let Some(e) = latest_event_timestamp {
            e
        } else {
            return Ok(());
        };
        let intervals = (latest_event_timestamp - last_indexed_timestamp).num_minutes() as usize;
        let mut timestamps = Vec::with_capacity(intervals);
        for i in 0..intervals {
            timestamps.push(last_indexed_timestamp + chrono::Duration::minutes(i as i64 + 1));
        }
        if timestamps.len() == 0 {
            return Ok(());
        }
        for timestamp in &timestamps {
            self.get_state_from_timestamp_with_state(timestamp, &mut transaction)
                .await?;
            let (min_asks, max_bids) = self
                .get_spreads_from_state()
                .map_err(|e| PipelineError::ProcessingError(e))?;
            let mut markets = min_asks.keys().chain(max_bids.keys()).collect::<Vec<_>>();
            markets.sort();
            markets.dedup();
            for market in markets {
                sqlx::query_file!(
                    "sqlx_queries/spreads/insert_spread.sql",
                    market,
                    timestamp,
                    min_asks.get(market),
                    max_bids.get(market),
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
            }
        }
        if let Some(last) = timestamps.last() {
            sqlx::query_file!(
                "sqlx_queries/spreads/update_last_indexed_timestamp.sql",
                last,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        }
        commit_transaction(transaction).await?;
        Ok(())
    }
}
