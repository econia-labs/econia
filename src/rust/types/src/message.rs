use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone, Hash, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum Channel {
    Fills,
    Orders,
    Ticker1h,
    Ticker3h,
    // TODO add more channels
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
    Error { message: String },
}
