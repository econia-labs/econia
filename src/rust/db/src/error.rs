use thiserror::Error;

#[derive(Error, Debug)]
pub enum DbError {
    #[error("invalid address")]
    InvalidAddress,

    #[error(transparent)]
    PoolBuildError(#[from] diesel_async::pooled_connection::deadpool::BuildError),

    #[error(transparent)]
    PoolError(#[from] diesel_async::pooled_connection::deadpool::PoolError),

    #[error(transparent)]
    QueryError(#[from] diesel::result::Error),
}
