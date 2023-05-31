use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use types::error::TypeError;

use super::{bigdecimal_to_u128, order::Side};

#[derive(Clone, Debug, Queryable)]
pub struct Fill {
    pub market_id: BigDecimal,
    pub maker_order_id: BigDecimal,
    pub maker: String,
    pub maker_side: Side,
    pub custodian_id: Option<BigDecimal>,
    pub size: BigDecimal,
    pub price: BigDecimal,
    pub time: DateTime<Utc>,
}

impl TryFrom<Fill> for types::order::Fill {
    type Error = TypeError;

    fn try_from(value: Fill) -> Result<Self, Self::Error> {
        Ok(Self {
            market_id: value
                .market_id
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "market_id".to_string(),
                })?,
            maker_order_id: bigdecimal_to_u128(&value.maker_order_id).ok_or_else(|| {
                TypeError::ConversionError {
                    name: "maker_order_id".to_string(),
                }
            })?,
            maker: value.maker,
            maker_side: value.maker_side.into(),
            custodian_id: value
                .custodian_id
                .map(|id| {
                    id.to_u64().ok_or_else(|| TypeError::ConversionError {
                        name: { "custodian_id".to_string() },
                    })
                })
                .transpose()?,
            size: value
                .size
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "size".to_string(),
                })?,
            price: value
                .price
                .to_u64()
                .ok_or_else(|| TypeError::ConversionError {
                    name: "price".to_string(),
                })?,
            time: value.time,
        })
    }
}
