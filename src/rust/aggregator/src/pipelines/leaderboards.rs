use anyhow::anyhow;
use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool, Postgres, Transaction};

use aggregator::{
    util::{commit_transaction, create_repeatable_read_transaction},
    Pipeline, PipelineAggregationResult, PipelineError,
};

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
    market_id: BigDecimal,
}

#[async_trait::async_trait]
impl Pipeline for Leaderboards {
    fn model_name(&self) -> String {
        String::from("Leaderboard")
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

        // Get all competitions having created markets
        let competitions = sqlx::query_as!(
            Competition,
            r#"
                SELECT id, market_id FROM aggregator.competition_metadata AS cm
                WHERE start < CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP < "end"
                AND EXISTS (
                    SELECT * FROM market_registration_events AS mre
                    WHERE mre.market_id = cm.market_id
                )
            "#,
        )
        .fetch_all(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        for comp in competitions {
            aggregate_data_for_competition(&mut transaction, comp).await?;
        }
        commit_transaction(transaction).await?;
        Ok(())
    }
}

async fn aggregate_data_for_competition<'a>(
    transaction: &mut Transaction<'a, Postgres>,
    comp: Competition,
) -> PipelineAggregationResult {
    // Insert new users
    sqlx::query!(
        r#"
            -- Insert into the users table
            INSERT INTO aggregator.competition_leaderboard_users ("user", volume, integrators_used, n_trades, competition_id)

            -- Every address with default values from new fill events
            SELECT DISTINCT taker_address as "user", 0, '{}'::text[], 0, $1 FROM aggregator.fills($1)
            -- That doesn't already exist
            WHERE NOT EXISTS (
                SELECT *
                FROM aggregator.competition_leaderboard_users
                WHERE competition_id = $1
                AND fills.taker_address = aggregator.competition_leaderboard_users."user"
            )
            UNION
            SELECT DISTINCT maker_address as "user", 0, '{}'::text[], 0, $1 FROM aggregator.fills($1)
            -- That doesn't already exist
            WHERE NOT EXISTS (
                SELECT *
                FROM aggregator.competition_leaderboard_users
                WHERE competition_id = $1
                AND fills.maker_address = aggregator.competition_leaderboard_users."user"
            )
            UNION
            -- Every address with default values from new place events
            SELECT DISTINCT "user", 0, '{}'::text[], 0, $1 FROM aggregator.places($1)
            -- That doesn't already exist
            WHERE NOT EXISTS (
                SELECT *
                FROM aggregator.competition_leaderboard_users
                WHERE competition_id = $1
                AND places."user" = aggregator.competition_leaderboard_users."user"
            )
        "#,
        comp.id,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

    sqlx::query!(
        r#"
            UPDATE aggregator.competition_leaderboard_users AS a
            SET
                volume = a.volume + COALESCE((
                    user_volume.volume
                ), 0) * (SELECT tick_size FROM market_registration_events WHERE market_id = $2)
            FROM aggregator.user_volume($1) where a."user" = user_volume."user" AND a.competition_id = $1
        "#,
        comp.id,
        comp.market_id,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

    sqlx::query!(
        r#"
            UPDATE aggregator.competition_leaderboard_users AS a
            SET
                n_trades = a.n_trades + COALESCE((
                    user_trades.trades
                ), 0)
            FROM aggregator.user_trades($1) WHERE a."user" = user_trades."user" AND a.competition_id = $1
        "#,
        comp.id,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

    sqlx::query!(
        r#"
            WITH official_integrators AS (
                SELECT UNNEST(integrators_required) FROM aggregator.competition_metadata WHERE id = $1
            )
            UPDATE aggregator.competition_leaderboard_users AS a
            SET
                integrators_used = COALESCE((
                    SELECT ARRAY_AGG(DISTINCT x)
                    FROM UNNEST(a.integrators_used || user_integrators.integrators) AS t(x)
                    WHERE x IN (SELECT * FROM official_integrators)
                ),'{}'::TEXT[])
            FROM aggregator.user_integrators($1) WHERE a."user" = user_integrators."user" AND a.competition_id = $1
        "#,
        comp.id,
    )
    .execute(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

    // Set last aggregated transaction version
    let max_txnv_fills = sqlx::query!(
        r#"
            SELECT MAX(txn_version) AS max FROM aggregator.fills($1)
        "#,
        comp.id,
    )
    .fetch_one(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?
    .max;

    let max_txnv_places = sqlx::query!(
        r#"
            SELECT MAX(txn_version) AS max FROM aggregator.places($1)
        "#,
        comp.id,
    )
    .fetch_one(transaction as &mut PgConnection)
    .await
    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?
    .max;

    let max = BigDecimal::max(
        max_txnv_places.unwrap_or(BigDecimal::zero()),
        max_txnv_fills.unwrap_or(BigDecimal::zero()),
    );

    if !max.is_zero() {
        sqlx::query!(
            r#"
                INSERT INTO aggregator.competition_indexed_events (txn_version, competition_id)
                VALUES ($1, $2)
                ON CONFLICT (competition_id) DO UPDATE SET txn_version = $1
            "#,
            max,
            comp.id,
        )
        .execute(transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
    }
    Ok(())
}
