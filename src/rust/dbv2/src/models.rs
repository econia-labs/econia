use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;

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
