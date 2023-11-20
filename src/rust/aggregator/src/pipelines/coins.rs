use anyhow::anyhow;
use aptos_sdk::{rest_client::{AptosBaseUrl, Client},types::account_address::AccountAddress};
use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;

use aggregator::{Pipeline, PipelineAggregationResult, PipelineError};
use thiserror::Error;

pub struct Coins {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
    network: AptosBaseUrl
}

#[allow(dead_code)]
impl Coins {
    pub fn new(pool: PgPool, network: AptosBaseUrl) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
            network,
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
        self.process_and_save_internal().await
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(60 * 60))
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let coins = sqlx::query_file!("sqlx_queries/coins/get_missing_coins.sql")
        .fetch_all(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        for coin in coins {
            let (address, module, struct_name) = (coin.address.unwrap(), coin.module.unwrap(), coin.r#struct.unwrap());
            let move_struct_tag_str = format!("{}::{}::{}", address, module, struct_name);
            let coin_info = get_coin_info(move_struct_tag_str, &self.network).await;
            match coin_info {
                Ok(coin_info) => {
                    let CoinInfo { name, symbol, decimals } = coin_info;
                    sqlx::query_file!(
                        "sqlx_queries/coins/insert_coin.sql",
                        name, symbol, decimals, address, module, struct_name
                    )
                    .execute(&self.pool)
                    .await
                    .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
                },
                Err(GetCoinInfoError::RateLimited) => {tracing::warn!("Got rate limited by Aptos API.");},
                Err(GetCoinInfoError::Other(e)) => {tracing::error!("{e}");},
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

impl GetCoinInfoError {
    pub fn invalid_response() -> Self {
        GetCoinInfoError::Other(anyhow!("Invalid response."))
    }
}

fn map_other<T: Into<anyhow::Error>>(t: T) -> GetCoinInfoError {
    GetCoinInfoError::Other(anyhow!(t))
}

async fn get_coin_info(move_struct_tag_str: impl Into<String>, network: &AptosBaseUrl) -> Result<CoinInfo, GetCoinInfoError> {
    let move_struct_tag_str: String = move_struct_tag_str.into();
    let client = Client::new(network.to_url());
    let ad = move_struct_tag_str.split("::").collect::<Vec<_>>()[0];
    let ad = AccountAddress::from_str_strict(ad).map_err(|e| GetCoinInfoError::Other(anyhow!(e)))?;
    let res = client.get_account_resource(ad, &format!("0x1::coin::CoinInfo<{}>", move_struct_tag_str)).await;
    let res = res.map_err(|e| match e {
        aptos_sdk::rest_client::error::RestError::Http(reqwest::StatusCode::TOO_MANY_REQUESTS, _) => { GetCoinInfoError::RateLimited }
        x => GetCoinInfoError::Other(anyhow!(x))
    })?;
    let x = res.into_inner().ok_or(GetCoinInfoError::Other(anyhow!("Could not find resource.")))?;
    let r = CoinInfo {
        name: x.data
            .as_object()
            .ok_or(GetCoinInfoError::invalid_response())?
            .get("name")
            .ok_or(GetCoinInfoError::invalid_response())?
            .as_str()
            .ok_or(GetCoinInfoError::invalid_response())?
            .to_string(),
        symbol: x.data
            .as_object()
            .ok_or(GetCoinInfoError::invalid_response())?
            .get("symbol")
            .ok_or(GetCoinInfoError::invalid_response())?
            .as_str()
            .ok_or(GetCoinInfoError::invalid_response())?
            .to_string(),
        decimals: x.data
            .as_object()
            .ok_or(GetCoinInfoError::invalid_response())?
            .get("decimals")
            .ok_or(GetCoinInfoError::invalid_response())?
            .as_i64()
            .ok_or(GetCoinInfoError::invalid_response())? as i16,
    };
    Ok(r)
}
