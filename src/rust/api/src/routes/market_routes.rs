use axum::{
    extract::{Path, Query, State},
    Json,
};
use bigdecimal::BigDecimal;
use chrono::{DateTime, NaiveDateTime, Utc};
use serde::Deserialize;
use types::{bar::Resolution, error::TypeError};

use crate::{error::ApiError, AppState};

#[derive(Debug, Deserialize)]
pub struct MarketHistoryParams {
    resolution: Resolution,
    from: i64,
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

    // Compile time type checking not available if we dynamically compute the
    // table name, so we use pattern matching instead.
    let market_history_query = match params.resolution {
        Resolution::I1m => {
            sqlx::query_as!(
                db::models::bar::Bar,
                r#"
                select
                    market_id,
                    start_time,
                    open,
                    high,
                    low,
                    close,
                    volume
                from bars_1m where market_id = $1 and start_time >= $2 and start_time < $3;
                "#,
                market_id,
                from,
                to
            )
            .fetch_all(&state.pool)
            .await?
        }
        Resolution::I5m => {
            sqlx::query_as!(
                db::models::bar::Bar,
                r#"
                select
                    market_id,
                    start_time,
                    open,
                    high,
                    low,
                    close,
                    volume
                from bars_5m where market_id = $1 and start_time >= $2 and start_time < $3;
                "#,
                market_id,
                from,
                to
            )
            .fetch_all(&state.pool)
            .await?
        }
        Resolution::I15m => {
            sqlx::query_as!(
                db::models::bar::Bar,
                r#"
                select
                    market_id,
                    start_time,
                    open,
                    high,
                    low,
                    close,
                    volume
                from bars_15m where market_id = $1 and start_time >= $2 and start_time < $3;
                "#,
                market_id,
                from,
                to
            )
            .fetch_all(&state.pool)
            .await?
        }
    };

    if market_history_query.is_empty() {
        return Err(ApiError::NotFound);
    }

    let market_history = market_history_query
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::bar::Bar>, TypeError>>()?;

    Ok(Json(market_history))
}

#[derive(Debug, Deserialize)]
pub struct FillsParams {
    from: i64,
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

    let fills_query = sqlx::query_as!(
        db::models::fill::Fill,
        r#"
        select
            market_id,
            maker_order_id,
            maker,
            maker_side as "maker_side: db::models::order::Side",
            custodian_id,
            size,
            price,
            time
        from fills where market_id = $1 and time >= $2 and time < $3;
        "#,
        market_id,
        from,
        to
    )
    .fetch_all(&state.pool)
    .await?;

    if fills_query.is_empty() {
        return Err(ApiError::NotFound);
    }

    let fills = fills_query
        .into_iter()
        .map(|v| v.try_into())
        .collect::<Result<Vec<types::order::Fill>, TypeError>>()?;

    Ok(Json(fills))
}
