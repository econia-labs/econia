use thiserror::Error;

#[derive(Error, Debug)]
pub enum TypeError {
    #[error("conversion error")]
    ConversionError,

    #[error("missing value")]
    MissingValue { name: String },
}
