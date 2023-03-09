use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::coins;

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Coin {
    pub symbol: String,
    pub name: String,
    pub decimals: i16,
    pub address: String,
}

#[derive(Insertable)]
#[diesel(table_name = coins)]
pub struct NewCoin<'a> {
    pub symbol: &'a str,
    pub name: &'a str,
    pub decimals: i16,
    pub address: &'a str,
}
