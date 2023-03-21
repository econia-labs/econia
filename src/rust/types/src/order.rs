use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::Side;

#[derive(Clone, Debug, Serialize, Deserialize)]
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
