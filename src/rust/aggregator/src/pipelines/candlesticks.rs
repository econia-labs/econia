use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;
use sqlx_postgres::PgConnection;

use aggregator::{
    util::{commit_transaction, create_repeatable_read_transaction},
    Pipeline, PipelineAggregationResult, PipelineError,
};

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

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        sqlx::query_file!(
            "sqlx_queries/candlesticks/init_last_indexed_txn_version.sql",
            self.resolution,
        )
        .execute(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

        self.process_and_save_internal().await
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap()
                + Duration::from_std(std::time::Duration::from_secs(5)).unwrap()
                < Utc::now()
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(5))
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let mut transaction = create_repeatable_read_transaction(&self.pool).await?;

        sqlx::query_file!("sqlx_queries/candlesticks/insert_data.sql", self.resolution,)
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

        sqlx::query_file!(
            "sqlx_queries/candlesticks/update_last_indexed_txn_version.sql",
            self.resolution,
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;

        commit_transaction(transaction).await?;

        Ok(())
    }
}
