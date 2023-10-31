use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool};
use sqlx_postgres::types::PgInterval;

use aggregator::{Pipeline, PipelineError, PipelineAggregationResult};

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

fn resolutions() -> Vec<Duration> {
    vec![
        Duration::minutes(1),
        Duration::minutes(5),
        Duration::minutes(15),
        Duration::minutes(30),
        Duration::hours(1),
        Duration::hours(4),
        Duration::hours(12),
        Duration::days(1),
    ]
}

pub struct Candlesticks {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl Candlesticks {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for Candlesticks {
    fn model_name(&self) -> &'static str {
        "Candlesticks"
    }

    /// Init resolutions and last indexed transaction version number, then process and save.
    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        let expected_resolutions: Vec<PgInterval> = resolutions()
            .iter()
            .map(|e| e.to_std().unwrap().try_into().unwrap())
            .collect();
        let actual_resolutions: Vec<PgInterval> =
            sqlx::query_file!("sqlx_queries/candlesticks/get_resolutions.sql")
                .fetch_all(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?
                .iter()
                .map(|e| e.resolution.clone())
                .collect();
        if actual_resolutions.is_empty() {
            for resolution in expected_resolutions {
                sqlx::query_file!(
                    "sqlx_queries/candlesticks/insert_resolution.sql",
                    resolution
                )
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
            }
        } else if actual_resolutions != expected_resolutions {
            return Err(PipelineError::ProcessingError(anyhow!(
                "Actual resolutions do not match expected resolutions"
            )));
        }
        let last_indexed_txn_version =
            sqlx::query_file!("sqlx_queries/candlesticks/get_last_indexed_txn_version.sql")
                .fetch_optional(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        if last_indexed_txn_version.is_none() {
            sqlx::query_file!("sqlx_queries/candlesticks/init_last_indexed_txn_version.sql")
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        };
        transaction
            .commit()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        self.process_and_save_internal().await
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::from_std(TIMEOUT).unwrap()
                < Utc::now()
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(TIMEOUT)
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        Ok(())
    }
}
