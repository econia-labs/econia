use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

use crate::{error::TypeError, Coin, Market};

#[derive(Debug, Clone)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct QueryMarket {
    pub market_id: BigDecimal,
    pub name: String,
    pub base_symbol: Option<String>,
    pub base_name: Option<String>,
    pub base_decimals: Option<i16>,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub quote_symbol: String,
    pub quote_name: String,
    pub quote_decimals: i16,
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

        let quote = Coin {
            account_address: value.quote_account_address,
            module_name: value.quote_module_name,
            struct_name: value.quote_struct_name,
            symbol: value.quote_symbol,
            name: value.quote_name,
            decimals: value.quote_decimals,
        };

        if value.base_name_generic.is_none() {
            // If the market is not a generic market, check that all coin
            // values are present.
            let base_account_address =
                value.base_account_address.ok_or(TypeError::MissingValue {
                    name: "base_account_address".into(),
                })?;
            let base_module_name = value.base_module_name.ok_or(TypeError::MissingValue {
                name: "base_module_name".into(),
            })?;
            let base_struct_name = value.base_struct_name.ok_or(TypeError::MissingValue {
                name: "base_struct_name".into(),
            })?;

            let base_symbol = value.base_symbol.ok_or(TypeError::MissingValue {
                name: "base_symbol".into(),
            })?;
            let base_name = value.base_name.ok_or(TypeError::MissingValue {
                name: "base_name".into(),
            })?;
            let base_decimals = value.base_decimals.ok_or(TypeError::MissingValue {
                name: "base_decimals".into(),
            })?;

            let base = Coin {
                account_address: base_account_address,
                module_name: base_module_name,
                struct_name: base_struct_name,
                symbol: base_symbol,
                name: base_name,
                decimals: base_decimals,
            };

            let market = Market {
                market_id,
                name: value.name,
                base: Some(base),
                base_name_generic: value.base_name_generic,
                quote,
                lot_size,
                tick_size,
                min_size,
                underwriter_id,
                created_at: value.created_at,
            };

            Ok(market)
        } else {
            // If the market is a generic market, make sure there are no
            // unexpected values present.
            if value.base_symbol.is_some() {
                return Err(TypeError::UnexpectedValue {
                    name: "base_symbol".into(),
                });
            };
            if value.base_name.is_some() {
                return Err(TypeError::UnexpectedValue {
                    name: "base_name".into(),
                });
            };
            if value.base_decimals.is_some() {
                return Err(TypeError::UnexpectedValue {
                    name: "base_decimals".into(),
                });
            };
            let market = Market {
                market_id,
                name: value.name,
                base: None,
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
}

#[derive(Debug, Clone)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct MarketIdQuery {
    pub market_id: BigDecimal,
}
