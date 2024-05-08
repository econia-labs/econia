use std::{collections::BTreeMap, sync::Arc, time::Duration};

use crate::{numeric::*, Direction, Event};

mod liquidity;
mod spread;
mod state;
mod volume;

use chrono::{DateTime, DurationRound, Utc};
use spread::Spread;
use sqlx::{Executor, Transaction};
use sqlx_postgres::{PgPool, PgPoolOptions, Postgres};
use state::ContractState;
use tokio::{sync::RwLock, try_join};
use tracing::instrument;

use self::{liquidity::Liquidity, volume::Volume};

const INTERVAL: chrono::Duration = chrono::Duration::seconds(1);

pub trait FeedFromEventsAndPrevState {
    async fn get_prev_state(pool: &PgPool) -> Self;
    fn update<'a>(&mut self, events: impl Iterator<Item = &'a Event>);
}

pub trait FeedFromEvents {
    fn new() -> Self;
    fn update(&mut self, events: &Vec<Event>);
}

pub trait FeedFromFeed<T> {
    fn from_feed(data: &T) -> Self;
}

pub trait InsertableFeed {
    async fn save<'a>(&self, timestamp: DateTime<Utc>, transaction: &mut Transaction<'a, Postgres>);
}

pub async fn get_next_start_timestamp(
    last_start_timestamp: &DateTime<Utc>,
    event_cache: &Arc<RwLock<BTreeMap<DateTime<Utc>, Event>>>,
) -> Option<DateTime<Utc>> {
    event_cache
        .read()
        .await
        .range(*last_start_timestamp + INTERVAL..)
        .next()
        .map(|e| e.0.duration_trunc(INTERVAL).unwrap())
}

pub async fn fill_cache(
    amount_of_events: i64,
    pool: &PgPool,
    event_cache: &Arc<RwLock<BTreeMap<DateTime<Utc>, Event>>>,
) {
    tracing::trace!("Adding {} events to cache.", amount_of_events);
    let start_timestamp = {
        event_cache
            .read()
            .await
            .last_key_value()
            .map(|e| e.0.clone())
            .unwrap_or(DateTime::UNIX_EPOCH)
    };
    let mut new_event_cache = BTreeMap::new();
    let limit = sqlx::query!(
        r#"SELECT "time" FROM aggv2.events WHERE "time" > $1 ORDER BY "time" offset $2 limit 1"#,
        start_timestamp,
        amount_of_events - 1
    )
    .fetch_optional(pool)
    .await
    .unwrap()
    .map(|e| e.time);
    let limit = if let Some(limit) = limit {
        limit
    } else {
        return;
    };
    let place_limit = sqlx::query!(
        r#"SELECT * FROM place_limit_order_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let place_market = sqlx::query!(
        r#"SELECT * FROM place_market_order_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let place_swap = sqlx::query!(
        r#"SELECT * FROM place_swap_order_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let cancels = sqlx::query!(
        r#"SELECT * FROM cancel_order_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let changes = sqlx::query!(
        r#"SELECT * FROM change_order_size_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let fills = sqlx::query!(
        r#"SELECT * FROM fill_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let market_registrations = sqlx::query!(
        r#"SELECT * FROM market_registration_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let balance_update_by_handle = sqlx::query!(
        r#"SELECT * FROM balance_updates_by_handle WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let recognized_markets = sqlx::query!(
        r#"SELECT * FROM recognized_market_events WHERE "time" > $1 AND "time" <= $2"#,
        start_timestamp,
        limit,
    )
    .fetch_all(pool);
    let (
        place_limit,
        place_market,
        place_swap,
        cancels,
        changes,
        fills,
        market_registrations,
        balance_update_by_handle,
        recognized_markets,
    ) = try_join!(
        place_limit,
        place_market,
        place_swap,
        cancels,
        changes,
        fills,
        market_registrations,
        balance_update_by_handle,
        recognized_markets
    )
    .unwrap();

    let place_limit = place_limit.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::PlaceLimitOrder {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                user: r.user,
                custodian_id: r.custodian_id,
                order_id: OrderId::new(r.order_id),
                side: if r.side {
                    Direction::Ask
                } else {
                    Direction::Bid
                },
                integrator: r.integrator,
                initial_size: Lot::new(r.initial_size),
                price: Price::new(r.price),
                restriction: r.restriction,
                self_match_behavior: r.self_match_behavior,
                size: Lot::new(r.size),
            },
        )
    });
    new_event_cache.extend(place_limit);
    let place_market = place_market.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::PlaceMarketOrder {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                user: r.user,
                custodian_id: r.custodian_id,
                order_id: OrderId::new(r.order_id),
                integrator: r.integrator,
                self_match_behavior: r.self_match_behavior,
                size: Lot::new(r.size),
                direction: if r.direction {
                    Direction::Ask
                } else {
                    Direction::Bid
                },
            },
        )
    });
    new_event_cache.extend(place_market);
    let place_swap = place_swap.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::PlaceSwapOrder {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                order_id: OrderId::new(r.order_id),
                integrator: r.integrator,
                direction: if r.direction {
                    Direction::Ask
                } else {
                    Direction::Bid
                },
                signing_account: r.signing_account,
                min_base: r.min_base,
                max_base: r.max_base,
                min_quote: r.min_quote,
                max_quote: r.max_quote,
                limit_price: Price::new(r.limit_price),
            },
        )
    });
    new_event_cache.extend(place_swap);
    let cancels = cancels.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::Cancel {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                user: r.user,
                custodian_id: r.custodian_id,
                order_id: OrderId::new(r.order_id),
                reason: r.reason,
            },
        )
    });
    new_event_cache.extend(cancels);
    let changes = changes.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::ChangeSize {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                user: r.user,
                custodian_id: r.custodian_id,
                order_id: OrderId::new(r.order_id),
                side: if r.side {
                    Direction::Ask
                } else {
                    Direction::Bid
                },
                new_size: Lot::new(r.new_size),
            },
        )
    });
    new_event_cache.extend(changes);
    let fills = fills.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::Fill {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                emit_address: r.emit_address,
                maker_address: r.maker_address,
                maker_custodian_id: r.maker_custodian_id,
                maker_order_id: OrderId::new(r.maker_order_id),
                maker_side: if r.maker_side {
                    Direction::Ask
                } else {
                    Direction::Bid
                },
                price: Price::new(r.price),
                sequence_number_for_trade: r.sequence_number_for_trade,
                size: Lot::new(r.size),
                taker_address: r.taker_address,
                taker_custodian_id: r.taker_custodian_id,
                taker_order_id: OrderId::new(r.taker_order_id),
                taker_quote_fees_paid: r.taker_quote_fees_paid,
            },
        )
    });
    new_event_cache.extend(fills);
    let market_registrations = market_registrations.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::MarketRegistration {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                base_account_address: r.base_account_address,
                base_module_name: r.base_module_name,
                base_struct_name: r.base_struct_name,
                base_name_generic: r.base_name_generic,
                quote_account_address: r.quote_account_address,
                quote_module_name: r.quote_module_name,
                quote_struct_name: r.quote_struct_name,
                lot_size: r.lot_size,
                tick_size: r.tick_size,
                min_size: Lot::new(r.min_size),
                underwriter_id: r.underwriter_id,
            },
        )
    });
    new_event_cache.extend(market_registrations);
    let balance_update_by_handle = balance_update_by_handle.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::BalanceUpdatesByHandle {
                txn_version: TransactionVersion::new(r.txn_version),
                time: r.time,
                market_id: MarketId::new(r.market_id),
                custodian_id: r.custodian_id,
                base_total: BaseSubunit::new(r.base_total),
                base_available: BaseSubunit::new(r.base_available),
                base_ceiling: BaseSubunit::new(r.base_ceiling),
                quote_total: QuoteSubunit::new(r.quote_total),
                quote_available: QuoteSubunit::new(r.quote_available),
                quote_ceiling: QuoteSubunit::new(r.quote_ceiling),
            },
        )
    });
    new_event_cache.extend(balance_update_by_handle);
    let recognized_markets = recognized_markets.into_iter().map(|r| {
        (
            r.time.clone(),
            Event::MarketRegistration {
                txn_version: TransactionVersion::new(r.txn_version),
                event_idx: EventIndex::new(r.event_idx),
                time: r.time,
                market_id: MarketId::new(r.market_id.unwrap()),
                base_account_address: r.base_account_address,
                base_module_name: r.base_module_name,
                base_struct_name: r.base_struct_name,
                base_name_generic: r.base_name_generic,
                quote_account_address: r.quote_account_address,
                quote_module_name: r.quote_module_name,
                quote_struct_name: r.quote_struct_name,
                lot_size: r.lot_size.unwrap(),
                tick_size: r.tick_size.unwrap(),
                min_size: Lot::new(r.min_size.unwrap()),
                underwriter_id: r.underwriter_id.unwrap(),
            },
        )
    });
    new_event_cache.extend(recognized_markets);
    let mut event_cache = event_cache.write().await;
    event_cache.append(&mut new_event_cache);
}

pub async fn get_event_batch<'a>(
    start_timestamp: &DateTime<Utc>,
    event_cache: &'a Arc<RwLock<BTreeMap<DateTime<Utc>, Event>>>,
) -> BTreeMap<DateTime<Utc>, Event> {
    tracing::trace!("Getting event batch.");
    loop {
        let last_value = {
            event_cache
                .read()
                .await
                .last_key_value()
                .map(|e| (e.0.clone(), e.1.clone()))
        };
        match last_value {
            Some((datetime, _)) if datetime >= *start_timestamp + INTERVAL => {
                break;
            }
            _ => {
                tokio::time::sleep(Duration::from_millis(100)).await;
            }
        }
    }
    let mut ecw = event_cache.write().await;
    let mut end = ecw.split_off(&(*start_timestamp + INTERVAL));
    std::mem::swap(&mut *ecw, &mut end);
    end
}

struct Cache {
    state_insert_cache: Box<Option<ContractState>>,
    spread_insert_cache: Box<Vec<(DateTime<Utc>, Spread)>>,
    volume_insert_cache: Box<Vec<(DateTime<Utc>, Volume)>>,
    liquidity_insert_cache: Box<Vec<(DateTime<Utc>, Liquidity)>>,
}

struct AggregatorState {
    current_timestamp: DateTime<Utc>,
    events: usize,
    cached_events: usize,
}

#[instrument]
pub async fn run() -> anyhow::Result<()> {
    tracing::info!("Starting.");
    let pool = PgPoolOptions::new()
        .after_connect(|conn, _| {
            Box::pin(async move {
                conn.execute("SET default_transaction_isolation TO 'repeatable read'")
                    .await?;
                Ok(())
            })
        })
        .connect(&std::env::var("DATABASE_URL").unwrap())
        .await
        .unwrap();

    tracing::info!("Connected to database.");

    // Init feeds with state
    tracing::info!("Loading feeds.");
    let mut state = ContractState::get_prev_state(&pool).await;
    let volume = Volume::get_prev_state(&pool).await;
    tracing::info!("Done loading feeds.");

    state.update_timestamp(state.timestamp + INTERVAL);

    tracing::info!(
        from_timestamp = state.timestamp.to_string(),
        "Start aggregating."
    );

    let cache = Arc::new(RwLock::new(Cache {
        state_insert_cache: Default::default(),
        spread_insert_cache: Default::default(),
        volume_insert_cache: Default::default(),
        liquidity_insert_cache: Default::default(),
    }));

    let event_cache = Arc::new(RwLock::new(BTreeMap::new()));
    let agg_state = Arc::new(RwLock::new(AggregatorState {
        current_timestamp: state.timestamp.clone(),
        events: 0,
        cached_events: 0,
    }));

    let agg_loop = tokio::spawn(aggregator(
        state,
        volume,
        cache.clone(),
        event_cache.clone(),
        agg_state.clone(),
    ));
    let insert_loop = tokio::spawn(inserter(pool.clone(), cache.clone()));
    let cache_manager = tokio::spawn(cache_manager(
        pool.clone(),
        event_cache.clone(),
        agg_state.clone(),
    ));
    let logger = tokio::spawn(logger(agg_state));

    let (res_agg, res_ins, res_cache_manager, res_logger) =
        tokio::try_join!(agg_loop, insert_loop, cache_manager, logger)?;

    res_agg?;
    res_ins?;
    res_cache_manager?;
    res_logger?;

    Ok(())
}

async fn logger(agg_state: Arc<RwLock<AggregatorState>>) -> anyhow::Result<()> {
    loop {
        tokio::time::sleep(Duration::from_secs(1)).await;
        let mut state = agg_state.write().await;
        tracing::info!(
            tps = state.events,
            timestamp = state.current_timestamp.to_string(),
            cached_events = state.cached_events,
        );
        state.events = 0;
    }
}

#[instrument(skip(pool, event_cache, agg_state))]
async fn cache_manager(
    pool: PgPool,
    event_cache: Arc<RwLock<BTreeMap<DateTime<Utc>, Event>>>,
    agg_state: Arc<RwLock<AggregatorState>>,
) -> anyhow::Result<()> {
    loop {
        tokio::time::sleep(Duration::from_millis(50)).await;
        let remaining_events = event_cache.read().await.len();
        agg_state.write().await.cached_events = remaining_events;
        if remaining_events < 500_000 {
            fill_cache(100_000, &pool, &event_cache).await;
        }
    }
}

#[instrument(skip(pool, cache))]
async fn inserter(pool: PgPool, cache: Arc<RwLock<Cache>>) -> anyhow::Result<()> {
    let mut last_insert = Utc::now();
    loop {
        if microseconds_elapsed(last_insert) > 50_000 {
            let mut cache_write = cache.write().await;
            if cache_write.volume_insert_cache.is_empty()
                && cache_write.spread_insert_cache.is_empty()
                && cache_write.liquidity_insert_cache.is_empty()
                && cache_write.state_insert_cache.is_none()
            {
                continue;
            }
            tracing::trace!(
                "Inserting {} cached data.",
                cache_write.volume_insert_cache.len()
                    + cache_write.spread_insert_cache.len()
                    + cache_write.liquidity_insert_cache.len()
                    + if cache_write.state_insert_cache.is_some() {
                        1
                    } else {
                        0
                    }
            );
            let volumes = {
                let w = &mut cache_write.volume_insert_cache;
                let mut empty = Box::new(vec![]);
                if !w.is_empty() {
                    std::mem::swap(w, &mut empty);
                }
                empty
            };
            let spreads = {
                let w = &mut cache_write.spread_insert_cache;
                let mut empty = Box::new(vec![]);
                if !w.is_empty() {
                    std::mem::swap(w, &mut empty);
                }
                empty
            };
            let liquidities = {
                let w = &mut cache_write.liquidity_insert_cache;
                let mut empty = Box::new(vec![]);
                if !w.is_empty() {
                    std::mem::swap(w, &mut empty);
                }
                empty
            };
            let state = {
                let sicw = &mut cache_write.state_insert_cache;
                let state = (*sicw).clone();
                state
            };
            drop(cache_write);
            last_insert = Utc::now();
            let mut transaction = pool.begin().await?;
            for (timestamp, volume) in volumes.iter() {
                volume.save(*timestamp, &mut transaction).await;
            }
            for (timestamp, spreads) in spreads.iter() {
                spreads.save(*timestamp, &mut transaction).await;
            }
            for (timestamp, liquidity) in liquidities.iter() {
                liquidity.save(*timestamp, &mut transaction).await;
            }
            if let Some(state) = *state {
                state.save(state.timestamp, &mut transaction).await;
            }
            transaction.commit().await?;
        }
        tokio::time::sleep(Duration::from_millis(10)).await;
    }
}

fn microseconds_elapsed(time: DateTime<Utc>) -> i64 {
    Utc::now()
        .signed_duration_since(time)
        .num_microseconds()
        .unwrap()
}

#[instrument(skip(state, volume, cache, event_cache, agg_state))]
async fn aggregator(
    mut state: ContractState,
    mut volume: Volume,
    cache: Arc<RwLock<Cache>>,
    event_cache: Arc<RwLock<BTreeMap<DateTime<Utc>, Event>>>,
    agg_state: Arc<RwLock<AggregatorState>>,
) -> anyhow::Result<()> {
    loop {
        loop {
            if let Some(new_start_timestamp) =
                get_next_start_timestamp(&state.timestamp, &event_cache).await
            {
                state.update_timestamp(new_start_timestamp);
                {
                    agg_state.write().await.current_timestamp = new_start_timestamp;
                }
                break;
            }
            tokio::time::sleep(Duration::from_millis(50)).await;
        }

        tracing::debug!(
            start_timestamp = state.timestamp.to_string(),
            "Running aggregator loop."
        );

        let time_total = Utc::now();

        // Get events
        tracing::trace!("Getting events.");
        let time = Utc::now();
        let events = get_event_batch(&state.timestamp, &event_cache).await;
        {
            agg_state.write().await.events += events.len();
        }
        tracing::trace!(
            "Got {} events in {} microseconds.",
            events.len(),
            microseconds_elapsed(time)
        );

        // Run first layer
        tracing::trace!("Start first layer.");
        let time = Utc::now();

        let events = events.iter().map(|e| e.1);

        state.update(events.clone());
        volume.update(events.clone());

        tracing::trace!(
            "Done first layer in {} microseconds.",
            microseconds_elapsed(time)
        );

        // Run second layer
        tracing::trace!("Start second layer.");
        let time = Utc::now();

        let spreads = Spread::from_feed(&state);
        let liquidity = Liquidity::from_feed(&state);

        tracing::trace!(
            "Done second layer in {} microseconds.",
            microseconds_elapsed(time)
        );

        let state2 = state.clone();
        let volume2 = volume.clone();

        let mut cache_write = cache.write().await;

        cache_write
            .spread_insert_cache
            .push((state2.timestamp.clone(), spreads));
        cache_write
            .volume_insert_cache
            .push((state2.timestamp.clone(), volume2));
        cache_write
            .liquidity_insert_cache
            .push((state2.timestamp.clone(), liquidity));
        cache_write.state_insert_cache = Box::new(Some(state2));

        tracing::trace!(
            "Ran aggregator loop in {} microseconds.",
            microseconds_elapsed(time_total)
        );
    }
}
