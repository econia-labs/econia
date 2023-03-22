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

impl From<Coin> for types::Coin {
    fn from(value: Coin) -> Self {
        Self {
            account_address: value.account_address,
            module_name: value.module_name,
            struct_name: value.struct_name,
            symbol: value.symbol,
            name: value.name,
            decimals: value.decimals,
        }
    }
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
