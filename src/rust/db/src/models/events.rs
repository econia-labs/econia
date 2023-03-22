use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use field_count::FieldCount;
use types::{error::TypeError, events};

use super::order::Side;
use crate::schema::{maker_events, taker_events};

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
#[ExistingTypePath = "crate::schema::sql_types::MakerEventType"]
pub enum MakerEventType {
    Cancel,
    Change,
    Evict,
    Place,
}

impl TryFrom<u8> for MakerEventType {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Cancel),
            1 => Ok(Self::Change),
            2 => Ok(Self::Evict),
            3 => Ok(Self::Place),
            _ => Err(TypeError::ConversionError {
                name: "MakerEventType".to_string(),
            }),
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
pub struct NewMakerEvent {
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
pub struct NewTakerEvent {
    pub market_id: BigDecimal,
    pub side: Side,
    pub market_order_id: BigDecimal,
    pub maker: String,
    pub custodian_id: Option<BigDecimal>,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}
