use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use field_count::FieldCount;
use types::{error::TypeError, events};

use super::order::Side;
use crate::schema::{maker_events, market_registration_events, taker_events};

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

#[derive(Insertable, Debug)]
#[diesel(table_name = market_registration_events)]
pub struct NewMarketRegistrationEvent<'a> {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: Option<&'a str>,
    pub base_module_name: Option<&'a str>,
    pub base_struct_name: Option<&'a str>,
    pub base_name_generic: Option<&'a str>,
    pub quote_account_address: &'a str,
    pub quote_module_name: &'a str,
    pub quote_struct_name: &'a str,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}

impl<'a> From<&'a events::MarketRegistrationEvent> for NewMarketRegistrationEvent<'a> {
    fn from(value: &'a events::MarketRegistrationEvent) -> Self {
        Self {
            market_id: value.market_id.into(),
            time: value.time,
            base_account_address: value.base_account_address.as_deref(),
            base_module_name: value.base_module_name.as_deref(),
            base_struct_name: value.base_struct_name.as_deref(),
            base_name_generic: value.base_name_generic.as_deref(),
            quote_account_address: &value.quote_account_address,
            quote_module_name: &value.quote_module_name,
            quote_struct_name: &value.quote_struct_name,
            lot_size: value.lot_size.into(),
            tick_size: value.tick_size.into(),
            min_size: value.min_size.into(),
            underwriter_id: value.underwriter_id.into(),
        }
    }
}

#[derive(Debug, DbEnum, Clone, Copy)]
#[ExistingTypePath = "crate::schema::sql_types::MakerEventType"]
pub enum MakerEventType {
    Cancel,
    Change,
    Evict,
    Place,
}

impl From<events::MakerEventType> for MakerEventType {
    fn from(value: events::MakerEventType) -> Self {
        match value {
            events::MakerEventType::Cancel => Self::Cancel,
            events::MakerEventType::Change => Self::Change,
            events::MakerEventType::Evict => Self::Evict,
            events::MakerEventType::Place => Self::Place,
        }
    }
}

impl From<MakerEventType> for events::MakerEventType {
    fn from(value: MakerEventType) -> Self {
        match value {
            MakerEventType::Cancel => Self::Cancel,
            MakerEventType::Change => Self::Change,
            MakerEventType::Evict => Self::Evict,
            MakerEventType::Place => Self::Place,
        }
    }
}

#[derive(Clone, Debug, Queryable)]
pub struct MakerEvent {
    pub market_id: BigDecimal,
    pub side: Side,
    pub market_order_id: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub event_type: MakerEventType,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}

impl TryFrom<MakerEvent> for events::MakerEvent {
    type Error = TypeError;

    fn try_from(value: MakerEvent) -> Result<Self, Self::Error> {
        Ok(Self {
            market_id: value
                .market_id
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "market_id".to_string(),
                })?,
            side: value.side.into(),
            market_order_id: value.market_order_id.to_u64().ok_or_else(|| {
                TypeError::ConversionError {
                    name: "market_order_id".to_string(),
                }
            })?,
            user_address: value.user_address,
            custodian_id: value
                .custodian_id
                .map(|id| {
                    id.to_u64().ok_or_else(|| TypeError::ConversionError {
                        name: { "custodian_id".to_string() },
                    })
                })
                .transpose()?,
            event_type: value.event_type.into(),
            size: value
                .size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "size".to_string(),
                })?,
            price: value
                .price
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "price".to_string(),
                })?,
            time: value.time,
        })
    }
}

#[derive(Insertable, Debug, FieldCount)]
#[diesel(table_name = maker_events)]
pub struct NewMakerEvent<'a> {
    pub market_id: BigDecimal,
    pub side: Side,
    pub market_order_id: BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub event_type: MakerEventType,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}

impl<'a> From<&'a events::MakerEvent> for NewMakerEvent<'a> {
    fn from(value: &'a events::MakerEvent) -> Self {
        Self {
            market_id: value.market_id.into(),
            side: value.side.clone().into(),
            market_order_id: value.market_order_id.into(),
            user_address: &value.user_address,
            custodian_id: value.custodian_id.map(BigDecimal::from),
            event_type: value.event_type.clone().into(),
            size: value.size.into(),
            price: value.price.into(),
            time: value.time,
        }
    }
}

#[derive(Clone, Debug, Queryable)]
pub struct TakerEvent {
    pub market_id: BigDecimal,
    pub side: Side,
    pub market_order_id: BigDecimal,
    pub maker: String,
    pub custodian_id: Option<BigDecimal>,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}

impl TryFrom<TakerEvent> for events::TakerEvent {
    type Error = TypeError;

    fn try_from(value: TakerEvent) -> Result<Self, Self::Error> {
        Ok(Self {
            market_id: value
                .market_id
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "market_id".to_string(),
                })?,
            side: value.side.into(),
            market_order_id: value.market_order_id.to_u64().ok_or_else(|| {
                TypeError::ConversionError {
                    name: "market_order_id".to_string(),
                }
            })?,
            maker: value.maker,
            custodian_id: value
                .custodian_id
                .map(|id| {
                    id.to_u64().ok_or_else(|| TypeError::ConversionError {
                        name: { "custodian_id".to_string() },
                    })
                })
                .transpose()?,
            size: value
                .size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "size".to_string(),
                })?,
            price: value
                .price
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "price".to_string(),
                })?,
            time: value.time,
        })
    }
}

#[derive(Insertable, Debug, FieldCount)]
#[diesel(table_name = taker_events)]
pub struct NewTakerEvent<'a> {
    pub market_id: BigDecimal,
    pub side: Side,
    pub market_order_id: BigDecimal,
    pub maker: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}

impl<'a> From<&'a events::TakerEvent> for NewTakerEvent<'a> {
    fn from(value: &'a events::TakerEvent) -> Self {
        Self {
            market_id: value.market_id.into(),
            side: value.side.clone().into(),
            market_order_id: value.market_order_id.into(),
            maker: &value.maker,
            custodian_id: value.custodian_id.map(BigDecimal::from),
            size: value.size.into(),
            price: value.price.into(),
            time: value.time,
        }
    }
}
