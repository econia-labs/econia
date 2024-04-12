use std::{time::Duration, sync::Arc};

use crate::{BlockchainTimestamp, Event, numeric::*, Direction};

mod liquidity;
mod spread;
mod state;
mod volume;

use chrono::{DateTime, Utc};
use spread::Spread;
use sqlx::{Executor, Transaction};
use sqlx_postgres::{PgPool, PgPoolOptions, PgConnection, Postgres};
use state::ContractState;
use tracing::{span, Level, instrument, Instrument};

use self::{liquidity::Liquidity, volume::Volume};

const INTERVAL: std::time::Duration = std::time::Duration::from_secs(1);

pub trait FeedFromEventsAndPrevState {
    async fn get_prev_state(pool: &PgPool) -> Self;
    fn update(&mut self, events: &Vec<Event>);
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

pub async fn get_max_timestamp<'a>(transaction: &mut Transaction<'a, Postgres>) -> Option<DateTime<Utc>> {
    let max_limit =
        sqlx::query!(r#"SELECT "time" FROM place_limit_order_events ORDER BY "time" DESC LIMIT 1"#)
            .fetch_optional(transaction as &mut PgConnection)
            .await
            .unwrap()
            .map(|o| o.time);
    let max_market = sqlx::query!(
        r#"SELECT "time" FROM place_market_order_events ORDER BY "time" DESC LIMIT 1"#
    )
    .fetch_optional(transaction as &mut PgConnection)
    .await
    .unwrap()
    .map(|o| o.time);
    let max_swap = sqlx::query!(
        r#"SELECT "time" FROM place_market_order_events ORDER BY "time" DESC LIMIT 1"#
    )
    .fetch_optional(transaction as &mut PgConnection)
    .await
    .unwrap()
    .map(|o| o.time);
    let max_fill = sqlx::query!(
        r#"SELECT "time" FROM place_market_order_events ORDER BY "time" DESC LIMIT 1"#
    )
    .fetch_optional(transaction as &mut PgConnection)
    .await
    .unwrap()
    .map(|o| o.time);
    let max_market_reg = sqlx::query!(
        r#"SELECT "time" FROM place_market_order_events ORDER BY "time" DESC LIMIT 1"#
    )
    .fetch_optional(transaction as &mut PgConnection)
    .await
    .unwrap()
    .map(|o| o.time);
    max_limit
        .max(max_market)
        .max(max_swap)
        .max(max_fill)
        .max(max_market_reg)
}

pub async fn get_event_batch<'a>(
    start_blockchain_timestamp: &BlockchainTimestamp,
    max_timestamp: &DateTime<Utc>,
    _amount_of_events: i64,
    transaction: &mut Transaction<'a, Postgres>,
) -> Vec<Event> {
    let mut events: Vec<Event> = vec![];
    let place_limit = sqlx::query!(
        r#"SELECT * FROM place_limit_order_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::PlaceLimitOrder {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        user: r.user,
        custodian_id: r.custodian_id,
        order_id: OrderId::new(r.order_id),
        side: if r.side {Direction::Ask} else {Direction::Bid},
        integrator: r.integrator,
        initial_size: Lot::new(r.initial_size),
        price: Price::new(r.price),
        restriction: r.restriction,
        self_match_behavior: r.self_match_behavior,
        size: Lot::new(r.size),
    });
    events.extend(place_limit);
    let place_market = sqlx::query!(
        r#"SELECT * FROM place_market_order_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::PlaceMarketOrder {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        user: r.user,
        custodian_id: r.custodian_id,
        order_id: OrderId::new(r.order_id),
        integrator: r.integrator,
        self_match_behavior: r.self_match_behavior,
        size: Lot::new(r.size),
        direction: if r.direction {Direction::Ask} else {Direction::Bid},
    });
    events.extend(place_market);
    let place_swap = sqlx::query!(
        r#"SELECT * FROM place_swap_order_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::PlaceSwapOrder {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        order_id: OrderId::new(r.order_id),
        integrator: r.integrator,
        direction: if r.direction {Direction::Ask} else {Direction::Bid},
        signing_account: r.signing_account,
        min_base: r.min_base,
        max_base: r.max_base,
        min_quote: r.min_quote,
        max_quote: r.max_quote,
        limit_price: Price::new(r.limit_price),
    });
    events.extend(place_swap);
    let cancels = sqlx::query!(
        r#"SELECT * FROM cancel_order_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::Cancel {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        user: r.user,
        custodian_id: r.custodian_id,
        order_id: OrderId::new(r.order_id),
        reason: r.reason,
    });
    events.extend(cancels);
    let changes = sqlx::query!(
        r#"SELECT * FROM change_order_size_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::ChangeSize {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        user: r.user,
        custodian_id: r.custodian_id,
        order_id: OrderId::new(r.order_id),
        side: if r.side {Direction::Ask} else {Direction::Bid},
        new_size: Lot::new(r.new_size),
    });
    events.extend(changes);
    let fills = sqlx::query!(
        r#"SELECT * FROM fill_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::Fill {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        emit_address: r.emit_address,
        maker_address: r.maker_address,
        maker_custodian_id: r.maker_custodian_id,
        maker_order_id: OrderId::new(r.maker_order_id),
        maker_side: if r.maker_side {Direction::Ask} else {Direction::Bid},
        price: Price::new(r.price),
        sequence_number_for_trade: r.sequence_number_for_trade,
        size: Lot::new(r.size),
        taker_address: r.taker_address,
        taker_custodian_id: r.taker_custodian_id,
        taker_order_id: OrderId::new(r.taker_order_id),
        taker_quote_fees_paid: r.taker_quote_fees_paid,
    });
    events.extend(fills);
    let market_registrations = sqlx::query!(
        r#"SELECT * FROM market_registration_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::MarketRegistration {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
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
    });
    events.extend(market_registrations);
    let balance_update_by_handle = sqlx::query!(
        r#"SELECT * FROM balance_updates_by_handle WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::BalanceUpdatesByHandle {
        txn_version: TxnVersion::new(r.txn_version),
        time: r.time,
        market_id: MarketId::new(r.market_id),
        custodian_id: r.custodian_id,
        base_total: BaseSubunit::new(r.base_total),
        base_available: BaseSubunit::new(r.base_available),
        base_ceiling: BaseSubunit::new(r.base_ceiling),
        quote_total: QuoteSubunit::new(r.quote_total),
        quote_available: QuoteSubunit::new(r.quote_available),
        quote_ceiling: QuoteSubunit::new(r.quote_ceiling),
    });
    events.extend(balance_update_by_handle);
    let recognized_markets = sqlx::query!(
        r#"SELECT * FROM recognized_market_events WHERE txn_version >= $1 AND "time" < $2"#,
        start_blockchain_timestamp
            .get_transaction_version()
            .clone()
            .inner(),
        max_timestamp
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .unwrap()
    .into_iter()
    .map(|r| Event::MarketRegistration {
        txn_version: TxnVersion::new(r.txn_version),
        event_idx: EventId::new(r.event_idx),
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
    });
    events.extend(recognized_markets);
    events.sort_unstable_by_key(|e| e.blockchain_timestamp());
    events
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
    let mut volume = Volume::get_prev_state(&pool).await;
    tracing::info!("Done loading feeds.");

    let mut max_timestamp = state.timestamp + INTERVAL;
    let mut start_blockchain_timestamp =
        BlockchainTimestamp::from_transaction_version(state.transaction_version.clone());
    start_blockchain_timestamp.bump_version();

    tracing::info!(
        from_timestamp = state.timestamp.to_string(),
        form_blockchain_timestamp = start_blockchain_timestamp.to_string(),
        "Start aggregating."
    );

    loop {
        let timestamp_string = (max_timestamp - INTERVAL).to_string();
        let blockchain_timestamp_string = start_blockchain_timestamp.to_string();
        (state, volume) = aggregator_loop(&pool, state, volume, &mut max_timestamp, &mut start_blockchain_timestamp).await?;
    }
}

#[instrument(skip(pool, state, volume))]
async fn aggregator_loop(pool: &PgPool, mut state: ContractState, mut volume: Volume, max_timestamp: &mut DateTime<Utc>, start_blockchain_timestamp: &mut BlockchainTimestamp) -> anyhow::Result<(ContractState, Volume)> {
    tracing::trace!("Aggregator loop start.");

    // Intro
    let mut transaction = pool.begin().await?;
    let t = if let Some(t) = get_max_timestamp(&mut transaction).await {
        t
    } else {
        return Ok((state, volume));
    };
    if &t < max_timestamp {
        tracing::debug!(max_db_timestamp = t.to_string(), "Max timestamp in DB is lower than required to run an aggregator loop.");
        tokio::time::sleep(Duration::from_millis(100)).await;
        return Ok((state, volume));
    }

    // Get events
    tracing::trace!("Getting events between start blockchain timestamp and max timestamp.");
    let events =
        get_event_batch(&start_blockchain_timestamp, max_timestamp, 100_000, &mut transaction).await;
    tracing::debug!("Got {} events", events.len());
    if events.len() == 0 {
        state.save(state.timestamp, &mut transaction).await;
        transaction.commit().await?;
        state.update_timestamp(max_timestamp.clone());
        *max_timestamp += INTERVAL;
        return Ok((state, volume));
    }
    *start_blockchain_timestamp = events.last().unwrap().blockchain_timestamp();

    // Run first layer
    tracing::trace!("Start first layer.");
    let events = Arc::new(events);
    let events2 = events.clone();

    let state_handle = tokio::task::spawn_blocking(move || {
        let events2 = events2.clone();
        tracing::trace!("Start calculating.");
        state.update(&events2);
        tracing::trace!("Done calculating.");
        state
    }).instrument(span!(Level::TRACE, "state"));
    let events2 = events.clone();
    let volume_handle = tokio::task::spawn_blocking(move || {
        let events2 = events2.clone();
        tracing::trace!("Start calculating.");
        volume.update(&events2);
        tracing::trace!("Done calculating.");
        volume
    }).instrument(span!(Level::TRACE, "volume"));
    let (state_new, volume_new) = tokio::try_join!(state_handle, volume_handle)?;
    volume = volume_new;
    state = state_new;
    tracing::trace!("Done first layer.");

    // Run second layer
    tracing::trace!("Start second layer.");
    let arc_state = Arc::new(state);
    let arc_state2 = arc_state.clone();

    let spreads_handle = tokio::task::spawn_blocking(move || {
        tracing::trace!("Start calculating.");
        let spreads = Spread::from_feed(&arc_state2);
        tracing::trace!("Done calculating.");
        spreads
    }).instrument(span!(Level::TRACE, "spreads"));
    let arc_state2 = arc_state.clone();
    let liquidity_handle = tokio::task::spawn_blocking(move || {
        tracing::trace!("Start calculating.");
        let liquidity = Liquidity::from_feed(&arc_state2);
        tracing::trace!("Done calculating.");
        liquidity
    }).instrument(span!(Level::TRACE, "liquidity"));
    let (spreads, liquidity) = tokio::try_join!(spreads_handle, liquidity_handle)?;
    state = Arc::<ContractState>::into_inner(arc_state).unwrap();
    tracing::trace!("Done second layer.");

    // Save
    tracing::trace!("Start saving.");
    state.save(state.timestamp.clone(), &mut transaction).await;
    volume.save(state.timestamp.clone(), &mut transaction).await;
    spreads.save(state.timestamp.clone(), &mut transaction).await;
    liquidity.save(state.timestamp.clone(), &mut transaction).await;
    transaction.commit().await?;
    tracing::trace!("Done saving.");

    // Outro
    state.update_timestamp(max_timestamp.clone());
    *max_timestamp += INTERVAL;
    start_blockchain_timestamp.bump_version();

    Ok((state, volume))
}
