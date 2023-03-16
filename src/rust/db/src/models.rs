use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::{assets, market_registration_events};

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Asset {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: Option<String>,
    pub name: Option<String>,
    pub decimals: Option<i16>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = assets)]
pub struct NewAsset<'a> {
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
    pub base_account_address: String,
    pub base_module_name: String,
    pub base_struct_name: String,
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

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct MarketRegistrationEvent {
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: String,
    pub base_module_name: String,
    pub base_struct_name: String,
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
    pub base_account_address: &'a str,
    pub base_module_name: &'a str,
    pub base_struct_name: &'a str,
    pub base_name_generic: Option<&'a str>,
    pub quote_account_address: &'a str,
    pub quote_module_name: &'a str,
    pub quote_struct_name: &'a str,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}
