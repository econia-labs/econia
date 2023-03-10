use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::{coins, orderbooks};

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

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Orderbook {
    pub id: i32,
    pub base: String,
    pub quote: String,
    pub lot_size: i32,
    pub tick_size: i32,
    pub min_size: i32,
    pub underwriter_id: i32,
}

#[derive(Insertable)]
#[diesel(table_name = orderbooks)]
pub struct NewOrderbook<'a> {
    pub id: i32,
    pub base: &'a str,
    pub quote: &'a str,
    pub lot_size: i32,
    pub tick_size: i32,
    pub min_size: i32,
    pub underwriter_id: i32,
}
