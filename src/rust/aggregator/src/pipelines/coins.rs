use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;

use aggregator::{Pipeline, PipelineAggregationResult, PipelineError};
use thiserror::Error;

pub struct Coins {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

#[allow(dead_code)]
impl Coins {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for Coins {
    fn model_name(&self) -> String {
        String::from("Coins")
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::minutes(5) < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        sqlx::query!(
            r#"
                INSERT INTO aggregator.markets_registered_per_day (markets, date)
                SELECT COUNT(*), time::date
                FROM market_registration_events
                WHERE time::date NOT IN (
                    SELECT date FROM aggregator.markets_registered_per_day
                )
                GROUP BY time::date
            "#
        )
        .execute(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(60 * 60))
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let coins = sqlx::query!(
            r#"
                WITH market_coins AS (
                    SELECT DISTINCT
                        base_account_address AS address,
                        base_module_name AS module,
                        base_struct_name AS struct
                    FROM
                        market_registration_events
                    WHERE base_account_address IS NOT NULL
                    AND base_module_name IS NOT NULL
                    AND base_struct_name IS NOT NULL
                    UNION
                    SELECT DISTINCT
                        quote_account_address AS address,
                        quote_module_name AS module,
                        quote_struct_name AS struct
                    FROM
                        market_registration_events
                )
                SELECT
                    *
                FROM
                    market_coins AS m
                WHERE
                    NOT EXISTS (
                        SELECT
                            *
                        FROM
                            aggregator.coins AS c
                        WHERE
                            c.address = m.address
                        AND
                            c.module = m.module
                        AND
                            c.struct = m.struct
                    )
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        for coin in coins {
            let (address, module, struct_name) = (coin.address.unwrap(), coin.module.unwrap(), coin.r#struct.unwrap());
            let move_struct_tag_str = format!("{}::{}::{}", address, module, struct_name);
            let coin_info = get_coin_info(move_struct_tag_str).await;
            match coin_info {
                Ok(coin_info) => {
                    let CoinInfo { name, symbol, decimals } = coin_info;
                    sqlx::query!(
                        "INSERT INTO aggregator.coins VALUES ($1, $2, $3, $4, $5, $6)",
                        name, symbol, decimals, address, module, struct_name
                    )
                    .execute(&self.pool)
                    .await
                    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
                },
                Err(GetCoinInfoError::RateLimited) => {},
                Err(GetCoinInfoError::Other(e)) => {return Err(PipelineError::ProcessingError(anyhow!(e)));},
            }
        }
        Ok(())
    }
}

struct CoinInfo {
    name: String,
    symbol: String,
    decimals: i16,
}

#[derive(Debug, Error)]
enum GetCoinInfoError {
    #[error("Got rate limited by Aptos")]
    RateLimited,
    #[error("Other error: {0}")]
    Other(anyhow::Error),
}

async fn get_coin_info(move_struct_tag_str: String) -> Result<CoinInfo, GetCoinInfoError> {
    todo!()
}
