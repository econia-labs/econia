use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool};
use sqlx_postgres::types::PgInterval;

use aggregator::{Pipeline, PipelineError, PipelineAggregationResult};

pub struct Candlesticks {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
    /// in seconds
    resolution: i32,
}

impl Candlesticks {
    pub fn new(pool: PgPool, resolution: i32) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
            resolution,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for Candlesticks {
    fn model_name(&self) -> String {
        format!("Candlesticks({})", self.resolution)
    }

    /// Init resolutions and last indexed transaction version number, then process and save.
    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {

        sqlx::query_file!(
            "sqlx_queries/candlesticks/insert_candlestick.sql",
            self.resolution
        )
        .execute(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::from_std(std::time::Duration::from_secs(self.resolution as u64)).unwrap()
                < Utc::now()
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs((self.resolution / 2) as u64))
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let interval =
                PgInterval::from(std::time::Duration::from_secs(self.resolution as u64).try_into().unwrap());

        let mut transaction = self
            .pool
            .begin()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

        transaction
            .commit()
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

        Ok(())
    }
}
