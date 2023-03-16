use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use error::TypeError;
use serde::{Deserialize, Serialize};

pub mod constants;
pub mod error;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Coin {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: String,
    pub name: String,
    pub decimals: i16,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Market {
    pub market_id: u64,
    pub base: Coin,
    pub base_name_generic: Option<String>,
    pub quote: Coin,
    pub lot_size: u64,
    pub tick_size: u64,
    pub min_size: u64,
    pub underwriter_id: u64,
    pub created_at: DateTime<Utc>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct QueryMarket {
    pub market_id: BigDecimal,
    pub base_symbol: Option<String>,
    pub base_name: Option<String>,
    pub base_decimals: Option<i16>,
    pub base_account_address: String,
    pub base_module_name: String,
    pub base_struct_name: String,
    pub quote_symbol: Option<String>,
    pub quote_name: Option<String>,
    pub quote_decimals: Option<i16>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub base_name_generic: Option<String>,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
    pub created_at: DateTime<Utc>,
}

impl TryFrom<QueryMarket> for Market {
    type Error = TypeError;

    fn try_from(value: QueryMarket) -> Result<Self, Self::Error> {
        // Check that all base coin values are present.
        let base_symbol = value.base_symbol.ok_or(TypeError::MissingValue {
            name: "base_symbol".into(),
        })?;
        let base_name = value.base_name.ok_or(TypeError::MissingValue {
            name: "base_name".into(),
        })?;
        let base_decimals = value.base_decimals.ok_or(TypeError::MissingValue {
            name: "base_decimals".into(),
        })?;

        // Check that all quote coin values are present.
        let quote_symbol = value.quote_symbol.ok_or(TypeError::MissingValue {
            name: "quote_symbol".into(),
        })?;
        let quote_name = value.quote_name.ok_or(TypeError::MissingValue {
            name: "quote_name".into(),
        })?;
        let quote_decimals = value.quote_decimals.ok_or(TypeError::MissingValue {
            name: "quote_decimals".into(),
        })?;

        let base = Coin {
            account_address: value.base_account_address,
            module_name: value.base_module_name,
            struct_name: value.base_struct_name,
            symbol: base_symbol,
            name: base_name,
            decimals: base_decimals,
        };

        let quote = Coin {
            account_address: value.quote_account_address,
            module_name: value.quote_module_name,
            struct_name: value.quote_struct_name,
            symbol: quote_symbol,
            name: quote_name,
            decimals: quote_decimals,
        };

        // Convert BigDecimals to u64s.
        // These are all u64 in the Move code, so no errors are expected to occur here.
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let lot_size = value.lot_size.to_u64().ok_or(TypeError::ConversionError {
            name: "lot_size".into(),
        })?;
        let tick_size = value.tick_size.to_u64().ok_or(TypeError::ConversionError {
            name: "tick_size".into(),
        })?;
        let min_size = value.min_size.to_u64().ok_or(TypeError::ConversionError {
            name: "min_size".into(),
        })?;
        let underwriter_id = value
            .underwriter_id
            .to_u64()
            .ok_or(TypeError::ConversionError {
                name: "underwriter_id".into(),
            })?;

        let market = Market {
            market_id,
            base,
            base_name_generic: value.base_name_generic,
            quote,
            lot_size,
            tick_size,
            min_size,
            underwriter_id,
            created_at: value.created_at,
        };

        Ok(market)
    }
}
