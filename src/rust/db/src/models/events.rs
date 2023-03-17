use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use types::{error::TypeError, events};

use super::order::Side;
use crate::schema::maker_events;

#[derive(Debug, DbEnum, Clone)]
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

#[derive(Insertable, Debug)]
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

impl From<events::MakerEvent> for NewMakerEvent {
    fn from(value: events::MakerEvent) -> Self {
        Self {
            market_id: value.market_id.into(),
            side: value.side.into(),
            market_order_id: value.market_order_id.into(),
            user_address: value.user_address,
            custodian_id: value.custodian_id.map(|id| id.into()),
            event_type: value.event_type.into(),
            size: value.size.into(),
            price: value.price.into(),
            time: value.time,
        }
    }
}
