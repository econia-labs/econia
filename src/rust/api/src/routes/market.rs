use axum::{
    extract::{Path, Query, State},
    Json,
};
use bigdecimal::BigDecimal;
use chrono::{DateTime, NaiveDateTime, Utc};
use db::models::order::Side;
use serde::{Deserialize, Serialize};
use types::{bar::Resolution, book::PriceLevel, error::TypeError};

use crate::{error::ApiError, AppState};

/// Query parameters for the orderbook endpoint.
#[derive(Debug, Deserialize)]
pub struct OrderbookParams {
    depth: i64,
}

#[derive(Debug, Serialize)]
pub struct OrderbookResponse {
    bids: Vec<PriceLevel>,
    asks: Vec<PriceLevel>,
}

pub async fn get_orderbook(
    Path(market_id): Path<u64>,
    Query(params): Query<OrderbookParams>,
    State(state): State<AppState>,
) -> Result<Json<OrderbookResponse>, ApiError> {
    if params.depth < 1 {
        return Err(ApiError::InvalidDepth);
    }

    let market_id = BigDecimal::from(market_id);

    let bids = state
        .econia_db
        .get_order_book_price_levels(&market_id, Side::Bid, params.depth)
        .await?
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<PriceLevel>, TypeError>>()?;

    let asks = state
        .econia_db
        .get_order_book_price_levels(&market_id, Side::Ask, params.depth)
        .await?
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<PriceLevel>, TypeError>>()?;

    Ok(Json(OrderbookResponse { bids, asks }))
}

/// Query parameters for the market history endpoint.
#[derive(Debug, Deserialize)]
pub struct MarketHistoryParams {
    /// The resolution of the requested historical data.
    resolution: Resolution,
    /// Unix timestamp (in seconds) for the start of the requested time range.
    from: i64,
    /// Unix timestamp (in seconds) for the end of the requested time range.
    to: i64,
}

pub async fn get_market_history(
    Path(market_id): Path<u64>,
    Query(params): Query<MarketHistoryParams>,
    State(state): State<AppState>,
) -> Result<Json<Vec<types::bar::Bar>>, ApiError> {
    if params.from > params.to {
        return Err(ApiError::InvalidTimeRange);
    }
    let market_id = BigDecimal::from(market_id);

    let from_naive =
        NaiveDateTime::from_timestamp_opt(params.from, 0).ok_or(ApiError::InvalidTimeRange)?;
    let to_naive =
        NaiveDateTime::from_timestamp_opt(params.to, 0).ok_or(ApiError::InvalidTimeRange)?;

    let from = DateTime::<Utc>::from_utc(from_naive, Utc);
    let to = DateTime::<Utc>::from_utc(to_naive, Utc);

    tracing::debug!("querying range {} to {}", from, to);

    let market_history = state
        .econia_db
        .get_market_history(params.resolution, &market_id, from, to)
        .await?
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::bar::Bar>, TypeError>>()?;

    Ok(Json(market_history))
}

/// Query parameters for the fills endpoint.
#[derive(Debug, Deserialize)]
pub struct FillsParams {
    /// Unix timestamp (in seconds) for the start of the requested time range.
    from: i64,
    /// Unix timestamp (in seconds) for the end of the requested time range.
    to: i64,
}

pub async fn get_fills(
    Path(market_id): Path<u64>,
    Query(params): Query<FillsParams>,
    State(state): State<AppState>,
) -> Result<Json<Vec<types::order::Fill>>, ApiError> {
    if params.from > params.to {
        return Err(ApiError::InvalidTimeRange);
    }
    let market_id = BigDecimal::from(market_id);

    let from_naive =
        NaiveDateTime::from_timestamp_opt(params.from, 0).ok_or(ApiError::InvalidTimeRange)?;
    let to_naive =
        NaiveDateTime::from_timestamp_opt(params.to, 0).ok_or(ApiError::InvalidTimeRange)?;

    let from = DateTime::<Utc>::from_utc(from_naive, Utc);
    let to = DateTime::<Utc>::from_utc(to_naive, Utc);

    tracing::debug!("querying range {} to {}", from, to);

    let fills = state
        .econia_db
        .get_fills(&market_id, from, to)
        .await?
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::order::Fill>, TypeError>>()?;

    Ok(Json(fills))
}

// #[cfg(test)]
// mod tests {
//     use std::collections::HashSet;

//     use axum::{
//         body::Body,
//         http::{Request, StatusCode},
//     };
//     use chrono::TimeZone;
//     use tokio::sync::broadcast;
//     use tower::ServiceExt;

//     use super::*;
//     use crate::{load_config, routes::router, start_redis_channels, tests::make_test_server};

//     /// The `TestOnlyOrderbookResponse` struct is defined in the test module,
//     /// since the struct used as the response type in the API does not need
//     /// the `Deserialize` trait.
//     #[allow(dead_code)]
//     #[derive(Deserialize)]
//     struct TestOnlyOrderbookResponse {
//         bids: Vec<PriceLevel>,
//         asks: Vec<PriceLevel>,
//     }

//     /// Test that the market history endpoint returns market data with a
//     /// resolution of 1 minute.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/history`
//     /// endpoint with the `resolution` parameter set to `1h`. The response is
//     /// then checked to ensure that it has a `200 OK` status code, and the
//     /// response body is checked to ensure that it is a JSON response in the
//     /// correct format.
//     #[tokio::test]
//     async fn test_get_market_history_1m_resolution() {
//         let market_id = "0";
//         let resolution = Resolution::R1m;

//         let from = Utc
//             .with_ymd_and_hms(2023, 4, 5, 0, 0, 0)
//             .unwrap()
//             .timestamp();
//         let to = Utc
//             .with_ymd_and_hms(2023, 4, 5, 0, 10, 0)
//             .unwrap()
//             .timestamp();

//         let config = load_config();

//         let pool = PgPool::connect(&config.database_url)
//             .await
//             .expect("Could not connect to DATABASE_URL");

//         let market_ids = get_market_ids(pool.clone()).await;
//         if market_ids.is_empty() {
//             tracing::warn!("no markets registered in database");
//         }

//         let (btx, _brx) = broadcast::channel(16);
//         let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

//         let state = AppState {
//             pool,
//             sender: btx,
//             market_ids: HashSet::from_iter(market_ids.into_iter()),
//         };
//         let app = router(state);

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!(
//                         "/market/{}/history?resolution={}&from={}&to={}",
//                         market_id, resolution, from, to
//                     ))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::OK);

//         let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
//         let res = serde_json::from_slice::<Vec<types::bar::Bar>>(&body);
//         assert!(res.is_ok());

//         let bars = res.unwrap();
//         assert_eq!(bars.len(), 10);
//     }

//     /// Test that the market history endpoint returns market data with a
//     /// resolution of 1 hour.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/history`
//     /// endpoint with the `resolution` parameter set to `1h`. The response is
//     /// then checked to ensure that it has a `200 OK` status code, and the
//     /// response body is checked to ensure that it is a JSON response in the
//     /// correct format.
//     #[tokio::test]
//     async fn test_get_market_history_1h_resolution() {
//         let market_id = "0";
//         let resolution = Resolution::R1h;

//         let from = Utc
//             .with_ymd_and_hms(2023, 4, 5, 0, 0, 0)
//             .unwrap()
//             .timestamp();
//         let to = Utc
//             .with_ymd_and_hms(2023, 4, 5, 1, 0, 0)
//             .unwrap()
//             .timestamp();

//         let config = load_config();

//         let pool = PgPool::connect(&config.database_url)
//             .await
//             .expect("Could not connect to DATABASE_URL");

//         let market_ids = get_market_ids(pool.clone()).await;
//         if market_ids.is_empty() {
//             tracing::warn!("no markets registered in database");
//         }

//         let (btx, _brx) = broadcast::channel(16);
//         let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

//         let state = AppState {
//             pool,
//             sender: btx,
//             market_ids: HashSet::from_iter(market_ids.into_iter()),
//         };
//         let app = router(state);

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!(
//                         "/market/{}/history?resolution={}&from={}&to={}",
//                         market_id, resolution, from, to
//                     ))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::OK);

//         let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
//         let res = serde_json::from_slice::<Vec<types::bar::Bar>>(&body);
//         assert!(res.is_ok());

//         let bars = res.unwrap();
//         assert_eq!(bars.len(), 1);
//     }

//     /// Test that the market history endpoint returns a `400 Bad Request` error
//     /// when the resolution parameter is set to an unsupported value.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/history`
//     /// endpoint with the `resolution` parameter set to `3m`, which is not
//     /// supported by the API. The response is then checked to ensure that it
//     /// has a `400 Bad Request` status code.
//     #[tokio::test]
//     async fn test_get_market_history_invalid_resolution() {
//         let market_id = "0";

//         let from = Utc
//             .with_ymd_and_hms(2023, 4, 5, 0, 0, 0)
//             .unwrap()
//             .timestamp();
//         let to = Utc
//             .with_ymd_and_hms(2023, 4, 5, 1, 0, 0)
//             .unwrap()
//             .timestamp();

//         let config = load_config();

//         let pool = PgPool::connect(&config.database_url)
//             .await
//             .expect("Could not connect to DATABASE_URL");

//         let market_ids = get_market_ids(pool.clone()).await;
//         if market_ids.is_empty() {
//             tracing::warn!("no markets registered in database");
//         }

//         let (btx, _brx) = broadcast::channel(16);
//         let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

//         let state = AppState {
//             pool,
//             sender: btx,
//             market_ids: HashSet::from_iter(market_ids.into_iter()),
//         };
//         let app = router(state);

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!(
//                         "/market/{}/history?resolution=3m&from={}&to={}",
//                         market_id, from, to
//                     ))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::BAD_REQUEST);
//     }

//     /// Test that the market history endpoint returns a `400 Bad Request` error
//     /// when the `to` timestamp comes before the `from` timestamp.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/history`
//     /// endpoint with the `resolution` parameter set to `1m`, and with the `to`
//     /// timestamp set to a value that is before the `from` timestamp. The
//     /// response is then checked to ensure that it has a `400 Bad Request`
//     /// status code.
//     #[tokio::test]
//     async fn test_get_market_history_to_before_from() {
//         let market_id = "0";
//         let resolution = Resolution::R1m;

//         let from = Utc
//             .with_ymd_and_hms(2023, 4, 6, 0, 0, 0)
//             .unwrap()
//             .timestamp();
//         let to = Utc
//             .with_ymd_and_hms(2023, 4, 5, 0, 0, 0)
//             .unwrap()
//             .timestamp();

//         let config = load_config();

//         let pool = PgPool::connect(&config.database_url)
//             .await
//             .expect("Could not connect to DATABASE_URL");

//         let market_ids = get_market_ids(pool.clone()).await;
//         if market_ids.is_empty() {
//             tracing::warn!("no markets registered in database");
//         }

//         let (btx, _brx) = broadcast::channel(16);
//         let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

//         let state = AppState {
//             pool,
//             sender: btx,
//             market_ids: HashSet::from_iter(market_ids.into_iter()),
//         };
//         let app = router(state);

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!(
//                         "/market/{}/history?resolution={}&from={}&to={}",
//                         market_id, resolution, from, to
//                     ))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::BAD_REQUEST);
//     }

//     /// Test that the orderbook endpoint returns L1 market data when a request
//     /// with depth set to 1 is sent. Only the best bid and ask prices and the
//     /// size available at those prices should be returned.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/orderbook`
//     /// endpoint with the `depth` parameter set to `1`. The response is
//     /// then checked to ensure that it has a `200 OK` status code, and the
//     /// response body is checked to ensure that it is a JSON response in the
//     /// correct format.
//     #[tokio::test]
//     async fn test_get_l1_orderbook() {
//         let market_id = 0;
//         let depth = 1;

//         let config = load_config();
//         let app = make_test_server(config).await;

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!("/market/{}/orderbook?depth={}", market_id, depth))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::OK);

//         let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
//         let res = serde_json::from_slice::<TestOnlyOrderbookResponse>(&body);
//         assert!(res.is_ok());

//         let book_data = res.unwrap();
//         assert_eq!(book_data.bids.len(), 1);
//         assert_eq!(book_data.asks.len(), 1);
//     }

//     /// Test that the orderbook endpoint returns L2 market data when a request
//     /// with depth set to 10 is sent.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/orderbook`
//     /// endpoint with the `depth` parameter set to `10`. The response is
//     /// then checked to ensure that it has a `200 OK` status code, and the
//     /// response body is checked to ensure that it is a JSON response in the
//     /// correct format.
//     #[tokio::test]
//     async fn test_get_l2_orderbook() {
//         let market_id = 0;
//         let depth = 10;

//         let config = load_config();
//         let app = make_test_server(config).await;

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!("/market/{}/orderbook?depth={}", market_id, depth))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::OK);

//         let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
//         let res = serde_json::from_slice::<TestOnlyOrderbookResponse>(&body);
//         assert!(res.is_ok());
//     }

//     /// Test that the orderbook endpoint returns a `400 Bad Request` error
//     /// when the depth parameter is not set.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/orderbook`
//     /// endpoint without the `depth` parameter. The response is then checked to
//     /// ensure that it has a `400 Bad Request` status code.
//     #[tokio::test]
//     async fn test_get_orderbook_no_depth_param() {
//         let market_id = 0;
//         let config = load_config();
//         let app = make_test_server(config).await;

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!("/market/{}/orderbook", market_id))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::BAD_REQUEST);
//     }

//     /// Test that the orderbook endpoint returns a `400 Bad Request` error
//     /// when the depth parameter is set to a negative number.
//     ///
//     /// This test sends a GET request to the `/market/{market_id}/orderbook`
//     /// endpoint with the `depth` parameter of `-1`. The response is then
//     /// checked to ensure that it has a `400 Bad Request` status code.
//     #[tokio::test]
//     async fn test_get_orderbook_negative_depth_param() {
//         let market_id = 0;
//         let depth = -1;

//         let config = load_config();
//         let app = make_test_server(config).await;

//         let response = app
//             .oneshot(
//                 Request::builder()
//                     .uri(format!("/market/{}/orderbook?depth={}", market_id, depth))
//                     .body(Body::empty())
//                     .unwrap(),
//             )
//             .await
//             .unwrap();

//         assert_eq!(response.status(), StatusCode::BAD_REQUEST);
//     }
// }
