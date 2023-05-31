use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use types::error::TypeError;

use crate::schema::orders;

use super::{bigdecimal_to_u128, ToInsertable};

#[derive(Debug, DbEnum, Clone, PartialEq, Eq, Copy)]
#[ExistingTypePath = "crate::schema::sql_types::Side"]
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

impl From<types::order::Side> for Side {
    fn from(value: types::order::Side) -> Self {
        match value {
            types::order::Side::Bid => Self::Bid,
            types::order::Side::Ask => Self::Ask,
        }
    }
}

impl From<Side> for types::order::Side {
    fn from(value: Side) -> Self {
        match value {
            Side::Bid => Self::Bid,
            Side::Ask => Self::Ask,
        }
    }
}

impl TryFrom<u8> for Side {
    type Error = TypeError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Side::Bid),
            1 => Ok(Side::Ask),
            _ => Err(TypeError::ConversionError {
                name: "Side".to_string(),
            }),
        }
    }
}

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[ExistingTypePath = "crate::schema::sql_types::OrderState"]
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

#[derive(Clone, Debug, Queryable)]
pub struct Order {
    pub market_order_id: BigDecimal,
    pub market_id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: OrderState,
    pub created_at: DateTime<Utc>,
}

#[derive(Insertable, Debug)]
#[diesel(table_name = orders)]
pub struct NewOrder<'a> {
    pub market_order_id: &'a BigDecimal,
    pub market_id: &'a BigDecimal,
    pub side: Side,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<&'a BigDecimal>,
    pub order_state: OrderState,
    pub created_at: &'a DateTime<Utc>,
}

impl ToInsertable for Order {
    type Insertable<'a> = NewOrder<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewOrder {
            market_order_id: &self.market_order_id,
            market_id: &self.market_id,
            side: self.side,
            size: &self.size,
            price: &self.price,
            user_address: &self.user_address,
            custodian_id: self.custodian_id.as_ref(),
            order_state: self.order_state,
            created_at: &self.created_at,
        }
    }
}

impl From<OrderState> for types::order::OrderState {
    fn from(value: OrderState) -> Self {
        match value {
            OrderState::Open => types::order::OrderState::Open,
            OrderState::Filled => types::order::OrderState::Filled,
            OrderState::Cancelled => types::order::OrderState::Cancelled,
            OrderState::Evicted => types::order::OrderState::Evicted,
        }
    }
}

impl TryFrom<Order> for types::order::Order {
    type Error = TypeError;

    fn try_from(value: Order) -> Result<Self, Self::Error> {
        let market_order_id = bigdecimal_to_u128(&value.market_order_id).ok_or_else(|| {
            TypeError::ConversionError {
                name: "market_order_id".to_string(),
            }
        })?;
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let side: types::order::Side = value.side.into();
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let price = value.price.to_u64().ok_or(TypeError::ConversionError {
            name: "price".into(),
        })?;

        let custodian_id = if let Some(cid) = value.custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "custodian_id".into(),
            })?)
        } else {
            None
        };

        let order_state: types::order::OrderState = value.order_state.into();

        Ok(types::order::Order {
            market_order_id,
            market_id,
            side,
            size,
            price,
            user_address: value.user_address,
            custodian_id,
            order_state,
            created_at: value.created_at,
        })
    }
}
