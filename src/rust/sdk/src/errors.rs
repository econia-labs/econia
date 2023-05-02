use aptos_sdk::{
    bcs,
    crypto::CryptoMaterialError,
    move_types::{account_address::AccountAddressParseError, language_storage::TypeTag},
    rest_client::error::RestError,
};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum EconiaError {
    #[error("the provided econia address: `{0}` is invalid")]
    InvalidEconiaAddress(String),

    #[error(transparent)]
    AptosError(#[from] RestError),

    #[error(transparent)]
    AccountAddressParseError(#[from] AccountAddressParseError),

    #[error(transparent)]
    CryptographyError(#[from] CryptoMaterialError),

    #[error("the provided type tag: `{0}` is invalid")]
    InvalidTypeTag(TypeTag),

    #[error("the provided account address is not registered for coin: `{0}`")]
    AccountNotRegisteredForCoin(TypeTag),

    #[error(transparent)]
    JsonError(#[from] serde_json::Error),

    #[error("the provided aptos module id: `{0}` is invalid")]
    InvalidModuleId(String),

    #[error(transparent)]
    BcsError(#[from] bcs::Error),

    #[error("aptos transaction is invalid")]
    InvalidTransaction,

    #[error("aptos transaction is missing an entry function")]
    TransactionMissingEntryFunction,

    #[error("failed submitting aptos transaction")]
    FailedSubmittingTransaction,

    #[error("Custom error: {0}")]
    Custom(Box<dyn std::error::Error>),
}
