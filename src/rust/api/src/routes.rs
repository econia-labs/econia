use std::iter::zip;

use axum::{extract::State, routing::get, Json, Router};
use bigdecimal::ToPrimitive;
use tower::ServiceBuilder;
use tower_http::{
    compression::CompressionLayer,
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};
use types::error::TypeError;

use crate::{error::ApiError, ws::ws_handler, AppState};

mod account;
mod market;

pub fn router(state: AppState) -> Router {
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
        .route("/markets", get(markets))
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

async fn markets(State(state): State<AppState>) -> Result<Json<Vec<types::Market>>, ApiError> {
    let mut conn = state.econia_db.get().await?;
    let quote_markets = {
        use db::schema::markets::dsl::*;
        use diesel::prelude::*;
        use diesel_async::RunQueryDsl;

        markets
            .inner_join(
                db::schema::coins::table.on(quote_account_address
                    .eq(db::schema::coins::account_address)
                    .and(quote_module_name.eq(db::schema::coins::module_name))
                    .and(quote_struct_name.eq(db::schema::coins::struct_name))),
            )
            .load::<(db::models::market::Market, db::models::coin::Coin)>(&mut conn)
            .await
            .unwrap()
    };

    let base_markets = {
        use db::schema::markets::dsl::*;
        use diesel::prelude::*;
        use diesel_async::RunQueryDsl;

        markets
            .left_join(
                db::schema::coins::table.on(base_account_address
                    .eq(db::schema::coins::account_address.nullable())
                    .and(base_module_name.eq(db::schema::coins::module_name.nullable()))
                    .and(base_struct_name.eq(db::schema::coins::struct_name.nullable()))),
            )
            .load::<(db::models::market::Market, Option<db::models::coin::Coin>)>(&mut conn)
            .await
            .unwrap()
    };

    let markets = zip(quote_markets.into_iter(), base_markets.into_iter())
        .map(|((market, quote), (_, base))| {
            let market =
                types::Market {
                    market_id: market.market_id.to_u64().ok_or_else(|| {
                        TypeError::ConversionError {
                            name: "market_id".to_string(),
                        }
                    })?,
                    base: base.map(|b| b.into()),
                    base_name_generic: market.base_name_generic,
                    quote: quote.into(),
                    lot_size: market.lot_size.to_u64().ok_or_else(|| {
                        TypeError::ConversionError {
                            name: "lot_size".to_string(),
                        }
                    })?,
                    tick_size: market.tick_size.to_u64().ok_or_else(|| {
                        TypeError::ConversionError {
                            name: "tick_size".to_string(),
                        }
                    })?,
                    min_size: market.min_size.to_u64().ok_or_else(|| {
                        TypeError::ConversionError {
                            name: "min_size".to_string(),
                        }
                    })?,
                    underwriter_id: market.underwriter_id.to_u64().ok_or_else(|| {
                        TypeError::ConversionError {
                            name: "underwriter_id".to_string(),
                        }
                    })?,
                    created_at: market.created_at,
                };
            Ok::<types::Market, TypeError>(market)
        })
        .collect::<Result<Vec<_>, TypeError>>()?;

    Ok(Json(markets))
}

#[cfg(test)]
mod tests {
    use std::collections::HashSet;

    use axum::{
        body::Body,
        http::{Request, StatusCode},
        routing::get,
        Router,
    };
    use db::EconiaDbClient;
    use tokio::sync::broadcast;
    use tower::ServiceExt;

    use super::*;
    use crate::load_config;

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

    #[tokio::test]
    async fn test_markets() {
        let config = load_config();
        let econia_db = EconiaDbClient::connect(db::Config {
            database_url: config.database_url,
        })
        .await;

        let (tx, _) = broadcast::channel(16);

        let state = AppState {
            econia_db,
            sender: tx,
            market_ids: HashSet::new(),
        };

        let app = Router::new()
            .route("/markets", get(markets))
            .with_state(state);

        let response = app
            .oneshot(
                Request::builder()
                    .uri("/markets")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
        let s = String::from_utf8(body.to_vec()).unwrap();
        let result: Result<Vec<types::Market>, serde_json::Error> =
            serde_json::from_str(s.as_str());

        assert!(result.is_ok());
    }
}
