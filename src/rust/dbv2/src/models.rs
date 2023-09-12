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
