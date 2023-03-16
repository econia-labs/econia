use diesel::prelude::*;
use serde::{Deserialize, Serialize};

use crate::schema::assets;

#[derive(Clone, Debug, Serialize, Deserialize, Queryable)]
pub struct Asset {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: Option<String>,
    pub name: Option<String>,
    pub decimals: Option<i16>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = assets)]
pub struct NewAsset<'a> {
    pub account_address: &'a str,
    pub module_name: &'a str,
    pub struct_name: &'a str,
    pub symbol: Option<&'a str>,
    pub name: Option<&'a str>,
    pub decimals: Option<i16>,
}