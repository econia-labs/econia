use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

use crate::schema::orders;

#[derive(Debug, DbEnum, Serialize, Deserialize, Clone)]
#[serde(rename_all = "lowercase")]
#[ExistingTypePath = "crate::schema::sql_types::Side"]
pub enum Side {
    Buy,
    Sell,
}

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Order {
    pub id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: String,
    pub custodian_id: BigDecimal,
    pub created_at: DateTime<Utc>,
    pub order_access_key: BigDecimal,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = orders)]
pub struct NewOrder<'a> {
    pub id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: BigDecimal,
    pub created_at: DateTime<Utc>,
    pub order_access_key: BigDecimal,
}
