use anyhow::anyhow;
use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgPool, PgConnection};

use super::{Data, DataAggregationError, DataAggregationResult};

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
    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::seconds(5) < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> DataAggregationResult {
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(60 * 60))
    }

    async fn process_and_save_internal(&mut self) -> DataAggregationResult {
        let mut transaction = self.pool.begin()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let fill_events = sqlx::query!(
            r#"
                SELECT * FROM fill_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE fill_events.txn_version = aggregated_events.txn_version
                    AND fill_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let change_events = sqlx::query!(
            r#"
                SELECT * FROM change_order_size_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE change_order_size_events.txn_version = aggregated_events.txn_version
                    AND change_order_size_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let cancel_events = sqlx::query!(
            r#"
                SELECT * FROM cancel_order_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE cancel_order_events.txn_version = aggregated_events.txn_version
                    AND cancel_order_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let limit_events = sqlx::query!(
            r#"
                SELECT * FROM place_limit_order_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE place_limit_order_events.txn_version = aggregated_events.txn_version
                    AND place_limit_order_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let market_events = sqlx::query!(
            r#"
                SELECT * FROM place_market_order_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE place_market_order_events.txn_version = aggregated_events.txn_version
                    AND place_market_order_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let swap_events = sqlx::query!(
            r#"
                SELECT * FROM place_swap_order_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE place_swap_order_events.txn_version = aggregated_events.txn_version
                    AND place_swap_order_events.event_idx = aggregated_events.event_idx
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        for x in &limit_events {
            sqlx::query!(
                r#"
                    INSERT INTO aggregator.user_history_limit VALUES (
                        $1, $2, $3, $4, $5, $6, $7
                    );
                "#,
                x.market_id,
                x.order_id,
                x.user,
                x.custodian_id,
                x.side,
                x.self_match_behavior,
                x.restriction,
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
        if !limit_events.is_empty() {
            for x in limit_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
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
        if !market_events.is_empty() {
            for x in market_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
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
            let market = sqlx::query!("SELECT * FROM market_registration_events WHERE market_id = $1", x.market_id)
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
        if !swap_events.is_empty() {
            for x in swap_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
        }
        for x in &change_events {
            sqlx::query!(
                r#"
                    UPDATE aggregator.user_history
                    SET remaining_size = $1, last_updated_at = $4
                    WHERE order_id = $2 AND market_id = $3;
                "#,
                x.new_size,
                x.order_id,
                x.market_id,
                x.time,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
        if !change_events.is_empty() {
            for x in change_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
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
        if !cancel_events.is_empty() {
            for x in cancel_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
        }
        for x in &fill_events {
            // If remaining_size is 0, update order_status.
            // But if order_status was 'cancelled', do not update.
            sqlx::query!(
                r#"
                    UPDATE aggregator.user_history
                    SET
                        remaining_size = remaining_size - $1,
                        total_filled = total_filled + $1,
                        order_status = CASE remaining_size
                            WHEN 0 THEN CASE order_status
                                WHEN 'cancelled' THEN order_status
                                ELSE 'closed'
                            END
                            ELSE order_status
                        END,
                        last_updated_at = CASE last_updated_at > $4
                            WHEN true THEN last_updated_at
                            ELSE $4
                        END
                    WHERE order_id = $2 AND market_id = $3;
                "#,
                x.size,
                x.maker_order_id,
                x.market_id,
                x.time,
            )
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        }
        if !fill_events.is_empty() {
            for x in fill_events {
                sqlx::query!(
                    r#"
                        INSERT INTO aggregator.aggregated_events VALUES (
                            $1, $2
                        );
                    "#,
                    x.txn_version,
                    x.event_idx,
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
            }
        }
        transaction.commit()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}
