#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

use crate::{book::PriceLevelWithId, events::FillEvent, order::Order};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(
        deny_unknown_fields,
        tag = "channel",
        content = "params",
        rename_all = "snake_case"
    )
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
    PriceLevels {
        market_id: u64,
    }, // TODO add more channels
}

#[derive(Debug, Clone)]
#[cfg_attr(
    feature = "serde",
    derive(Deserialize, Serialize),
    serde(
        deny_unknown_fields,
        tag = "channel",
        content = "data",
        rename_all = "snake_case"
    )
)]
pub enum Update {
    Orders(Order),
    Fills(FillEvent),
    PriceLevels(PriceLevelWithId), // TODO add more update types
}

#[derive(Debug, Clone, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Deserialize, Serialize),
    serde(deny_unknown_fields, tag = "method", rename_all = "snake_case")
)]
pub enum InboundMessage {
    Ping,
    Subscribe(Channel),
    Unsubscribe(Channel),
}

#[derive(Debug, Clone)]
#[cfg_attr(feature = "serde", derive(Serialize), serde(rename_all = "snake_case"))]
pub enum ConfirmMethod {
    Subscribe,
    Unsubscribe,
}

#[derive(Debug, Clone)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize),
    serde(deny_unknown_fields, tag = "event", rename_all = "snake_case")
)]
pub enum OutboundMessage {
    Pong,
    Confirm {
        #[cfg_attr(feature = "serde", serde(flatten))]
        channel: Channel,
        method: ConfirmMethod,
    },
    Update(Update),
    Error {
        message: String,
    },
    Close,
}

#[cfg(feature = "serde")]
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
