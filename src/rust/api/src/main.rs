use std::{collections::HashSet, net::SocketAddr};

use bigdecimal::ToPrimitive;
use futures_util::StreamExt;
use serde::Deserialize;
use sqlx::{PgPool, Pool, Postgres};
use tokio::sync::broadcast;
use tracing_subscriber::prelude::*;
use types::message::Update;

use crate::routes::router;

mod error;
mod routes;
mod ws;

#[derive(Deserialize, Debug)]
pub struct Config {
    port: u16,
    database_url: String,
    redis_url: String,
}

#[derive(Debug, Clone)]
pub struct AppState {
    pub pool: Pool<Postgres>,
    pub sender: broadcast::Sender<Update>,
    pub market_ids: HashSet<u64>,
}

pub fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

#[tokio::main]
async fn main() {
    let config = load_config();

    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "api=debug,sqlx=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let pool = PgPool::connect(&config.database_url)
        .await
        .expect("Could not connect to DATABASE_URL");

    let market_ids = get_market_ids(pool.clone()).await;
    if market_ids.is_empty() {
        tracing::warn!("no markets registered in database");
    }

    let (btx, brx) = broadcast::channel(16);
    let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

    let state = AppState {
        pool,
        sender: btx,
        market_ids: HashSet::from_iter(market_ids.into_iter()),
    };
    let app = router(state);
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));

    tokio::spawn(async move {
        log_redis_messages(brx).await;
    });

    tracing::info!("Listening on http://{}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service_with_connect_info::<SocketAddr>())
        .await
        .unwrap();
}

async fn get_market_ids(pool: Pool<Postgres>) -> Vec<u64> {
    sqlx::query_as!(
        types::query::MarketIdQuery,
        r#"select market_id from markets;"#
    )
    .fetch_all(&pool)
    .await
    .unwrap()
    .into_iter()
    .map(|v| v.market_id.to_u64().unwrap())
    .collect::<Vec<u64>>()
}

async fn start_redis_channels(
    redis_url: String,
    market_ids: Vec<u64>,
    tx: broadcast::Sender<Update>,
) -> redis::aio::MultiplexedConnection {
    let client = redis::Client::open(redis_url).expect("could not start redis client");
    let conn = client
        .get_multiplexed_tokio_connection()
        .await
        .expect("could not connect to redis");

    let pubsub_conn = client.get_async_connection().await.unwrap();

    let mut pubsub = pubsub_conn.into_pubsub();

    for market_id in market_ids {
        // TODO add more channels
        let channels = vec!["orders", "fills"];
        for channel in channels {
            // Note: support for pubsub over a multiplexed connection should be coming soon.
            let pubsub_ch = format!("{}:{}", channel, market_id);
            pubsub.subscribe(pubsub_ch.as_str()).await.unwrap();

            tracing::info!("subscribed to channel `{}` on redis", pubsub_ch.as_str());
        }
    }

    tokio::spawn(async move {
        let mut stream = pubsub.on_message();

        while let Some(msg) = stream.next().await {
            let payload = msg.get_payload::<String>().unwrap();
            let update: Update = serde_json::from_str(&payload).unwrap();
            tx.send(update).unwrap();
        }
    });

    conn
}

async fn log_redis_messages(mut rx: broadcast::Receiver<Update>) {
    while let Ok(msg) = rx.recv().await {
        let s = serde_json::to_string(&msg).unwrap();
        tracing::info!("received message from redis: {}", s);
    }
}

#[cfg(test)]
pub mod tests {
    use std::{
        collections::HashSet,
        net::{SocketAddr, TcpListener},
    };

    use axum::extract::connect_info::MockConnectInfo;
    use sqlx::PgPool;
    use tokio::sync::broadcast;

    use super::*;

    pub async fn spawn_server(config: Config) -> SocketAddr {
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3000))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });
        addr
    }
    pub fn return_two() -> usize {
        2
    }
}
