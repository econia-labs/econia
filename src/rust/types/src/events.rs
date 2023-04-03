use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::{error::TypeError, order::Side};

#[derive(Clone, Copy, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum MakerEventType {
    Cancel,
    Change,
    Evict,
    Place,
}

impl TryFrom<u8> for MakerEventType {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(MakerEventType::Cancel),
            1 => Ok(MakerEventType::Change),
            2 => Ok(MakerEventType::Evict),
            3 => Ok(MakerEventType::Place),
            _ => Err(TypeError::ConversionError {
                name: "MakerEventType".to_string(),
            }),
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct MakerEvent {
    pub market_id: u64,
    pub side: Side,
    pub market_order_id: u64,
    pub user_address: String,
    pub custodian_id: Option<u64>,
    pub event_type: MakerEventType,
    pub size: u64,
    pub price: u64,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct TakerEvent {
    pub market_id: u64,
    pub side: Side,
    pub market_order_id: u64,
    pub maker: String,
    pub custodian_id: Option<u64>,
    pub size: u64,
    pub price: u64,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct MarketRegistrationEvent {
    pub market_id: u64,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub lot_size: u64,
    pub tick_size: u64,
    pub min_size: u64,
    pub underwriter_id: u64,
    pub time: DateTime<Utc>,
}
