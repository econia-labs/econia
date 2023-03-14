use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::coins;

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

#[derive(Insertable)]
#[diesel(table_name = coins)]
pub struct NewCoin<'a> {
    pub account_address: &'a str,
    pub module_name: &'a str,
    pub struct_name: &'a str,
    pub symbol: Option<&'a str>,
    pub name: Option<&'a str>,
    pub decimals: Option<i16>,
}

// #[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
// pub struct Orderbook {
//     pub id: i32,
//     pub base: String,
//     pub quote: String,
//     pub lot_size: i32,
//     pub tick_size: i32,
//     pub min_size: i32,
//     pub underwriter_id: i32,
// }

// #[derive(Insertable)]
// #[diesel(table_name = orderbooks)]
// pub struct NewOrderbook<'a> {
//     pub id: i32,
//     pub base: &'a str,
//     pub quote: &'a str,
//     pub lot_size: i32,
//     pub tick_size: i32,
//     pub min_size: i32,
//     pub underwriter_id: i32,
// }
