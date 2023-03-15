use std::net::SocketAddr;

use axum::{routing::get, Router};
use serde::Deserialize;
use sqlx::{PgPool};
use tower_http::trace::TraceLayer;
use tracing_subscriber::prelude::*;

mod error;
mod routes;

#[derive(Deserialize, Debug)]
pub struct Config {
    port: u16,
    database_url: String,
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

    let app = Router::new()
        .route("/", get(routes::index))
        .route("/markets", get(routes::markets))
        .with_state(pool)
        .layer(TraceLayer::new_for_http());

    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));

    tracing::info!("Listening on http://{}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service_with_connect_info::<SocketAddr>())
        .await
        .unwrap();
}
