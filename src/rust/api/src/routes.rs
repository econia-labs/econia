use std::sync::Arc;

use axum::{routing::get, Router};
use tower::ServiceBuilder;
use tower_http::{
    compression::CompressionLayer,
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};

use crate::{ws::ws_handler, AppState};

mod account;
mod market;

pub fn router(state: Arc<AppState>) -> Router {
    let cors_layer = CorsLayer::new()
        .allow_methods(Any)
        .allow_headers(Any)
        .allow_origin(Any);

    let middleware_stack = ServiceBuilder::new()
        .layer(CompressionLayer::new())
        .layer(TraceLayer::new_for_http())
        .layer(cors_layer);

    Router::new()
        .route("/", get(index))
        .route("/markets", get(market::get_markets))
        .route("/market/:market_id", get(market::get_market_by_id))
        .route("/stats", get(market::get_stats))
        .route("/market/:market_id/stats", get(market::get_stats_by_id))
        .route(
            "/account/:account_address/order-history",
            get(account::order_history_by_account),
        )
        .route(
            "/account/:account_address/open-orders",
            get(account::open_orders_by_account),
        )
        .route("/market/:market_id/orderbook", get(market::get_orderbook))
        .route(
            "/market/:market_id/history",
            get(market::get_market_history),
        )
        .route("/market/:market_id/fills", get(market::get_fills))
        .route("/ws", get(ws_handler))
        .with_state(state)
        .layer(middleware_stack)
}

async fn index() -> String {
    String::from("Econia backend API")
}

#[cfg(test)]
mod tests {
    use axum::{
        body::Body,
        http::{Request, StatusCode},
        routing::get,
        Router,
    };
    use tower::ServiceExt;

    use super::*;

    #[tokio::test]
    async fn test_index() {
        let app = Router::new().route("/", get(index));

        let response = app
            .oneshot(Request::builder().uri("/").body(Body::empty()).unwrap())
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
        assert_eq!(&body[..], b"Econia backend API");
    }
}
