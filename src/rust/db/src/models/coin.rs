use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::coins;

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Coin {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: String,
    pub name: String,
    pub decimals: i16,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = coins)]
pub struct NewCoin<'a> {
    pub account_address: &'a str,
    pub module_name: &'a str,
    pub struct_name: &'a str,
    pub symbol: &'a str,
    pub name: &'a str,
    pub decimals: i16,
}
