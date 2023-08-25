use chrono::{DateTime, Utc};
#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

use crate::error::TypeError;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[cfg_attr(
    feature = "sqlx",
    derive(sqlx::Type),
    sqlx(type_name = "side", rename_all = "snake_case")
)]
pub enum Side {
    Bid,
    Ask,
}

impl From<bool> for Side {
    fn from(value: bool) -> Self {
        match value {
            false => Self::Bid,
            true => Self::Ask,
        }
    }
}

impl From<Side> for bool {
    fn from(value: Side) -> Self {
        match value {
            Side::Bid => false,
            Side::Ask => true,
        }
    }
}

impl TryFrom<u8> for Side {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Bid),
            1 => Ok(Self::Ask),
            _ => Err(TypeError::ConversionError {
                name: "Side".to_string(),
            }),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
pub enum Direction {
    Buy,
    Sell,
}

impl From<bool> for Direction {
    fn from(value: bool) -> Self {
        match value {
            false => Self::Buy,
            true => Self::Sell,
        }
    }
}

impl TryFrom<u8> for Direction {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Buy),
            1 => Ok(Self::Sell),
            _ => Err(TypeError::ConversionError {
                name: "Direction".to_string(),
            }),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[repr(u8)]
pub enum AdvanceStyle {
    Ticks,
    Percent,
}

impl From<bool> for AdvanceStyle {
    fn from(value: bool) -> Self {
        match value {
            false => Self::Ticks,
            true => Self::Percent,
        }
    }
}

impl TryFrom<u8> for AdvanceStyle {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Ticks),
            1 => Ok(Self::Percent),
            _ => Err(TypeError::ConversionError {
                name: "AdvanceStyle".to_string(),
            }),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[repr(u8)]
pub enum SelfMatchBehavior {
    Abort,
    CancelBoth,
    CancelMaker,
    CancelTaker,
}

impl TryFrom<u8> for SelfMatchBehavior {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Abort),
            1 => Ok(Self::CancelBoth),
            2 => Ok(Self::CancelMaker),
            3 => Ok(Self::CancelTaker),
            _ => Err(TypeError::ConversionError {
                name: "SelfMatchBehavior".to_string(),
            }),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[repr(u8)]
pub enum Restriction {
    NoRestriction,
    FillOrAbort,
    ImmediateOrCancel,
    PostOrAbort,
}

impl TryFrom<u8> for Restriction {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::NoRestriction),
            1 => Ok(Self::FillOrAbort),
            2 => Ok(Self::ImmediateOrCancel),
            3 => Ok(Self::PostOrAbort),
            _ => Err(TypeError::ConversionError {
                name: "Restriction".to_string(),
            }),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[cfg_attr(
    feature = "sqlx",
    derive(sqlx::Type),
    sqlx(type_name = "order_state", rename_all = "snake_case")
)]
pub enum OrderState {
    Open,
    Filled,
    Cancelled,
    Evicted,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[cfg_attr(
    feature = "serde",
    derive(Serialize, Deserialize),
    serde(rename_all = "snake_case")
)]
#[repr(u8)]
pub enum CancelType {
    Both,
    Maker,
    Taker,
}

impl TryFrom<u8> for CancelType {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Both),
            1 => Ok(Self::Maker),
            2 => Ok(Self::Taker),
            _ => Err(TypeError::ConversionError {
                name: "CancelType".to_string(),
            }),
        }
    }
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Order {
    pub order_id: u128,
    pub market_id: u64,
    pub side: Side,
    pub size: u64,
    pub remaining_size: u64,
    pub price: u64,
    pub user_address: String,
    pub custodian_id: Option<u64>,
    pub order_state: OrderState,
    pub created_at: DateTime<Utc>,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Fill {
    pub market_id: u64,
    pub maker_order_id: u128,
    pub maker: String,
    pub maker_side: Side,
    pub custodian_id: Option<u64>,
    pub size: u64,
    pub price: u64,
    pub time: DateTime<Utc>,
}

pub const HI_PRICE: u64 = 0xffffffff;
pub const HI_64: u64 = 0xffffffffffffffff;
pub const MAX_POSSIBLE: u64 = 0xffffffffffffffff;
pub const SHIFT_COUNTER: u64 = 64;
pub const SHIFT_MARKET_ID: u64 = 64;
pub const NO_CUSTODIAN: u64 = 0;
pub const NO_UNDERWRITER: u64 = 0;
pub const NIL: u64 = 0;
