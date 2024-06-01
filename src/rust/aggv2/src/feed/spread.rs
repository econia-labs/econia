use std::collections::HashMap;

use chrono::{DateTime, Utc};
use sqlx::Transaction;
use sqlx_postgres::{Postgres, PgConnection};

use crate::{numeric::{*}, feed::ContractState};

use super::{FeedFromFeed, InsertableFeed};

pub type Spread = HashMap<MarketId, MarketSpread>;

#[derive(Clone)]
pub struct MarketSpread {
    pub min_ask: Option<Price>,
    pub max_bid: Option<Price>,
}

impl FeedFromFeed<ContractState> for Spread {
    fn from_feed(state: &ContractState) -> Self {
        let mut spread = Self::default();
        for (market_id, market) in state.markets.iter() {
            let current_data = spread.entry(market_id.clone()).or_insert(MarketSpread {
                min_ask: None,
                max_bid: None,
            });
            let current_min_ask = current_data.min_ask.clone();
            let current_max_bid = current_data.max_bid.clone();
            let min_ask = market.asks.iter().map(|(_, order)| order.price.clone()).min();
            let max_bid = market.bids.iter().map(|(_, order)| order.price.clone()).max();
            current_data.min_ask = current_min_ask.min(min_ask);
            current_data.max_bid = current_max_bid.min(max_bid);
        }
        spread
    }
}

impl InsertableFeed for Spread {
    async fn save<'a>(&self, timestamp: DateTime<Utc>, transaction: &mut Transaction<'a, Postgres>) {
        for (key, value) in self {
            sqlx::query!(
                "INSERT INTO aggv2.spread VALUES ($1, $2, $3, $4)",
                timestamp,
                key.clone().inner(),
                value.clone().min_ask.map(|o| o.inner()),
                value.clone().max_bid.map(|o| o.inner())
            ).execute(transaction as &mut PgConnection)
            .await.unwrap();
        }
    }
}
