use thiserror::Error;

#[derive(Error, Debug)]
pub enum TypeError {
    #[error("conversion error")]
    ConversionError { name: String },

    #[error("missing value")]
    MissingValue { name: String },

    #[error("unexpected value")]
    UnexpectedValue { name: String },
}
