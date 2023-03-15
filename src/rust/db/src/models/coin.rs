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
