use std::net::SocketAddr;

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
                .unwrap_or_else(|_| "api=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let pool = PgPool::connect(&config.database_url)
        .await
        .expect("Could not connect to DATABASE_URL");

    let (btx, brx) = broadcast::channel(16);
    let _conn = start_redis_channels(config.redis_url, btx.clone()).await;

    let state = AppState { pool, sender: btx };
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

async fn start_redis_channels(
    redis_url: String,
    tx: broadcast::Sender<Update>,
) -> redis::aio::MultiplexedConnection {
    let client = redis::Client::open(redis_url).expect("could not start redis client");
    let conn = client
        .get_multiplexed_tokio_connection()
        .await
        .expect("could not connect to redis");

    // TODO iterate over every channel
    tokio::spawn(async move {
        let pubsub_conn = client.get_async_connection().await.unwrap();

        let mut pubsub = pubsub_conn.into_pubsub();
        pubsub.subscribe("orders").await.unwrap();

        tracing::info!("subscribed to channel `orders` on redis");

        let mut stream = pubsub.on_message();

        while let Some(msg) = stream.next().await {
            let payload = msg.get_payload::<String>().unwrap();
            tracing::info!("received message from redis");
            tracing::info!("{}", payload);

            let update: Update = serde_json::from_str(&payload).unwrap();
            tracing::info!("{:?}", update);

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
