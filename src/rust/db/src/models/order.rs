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
    Buy,
    Sell,
}

#[derive(Debug, DbEnum, Serialize, Deserialize, Clone, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
#[ExistingTypePath = "crate::schema::sql_types::OrderState"]
pub enum OrderState {
    Open,
    Filled,
    Canceled,
}

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Order {
    pub market_order_id: BigDecimal,
    pub market_id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: OrderState,
    pub remaining_size: BigDecimal,
    pub created_at: DateTime<Utc>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = orders)]
pub struct NewOrder<'a> {
    pub market_order_id: BigDecimal,
    pub market_id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: OrderState,
    pub remaining_size: BigDecimal,
    pub created_at: DateTime<Utc>,
}
