use axum::{extract::State, Json};
use sqlx::{Pool, Postgres};
use types::error::TypeError;

use crate::error::ApiError;

pub async fn index() -> String {
    String::from("Econia backend API")
}

pub async fn markets(
    State(pool): State<Pool<Postgres>>,
) -> Result<Json<Vec<types::Market>>, ApiError> {
    let query_markets = sqlx::query_as!(
        types::QueryMarket,
        r#"
        select 
            market_id,
            base_coins.symbol as base_symbol,
            base_coins.name as base_name,
            base_coins.decimals as base_decimals,
            base_coins.account_address as base_account_address,
            base_coins.module_name as base_module_name,
            base_coins.struct_name as base_struct_name,
            quote_coins.symbol as quote_symbol,
            quote_coins.name as quote_name,
            quote_coins.decimals as quote_decimals,
            quote_coins.account_address as quote_account_address,
            quote_coins.module_name as quote_module_name,
            quote_coins.struct_name as quote_struct_name,
            base_name_generic,
            lot_size,
            tick_size,
            min_size,
            underwriter_id,
            created_at
        from markets
            join coins base_coins on markets.base_id = base_coins.id
            join coins quote_coins on markets.quote_id = quote_coins.id
        "#
    )
    .fetch_all(&pool)
    .await?;

    let markets = query_markets
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::Market>, TypeError>>()?;

    Ok(Json(markets))
}

#[cfg(test)]
mod tests {
    use axum::{
        body::Body,
        http::{Request, StatusCode},
        routing::get,
        Router,
    };
    use sqlx::PgPool;
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

        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let app = Router::new()
            .route("/markets", get(markets))
            .with_state(pool);

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
