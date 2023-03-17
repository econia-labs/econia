use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

use super::order::Side;
use crate::schema::{maker_events, taker_events};

#[derive(Debug, DbEnum, Serialize, Deserialize, Clone)]
#[serde(rename_all = "lowercase")]
#[ExistingTypePath = "crate::schema::sql_types::MakerEventType"]
pub enum MakerEventType {
    Cancel,
    Change,
    Evict,
    Place,
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

#[derive(Insertable, Debug)]
#[diesel(table_name = maker_events)]
pub struct NewMakerEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub side: &'a Side,
    pub market_order_id: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub event_type: &'a MakerEventType,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub time: &'a DateTime<Utc>,
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

#[derive(Insertable, Debug)]
#[diesel(table_name = taker_events)]
pub struct NewTakerEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub side: &'a Side,
    pub market_order_id: &'a BigDecimal,
    pub maker: &'a str,
    pub custodian_id: Option<&'a BigDecimal>,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub time: &'a DateTime<Utc>,
}
