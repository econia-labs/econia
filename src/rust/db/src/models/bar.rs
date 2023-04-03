use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use types::error::TypeError;

use crate::schema::bars_1m;

#[derive(Clone, Debug, Queryable)]
pub struct Bar {
    pub market_id: BigDecimal,
    pub start_time: DateTime<Utc>,
    pub open: BigDecimal,
    pub high: BigDecimal,
    pub low: BigDecimal,
    pub close: BigDecimal,
    pub volume: BigDecimal,
}

#[derive(Debug, Insertable)]
#[diesel(table_name = bars_1m)]
pub struct NewBar {
    pub market_id: BigDecimal,
    pub start_time: DateTime<Utc>,
    pub open: BigDecimal,
    pub high: BigDecimal,
    pub low: BigDecimal,
    pub close: BigDecimal,
    pub volume: BigDecimal,
}

impl TryFrom<Bar> for types::bar::Bar {
    type Error = TypeError;

    fn try_from(value: Bar) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let open = value.open.to_u64().ok_or(TypeError::ConversionError {
            name: "open".into(),
        })?;
        let high = value.high.to_u64().ok_or(TypeError::ConversionError {
            name: "high".into(),
        })?;
        let low = value
            .low
            .to_u64()
            .ok_or(TypeError::ConversionError { name: "low".into() })?;
        let close = value.close.to_u64().ok_or(TypeError::ConversionError {
            name: "close".into(),
        })?;
        let volume = value.volume.to_u64().ok_or(TypeError::ConversionError {
            name: "volume".into(),
        })?;

        Ok(types::bar::Bar {
            market_id,
            start_time: value.start_time,
            open,
            high,
            low,
            close,
            volume,
        })
    }
}
