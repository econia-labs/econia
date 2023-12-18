use std::collections::HashMap;

use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Transaction};

use aggregator::{util::*, Pipeline, PipelineAggregationResult, PipelineError};
use sqlx_postgres::Postgres;

use crate::dbtypes::{OrderDirection, OrderType};

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(1);

pub struct OrderHistory {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
    state: Option<OrderHistoryState>,
}

impl OrderHistory {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
            state: None,
        }
    }
}

type OrderKey = (BigDecimal, BigDecimal);

#[derive(Clone)]
struct OrderHistoryState {
    orders: HashMap<OrderKey, Order>,
    last_txn_indexed: BigDecimal,
}

impl OrderHistoryState {
    pub fn new(last_txn: BigDecimal, orders: HashMap<OrderKey, Order>) -> Self {
        Self {
            last_txn_indexed: last_txn,
            orders,
        }
    }
}

impl Default for OrderHistoryState {
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
    user: String,
    size: BigDecimal,
    side: bool,
    price: BigDecimal,
}

impl OrderHistory {
    /// Given a previous state (and the last transaction version included in that state), computes
    /// the new state at the given timestamp.
    async fn get_state_from_timestamp_with_state<'a>(
        &self,
        mut orders: HashMap<OrderKey, Order>,
        txn_version_of_state: &BigDecimal,
        timestamp: &DateTime<Utc>,
        transaction: &mut Transaction<'a, Postgres>,
    ) -> Result<OrderHistoryState, PipelineError> {
        // Get the biggest transaction version that happened before the given timestamp.
        let txn_version = sqlx::query_file!(
            "sqlx_queries/order_history/get_max_txn_version_before_timestamp.sql",
            timestamp
        )
        .fetch_one(transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?
        .txn_version
        .unwrap_or(BigDecimal::zero());

        // Get all place events that happened between the last transaction included in the previous
        // state and the last transaction that happened before the given timestamp.
        let places = sqlx::query_file_as!(
            Order,
            "sqlx_queries/order_history/get_place_limit_order_events_between_txn_versions.sql",
            txn_version_of_state,
            txn_version,
        )
        .fetch_all(transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?;

        // Get all fill events that happened between the last transaction included in the previous
        // state and the last transaction that happened before the given timestamp.
        struct Fill {
            market_id: BigDecimal,
            maker_order_id: BigDecimal,
            taker_order_id: BigDecimal,
            txn_version: BigDecimal,
            event_idx: BigDecimal,
            size: BigDecimal,
        }
        let fills = sqlx::query_file_as!(
            Fill,
            "sqlx_queries/order_history/get_fill_events_between_txn_versions.sql",
            txn_version_of_state,
            txn_version
        )
        .fetch_all(transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?;

        // Get all change events that happened between the last transaction included in the previous
        // state and the last transaction that happened before the given timestamp.
        struct Change {
            market_id: BigDecimal,
            order_id: BigDecimal,
            txn_version: BigDecimal,
            event_idx: BigDecimal,
            new_size: BigDecimal,
        }
        let changes = sqlx::query_file_as!(
            Change,
            "sqlx_queries/order_history/get_change_order_size_events_between_txn_versions.sql",
            txn_version_of_state,
            txn_version
        )
        .fetch_all(transaction as &mut PgConnection)
        .await
        .map_err(to_pipeline_error)?;

        // Get all cancel events that happened between the last transaction included in the previous
        // state and the last transaction that happened before the given timestamp.
        let cancels = sqlx::query_file!(
            "sqlx_queries/order_history/get_cancel_order_events_between_txn_versions.sql",
            txn_version_of_state,
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
        let handle_fill =
            |fill: &Fill, orders: &mut HashMap<OrderKey, Order>, index: &mut usize| {
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
            };
        let handle_change =
            |change: &Change, orders: &mut HashMap<OrderKey, Order>, index: &mut usize| {
                *index += 1;
                let order_key = (change.market_id.clone(), change.order_id.clone());
                if let Some(order) = orders.get_mut(&order_key) {
                    order.size = change.new_size.clone();
                    if order.size.is_zero() {
                        orders.remove(&order_key);
                    }
                }
            };
        while fills_index < fills.len() && changes_index < changes.len() {
            let fill = fills.get(fills_index).unwrap();
            let fill_index = (fill.txn_version.clone(), fill.event_idx.clone());

            let change = changes.get(changes_index).unwrap();
            let change_index = (change.txn_version.clone(), change.event_idx.clone());

            if fill_index < change_index {
                handle_fill(fill, &mut orders, &mut fills_index);
            } else {
                handle_change(change, &mut orders, &mut changes_index);
            }
        }
        while fills_index < fills.len() {
            let fill = fills.get(fills_index).unwrap();
            handle_fill(fill, &mut orders, &mut fills_index);
        }
        while changes_index < changes.len() {
            let change = changes.get(changes_index).unwrap();
            handle_change(change, &mut orders, &mut changes_index);
        }
        Ok(OrderHistoryState::new(txn_version, orders))
    }
}

#[async_trait::async_trait]
impl Pipeline for OrderHistory {
    fn model_name(&self) -> String {
        String::from("OrderHistory")
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
            sqlx::query_file!("sqlx_queries/order_history/get_last_indexed_timestamp.sql")
                .fetch_optional(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
        if last_indexed_timestamp.is_none() {
            sqlx::query_file!("sqlx_queries/order_history/init_last_indexed_timestamp.sql")
                .execute(&self.pool)
                .await
                .map_err(to_pipeline_error)?;
        }
        let last_indexed_timestamp =
            sqlx::query_file!("sqlx_queries/order_history/get_last_indexed_timestamp.sql")
                .fetch_optional(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
        if last_indexed_timestamp.is_none() {
            return Ok(());
        }
        let last_indexed_timestamp = last_indexed_timestamp.unwrap().time;
        let latest_event_timestamp = sqlx::query_file!("sqlx_queries/order_history/get_latest_event_timestamp.sql")
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
        let mut state = self.state.clone().unwrap_or_default();
        for timestamp in &timestamps {
            state = if state.orders.is_empty() && state.last_txn_indexed == BigDecimal::zero() {
                self.get_state_from_timestamp_with_state(
                    state.orders,
                    &BigDecimal::zero(),
                    timestamp,
                    &mut transaction,
                )
                .await?
            } else {
                self.get_state_from_timestamp_with_state(
                    state.orders,
                    &state.last_txn_indexed,
                    timestamp,
                    &mut transaction,
                )
                .await?
            };
            for order in state.orders.values() {
                sqlx::query_file!(
                    "sqlx_queries/order_history/insert_order.sql",
                    order.market_id,
                    order.order_id,
                    order.user,
                    order.size,
                    OrderDirection::from_bool_type(order.side, OrderType::Limit) as OrderDirection,
                    order.price,
                    timestamp,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(to_pipeline_error)?;
            }
        }
        if let Some(last) = timestamps.last() {
            sqlx::query_file!(
                "sqlx_queries/order_history/update_last_indexed_timestamp.sql",
                last,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        }
        commit_transaction(transaction).await?;
        self.state = Some(state);
        Ok(())
    }
}
