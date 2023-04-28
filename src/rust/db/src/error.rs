use thiserror::Error;

#[derive(Error, Debug)]
pub enum DbError {
    #[error("invalid address")]
    InvalidAddress,

    #[error(transparent)]
    ConnectionError(#[from] diesel::result::ConnectionError),

    #[error(transparent)]
    QueryError(#[from] diesel::result::Error),
}
