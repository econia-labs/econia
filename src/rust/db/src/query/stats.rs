use bigdecimal::{BigDecimal, ToPrimitive};
use types::error::TypeError;

#[derive(Debug, Clone)]
pub struct QueryStats {
    pub market_id: BigDecimal,
    pub open: BigDecimal,
    pub high: BigDecimal,
    pub low: BigDecimal,
    pub close: BigDecimal,
    pub change: BigDecimal,
    pub volume: BigDecimal,
}

impl TryFrom<QueryStats> for types::stats::Stats {
    type Error = TypeError;

    fn try_from(value: QueryStats) -> Result<Self, Self::Error> {
        let market_id = value.market_id.to_u64().ok_or(TypeError::ConversionError {
            name: "market_id".into(),
        })?;
        let open = value.open.to_u64().ok_or(TypeError::ConversionError {
            name: "open".into(),
        })?;
        let low = value
            .low
            .to_u64()
            .ok_or(TypeError::ConversionError { name: "low".into() })?;
        let high = value.high.to_u64().ok_or(TypeError::ConversionError {
            name: "high".into(),
        })?;
        let close = value.close.to_u64().ok_or(TypeError::ConversionError {
            name: "close".into(),
        })?;
        let change = value.change.to_f64().ok_or(TypeError::ConversionError {
            name: "change".into(),
        })?;
        // There can be floating point precision issues with the PostgreSQL
        // round function.
        let change = (change * 1e9).round() / 1e9;
        let volume = value.volume.to_u64().ok_or(TypeError::ConversionError {
            name: "volume".into(),
        })?;

        Ok(types::stats::Stats {
            market_id,
            open,
            high,
            low,
            close,
            change,
            volume,
        })
    }
}
