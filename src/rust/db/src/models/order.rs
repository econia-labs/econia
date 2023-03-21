use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

use crate::schema::orders;

#[derive(Debug, DbEnum, Serialize, Deserialize, Clone, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
#[ExistingTypePath = "crate::schema::sql_types::Side"]
pub enum Side {
    Bid,
    Ask,
}

#[derive(Debug, DbEnum, Serialize, Deserialize, Clone, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
#[ExistingTypePath = "crate::schema::sql_types::OrderState"]
pub enum OrderState {
    Open,
    Filled,
    Cancelled,
    Evicted,
}

#[derive(Clone, Debug, Queryable)]
pub struct Order {
    pub market_order_id: BigDecimal,
    pub market_id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: OrderState,
    pub created_at: DateTime<Utc>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = orders)]
pub struct NewOrder<'a> {
    pub market_order_id: &'a BigDecimal,
    pub market_id: &'a BigDecimal,
    pub side: &'a Side,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: &'a OrderState,
    pub created_at: &'a DateTime<Utc>,
}
