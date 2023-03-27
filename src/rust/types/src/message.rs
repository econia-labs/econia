use serde::{Deserialize, Serialize};

use crate::order::Order;

#[derive(Debug, Deserialize, Serialize, Clone, Hash, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum Channel {
    Orders { user_address: String },
    Ticker1h { market: String },
    Ticker3h { market: String },
    // TODO add more channels
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "channel", rename_all = "snake_case")]
pub enum Update {
    Orders { data: Order },
    // TODO add more update types
}

#[derive(Debug, Deserialize, Clone)]
#[serde(tag = "method", rename_all = "snake_case")]
pub enum InboundMessage {
    Ping,
    Subscribe {
        channel: Channel,
        market: String,
        account_address: Option<String>,
    },
    Unsubscribe {
        channel: Channel,
        market: String,
        account_address: Option<String>,
    },
}

#[derive(Debug, Serialize, Clone)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum OutboundMessage {
    Pong,
    Confirm { channel: Channel },
    Update(Update),
    Error { message: String },
    Close,
}
