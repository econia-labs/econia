use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::market_registration_events;

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
