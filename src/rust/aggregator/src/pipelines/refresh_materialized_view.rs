use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;

use aggregator::{Pipeline, PipelineAggregationResult, PipelineError};

pub struct RefreshMaterializedView {
    pool: PgPool,
    view_name: String,
    update_interval: std::time::Duration,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl RefreshMaterializedView {
    pub fn new(
        pool: PgPool,
        view_name: impl Into<String>,
        update_interval: std::time::Duration,
    ) -> Self {
        Self {
            pool,
            view_name: view_name.into(),
            update_interval,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for RefreshMaterializedView {
    fn model_name(&self) -> String {
        String::from("RefreshMaterializedView")
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap()
                + Duration::from_std(self.update_interval).unwrap()
                < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(self.update_interval)
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        sqlx::query(format!("REFRESH MATERIALIZED VIEW {};", self.view_name).as_str())
            .execute(&self.pool)
            .await
            .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}
