use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use types::error::TypeError;

use crate::schema::orders;

#[derive(Debug, DbEnum, Clone, PartialEq, Eq, Copy)]
#[ExistingTypePath = "crate::schema::sql_types::Side"]
pub enum Side {
    Bid,
    Ask,
}

impl From<types::Side> for Side {
    fn from(value: types::Side) -> Self {
        match value {
            types::Side::Bid => Self::Bid,
            types::Side::Ask => Self::Ask,
        }
    }
}

impl From<Side> for types::Side {
    fn from(value: Side) -> Self {
        match value {
            Side::Bid => Self::Bid,
            Side::Ask => Self::Ask,
        }
    }
}

#[derive(Debug, DbEnum, Clone, PartialEq, Eq)]
#[ExistingTypePath = "crate::schema::sql_types::OrderState"]
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
    pub side: &'a Side,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: &'a OrderState,
    pub created_at: &'a DateTime<Utc>,
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
        let market_order_id = value
            .market_order_id
            .to_u64()
            .ok_or(TypeError::ConversionError {
                name: "market_order_id".into(),
            })?;
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let side: types::Side = value.side.into();
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
