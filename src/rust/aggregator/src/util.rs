use anyhow::anyhow;
use bigdecimal::BigDecimal;
use sqlx::{Executor, Pool, Transaction};
use sqlx_postgres::Postgres;

use crate::{PipelineAggregationResult, PipelineError};

pub fn to_pipeline_error<T: Into<anyhow::Error>>(e: T) -> PipelineError {
    PipelineError::ProcessingError(anyhow!(e))
}

pub async fn create_repeatable_read_transaction<'a>(
    pool: &Pool<Postgres>,
) -> Result<Transaction<'a, Postgres>, PipelineError> {
    let mut transaction = pool.begin().await.map_err(to_pipeline_error)?;
    transaction
        .execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;")
        .await
        .map_err(to_pipeline_error)?;
    Ok(transaction)
}

pub async fn commit_transaction<'a>(tx: Transaction<'a, Postgres>) -> PipelineAggregationResult {
    tx.commit().await.map_err(to_pipeline_error)?;
    Ok(())
}
