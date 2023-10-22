use anyhow::anyhow;
use bigdecimal::{num_bigint::ToBigInt, BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{Executor, PgConnection, PgPool, Postgres, Transaction};

use super::{Data, DataAggregationError, DataAggregationResult};

/// Number of bits to shift when encoding transaction version.
const SHIFT_TXN_VERSION: u8 = 64;

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
impl Data for UserHistory {
    fn model_name(&self) -> &'static str {
        "UserHistory"
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::seconds(5) < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> DataAggregationResult {
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(5))
    }

    /// All database interactions are handled in a single atomic transaction. Processor insertions
    /// are also handled in a single atomic transaction for each batch of transactions, such that
    /// user history aggregation logic is effectively serialized across historical chain state.
    async fn process_and_save_internal(&mut self) -> DataAggregationResult {
        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        transaction
            .execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;")
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        struct TxnVersion {
            txn_version: BigDecimal,
        }
        let max_txn_version = sqlx::query_as!(
            TxnVersion,
            "SELECT txn_version FROM aggregator.user_history_last_indexed_txn",
        )
        .fetch_optional(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let txnv_exists = max_txn_version.is_some();
        let max_txn_version = max_txn_version
            .unwrap_or(TxnVersion { txn_version: BigDecimal::zero() })
            .txn_version;
        let fill_events = sqlx::query!(
            r#"
                SELECT * FROM fill_events
                WHERE txn_version > $1
                ORDER BY txn_version, event_idx
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let change_events = sqlx::query!(
            r#"
                SELECT * FROM change_order_size_events
                WHERE txn_version > $1
                ORDER BY txn_version, event_idx
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let cancel_events = sqlx::query!(
            r#"
                SELECT * FROM cancel_order_events
                WHERE txn_version > $1
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let limit_events = sqlx::query!(
            r#"
                SELECT * FROM place_limit_order_events
                WHERE txn_version > $1
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let market_events = sqlx::query!(
            r#"
                SELECT * FROM place_market_order_events
                WHERE txn_version > $1
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let swap_events = sqlx::query!(
            r#"
                SELECT * FROM place_swap_order_events
                WHERE txn_version > $1
            "#,
            max_txn_version
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        for x in &limit_events {
            let txn = x
                .txn_version
                .to_bigint()
                .ok_or(DataAggregationError::ProcessingError(anyhow!(
                    "txn_version not integer"
                )))?
                << SHIFT_TXN_VERSION;
            let event = x
                .event_idx
                .to_bigint()
                .ok_or(DataAggregationError::ProcessingError(anyhow!(
                    "event_idx not integer"
                )))?;
            let txn_event: BigDecimal = BigDecimal::from(txn | event);
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history_limit VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9
                    );
                "#,
                x.market_id,
                x.order_id,
                x.user,
                x.custodian_id,
                x.side,
                x.self_match_behavior,
                x.restriction,
                x.price,
                txn_event,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9
                    );
                "#,
                x.market_id,
                x.order_id,
                x.time,
                None as Option<DateTime<Utc>>,
                x.integrator,
                BigDecimal::zero(),
                x.initial_size,
                OrderStatus::Open as OrderStatus,
                OrderType::Limit as OrderType,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
        for x in &market_events {
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history_market VALUES (
                        $1, $2, $3, $4, $5, $6
                    );
                "#,
                x.market_id,
                x.order_id,
                x.user,
                x.custodian_id,
                x.direction,
                x.self_match_behavior,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9
                    );
                "#,
                x.market_id,
                x.order_id,
                x.time,
                None as Option<DateTime<Utc>>,
                x.integrator,
                BigDecimal::zero(),
                x.size,
                OrderStatus::Open as OrderStatus,
                OrderType::Market as OrderType,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
        for x in &swap_events {
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history_swap VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9
                    );
                "#,
                x.market_id,
                x.order_id,
                x.direction,
                x.limit_price,
                x.signing_account,
                x.min_base,
                x.max_base,
                x.min_quote,
                x.max_quote,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            let market = sqlx::query!(
                "SELECT * FROM market_registration_events WHERE market_id = $1",
                x.market_id
            )
            .fetch_one(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9
                    );
                "#,
                x.market_id,
                x.order_id,
                x.time,
                None as Option<DateTime<Utc>>,
                x.integrator,
                BigDecimal::zero(),
                x.max_base.clone() / market.lot_size,
                OrderStatus::Open as OrderStatus,
                OrderType::Swap as OrderType,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
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
        for x in &cancel_events {
            sqlx::query!(
                r#"
                    UPDATE aggregator.user_history
                    SET order_status = 'cancelled', last_updated_at = $3
                    WHERE order_id = $1 AND market_id = $2;
                "#,
                x.order_id,
                x.market_id,
                x.time,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
        update_max_txn_version(&mut transaction, txnv_exists).await?;
        transaction
            .commit()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
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
) -> DataAggregationResult {
    aggregate_fill(tx, size, maker_order_id, market_id, time).await?;
    aggregate_fill(tx, size, taker_order_id, market_id, time).await?;
    Ok(())
}

async fn aggregate_fill<'a>(
    tx: &mut Transaction<'a, Postgres>,
    size: &BigDecimal,
    order_id: &BigDecimal,
    market_id: &BigDecimal,
    time: &DateTime<Utc>,
) -> DataAggregationResult {
    // Only limit orders can remain open after a transaction during which they are filled against,
    // so flag market orders and swaps as closed by default: if they end up being cancelled instead
    // of closed, the cancel event emitted during the same transaction (aggregated after fills) will
    // clean up the order status to cancelled.
    sqlx::query!(
        r#"
        UPDATE aggregator.user_history
        SET
            remaining_size = remaining_size - $1,
            total_filled = total_filled + $1,
            order_status = CASE order_type
                WHEN 'limit' THEN CASE remaining_size - $1
                    WHEN 0 THEN 'closed'
                    ELSE order_status
                END
                ELSE 'closed'
            END,
            last_updated_at = $4
        WHERE order_id = $2 AND market_id = $3
        "#,
        size,
        order_id,
        market_id,
        time
    )
    .execute(tx as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
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
) -> DataAggregationResult {
    // Get some info
    let record = sqlx::query!(
        r#"
            SELECT order_type as "order_type: OrderType", remaining_size
            FROM aggregator.user_history
            WHERE market_id = $1
            AND order_id = $2
        "#,
        market_id,
        order_id,
    )
    .fetch_one(tx as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    let (order_type, original_size): (OrderType, BigDecimal) =
        (record.order_type, record.remaining_size);
    // If it's a limit order and needs reordering
    if matches!(order_type, OrderType::Limit) && &original_size < new_size {
        let txn = txn_version
            .to_bigint()
            .ok_or(DataAggregationError::ProcessingError(anyhow!(
                "txn_version not integer"
            )))?
            << SHIFT_TXN_VERSION;
        let event = event_idx
            .to_bigint()
            .ok_or(DataAggregationError::ProcessingError(anyhow!(
                "event_idx not integer"
            )))?;
        let txn_event: BigDecimal = BigDecimal::from(txn | event);
        sqlx::query!(
            r#"
                UPDATE aggregator.user_history_limit
                SET last_increase_stamp = $3
                WHERE market_id = $1
                AND order_id = $2
            "#,
            market_id,
            order_id,
            txn_event,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    }
    sqlx::query!(
        r#"
            UPDATE aggregator.user_history
            SET
                last_updated_at = $4,
                remaining_size = $1
            WHERE order_id = $2 AND market_id = $3;
        "#,
        new_size,
        order_id,
        market_id,
        time,
    )
    .execute(tx as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    Ok(())
}

async fn update_max_txn_version<'a>(
    tx: &mut Transaction<'a, Postgres>,
    already_exists: bool,
) -> DataAggregationResult {
    let new_max_txn_version = sqlx::query!(
        r#"
            WITH max_per_table AS (
                SELECT MAX(txn_version) AS max FROM fill_events
                UNION ALL
                SELECT MAX(txn_version) AS max FROM place_limit_order_events
                UNION ALL
                SELECT MAX(txn_version) AS max FROM place_market_order_events
                UNION ALL
                SELECT MAX(txn_version) AS max FROM place_swap_order_events
            )
            SELECT MAX(max) AS max FROM max_per_table
        "#,
    )
    .fetch_one(tx as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?
    .max.unwrap_or(BigDecimal::zero());
    if already_exists {
        sqlx::query!(
            r#"
                UPDATE aggregator.user_history_last_indexed_txn
                SET txn_version = $1
            "#,
            new_max_txn_version,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    } else {
        sqlx::query!(
            r#"
                INSERT INTO aggregator.user_history_last_indexed_txn VALUES ($1)
            "#,
            new_max_txn_version,
        )
        .execute(tx as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    }
    Ok(())
}
