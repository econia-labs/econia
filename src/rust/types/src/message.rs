use serde::{Deserialize, Serialize};

use crate::order::Order;

#[derive(Debug, Deserialize, Serialize, Clone, Hash, PartialEq, Eq)]
#[serde(tag = "channel", rename_all = "snake_case")]
pub enum Channel {
    Orders {
        market_id: u64,
        user_address: String,
    },
    Ticker1h {
        market_id: u64,
    },
    Ticker3h {
        market_id: u64,
    },
    // TODO add more channels
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "channel", rename_all = "snake_case")]
pub enum Update {
    Orders { data: Order },
    // TODO add more update types
}

#[derive(Debug, Deserialize, Clone, PartialEq, Eq)]
#[serde(tag = "method", rename_all = "snake_case")]
pub enum InboundMessage {
    Ping,
    Subscribe(Channel),
    Unsubscribe(Channel),
}

#[derive(Debug, Serialize, Clone)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum OutboundMessage {
    Pong,
    Confirm(Channel),
    Update(Update),
    Error { message: String },
    Close,
}

#[cfg(test)]
mod tests {
    use serde_json;

    use super::*;

    #[test]
    fn test_deserialize_ping_message() {
        let s = r#"{"method":"ping"}"#;
        let msg: InboundMessage = serde_json::from_str(s).unwrap();
        assert_eq!(msg, InboundMessage::Ping);
    }

    #[test]
    fn test_deserialize_subscribe_message() {
        let s = r#"{"method":"subscribe","channel":"orders","market_id":0,"user_address":"0x1"}"#;
        let msg: InboundMessage = serde_json::from_str(s).unwrap();
        assert_eq!(
            msg,
            InboundMessage::Subscribe(Channel::Orders {
                market_id: 0,
                user_address: "0x1".into(),
            })
        );
    }

    #[test]
    fn test_serialize_pong_message() {
        let msg = OutboundMessage::Pong;
        let s = serde_json::to_string(&msg).unwrap();
        assert_eq!(s, r#"{"event":"pong"}"#);
    }

    #[test]
    fn test_serialize_confirm_message() {
        let msg = OutboundMessage::Confirm(Channel::Orders {
            market_id: 0,
            user_address: "0x1".into(),
        });
        let s = serde_json::to_string(&msg).unwrap();
        assert_eq!(
            s,
            r#"{"event":"confirm","channel":"orders","market_id":0,"user_address":"0x1"}"#
        );
    }
}
