use std::collections::HashMap;

use bigdecimal::BigDecimal;
use sqlx::Transaction;
use sqlx_postgres::{Postgres, PgConnection};

use crate::{feed::ContractState, numeric::*};

use super::{FeedFromFeed, InsertableFeed};

pub type Liquidity = HashMap<MarketId, HashMap<i32, MarketLiquidity>>;

pub struct MarketLiquidity {
    pub base: Tick,
    pub quote: Tick,
}

impl MarketLiquidity {
    pub fn new() -> Self {
        Self {
            base: Tick::new(0),
            quote: Tick::new(0),
        }
    }
}

const BPS_TIMES_TEN_MULTIPILER: u64 = 10 * 100 * 100;

impl FeedFromFeed<ContractState> for Liquidity {
    fn from_feed(state: &ContractState) -> Self {
        let mut liquidity = Self::default();
        for (market_id, market) in state.markets.iter() {
            if !market.last_price.is_some() {
                continue;
            }
            let last_price = market.last_price.clone().unwrap();
            let current_data = liquidity.entry(market_id.clone()).or_default();
            for order in market.asks.values() {
                let bps_times_ten = (order.price.clone() * BPS_TIMES_TEN_MULTIPILER / last_price.clone() - 100_000).inner();
                for bps_times_ten_group in [25, 50, 100, 250, 500, 1000, 2000] {
                    if bps_times_ten <= BigDecimal::from(bps_times_ten_group) {
                        let market_liquidity = current_data
                            .entry(bps_times_ten_group)
                            .or_insert(MarketLiquidity::new());
                        market_liquidity.base += &order.size * &last_price;
                    }
                }
            }
            for order in market.bids.values() {
                let bps_times_ten = (order.price.clone() * BPS_TIMES_TEN_MULTIPILER / last_price.clone() - 100_000).inner();
                for bps_times_ten_group in [25, 50, 100, 250, 500, 1000, 2000] {
                    if bps_times_ten <= BigDecimal::from(bps_times_ten_group) {
                        let market_liquidity = current_data
                            .entry(bps_times_ten_group)
                            .or_insert(MarketLiquidity::new());
                        market_liquidity.quote += &order.size * &order.price;
                    }
                }
            }
        }
        liquidity
    }
}

impl InsertableFeed for Liquidity {
    async fn save<'a>(&self, timestamp: chrono::prelude::DateTime<chrono::prelude::Utc>, transaction: &mut Transaction<'a, Postgres>) {
        for (key, value) in self {
            for (bps_times_ten, liquidity) in value {
                sqlx::query!(
                    "INSERT INTO aggv2.liquidity VALUES ($1, $2, $3, $4, $5)",
                    timestamp,
                    key.clone().inner(),
                    liquidity.base.clone().inner(),
                    liquidity.quote.clone().inner(),
                    bps_times_ten,
                ).execute(transaction as &mut PgConnection)
                .await.unwrap();
            }
        }
    }
}
