use anyhow::anyhow;
use bigdecimal::{BigDecimal, Zero};
use chrono::{DateTime, Duration, Utc};
use sqlx::{PgConnection, PgPool};

use aggregator::{
    util::{commit_transaction, create_repeatable_read_transaction},
    Pipeline, PipelineAggregationResult, PipelineError,
};

pub const TIMEOUT: std::time::Duration = std::time::Duration::from_millis(100);

pub struct UserBalances {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

impl UserBalances {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for UserBalances {
    fn model_name(&self) -> String {
        String::from("UserBalances")
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
        struct TxnVersion {
            txn_version: BigDecimal,
        }
        let last_indexed_txn_version = sqlx::query_file_as!(
            TxnVersion,
            "sqlx_queries/user_balances/get_last_indexed_txn_version.sql",
        )
        .fetch_optional(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        let txnv_exists = last_indexed_txn_version.is_some();
        let last_indexed_txn_version = last_indexed_txn_version
            .unwrap_or(TxnVersion {
                txn_version: BigDecimal::zero(),
            })
            .txn_version;
        sqlx::query_file!(
            "sqlx_queries/user_balances/backfill.sql",
            last_indexed_txn_version
        )
        .execute(&mut transaction as &mut PgConnection)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        if txnv_exists {
            sqlx::query_file!("sqlx_queries/user_balances/update_last_indexed_txn_version.sql",)
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        } else {
            sqlx::query_file!("sqlx_queries/user_balances/insert_last_indexed_txn_version.sql",)
                .execute(&mut transaction as &mut PgConnection)
                .await
                .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        }
        commit_transaction(transaction).await?;
        Ok(())
    }
}
