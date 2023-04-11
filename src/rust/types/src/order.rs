use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::error::TypeError;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Side {
    Ask,
    Bid,
}

impl From<bool> for Side {
    fn from(value: bool) -> Self {
        match value {
            false => Self::Ask,
            true => Self::Bid,
        }
    }
}

impl TryFrom<u8> for Side {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Side::Ask),
            1 => Ok(Side::Bid),
            _ => Err(TypeError::ConversionError {
                name: "Side".to_string(),
            }),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OrderState {
    Open,
    Filled,
    Cancelled,
    Evicted,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Order {
    pub market_order_id: u64,
    pub market_id: u64,
    pub side: Side,
    pub size: u64,
    pub price: u64,
    pub user_address: String,
    pub custodian_id: Option<u64>,
    pub order_state: OrderState,
    pub created_at: DateTime<Utc>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Fill {
    pub market_id: u64,
    pub maker_order_id: u64,
    pub maker: String,
    pub maker_side: Side,
    pub custodian_id: Option<u64>,
    pub size: u64,
    pub price: u64,
    pub time: DateTime<Utc>,
}
