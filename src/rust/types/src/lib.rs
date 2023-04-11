use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

pub mod bar;
pub mod book;
pub mod constants;
pub mod error;
pub mod events;
pub mod message;
pub mod order;
pub mod query;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Coin {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
    pub symbol: String,
    pub name: String,
    pub decimals: i16,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Market {
    pub market_id: u64,
    pub base: Option<Coin>,
    pub base_name_generic: Option<String>,
    pub quote: Coin,
    pub lot_size: u64,
    pub tick_size: u64,
    pub min_size: u64,
    pub underwriter_id: u64,
    pub created_at: DateTime<Utc>,
}
