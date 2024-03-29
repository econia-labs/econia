#[cfg(feature = "serde")]
use std::{fmt::Display, str::FromStr};

#[cfg(feature = "serde")]
use serde::{Deserialize, Deserializer, Serialize};

use crate::order::{CancelReason, Restriction, SelfMatchBehavior, Side};

#[cfg(feature = "serde")]
fn from_str<'de, T, D>(deserializer: D) -> Result<T, D::Error>
where
    T: FromStr,
    T::Err: Display,
    D: Deserializer<'de>,
{
    let s = String::deserialize(deserializer)?;
    T::from_str(&s).map_err(serde::de::Error::custom)
}

#[cfg(feature = "serde")]
fn from_str_opt<'de, T, D>(deserializer: D) -> Result<Option<T>, D::Error>
where
    T: FromStr,
    T::Err: Display,
    D: Deserializer<'de>,
{
    let s = String::deserialize(deserializer)?;
    Ok(if s.is_empty() {
        None
    } else {
        Some(T::from_str(&s).map_err(serde::de::Error::custom)?)
    })
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
#[cfg_attr(feature = "serde", serde(untagged))]
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

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct TypeInfo {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct MarketRegistrationEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    pub base_type: Option<TypeInfo>,
    pub base_name_generic: Option<String>,
    pub quote_type: TypeInfo,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub lot_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub tick_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub min_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub underwriter_id: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct RecognizedMarketInfo {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub lot_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub tick_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub min_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub underwriter_id: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct RecognizedMarketEvent {
    pub base_type: Option<TypeInfo>,
    pub base_name_generic: Option<String>,
    pub quote_type: TypeInfo,
    pub recognized_market_info: Option<RecognizedMarketInfo>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct CancelOrderEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub order_id: u128,
    pub user: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub custodian_id: Option<u64>,
    pub reason: CancelReason,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct ChangeOrderSizeEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub order_id: u128,
    pub user: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub custodian_id: Option<u64>,
    pub side: Side,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub new_size: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct FillEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub price: u64,
    pub maker_side: Side,
    pub maker: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub maker_custodian_id: Option<u64>,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub maker_order_id: u128,
    pub taker: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub taker_custodian_id: Option<u64>,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub taker_order_id: u128,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub taker_quote_fees_paid: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub sequence_number_for_trade: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceLimitOrderEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    pub user: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub custodian_id: Option<u64>,
    pub integrator: Option<String>,
    pub side: Side,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub price: u64,
    pub restriction: Restriction,
    pub self_match_behavior: SelfMatchBehavior,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub remaining_size: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub order_id: u128,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceMarketOrderEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    pub user: String,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str_opt"))]
    pub custodian_id: Option<u64>,
    pub integrator: Option<String>,
    pub direction: Side,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub size: u64,
    pub self_match_behavior: SelfMatchBehavior,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub order_id: u128,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct PlaceSwapOrderEvent {
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub market_id: u64,
    pub signing_account: String,
    pub integrator: Option<String>,
    pub direction: Side,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub min_base: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub max_base: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub min_quote: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub max_quote: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub limit_price: u64,
    #[cfg_attr(feature = "serde", serde(deserialize_with = "from_str"))]
    pub order_id: u128,
}
