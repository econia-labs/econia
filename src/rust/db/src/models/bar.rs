use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::prelude::*;

use crate::schema::bars_1m;

#[derive(Clone, Debug, Queryable, Insertable)]
#[diesel(table_name = bars_1m)]
pub struct Bar {
    pub market_id: BigDecimal,
    pub start_time: DateTime<Utc>,
    pub open: BigDecimal,
    pub high: BigDecimal,
    pub low: BigDecimal,
    pub close: BigDecimal,
    pub volume: BigDecimal,
}
