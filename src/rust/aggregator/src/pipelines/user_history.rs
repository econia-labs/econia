use anyhow::anyhow;
use bigdecimal::{num_bigint::ToBigInt, BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{Executor, PgConnection, PgPool, Postgres, Transaction};

use aggregator::{Pipeline, PipelineAggregationResult, PipelineError};

/// Number of bits to shift when encoding transaction version.
const SHIFT_TXN_VERSION: u8 = 64;

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_millis(100);

#[derive(sqlx::Type, Debug)]
#[sqlx(type_name = "order_status", rename_all = "lowercase")]
pub enum OrderStatus {
    Open,
    Closed,
    Cancelled,
}

#[derive(sqlx::Type, Debug)]
#[sqlx(type_name = "order_type", rename_all = "lowercase")]
pub enum OrderType {
    Limit,
    Market,
    Swap,
}

pub struct UserHistory {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl UserHistory {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for UserHistory {
    fn model_name(&self) -> String {
        String::from("UserHistory")
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

    /// All database interactions are handled in a single atomic transaction. Processor insertions
    /// are also handled in a single atomic transaction for each batch of transactions, such that
    /// user history aggregation logic is effectively serialized across historical chain state.
    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        transaction
            .execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;")
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        struct TxnVersion {
            txn_version: BigDecimal,
        }
        let max_txn_version = sqlx::query_file_as!(
            TxnVersion,
            "sqlx_queries/user_history/get_last_indexed_txn_version.sql",
        )
        .fetch_optional(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        let txnv_exists = max_txn_version.is_some();
        let max_txn_version = max_txn_version
            .unwrap_or(TxnVersion {
                txn_version: BigDecimal::zero(),
            })
            .txn_version;
        let fill_events = sqlx::query_file!(
            "sqlx_queries/user_history/get_fill_events.sql",
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        let change_events = sqlx::query_file!(
            "sqlx_queries/user_history/get_change_order_size_events.sql",
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        sqlx::query_file!(
            "sqlx_queries/user_history/insert_user_history_limit.sql",
            max_txn_version,
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        sqlx::query_file!(
            "sqlx_queries/user_history/insert_user_history_market.sql",
            max_txn_version,
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        sqlx::query_file!(
            "sqlx_queries/user_history/insert_user_history_swap.sql",
            max_txn_version,
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        // Step through fill and change events in total order.
        let mut fill_index = 0;
        let mut change_index = 0;
        for _ in 0..(fill_events.len() + change_events.len()) {
            let (fill_event_to_aggregate, change_event_to_aggregate) =
                match (fill_events.get(fill_index), change_events.get(change_index)) {
                    (Some(fill), Some(change)) => {
                        if fill.txn_version < change.txn_version
                            || (fill.txn_version == change.txn_version
                                && fill.event_idx < change.event_idx)
                        {
                            (Some(fill), None)
                        } else {
                            (None, Some(change))
                        }
                    }
                    (Some(fill), None) => (Some(fill), None),
                    (None, Some(change)) => (None, Some(change)),
                    (None, None) => unreachable!(),
                };
            match (fill_event_to_aggregate, change_event_to_aggregate) {
                (Some(fill), None) => {
                    // Dedupe if needed by only aggregating events emitted to maker handle.
                    if fill.maker_address == fill.emit_address {
                        aggregate_fill_for_maker_and_taker(
                            &mut transaction,
                            &fill.size,
                            &fill.maker_order_id,
                            &fill.taker_order_id,
                            &fill.market_id,
                            &fill.time,
                            &fill.price,
                        )
                        .await?;
                    }
                    fill_index += 1;
                }
                (None, Some(change)) => {
                    aggregate_change(
                        &mut transaction,
                        &change.new_size,
                        &change.order_id,
                        &change.market_id,
                        &change.time,
                        &change.txn_version,
                        &change.event_idx,
                    )
                    .await?;
                    change_index += 1;
                }
                _ => unreachable!(),
            };
        }
        sqlx::query_file!(
            "sqlx_queries/user_history/mark_cancelled.sql",
            max_txn_version,
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        update_max_txn_version(&mut transaction, txnv_exists).await?;
        transaction
            .commit()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}

async fn aggregate_fill_for_maker_and_taker<'a>(
    tx: &mut Transaction<'a, Postgres>,
    size: &BigDecimal,
    maker_order_id: &BigDecimal,
    taker_order_id: &BigDecimal,
    market_id: &BigDecimal,
    time: &DateTime<Utc>,
    price: &BigDecimal,
) -> PipelineAggregationResult {
    aggregate_fill(tx, size, maker_order_id, market_id, time, price).await?;
    aggregate_fill(tx, size, taker_order_id, market_id, time, price).await?;
    Ok(())
}

async fn aggregate_fill<'a>(
    tx: &mut Transaction<'a, Postgres>,
    size: &BigDecimal,
    order_id: &BigDecimal,
    market_id: &BigDecimal,
    time: &DateTime<Utc>,
    price: &BigDecimal,
) -> PipelineAggregationResult {
    // Only limit orders can remain open after a transaction during which they are filled against,
    // so flag market orders and swaps as closed by default: if they end up being cancelled instead
    // of closed, the cancel event emitted during the same transaction (aggregated after fills) will
    // clean up the order status to cancelled.
    sqlx::query_file!(
        "sqlx_queries/user_history/aggregate_fill.sql",
        size,
        order_id,
        market_id,
        time,
        price,
    )
    .execute(tx as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    Ok(())
}

async fn aggregate_change<'a>(
    tx: &mut Transaction<'a, Postgres>,
    new_size: &BigDecimal,
    order_id: &BigDecimal,
    market_id: &BigDecimal,
    time: &DateTime<Utc>,
    txn_version: &BigDecimal,
    event_idx: &BigDecimal,
) -> PipelineAggregationResult {
    // Get some info
    let record = sqlx::query_file!(
        "sqlx_queries/user_history/get_order_type_with_remaining_size.sql",
        market_id,
        order_id,
    )
    .fetch_one(tx as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    let (order_type, original_size): (OrderType, BigDecimal) =
        (record.order_type, record.remaining_size);
    // If it's a limit order and needs reordering
    if matches!(order_type, OrderType::Limit) && &original_size < new_size {
        let txn = txn_version
            .to_bigint()
            .ok_or(PipelineError::ProcessingError(anyhow!(
                "txn_version not integer"
            )))?
            << SHIFT_TXN_VERSION;
        let event = event_idx
            .to_bigint()
            .ok_or(PipelineError::ProcessingError(anyhow!(
                "event_idx not integer"
            )))?;
        let txn_event: BigDecimal = BigDecimal::from(txn | event);
        sqlx::query_file!(
            "sqlx_queries/user_history/update_last_increase_stamp.sql",
            market_id,
            order_id,
            txn_event,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    }
    sqlx::query_file!(
        "sqlx_queries/user_history/aggregate_size_change.sql",
        new_size,
        order_id,
        market_id,
        time,
    )
    .execute(tx as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    Ok(())
}

async fn update_max_txn_version<'a>(
    tx: &mut Transaction<'a, Postgres>,
    already_exists: bool,
) -> PipelineAggregationResult {
    let new_max_txn_version =
        sqlx::query_file!("sqlx_queries/user_history/get_new_last_indexed_txn_version.sql",)
            .fetch_one(tx as &mut PgConnection)
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?
            .max
            .unwrap_or(BigDecimal::zero());
    if already_exists {
        sqlx::query_file!(
            "sqlx_queries/user_history/set_new_last_indexed_txn_version.sql",
            new_max_txn_version,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    } else {
        sqlx::query_file!(
            "sqlx_queries/user_history/init_last_indexed_txn_version.sql",
            new_max_txn_version,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    }
    Ok(())
}
