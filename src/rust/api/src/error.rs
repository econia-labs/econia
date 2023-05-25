use axum::{http::StatusCode, response::IntoResponse};
use thiserror::Error;
use types::message::OutboundMessage;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("404 Not Found")]
    NotFound,

    #[error("`{0}` is not a valid address")]
    InvalidAddress(String),

    #[error("invalid time range")]
    InvalidTimeRange,

    #[error("depth must be 1 or greater")]
    InvalidDepth,

    #[error(transparent)]
    SqlxError(#[from] sqlx::error::Error),

    #[error(transparent)]
    TypeError(#[from] types::error::TypeError),

    #[error(transparent)]
    ParseBigDecimal(#[from] bigdecimal::ParseBigDecimalError),
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        tracing::error!("{}", self.to_string());
        let res = match self {
            Self::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            Self::InvalidAddress(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            Self::InvalidTimeRange => (StatusCode::BAD_REQUEST, self.to_string()),
            Self::InvalidDepth => (StatusCode::BAD_REQUEST, self.to_string()),
            Self::SqlxError(_) => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            Self::TypeError(_) => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            Self::ParseBigDecimal(_) => (StatusCode::BAD_REQUEST, self.to_string()),
        };
        res.into_response()
    }
}

#[derive(Error, Debug)]
pub enum WebSocketError {
    #[error(transparent)]
    AxumError(#[from] axum::Error),

    #[error(transparent)]
    MpscSend(#[from] tokio::sync::mpsc::error::SendError<OutboundMessage>),

    #[error(transparent)]
    SerdeParse(#[from] serde_json::Error),
}
