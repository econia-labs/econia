use chrono::{DateTime, Utc};
#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

use crate::{error::TypeError, order::Side};

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub enum EconiaEvent {
    MarketRegistration(Box<MarketRegistrationEvent>),
    RecognizedMarket(Box<RecognizedMarketEvent>),
    CancelOrder(Box<CancelOrderEvent>),
    ChangeOrderSize(Box<ChangeOrderSizeEvent>),
    Fill(Box<FillEvent>),
    PlaceLimitOrder(Box<PlaceLimitOrderEvent>),
    PlaceMarketOrder(Box<PlaceMarketOrderEvent>),
    PlaceSwapOrder(Box<PlaceSwapOrderEvent>),
}

#[derive(Clone, Copy, Debug)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
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

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
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

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct RecognizedMarketInfo {
    pub market_id: u64,
    pub lot_size: u64,
    pub tick_size: u64,
    pub min_size: u64,
    pub underwriter_id: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct RecognizedMarketEvent {
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub recognized_market_info: Option<RecognizedMarketInfo>,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct CancelOrderEvent {
    pub market_id: u64,
    pub order_id: u128,
    pub user: String,
    pub custodian_id: Option<u64>,
    pub reason: u8,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct ChangeOrderSizeEvent {
    pub market_id: u64,
    pub order_id: u128,
    pub user: String,
    pub custodian_id: Option<u64>,
    pub side: Side,
    pub new_size: u64,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct FillEvent {
    pub market_id: u64,
    pub size: u64,
    pub price: u64,
    pub maker_side: Side,
    pub maker: String,
    pub maker_custodian_id: Option<u64>,
    pub maker_order_id: u128,
    pub taker: String,
    pub taker_custodian_id: Option<u64>,
    pub taker_order_id: u128,
    pub taker_quote_fees_paid: u64,
    pub sequence_number_for_trade: u64,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceLimitOrderEvent {
    pub market_id: u64,
    pub user: String,
    pub custodian_id: Option<u64>,
    pub integrator: Option<String>,
    pub side: Side,
    pub size: u64,
    pub price: u64,
    pub restriction: u8,
    pub self_match_behavior: u8,
    pub remaining_size: u64,
    pub order_id: u128,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceMarketOrderEvent {
    pub market_id: u64,
    pub user: String,
    pub custodian_id: Option<u64>,
    pub integrator: Option<String>,
    pub direction: Side,
    pub size: u64,
    pub self_match_behavior: u8,
    pub order_id: u128,
    pub time: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceSwapOrderEvent {
    pub market_id: u64,
    pub signing_account: String,
    pub integrator: Option<String>,
    pub direction: Side,
    pub min_base: u64,
    pub max_base: u64,
    pub min_quote: u64,
    pub max_quote: u64,
    pub limit_price: u64,
    pub order_id: u128,
    pub time: DateTime<Utc>,
}
