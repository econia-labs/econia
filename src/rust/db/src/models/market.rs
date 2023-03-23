use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use field_count::FieldCount;
use types::{error::TypeError, events};

use crate::schema::{market_registration_events, recognized_market_events};

#[derive(Clone, Debug, Queryable)]
pub struct Market {
    pub market_id: BigDecimal,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
    pub created_at: DateTime<Utc>,
}

#[derive(Clone, Debug, Queryable)]
pub struct MarketRegistrationEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}

impl TryFrom<MarketRegistrationEvent> for events::MarketRegistrationEvent {
    type Error = TypeError;

    fn try_from(value: MarketRegistrationEvent) -> Result<Self, Self::Error> {
        Ok(Self {
            market_id: value
                .market_id
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "market_id".to_string(),
                })?,
            time: value.time,
            base_account_address: value.base_account_address,
            base_module_name: value.base_module_name,
            base_struct_name: value.base_struct_name,
            base_name_generic: value.base_name_generic,
            quote_account_address: value.quote_account_address,
            quote_module_name: value.quote_module_name,
            quote_struct_name: value.quote_struct_name,
            lot_size: value
                .lot_size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "lot_size".to_string(),
                })?,
            tick_size: value
                .tick_size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "tick_size".to_string(),
                })?,
            min_size: value
                .min_size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "min_size".to_string(),
                })?,
            underwriter_id: value.underwriter_id.to_u64().ok_or_else(|| {
                TypeError::ConversionError {
                    name: "underwriter_id".to_string(),
                }
            })?,
        })
    }
}

#[derive(Insertable, Debug, FieldCount)]
#[diesel(table_name = market_registration_events)]
pub struct NewMarketRegistrationEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
#[ExistingTypePath = "crate::schema::sql_types::MarketEventType"]
pub enum MarketEventType {
    Add,
    Remove,
    Update,
}

#[derive(Clone, Debug, Queryable)]
pub struct RecognizedMarketEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub event_type: MarketEventType,
    pub lot_size: Option<BigDecimal>,
    pub tick_size: Option<BigDecimal>,
    pub min_size: Option<BigDecimal>,
}

#[derive(Insertable, Debug, FieldCount)]
#[diesel(table_name = recognized_market_events)]
pub struct NewRecognizedMarketEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub event_type: MarketEventType,
    pub lot_size: Option<BigDecimal>,
    pub tick_size: Option<BigDecimal>,
    pub min_size: Option<BigDecimal>,
}
