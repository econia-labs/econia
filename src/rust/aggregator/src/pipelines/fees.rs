use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;

use aggregator::{util::*, Pipeline, PipelineAggregationResult};
use sqlx_postgres::PgConnection;

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(60);

pub struct Fees {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl Fees {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for Fees {
    fn model_name(&self) -> String {
        String::from("Fees")
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
        sqlx::query_file!("sqlx_queries/fees/backfill.sql",)
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        sqlx::query_file!("sqlx_queries/fees/delete_last_indexed_txn.sql",)
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        sqlx::query_file!("sqlx_queries/fees/update_last_indexed_txn.sql",)
            .execute(&mut transaction as &mut PgConnection)
            .await
            .map_err(to_pipeline_error)?;
        commit_transaction(transaction).await?;
        Ok(())
    }
}
