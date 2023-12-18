use std::{
    str::FromStr,
    sync::Arc,
    time::{Duration, SystemTime},
};

use aggregator::Pipeline;
use anyhow::{anyhow, Result};
use aptos_sdk::rest_client::AptosBaseUrl;
use clap::{Parser, ValueEnum};
use pipelines::{Candlesticks, Coins, Leaderboards, OrderHistory, RefreshMaterializedView, RollingVolume, UserHistory};
use sqlx::Executor;
use sqlx_postgres::PgPoolOptions;
use tokio::{sync::Mutex, task::JoinSet};
use url::Url;

mod dbtypes;
mod pipelines;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// If set, no pipeline will be included by default.
    #[arg(short, long)]
    no_default: bool,

    /// Exclusion list. Pipelines specified here will not be executed. Ignored if --no-default passed.
    #[arg(short, long)]
    exclude: Option<Vec<Pipelines>>,

    /// Inclusion list. Pipelines specified here will be executed. Ignored if --no-default is not passed.
    #[arg(short, long, value_enum)]
    include: Option<Vec<Pipelines>>,

    /// Database URL.
    #[arg(short, long)]
    database_url: Option<String>,

    /// Aptos network.
    #[arg(short, long)]
    aptos_network: Option<AptosNetwork>,
}

#[derive(Clone, Debug, PartialEq, ValueEnum)]
pub enum Pipelines {
    Candlesticks,
    Coins,
    Leaderboards,
    Market24hData,
    OrderHistory,
    RollingVolume,
    UserHistory,
}

#[derive(Clone, Debug, PartialEq)]
pub enum AptosNetwork {
    Mainnet,
    Testnet,
    Devnet,
    Custom(String),
}

impl FromStr for AptosNetwork {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let network = match s {
            "mainnet" => Self::Mainnet,
            "testnet" => Self::Testnet,
            "devnet" => Self::Devnet,
            _ => {
                if s.to_string().starts_with("custom(") && s.to_string().ends_with(')') {
                    Self::Custom(s["custom(".len()..s.len() - ")".len()].to_string())
                } else {
                    return Err(anyhow!("Invalid Aptos Network"));
                }
            }
        };
        Ok(network)
    }
}

struct EnvConfig {
    pipelines: Option<Vec<Pipelines>>,
    database_url: Option<String>,
    aptos_network: Option<AptosNetwork>,
}

impl EnvConfig {
    pub fn new() -> Self {
        EnvConfig {
            pipelines: std::env::var("PIPELINES")
                .ok()
                .map(|s|
                    s.split(',')
                        .map(|s|
                            ValueEnum::from_str(s, true)
                                .unwrap_or_else(|_| {
                                    tracing::error!("Invalid pipeline.");
                                    panic!()
                                })
                        )
                        .collect()
                ),
            database_url: std::env::var("DATABASE_URL").ok(),
            aptos_network: std::env::var("APTOS_NETWORK").ok().map(|s|
                AptosNetwork::from_str(&s).unwrap_or_else(|_| {
                    tracing::error!("Invalid Aptos network.");
                    panic!()
                })
            )
        }
    }
}

impl AptosNetwork {
    pub fn to_base_url(&self) -> AptosBaseUrl {
        match self {
            Self::Mainnet => AptosBaseUrl::Mainnet,
            Self::Testnet => AptosBaseUrl::Testnet,
            Self::Devnet => AptosBaseUrl::Devnet,
            Self::Custom(s) => AptosBaseUrl::Custom(Url::parse(&s).unwrap_or_else(|_| {
                tracing::error!("Invalid custom Aptos network url.");
                panic!()
            })),
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();
    tracing::info!("Started up.");

    dotenvy::dotenv().ok();

    let args: Args = Args::parse();
    let env_config: EnvConfig = EnvConfig::new();

    let network = env_config.aptos_network.unwrap_or_else(|| args.aptos_network.unwrap_or_else(|| {
        tracing::warn!("APTOS_NETWORK is not set. Using AptosNetwork::Testnet by default.");
        AptosNetwork::Testnet
    }));

    let database_url = env_config.database_url.unwrap_or_else(|| {
        args.database_url.unwrap_or_else(|| {
            tracing::error!("DATABASE_URL is not set.");
            panic!();
        })
    });

    let pipelines = env_config.pipelines.unwrap_or_else(|| {
        if args.no_default {
            (args
                .include
                .unwrap_or_else(|| {
                    tracing::error!("No pipelines are included and --no-default is set.");
                    panic!();
                }))
            .clone()
        } else {
            let mut x = vec![
                Pipelines::Candlesticks,
                Pipelines::Coins,
                Pipelines::Market24hData,
                Pipelines::UserHistory,
            ];
            let exclude = args.exclude.unwrap_or(vec![]);
            x = x.into_iter().filter(|a| !exclude.contains(a)).collect();
            x.append(&mut args.include.unwrap_or(vec![]));
            x
        }
    });

    tracing::info!("Using pipelines {pipelines:?}.");
    tracing::info!("Using network {network:?}.");

    let pool = PgPoolOptions::new()
        .after_connect(|conn, _| {
            Box::pin(async move {
                conn.execute("SET default_transaction_isolation TO 'repeatable read'")
                    .await?;
                Ok(())
            })
        })
        .connect(&database_url)
        .await?;

    tracing::info!("Connected to DB.");

    let default_interval = Duration::from_secs(5);

    let mut data: Vec<Arc<Mutex<dyn Pipeline + Send + Sync>>> = vec![];

    for pipeline in pipelines {
        match pipeline {
            Pipelines::Candlesticks => {
                data.push(Arc::new(Mutex::new(Candlesticks::new(pool.clone(), 60))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 5,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 15,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 30,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 60,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 60 * 4,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 60 * 12,
                ))));
                data.push(Arc::new(Mutex::new(Candlesticks::new(
                    pool.clone(),
                    60 * 60 * 24,
                ))));
            }
            Pipelines::Coins => {
                data.push(Arc::new(Mutex::new(Coins::new(
                    pool.clone(),
                    network.to_base_url(),
                ))));
            }
            Pipelines::Leaderboards => {
                data.push(Arc::new(Mutex::new(Leaderboards::new(pool.clone()))));
            }
            Pipelines::Market24hData => {
                data.push(Arc::new(Mutex::new(RefreshMaterializedView::new(
                    pool.clone(),
                    "aggregator.markets_24h_data",
                    Duration::from_secs(5 * 60),
                ))))
            }
            Pipelines::OrderHistory => data.push(Arc::new(Mutex::new(OrderHistory::new(pool.clone())))),
            Pipelines::RollingVolume => data.push(Arc::new(Mutex::new(RollingVolume::new(pool.clone())))),
            Pipelines::UserHistory => {
                data.push(Arc::new(Mutex::new(UserHistory::new(pool.clone()))));
            }
        }
    }

    let mut handles = JoinSet::new();

    for data in data {
        handles.spawn(async move {
            let mut data = data.lock().await;

            tracing::info!(
                "[{}] Starting process & saving (historical).",
                data.model_name()
            );
            let start = SystemTime::now();
            data.process_and_save_historical_data().await?;
            let time = start
                .elapsed()
                .unwrap_or(Duration::from_secs(0))
                .as_millis();
            tracing::info!(
                "[{}] Finished process & saving in {}ms (historical).",
                data.model_name(),
                time
            );

            loop {
                let interval = data.poll_interval().unwrap_or(default_interval);

                tokio::time::sleep(interval).await;

                if data.ready() {
                    tracing::info!("[{}] Starting process & saving.", data.model_name());
                    let start = SystemTime::now();
                    data.process_and_save().await?;
                    let time = start
                        .elapsed()
                        .unwrap_or(Duration::from_secs(0))
                        .as_millis();
                    tracing::info!(
                        "[{}] Finished process & saving in {}ms.",
                        data.model_name(),
                        time
                    );
                } else {
                    tracing::info!("[{}] Data is not ready.", data.model_name());
                }
            }

            #[allow(unreachable_code)]
            Ok::<(), anyhow::Error>(())
        });
    }

    while let Some(res) = handles.join_next().await {
        res??;
    }

    Ok(())
}
