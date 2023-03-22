use diesel::prelude::*;

use crate::schema::coins;

#[derive(Clone, Debug, Queryable)]
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
pub struct NewCoin {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: String,
    pub name: String,
    pub decimals: i16,
}
