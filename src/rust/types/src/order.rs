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
}

impl TryFrom<u8> for Restriction {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::NoRestriction),
            1 => Ok(Self::FillOrAbort),
            2 => Ok(Self::ImmediateOrCancel),
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

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Order {
    pub market_order_id: u128,
    pub market_id: u64,
    pub side: Side,
    pub size: u64,
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
