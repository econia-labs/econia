use axum::{
    extract::{Path, State},
    Json,
};
use types::error::TypeError;

use crate::{error::ApiError, AppState};

pub async fn order_history_by_account(
    Path(account_address): Path<String>,
    State(state): State<AppState>,
) -> Result<Json<Vec<types::order::Order>>, ApiError> {
    let order_history = state
        .econia_db
        .get_order_history_by_account(&account_address)
        .await
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::order::Order>, TypeError>>()?;

    if order_history.is_empty() {
        return Err(ApiError::NotFound);
    }

    Ok(Json(order_history))
}

pub async fn open_orders_by_account(
    Path(account_address): Path<String>,
    State(state): State<AppState>,
) -> Result<Json<Vec<types::order::Order>>, ApiError> {
    let open_orders = state
        .econia_db
        .get_open_orders_by_account(&account_address)
        .await
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::order::Order>, TypeError>>()?;

    if open_orders.is_empty() {
        return Err(ApiError::NotFound);
    }

    Ok(Json(open_orders))
}

#[cfg(test)]
mod tests {
    use axum::{
        body::Body,
        http::{Request, StatusCode},
    };
    use tower::ServiceExt;

    use crate::{load_config, tests::make_test_server};

    /// Test that the order history by accoutn endpoint returns order history
    /// for the specified user.
    ///
    /// This test sends a GET request to the `/accounts/{account_id}/order-history`
    /// endpoint with the `account_id` parameter set to `0x123`. The response is
    /// then checked to ensure that it has a `200 OK` status code, and the
    /// response body is checked to ensure that it is a JSON response in the
    /// correct format.
    #[tokio::test]
    async fn test_order_history_by_account() {
        let account_id = "0x123";
        let config = load_config();
        let app = make_test_server(config).await;

        let response = app
            .oneshot(
                Request::builder()
                    .uri(format!("/account/{}/order-history", account_id))
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
        let res = serde_json::from_slice::<Vec<types::order::Order>>(&body);
        assert!(res.is_ok());
    }

    #[tokio::test]
    async fn test_open_orders_by_account() {
        let account_id = "0x123";
        let config = load_config();
        let app = make_test_server(config).await;

        let response = app
            .oneshot(
                Request::builder()
                    .uri(format!("/account/{}/open-orders", account_id))
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = hyper::body::to_bytes(response.into_body()).await.unwrap();
        let res = serde_json::from_slice::<Vec<types::order::Order>>(&body);
        assert!(res.is_ok());
    }
}
