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
            base_account_address,
            base.name as base_name,
            base.symbol as base_symbol,
            base.decimals as base_decimals,
            base_module_name,
            base_struct_name,
            base_name_generic,
            quote.name as quote_name,
            quote.symbol as quote_symbol,
            quote.decimals as quote_decimals,
            quote_account_address,
            quote_module_name,
            quote_struct_name,
            lot_size,
            tick_size,
            min_size,
            underwriter_id,
            created_at
        from markets
            join coins base on markets.base_account_address = base.account_address
                                and markets.base_module_name = base.module_name
                                and markets.base_struct_name = base.struct_name
            join coins quote on markets.quote_account_address = quote.account_address
                                and markets.quote_module_name = quote.module_name
                                and markets.quote_struct_name = quote.struct_name;
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
