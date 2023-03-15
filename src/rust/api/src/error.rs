use axum::{http::StatusCode, response::IntoResponse};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error(transparent)]
    SqlxError(#[from] sqlx::error::Error),

    #[error(transparent)]
    TypeError(#[from] types::error::TypeError),
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        tracing::error!("{}", self.to_string());
        let res = match self {
            Self::SqlxError(_) => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            Self::TypeError(_) => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
        };
        res.into_response()
    }
}
