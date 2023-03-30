use serde::{Deserialize, Serialize};

use crate::order::{Fill, Order};

#[derive(Debug, Deserialize, Serialize, Clone, Hash, PartialEq, Eq)]
#[serde(
    deny_unknown_fields,
    tag = "channel",
    content = "params",
    rename_all = "snake_case"
)]
pub enum Channel {
    Orders {
        market_id: u64,
        user_address: String,
    },
    Fills {
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
#[serde(
    deny_unknown_fields,
    tag = "channel",
    content = "data",
    rename_all = "snake_case"
)]
pub enum Update {
    Orders(Order),
    Fills(Fill),
    // TODO add more update types
}

#[derive(Debug, Deserialize, Serialize, Clone, PartialEq, Eq)]
#[serde(deny_unknown_fields, tag = "method", rename_all = "snake_case")]
pub enum InboundMessage {
    Ping,
    Subscribe(Channel),
    Unsubscribe(Channel),
}

#[derive(Debug, Serialize, Clone)]
#[serde(rename_all = "snake_case")]
pub enum ConfirmMethod {
    Subscribe,
    Unsubscribe,
}

#[derive(Debug, Serialize, Clone)]
#[serde(deny_unknown_fields, tag = "event", rename_all = "snake_case")]
pub enum OutboundMessage {
    Pong,
    Confirm {
        #[serde(flatten)]
        channel: Channel,
        method: ConfirmMethod,
    },
    Update(Update),
    Error {
        message: String,
    },
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
        let s = r#"{"method":"subscribe","channel":"orders","params":{"market_id":0,"user_address":"0x1"}}"#;
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
    fn test_serialize_confirm_subscribe_message() {
        let msg = OutboundMessage::Confirm {
            channel: Channel::Orders {
                market_id: 0,
                user_address: "0x1".into(),
            },
            method: ConfirmMethod::Subscribe,
        };
        let s = serde_json::to_string(&msg).unwrap();
        assert_eq!(
            s,
            r#"{"event":"confirm","channel":"orders","params":{"market_id":0,"user_address":"0x1"},"method":"subscribe"}"#
        );
    }

    #[test]
    fn test_serialize_confirm_unsubscribe_message() {
        let msg = OutboundMessage::Confirm {
            channel: Channel::Orders {
                market_id: 0,
                user_address: "0x1".into(),
            },
            method: ConfirmMethod::Unsubscribe,
        };
        let s = serde_json::to_string(&msg).unwrap();
        assert_eq!(
            s,
            r#"{"event":"confirm","channel":"orders","params":{"market_id":0,"user_address":"0x1"},"method":"unsubscribe"}"#
        );
    }
}
