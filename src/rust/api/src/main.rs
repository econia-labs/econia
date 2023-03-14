use std::net::SocketAddr;

use axum::{extract::State, routing::get, Json, Router};
use db::models::Market;
use serde::Deserialize;
use sqlx::{PgPool, Pool, Postgres};
use tower_http::trace::TraceLayer;
use tracing_subscriber::prelude::*;

#[derive(Deserialize, Debug)]
pub struct Config {
    port: u16,
    database_url: String,
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

    let app = Router::new()
        .route("/", get(index))
        .route("/markets", get(markets))
        .with_state(pool)
        .layer(TraceLayer::new_for_http());

    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));

    tracing::info!("Listening on http://{}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service_with_connect_info::<SocketAddr>())
        .await
        .unwrap();
}

fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

async fn index() -> String {
    String::from("Econia backend API")
}

async fn markets(State(pool): State<Pool<Postgres>>) -> Json<Vec<Market>> {
    let markets: Vec<Market> = sqlx::query_as!(Market, r"select * from markets")
        .fetch_all(&pool)
        .await
        .unwrap();
    Json(markets)
}
