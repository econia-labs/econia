//use aptos_sdk::types::account_address::AccountAddress;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use serde::Deserialize;
use serde_json;

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::market_registration_events)]
pub struct MarketRegistrationEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub market_id: BigDecimal,
    pub time: DateTime<Utc>,
    pub base_account_address: Option<String>,
    pub base_module_name: Option<String>,
    pub base_struct_name: Option<String>,
    pub base_name_generic: Option<String>,
    pub quote_account_address: String,
    pub quote_module_name: String,
    pub quote_struct_name: String,
    pub lot_size: BigDecimal,
    pub tick_size: BigDecimal,
    pub min_size: BigDecimal,
    pub underwriter_id: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::fill_events)]
pub struct FillEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub emit_address: String,
    pub time: DateTime<Utc>,
    pub maker_address: String,
    pub maker_custodian_id: BigDecimal,
    pub maker_order_id: BigDecimal,
    pub maker_side: bool,
    pub market_id: BigDecimal,
    pub price: BigDecimal,
    pub sequence_number_for_trade: BigDecimal,
    pub size: BigDecimal,
    pub taker_address: String,
    pub taker_custodian_id: BigDecimal,
    pub taker_order_id: BigDecimal,
    pub taker_quote_fees_paid: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::place_limit_order_events)]
pub struct PlaceLimitOrderEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub time: DateTime<Utc>,
    pub market_id: BigDecimal,
    pub user: String,
    pub custodian_id: BigDecimal,
    pub order_id: BigDecimal,
    pub side: bool,
    pub integrator: String,
    pub initial_size: BigDecimal,
    pub price: BigDecimal,
    pub restriction: i16,
    pub self_match_behavior: i16,
    pub size: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::place_market_order_events)]
pub struct PlaceMarketOrderEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub time: DateTime<Utc>,
    pub market_id: BigDecimal,
    pub user: String,
    pub custodian_id: BigDecimal,
    pub order_id: BigDecimal,
    pub direction: bool,
    pub integrator: String,
    pub self_match_behavior: i16,
    pub size: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::place_swap_order_events)]
pub struct PlaceSwapOrderEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub time: DateTime<Utc>,
    pub market_id: BigDecimal,
    pub order_id: BigDecimal,
    pub direction: bool,
    pub signing_account: String,
    pub integrator: String,
    pub min_base: BigDecimal,
    pub max_base: BigDecimal,
    pub min_quote: BigDecimal,
    pub max_quote: BigDecimal,
    pub limit_price: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::change_order_size_events)]
pub struct ChangeOrderSizeEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub time: DateTime<Utc>,
    pub market_id: BigDecimal,
    pub user: String,
    pub custodian_id: BigDecimal,
    pub order_id: BigDecimal,
    pub side: bool,
    pub new_size: BigDecimal,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::cancel_order_events)]
pub struct CancelOrderEvent {
    pub txn_version: BigDecimal,
    pub event_idx: BigDecimal,
    pub time: DateTime<Utc>,
    pub market_id: BigDecimal,
    pub user: String,
    pub custodian_id: BigDecimal,
    pub order_id: BigDecimal,
    pub reason: i16,
}

#[derive(Clone, Debug, Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::market_account_handles)]
pub struct MarketAccountHandle {
    pub user: String,
    pub handle: String,
}

// Write set types.

#[derive(Deserialize)]
pub struct MarketAccounts {
    pub map: Table,
    pub custodians: Tablist,
}

#[derive(Deserialize)]
pub struct StructOption {
    pub vec: Vec<serde_json::Value>,
}

#[derive(Deserialize)]
pub struct Table {
    pub handle: String,
}

#[derive(Deserialize)]
pub struct TableWithLength {
    pub inner: Table,
    pub length: u64,
}

#[derive(Deserialize)]
pub struct Tablist {
    pub table: Table,
    pub head: StructOption,
    pub tail: StructOption,
}

#[derive(Deserialize)]
pub struct TypeInfo {
    pub account_address: String,
    pub module_name: String,
    pub struct_name: String,
}
