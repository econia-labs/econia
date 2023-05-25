use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use field_count::FieldCount;
use types::{error::TypeError, events};

use crate::schema::{market_registration_events, recognized_market_events};

use super::ToInsertable;

#[derive(Clone, Debug, Queryable)]
pub struct Market {
    pub market_id: BigDecimal,
    pub name: String,
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
pub struct NewMarketRegistrationEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: Option<&'a str>,
    pub base_module_name: Option<&'a str>,
    pub base_struct_name: Option<&'a str>,
    pub base_name_generic: Option<&'a str>,
    pub quote_account_address: &'a str,
    pub quote_module_name: &'a str,
    pub quote_struct_name: &'a str,
    pub lot_size: &'a BigDecimal,
    pub tick_size: &'a BigDecimal,
    pub min_size: &'a BigDecimal,
    pub underwriter_id: &'a BigDecimal,
}

impl ToInsertable for MarketRegistrationEvent {
    type Insertable<'a> = NewMarketRegistrationEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewMarketRegistrationEvent {
            market_id: &self.market_id,
            time: self.time,
            base_account_address: self.base_account_address.as_deref(),
            base_module_name: self.base_module_name.as_deref(),
            base_struct_name: self.base_struct_name.as_deref(),
            base_name_generic: self.base_name_generic.as_deref(),
            quote_account_address: &self.quote_account_address,
            quote_module_name: &self.quote_module_name,
            quote_struct_name: &self.quote_struct_name,
            lot_size: &self.lot_size,
            tick_size: &self.tick_size,
            min_size: &self.min_size,
            underwriter_id: &self.underwriter_id,
        }
    }
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
pub struct NewRecognizedMarketEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub time: DateTime<Utc>,
    pub event_type: MarketEventType,
    pub lot_size: Option<&'a BigDecimal>,
    pub tick_size: Option<&'a BigDecimal>,
    pub min_size: Option<&'a BigDecimal>,
}

impl ToInsertable for RecognizedMarketEvent {
    type Insertable<'a> = NewRecognizedMarketEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewRecognizedMarketEvent {
            market_id: &self.market_id,
            time: self.time,
            event_type: self.event_type,
            lot_size: self.lot_size.as_ref(),
            tick_size: self.tick_size.as_ref(),
            min_size: self.min_size.as_ref(),
        }
    }
}

#[derive(Clone, Debug)]
pub struct PriceLevel {
    pub price: BigDecimal,
    pub size: BigDecimal,
}

impl TryFrom<PriceLevel> for types::book::PriceLevel {
    type Error = TypeError;

    fn try_from(value: PriceLevel) -> Result<Self, Self::Error> {
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let price = value.price.to_u64().ok_or(TypeError::ConversionError {
            name: "price".into(),
        })?;

        Ok(types::book::PriceLevel { size, price })
    }
}
