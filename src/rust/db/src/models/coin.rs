use diesel::prelude::*;

use crate::schema::coins;

use super::IntoInsertable;

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
pub struct NewCoin<'a> {
    pub account_address: &'a str,
    pub module_name: &'a str,
    pub struct_name: &'a str,
    pub symbol: &'a str,
    pub name: &'a str,
    pub decimals: i16,
}

impl<'a> IntoInsertable for &'a Coin {
    type Insertable = NewCoin<'a>;

    fn into_insertable(self) -> Self::Insertable {
        NewCoin::<'a> {
            account_address: &self.account_address,
            module_name: &self.module_name,
            struct_name: &self.struct_name,
            symbol: &self.symbol,
            name: &self.name,
            decimals: self.decimals,
        }
    }
}
