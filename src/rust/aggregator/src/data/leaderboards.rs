use anyhow::anyhow;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Postgres, Transaction};

use super::{Data, DataAggregationError, DataAggregationResult};

pub struct Leaderboards {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl Leaderboards {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

struct Competition {
    id: i32,
    start: DateTime<Utc>,
    end: DateTime<Utc>,
    prize: i64,
    market_id: BigDecimal,
    frontends_required: Vec<String>,
}

#[async_trait::async_trait]
impl Data for Leaderboards {
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

    async fn process_and_save_internal(&mut self) -> DataAggregationResult {
        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        let competitions = sqlx::query_as!(
            Competition,
            r#"
                SELECT * FROM competition_metadata
                WHERE start < CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP < "end"
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        for comp in competitions {
            do_comp(&mut transaction, comp).await?;
        }
        transaction
            .commit()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}

async fn do_comp<'a>(
    transaction: &mut Transaction<'a, Postgres>,
    comp: Competition,
) -> DataAggregationResult {
    let users = sqlx::query!(
        r#"
            SELECT * FROM competition_leaderboard_users WHERE "user" IN (
                SELECT "user" FROM fill_events
                WHERE NOT EXISTS (
                    SELECT * FROM aggregator.aggregated_events
                    WHERE fill_events.txn_version = aggregated_events.txn_version
                    AND fill_events.event_idx = aggregated_events.event_idx
                )
            )
            AND competition_id = $1
        "#,
        comp.id
    )
    .fetch_all(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    for user in users {
        sqlx::query!(
            r#"
                UPDATE competition_leaderboard_users
                SET
                    volume = (
                        WITH relevant_fills AS (
                            SELECT * FROM fill_events
                            WHERE NOT EXISTS (
                                SELECT * FROM competition_indexed_events
                                WHERE fill_events.txn_version = competition_indexed_events.txn_version
                                AND fill_events.event_idx = competition_indexed_events.event_idx
                                AND competition_indexed_events.competition_id = $2
                            )
                            AND maker_address = $1 OR taker_address = $1
                            AND time > $3 AND time < $4
                        )
                        SELECT SUM(size) FROM relevant_fills
                    ),
                    frontends_used = (
                        SELECT array_agg(integrator) AS integrators FROM (
                            SELECT DISTINCT "user", integrator FROM place_limit_order_events
                            WHERE NOT EXISTS (
                                SELECT * FROM competition_indexed_events
                                WHERE place_limit_order_events.txn_version = competition_indexed_events.txn_version
                                AND place_limit_order_events.event_idx = competition_indexed_events.event_idx
                                AND competition_indexed_events.competition_id = $2
                            )
                            AND time > $3 AND time < $4
                            UNION
                            SELECT DISTINCT "user", integrator FROM place_market_order_events
                            WHERE NOT EXISTS (
                                SELECT * FROM competition_indexed_events
                                WHERE place_market_order_events.txn_version = competition_indexed_events.txn_version
                                AND place_market_order_events.event_idx = competition_indexed_events.event_idx
                                AND competition_indexed_events.competition_id = $2
                            )
                            AND time > $3 AND time < $4
                            UNION
                            SELECT DISTINCT signing_account as "user", integrator FROM place_swap_order_events
                            WHERE NOT EXISTS (
                                SELECT * FROM competition_indexed_events
                                WHERE place_swap_order_events.txn_version = competition_indexed_events.txn_version
                                AND place_swap_order_events.event_idx = competition_indexed_events.event_idx
                                AND competition_indexed_events.competition_id = $2
                            )
                            AND time > $3 AND time < $4
                        ) AS a
                        WHERE integrator IN (SELECT unnest(frontends_required) FROM competition_metadata)
                        AND "user" = $1
                    ),
                    trades = (
                        WITH homogenous_fills AS (
                            SELECT taker_address AS "user", taker_order_id AS order_id
                            FROM fill_events
                            WHERE time > $3 AND time < $4
                            UNION
                            SELECT maker_address AS "user", maker_order_id AS order_id
                            FROM fill_events
                            WHERE time > $3 AND time < $4
                        )
                        SELECT COUNT(order_id) AS orders
                        FROM homogenous_fills
                        WHERE "user" = $1
                    )
                WHERE "user" = $1
            "#,
            user.user,
            comp.id,
            comp.start,
            comp.end,
        )
        .execute(transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    }
    sqlx::query!(
        r#"
            INSERT INTO competition_indexed_events SELECT txn_version, event_idx, $1 FROM fill_events
            WHERE NOT EXISTS (
                SELECT * FROM competition_indexed_events
                WHERE fill_events.txn_version = competition_indexed_events.txn_version
                AND fill_events.event_idx = competition_indexed_events.event_idx
                AND competition_indexed_events.competition_id = $1
            )
            AND fill_events.time > $2 AND fill_events.time < $3
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    sqlx::query!(
        r#"
            INSERT INTO competition_indexed_events SELECT txn_version, event_idx, $1 FROM fill_events
            WHERE NOT EXISTS (
                SELECT * FROM competition_indexed_events
                WHERE fill_events.txn_version = competition_indexed_events.txn_version
                AND fill_events.event_idx = competition_indexed_events.event_idx
                AND competition_indexed_events.competition_id = $1
            )
            AND fill_events.time > $2 AND fill_events.time < $3
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    sqlx::query!(
        r#"
            INSERT INTO competition_indexed_events SELECT txn_version, event_idx, $1 FROM place_limit_order_events
            WHERE NOT EXISTS (
                SELECT * FROM competition_indexed_events
                WHERE place_limit_order_events.txn_version = competition_indexed_events.txn_version
                AND place_limit_order_events.event_idx = competition_indexed_events.event_idx
                AND competition_indexed_events.competition_id = $1
            )
            AND place_limit_order_events.time > $2 AND place_limit_order_events.time < $3
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    sqlx::query!(
        r#"
            INSERT INTO competition_indexed_events SELECT txn_version, event_idx, $1 FROM place_market_order_events
            WHERE NOT EXISTS (
                SELECT * FROM competition_indexed_events
                WHERE place_market_order_events.txn_version = competition_indexed_events.txn_version
                AND place_market_order_events.event_idx = competition_indexed_events.event_idx
                AND competition_indexed_events.competition_id = $1
            )
            AND place_market_order_events.time > $2 AND place_market_order_events.time < $3
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    sqlx::query!(
        r#"
            INSERT INTO competition_indexed_events SELECT txn_version, event_idx, $1 FROM place_swap_order_events
            WHERE NOT EXISTS (
                SELECT * FROM competition_indexed_events
                WHERE place_swap_order_events.txn_version = competition_indexed_events.txn_version
                AND place_swap_order_events.event_idx = competition_indexed_events.event_idx
                AND competition_indexed_events.competition_id = $1
            )
            AND place_swap_order_events.time > $2 AND place_swap_order_events.time < $3
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
    Ok(())
}
