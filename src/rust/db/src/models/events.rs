use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

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
    pub custodian_id: Option<&'a BigDecimal>,
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
