use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::{coins, market_registration_events};

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Coin {
    pub id: i32,
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: Option<String>,
    pub name: Option<String>,
    pub decimals: Option<i16>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = coins)]
pub struct NewCoin<'a> {
    pub account_address: &'a str,
    pub module_name: &'a str,
    pub struct_name: &'a str,
    pub symbol: Option<&'a str>,
    pub name: Option<&'a str>,
    pub decimals: Option<i16>,
}

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Market {
    pub market_id: BigDecimal,
    pub base_id: i32,
    pub base_name_generic: Option<String>,
    pub quote_id: i32,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
    pub created_at: DateTime<Utc>,
}

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct MarketRegistrationEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_id: i32,
    pub base_name_generic: Option<String>,
    pub quote_id: i32,
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
    pub base_id: i32,
    pub base_name_generic: Option<&'a str>,
    pub quote_id: i32,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}
