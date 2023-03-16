use thiserror::Error;

#[derive(Error, Debug)]
pub enum DbError {
    #[error("invalid address")]
    InvalidAddress,
}
