use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use types::error::TypeError;

use crate::schema::{
    cancel_order_events, change_order_size_events, fill_events, orders, place_limit_order_events,
    place_market_order_events, place_swap_order_events,
};

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

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[ExistingTypePath = "crate::schema::sql_types::Restriction"]
pub enum Restriction {
    NoRestriction,
    FillOrAbort,
    ImmediateOrCancel,
    PostOrAbort,
}

impl From<Restriction> for types::order::Restriction {
    fn from(value: Restriction) -> Self {
        match value {
            Restriction::NoRestriction => types::order::Restriction::NoRestriction,
            Restriction::FillOrAbort => types::order::Restriction::FillOrAbort,
            Restriction::ImmediateOrCancel => types::order::Restriction::ImmediateOrCancel,
            Restriction::PostOrAbort => types::order::Restriction::PostOrAbort,
        }
    }
}

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[ExistingTypePath = "crate::schema::sql_types::CancelReason"]
pub enum CancelReason {
    SizeChangeInternal,
    Eviction,
    ImmediateOrCancel,
    ManualCancel,
    MaxQuoteTraded,
    NotEnoughLiquidity,
    SelfMatchMaker,
    SelfMatchTaker,
}

impl From<CancelReason> for types::events::CancelReason {
    fn from(value: CancelReason) -> Self {
        match value {
            CancelReason::SizeChangeInternal => types::events::CancelReason::SizeChangeInternal,
            CancelReason::Eviction => types::events::CancelReason::Eviction,
            CancelReason::ImmediateOrCancel => types::events::CancelReason::ImmediateOrCancel,
            CancelReason::ManualCancel => types::events::CancelReason::ManualCancel,
            CancelReason::MaxQuoteTraded => types::events::CancelReason::MaxQuoteTraded,
            CancelReason::NotEnoughLiquidity => types::events::CancelReason::NotEnoughLiquidity,
            CancelReason::SelfMatchMaker => types::events::CancelReason::SelfMatchMaker,
            CancelReason::SelfMatchTaker => types::events::CancelReason::SelfMatchTaker,
        }
    }
}

#[derive(Debug, DbEnum, Clone, Copy, PartialEq, Eq)]
#[ExistingTypePath = "crate::schema::sql_types::SelfMatchBehavior"]
pub enum SelfMatchBehavior {
    Abort,
    CancelBoth,
    CancelMaker,
    CancelTaker,
}

impl From<SelfMatchBehavior> for types::order::SelfMatchBehavior {
    fn from(value: SelfMatchBehavior) -> Self {
        match value {
            SelfMatchBehavior::Abort => types::order::SelfMatchBehavior::Abort,
            SelfMatchBehavior::CancelBoth => types::order::SelfMatchBehavior::CancelBoth,
            SelfMatchBehavior::CancelMaker => types::order::SelfMatchBehavior::CancelMaker,
            SelfMatchBehavior::CancelTaker => types::order::SelfMatchBehavior::CancelTaker,
        }
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = orders, primary_key(order_id, market_id))]
pub struct Order {
    pub order_id: BigDecimal,
    pub market_id: BigDecimal,
    pub side: Side,
    pub size: BigDecimal,
    pub remaining_size: BigDecimal,
    pub price: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub order_state: OrderState,
    pub created_at: DateTime<Utc>,
}

impl TryFrom<Order> for types::order::Order {
    type Error = TypeError;

    fn try_from(value: Order) -> Result<Self, Self::Error> {
        let order_id =
            bigdecimal_to_u128(&value.order_id).ok_or_else(|| TypeError::ConversionError {
                name: "order_id".to_string(),
            })?;
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let side: types::order::Side = value.side.into();
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let remaining_size = value
            .remaining_size
            .to_u64()
            .ok_or(TypeError::ConversionError {
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
            order_id,
            market_id,
            side,
            size,
            remaining_size,
            price,
            user_address: value.user_address,
            custodian_id,
            order_state,
            created_at: value.created_at,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = cancel_order_events, primary_key(market_id, order_id))]
pub struct CancelOrderEvent {
    pub market_id: BigDecimal,
    pub order_id: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub reason: CancelReason,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = cancel_order_events, primary_key(market_id, order_id))]
pub struct NewCancelOrderEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub order_id: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<&'a BigDecimal>,
    pub reason: CancelReason,
    pub time: &'a DateTime<Utc>,
}

impl ToInsertable for CancelOrderEvent {
    type Insertable<'a> = NewCancelOrderEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewCancelOrderEvent {
            market_id: &self.market_id,
            order_id: &self.order_id,
            user_address: &self.user_address,
            custodian_id: self.custodian_id.as_ref(),
            reason: self.reason,
            time: &self.time,
        }
    }
}

impl TryFrom<CancelOrderEvent> for types::events::CancelOrderEvent {
    type Error = TypeError;

    fn try_from(value: CancelOrderEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let order_id = value.order_id.to_u128().ok_or(TypeError::ConversionError {
            name: "order_id".into(),
        })?;
        let reason = value.reason.into();
        let custodian_id = if let Some(cid) = value.custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "custodian_id".into(),
            })?)
        } else {
            None
        };

        Ok(types::events::CancelOrderEvent {
            market_id,
            order_id,
            user: value.user_address,
            custodian_id,
            reason,
            time: value.time,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = change_order_size_events, primary_key(market_id, order_id))]
pub struct ChangeOrderSizeEvent {
    pub market_id: BigDecimal,
    pub order_id: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub side: Side,
    pub new_size: BigDecimal,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = change_order_size_events, primary_key(market_id, order_id))]
pub struct NewChangeOrderSizeEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub order_id: &'a BigDecimal,
    pub user_address: &'a str,
    pub custodian_id: Option<&'a BigDecimal>,
    pub side: Side,
    pub new_size: &'a BigDecimal,
    pub time: &'a DateTime<Utc>,
}

impl ToInsertable for ChangeOrderSizeEvent {
    type Insertable<'a> = NewChangeOrderSizeEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewChangeOrderSizeEvent {
            market_id: &self.market_id,
            order_id: &self.order_id,
            user_address: &self.user_address,
            custodian_id: self.custodian_id.as_ref(),
            side: self.side,
            new_size: &self.new_size,
            time: &self.time,
        }
    }
}

impl TryFrom<ChangeOrderSizeEvent> for types::events::ChangeOrderSizeEvent {
    type Error = TypeError;

    fn try_from(value: ChangeOrderSizeEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let order_id = value.order_id.to_u128().ok_or(TypeError::ConversionError {
            name: "order_id".into(),
        })?;
        let side: types::order::Side = value.side.into();
        let new_size = value.new_size.to_u64().ok_or(TypeError::ConversionError {
            name: "new_size".into(),
        })?;

        let custodian_id = if let Some(cid) = value.custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "custodian_id".into(),
            })?)
        } else {
            None
        };

        Ok(types::events::ChangeOrderSizeEvent {
            market_id,
            order_id,
            user: value.user_address,
            custodian_id,
            side,
            new_size,
            time: value.time,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = fill_events, primary_key(market_id, maker_order_id, taker_order_id))]
pub struct FillEvent {
    pub market_id: BigDecimal,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub maker_side: Side,
    pub maker: String,
    pub maker_custodian_id: Option<BigDecimal>,
    pub maker_order_id: BigDecimal,
    pub taker: String,
    pub taker_custodian_id: Option<BigDecimal>,
    pub taker_order_id: BigDecimal,
    pub taker_quote_fees_paid: BigDecimal,
    pub sequence_number_for_trade: BigDecimal,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = fill_events, primary_key(market_id, maker_order_id, taker_order_id))]
pub struct NewFillEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub maker_side: Side,
    pub maker: String,
    pub maker_custodian_id: Option<&'a BigDecimal>,
    pub maker_order_id: &'a BigDecimal,
    pub taker: String,
    pub taker_custodian_id: Option<&'a BigDecimal>,
    pub taker_order_id: &'a BigDecimal,
    pub taker_quote_fees_paid: &'a BigDecimal,
    pub sequence_number_for_trade: &'a BigDecimal,
    pub time: DateTime<Utc>,
}

impl ToInsertable for FillEvent {
    type Insertable<'a> = NewFillEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewFillEvent {
            market_id: &self.market_id,
            size: &self.size,
            price: &self.price,
            maker_side: self.maker_side,
            maker: self.maker.clone(),
            maker_custodian_id: self.maker_custodian_id.as_ref(),
            maker_order_id: &self.maker_order_id,
            taker: self.taker.clone(),
            taker_custodian_id: self.taker_custodian_id.as_ref(),
            taker_order_id: &self.taker_order_id,
            taker_quote_fees_paid: &self.taker_quote_fees_paid,
            sequence_number_for_trade: &self.sequence_number_for_trade,
            time: self.time,
        }
    }
}

impl TryFrom<FillEvent> for types::events::FillEvent {
    type Error = TypeError;

    fn try_from(value: FillEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let price = value.price.to_u64().ok_or(TypeError::ConversionError {
            name: "price".into(),
        })?;
        let maker_side: types::order::Side = value.maker_side.into();
        let maker_order_id = value
            .maker_order_id
            .to_u128()
            .ok_or(TypeError::ConversionError {
                name: "maker_order_id".into(),
            })?;
        let taker_order_id = value
            .taker_order_id
            .to_u128()
            .ok_or(TypeError::ConversionError {
                name: "taker_order_id".into(),
            })?;
        let taker_quote_fees_paid =
            value
                .taker_quote_fees_paid
                .to_u64()
                .ok_or(TypeError::ConversionError {
                    name: "taker_quote_fees_paid".into(),
                })?;
        let sequence_number_for_trade =
            value
                .sequence_number_for_trade
                .to_u64()
                .ok_or(TypeError::ConversionError {
                    name: "sequence_number_for_trade".into(),
                })?;

        let maker_custodian_id = if let Some(cid) = value.maker_custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "maker_custodian_id".into(),
            })?)
        } else {
            None
        };

        let taker_custodian_id = if let Some(cid) = value.taker_custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "taker_custodian_id".into(),
            })?)
        } else {
            None
        };

        Ok(types::events::FillEvent {
            market_id,
            size,
            price,
            maker_side,
            maker: value.maker,
            maker_custodian_id,
            maker_order_id,
            taker: value.taker,
            taker_custodian_id,
            taker_order_id,
            taker_quote_fees_paid,
            sequence_number_for_trade,
            time: value.time,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = place_limit_order_events, primary_key(market_id, order_id))]
pub struct PlaceLimitOrderEvent {
    pub market_id: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub integrator: Option<String>,
    pub side: Side,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub restriction: Restriction,
    pub self_match_behavior: SelfMatchBehavior,
    pub remaining_size: BigDecimal,
    pub order_id: BigDecimal,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = place_limit_order_events, primary_key(market_id, order_id))]
pub struct NewPlaceLimitOrderEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<&'a BigDecimal>,
    pub integrator: Option<String>,
    pub side: Side,
    pub size: &'a BigDecimal,
    pub price: &'a BigDecimal,
    pub restriction: Restriction,
    pub self_match_behavior: SelfMatchBehavior,
    pub remaining_size: &'a BigDecimal,
    pub order_id: &'a BigDecimal,
    pub time: DateTime<Utc>,
}

impl ToInsertable for PlaceLimitOrderEvent {
    type Insertable<'a> = NewPlaceLimitOrderEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewPlaceLimitOrderEvent {
            market_id: &self.market_id,
            user_address: self.user_address.clone(),
            custodian_id: self.custodian_id.as_ref(),
            integrator: self.integrator.clone(),
            side: self.side,
            size: &self.size,
            price: &self.price,
            restriction: self.restriction,
            self_match_behavior: self.self_match_behavior,
            remaining_size: &self.remaining_size,
            order_id: &self.order_id,
            time: self.time,
        }
    }
}

impl TryFrom<PlaceLimitOrderEvent> for types::events::PlaceLimitOrderEvent {
    type Error = TypeError;

    fn try_from(value: PlaceLimitOrderEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let price = value.price.to_u64().ok_or(TypeError::ConversionError {
            name: "price".into(),
        })?;
        let remaining_size = value
            .remaining_size
            .to_u64()
            .ok_or(TypeError::ConversionError {
                name: "remaining_size".into(),
            })?;
        let order_id = value.order_id.to_u128().ok_or(TypeError::ConversionError {
            name: "order_id".into(),
        })?;

        let custodian_id = if let Some(cid) = value.custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "custodian_id".into(),
            })?)
        } else {
            None
        };

        Ok(types::events::PlaceLimitOrderEvent {
            market_id,
            user: value.user_address,
            custodian_id,
            integrator: value.integrator,
            side: value.side.into(),
            size,
            price,
            restriction: value.restriction.into(),
            self_match_behavior: value.self_match_behavior.into(),
            remaining_size,
            order_id,
            time: value.time,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = place_market_order_events, primary_key(market_id, order_id))]
pub struct PlaceMarketOrderEvent {
    pub market_id: BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<BigDecimal>,
    pub integrator: Option<String>,
    pub direction: Side,
    pub size: BigDecimal,
    pub self_match_behavior: SelfMatchBehavior,
    pub order_id: BigDecimal,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = place_market_order_events, primary_key(market_id, order_id))]
pub struct NewPlaceMarketOrderEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub user_address: String,
    pub custodian_id: Option<&'a BigDecimal>,
    pub integrator: Option<String>,
    pub direction: Side,
    pub size: &'a BigDecimal,
    pub self_match_behavior: SelfMatchBehavior,
    pub order_id: &'a BigDecimal,
    pub time: DateTime<Utc>,
}

impl ToInsertable for PlaceMarketOrderEvent {
    type Insertable<'a> = NewPlaceMarketOrderEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewPlaceMarketOrderEvent {
            market_id: &self.market_id,
            user_address: self.user_address.clone(),
            custodian_id: self.custodian_id.as_ref(),
            integrator: self.integrator.clone(),
            direction: self.direction,
            size: &self.size,
            self_match_behavior: self.self_match_behavior,
            order_id: &self.order_id,
            time: self.time,
        }
    }
}

impl TryFrom<PlaceMarketOrderEvent> for types::events::PlaceMarketOrderEvent {
    type Error = TypeError;

    fn try_from(value: PlaceMarketOrderEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let size = value.size.to_u64().ok_or(TypeError::ConversionError {
            name: "size".into(),
        })?;
        let order_id = value.order_id.to_u128().ok_or(TypeError::ConversionError {
            name: "order_id".into(),
        })?;

        let custodian_id = if let Some(cid) = value.custodian_id {
            Some(cid.to_u64().ok_or(TypeError::ConversionError {
                name: "custodian_id".into(),
            })?)
        } else {
            None
        };

        Ok(types::events::PlaceMarketOrderEvent {
            market_id,
            user: value.user_address,
            custodian_id,
            integrator: value.integrator,
            direction: value.direction.into(),
            size,
            self_match_behavior: value.self_match_behavior.into(),
            order_id,
            time: value.time,
        })
    }
}

#[derive(Clone, Debug, Queryable, Identifiable)]
#[diesel(table_name = place_swap_order_events, primary_key(market_id, order_id))]
pub struct PlaceSwapOrderEvent {
    pub market_id: BigDecimal,
    pub signing_account: String,
    pub integrator: Option<String>,
    pub direction: Side,
    pub min_base: BigDecimal,
    pub max_base: BigDecimal,
    pub min_quote: BigDecimal,
    pub max_quote: BigDecimal,
    pub limit_price: BigDecimal,
    pub order_id: BigDecimal,
    pub time: DateTime<Utc>,
}

#[derive(Insertable, Debug, AsChangeset)]
#[diesel(table_name = place_swap_order_events, primary_key(market_id, order_id))]
pub struct NewPlaceSwapOrderEvent<'a> {
    pub market_id: &'a BigDecimal,
    pub signing_account: String,
    pub integrator: Option<String>,
    pub direction: Side,
    pub min_base: &'a BigDecimal,
    pub max_base: &'a BigDecimal,
    pub min_quote: &'a BigDecimal,
    pub max_quote: &'a BigDecimal,
    pub limit_price: &'a BigDecimal,
    pub order_id: &'a BigDecimal,
    pub time: DateTime<Utc>,
}

impl ToInsertable for PlaceSwapOrderEvent {
    type Insertable<'a> = NewPlaceSwapOrderEvent<'a>;

    fn to_insertable(&self) -> Self::Insertable<'_> {
        NewPlaceSwapOrderEvent {
            market_id: &self.market_id,
            signing_account: self.signing_account.clone(),
            integrator: self.integrator.clone(),
            direction: self.direction,
            min_base: &self.min_base,
            max_base: &self.max_base,
            min_quote: &self.min_quote,
            max_quote: &self.max_quote,
            limit_price: &self.limit_price,
            order_id: &self.order_id,
            time: self.time,
        }
    }
}

impl TryFrom<PlaceSwapOrderEvent> for types::events::PlaceSwapOrderEvent {
    type Error = TypeError;

    fn try_from(value: PlaceSwapOrderEvent) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let min_base = value.min_base.to_u64().ok_or(TypeError::ConversionError {
            name: "min_base".into(),
        })?;
        let max_base = value.max_base.to_u64().ok_or(TypeError::ConversionError {
            name: "max_base".into(),
        })?;
        let min_quote = value.min_quote.to_u64().ok_or(TypeError::ConversionError {
            name: "min_quote".into(),
        })?;
        let max_quote = value.max_quote.to_u64().ok_or(TypeError::ConversionError {
            name: "max_quote".into(),
        })?;
        let limit_price = value
            .limit_price
            .to_u64()
            .ok_or(TypeError::ConversionError {
                name: "limit_price".into(),
            })?;
        let order_id = value.order_id.to_u128().ok_or(TypeError::ConversionError {
            name: "order_id".into(),
        })?;

        Ok(types::events::PlaceSwapOrderEvent {
            market_id,
            signing_account: value.signing_account,
            integrator: value.integrator,
            direction: value.direction.into(),
            min_base,
            max_base,
            min_quote,
            max_quote,
            limit_price,
            order_id,
            time: value.time,
        })
    }
}
