//! Misc error types.

use aptos_sdk::{
    bcs,
    crypto::CryptoMaterialError,
    move_types::{account_address::AccountAddressParseError, language_storage::TypeTag},
    rest_client::error::RestError,
};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MarketError {
    #[error("")]
    MaxBaseZero = 0,
    #[error("")]
    MaxQuoteZero = 1,
    #[error("")]
    MinBaseExceedsMax = 2,
    #[error("")]
    MinQuoteExceedsMax = 3,
    #[error("")]
    OverflowAssetIn = 4,
    #[error("")]
    NotEnoughAssetOut = 5,
    #[error("")]
    InvalidMarketId = 6,
    #[error("")]
    InvalidBase = 7,
    #[error("")]
    InvalidQuote = 8,
    #[error("")]
    MinBaseNotTraded = 9,
    #[error("")]
    MinQuoteNotTraded = 10,
    #[error("")]
    PriceZero = 11,
    #[error("")]
    PriceTooHigh = 12,
    #[error("")]
    PostOrAbortCrossesSpread = 13,
    #[error("")]
    SizeTooSmall = 14,
    #[error("")]
    SizeBaseOverflow = 15,
    #[error("")]
    SizePriceTicksOverflow = 16,
    #[error("")]
    SizePriceQuoteOverflow = 17,
    #[error("")]
    InvalidRestriction = 18,
    #[error("")]
    SelfMatch = 19,
    #[error("")]
    PriceTimePriorityTooLow = 20,
    #[error("")]
    InvalidUnderwriter = 21,
    #[error("")]
    InvalidMarketOrderId = 22,
    #[error("")]
    InvalidCustodian = 23,
    #[error("")]
    InvalidUser = 24,
    #[error("")]
    FillOrAbortNotCrossSpread = 25,
    #[error("")]
    HeadKeyPriceMismatch = 26,
    #[error("")]
    NotSimulationAccount = 27,
    #[error("")]
    InvalidSelfMatchBehavior = 28,
    #[error("")]
    InvalidPercent = 29,
    #[error("")]
    SizeChangeInsertionError = 30,
    #[error("")]
    OrderDidNotPost = 31,
}

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

    #[error("invalid response from the contract")]
    InvalidResponse,

    #[error(transparent)]
    MarketError(#[from] MarketError),

    #[error("Custom error: {0}")]
    Custom(#[from] anyhow::Error),
}
