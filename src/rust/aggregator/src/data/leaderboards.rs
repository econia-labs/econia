use anyhow::anyhow;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Postgres, Transaction};

use super::{Data, DataAggregationError, DataAggregationResult};

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

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
    integrators_required: Vec<String>,
}

#[async_trait::async_trait]
impl Data for Leaderboards {
    fn model_name(&self) -> &'static str {
        "Leaderboard"
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::from_std(TIMEOUT).unwrap()
                < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> DataAggregationResult {
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(TIMEOUT)
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
                SELECT * FROM aggregator.competition_metadata
                WHERE start < CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP < "end"
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        for comp in competitions {
            aggregate_data_for_competition(&mut transaction, comp).await?;
        }
        transaction
            .commit()
            .await
            .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}

async fn aggregate_data_for_competition<'a>(
    transaction: &mut Transaction<'a, Postgres>,
    comp: Competition,
) -> DataAggregationResult {
    // Insert new users
    sqlx::query!(
        r#"
            INSERT INTO aggregator.competition_leaderboard_users ("user", volume, integrators_used, n_trades, competition_id)
            SELECT DISTINCT "user", 0, '{}'::text[], 0, $1 FROM aggregator.current_fills($1,$2,$3)
            WHERE NOT EXISTS (
                SELECT *
                FROM aggregator.competition_leaderboard_users
                WHERE competition_id = $1
                AND current_fills."user" = aggregator.competition_leaderboard_users."user"
            )
            UNION
            SELECT DISTINCT "user", 0, '{}'::text[], 0, $1 FROM aggregator.current_places($1,$2,$3)
            WHERE NOT EXISTS (
                SELECT *
                FROM aggregator.competition_leaderboard_users
                WHERE competition_id = $1
                AND current_places."user" = aggregator.competition_leaderboard_users."user"
            )
        "#,
        comp.id,
        comp.start,
        comp.end,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;

    // Update the data for all users
    sqlx::query!(
        r#"
            UPDATE aggregator.competition_leaderboard_users AS a
            SET

                -- Update volume
                volume = volume + COALESCE((
                    SELECT SUM(size*price)
                    FROM aggregator.current_fills($1,$2,$3)
                    WHERE current_fills."user" = a."user"
                ), 0) * (SELECT tick_size FROM market_registration_events WHERE market_id = $4),

                -- Update number of trades
                n_trades = (
                    SELECT COUNT(DISTINCT order_id) AS orders
                    FROM aggregator.homogenous_fills
                    WHERE homogenous_fills."user" = a."user"
                ),

                -- Update integrators used
                integrators_used =  integrators_used || (
                    -- Get a list of aggregators from all place events
                    SELECT array_agg(integrator) FROM (
                        -- Get user and integrator
                        SELECT DISTINCT "user", integrator
                        FROM aggregator.current_places($1,$2,$3)
                    ) AS b
                    -- Only keep aggregators that are in the "integrators_required" list
                    WHERE integrator IN (
                        SELECT unnest(integrators_required)
                        FROM aggregator.competition_metadata
                        WHERE competition_metadata.id = $1
                    )
                    -- Do not keep integrators that are already in the array (no duplicates)
                    AND integrator NOT IN (
                        SELECT unnest(integrators_used)
                        FROM aggregator.competition_leaderboard_users AS c
                        WHERE c.competition_id = $1
                        AND a."user" = c."user"
                    )
                    AND a."user" = b."user"
                )

            -- Only for the users that have an update
            WHERE a."user" IN (SELECT b."user" FROM aggregator.current_fills($1,$2,$3) AS b)
            OR a."user" IN (SELECT b."user" FROM aggregator.current_places($1,$2,$3) AS b);
        "#,
        comp.id,
        comp.start,
        comp.end,
        comp.market_id,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| DataAggregationError::ProcessingError(anyhow!(e)))?;

    // Marking events as aggregated
    sqlx::query!(
        r#"
            INSERT INTO aggregator.competition_indexed_events
            SELECT DISTINCT txn_version, event_idx, $1 FROM aggregator.current_fills($1,$2,$3)
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
            INSERT INTO aggregator.competition_indexed_events
            SELECT DISTINCT txn_version, event_idx, $1 FROM aggregator.current_places($1,$2,$3)
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
