use std::collections::HashMap;

use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use sqlx::Transaction;
use sqlx_postgres::{PgPool, Postgres, PgConnection};

use crate::{Direction, Event, numeric::*};

use super::{FeedFromEventsAndPrevState, InsertableFeed};

#[derive(Debug, Clone)]
pub struct ContractState {
    pub markets: HashMap<MarketId, MarketState>,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Clone)]
pub struct MarketState {
    pub asks: HashMap<OrderId, LimitOrder>,
    pub bids: HashMap<OrderId, LimitOrder>,
    pub accounts: HashMap<String, Account>,
    pub last_price: Option<Price>,
}

#[derive(Clone, Debug)]
pub struct Account {
    pub base: BaseSubunit,
    pub quote: QuoteSubunit,
}

#[derive(Clone, Debug)]
pub struct LimitOrder {
    pub last_changed: BlockStamp,
    pub user: String,
    pub custodian_id: BigDecimal,
    pub direction: Direction,
    pub integrator: String,
    pub price: Price,
    pub size: Lot,
}

impl ContractState {
    pub fn update_timestamp(&mut self, timestamp: DateTime<Utc>) {
        self.timestamp = timestamp;
    }
}

impl FeedFromEventsAndPrevState for ContractState {
    async fn get_prev_state(pool: &PgPool) -> Self {
        let state_cache = sqlx::query!("SELECT * FROM aggv2.state_cache").fetch_optional(pool).await.unwrap();
        if let Some(state_cache) = state_cache {
            let orders_cache = sqlx::query!("SELECT * FROM aggv2.order_cache").fetch_all(pool).await.unwrap();
            let accounts_cache = sqlx::query!("SELECT * FROM aggv2.account_cache").fetch_all(pool).await.unwrap();
            let markets_cache = sqlx::query!("SELECT * FROM aggv2.market_cache").fetch_all(pool).await.unwrap();
            let mut markets = HashMap::new();
            for market_cache in markets_cache {
                let market = MarketState {
                    asks: Default::default(),
                    bids: Default::default(),
                    accounts: Default::default(),
                    last_price: market_cache.last_price.map(|p| Price::new(p)),
                };
                markets.insert(MarketId::new(market_cache.market_id), market);
            }

            for account_cache in accounts_cache {
                let account = Account {
                    base: BaseSubunit::new(account_cache.base),
                    quote: QuoteSubunit::new(account_cache.quote),
                };
                markets.get_mut(&MarketId::new(account_cache.market_id)).unwrap().accounts.insert(account_cache.user, account);
            }

            for order_cache in orders_cache {
                let order = LimitOrder {
                    last_changed: BlockStamp::from_raw_parts(TransactionVersion::new(order_cache.last_changed_transaction_version), EventIndex::new(order_cache.last_changed_event_id)),
                    user: order_cache.user,
                    custodian_id: order_cache.custodian_id,
                    direction: if order_cache.is_ask { Direction::Ask } else { Direction::Bid },
                    integrator: order_cache.integrator,
                    price: Price::new(order_cache.price),
                    size: Lot::new(order_cache.size),
                };
                if order_cache.is_ask {
                    markets.get_mut(&MarketId::new(order_cache.market_id)).unwrap().asks.insert(OrderId::new(order_cache.order_id), order);
                } else {
                    markets.get_mut(&MarketId::new(order_cache.market_id)).unwrap().bids.insert(OrderId::new(order_cache.order_id), order);
                }
            }

            ContractState {
                markets,
                timestamp: state_cache.time,
            }
        } else {
            let timestamp = DateTime::UNIX_EPOCH;
            ContractState {
                markets: Default::default(),
                timestamp,
            }
        }
    }

    fn update<'a>(&mut self, events: impl Iterator<Item = &'a Event>) {
        for event in events {
            match event.clone() {
                Event::MarketRegistration { market_id, .. } => {
                    self.markets.insert(
                        MarketId::from(market_id),
                        MarketState {
                            asks: Default::default(),
                            bids: Default::default(),
                            accounts: Default::default(),
                            last_price: None,
                        },
                    );
                }
                Event::PlaceLimitOrder {
                    txn_version,
                    event_idx,
                    market_id,
                    user,
                    custodian_id,
                    order_id,
                    side,
                    integrator,
                    price,
                    size,
                    ..
                } => {
                    let market = self.markets.get_mut(&MarketId::from(market_id)).unwrap();
                    if matches!(side, Direction::Ask) {
                        market.asks.insert(
                            OrderId::from(order_id),
                            LimitOrder {
                                last_changed: BlockStamp::from_raw_parts(txn_version, event_idx),
                                user,
                                custodian_id,
                                direction: Direction::Ask,
                                integrator,
                                price,
                                size,
                            },
                        );
                    } else {
                        market.bids.insert(
                            OrderId::from(order_id),
                            LimitOrder {
                                last_changed: BlockStamp::from_raw_parts(txn_version, event_idx),
                                user,
                                custodian_id,
                                direction: Direction::Bid,
                                integrator,
                                price,
                                size,
                            },
                        );
                    }
                }
                Event::Fill {
                    emit_address,
                    maker_address,
                    maker_order_id,
                    maker_side,
                    market_id,
                    size,
                    taker_order_id,
                    price,
                    ..
                } => {
                    if maker_address == emit_address {
                        let market = self.markets.get_mut(&MarketId::from(market_id)).unwrap();
                        market.last_price = Some(price);
                        let (maker_order, taker_order) = if matches!(maker_side, Direction::Ask) {
                            (
                                market.asks.get_mut(&OrderId::from(maker_order_id)),
                                market.bids.get_mut(&OrderId::from(taker_order_id)),
                            )
                        } else {
                            (
                                market.bids.get_mut(&OrderId::from(maker_order_id)),
                                market.asks.get_mut(&OrderId::from(taker_order_id)),
                            )
                        };
                        if let Some(maker_order) = maker_order {
                            maker_order.size -= size.clone();
                        }
                        if let Some(taker_order) = taker_order {
                            taker_order.size -= size.clone();
                        }
                    }
                }
                Event::Cancel {
                    market_id,
                    order_id,
                    ..
                } => {
                    let market = self.markets.get_mut(&MarketId::from(market_id)).unwrap();
                    let order_id = OrderId::from(order_id);
                    market.asks.remove(&order_id);
                    market.bids.remove(&order_id);
                }
                Event::ChangeSize {
                    txn_version,
                    event_idx,
                    market_id,
                    order_id,
                    side,
                    new_size,
                    ..
                } => {
                    let market = self.markets.get_mut(&MarketId::from(market_id)).unwrap();
                    let order = if matches!(side, Direction::Ask) {
                        market.asks.get_mut(&OrderId::from(order_id))
                    } else {
                        market.bids.get_mut(&OrderId::from(order_id))
                    };
                    if let Some(order) = order {
                        order.size = new_size;
                        order.last_changed =
                            BlockStamp::from_raw_parts(txn_version, event_idx);
                    }
                }
                _ => {}
            }
        }
    }
}

impl InsertableFeed for ContractState {
    async fn save<'a>(&self, _timestamp: DateTime<Utc>, transaction: &mut Transaction<'a, Postgres>) {
        sqlx::query!("DELETE FROM aggv2.state_cache").execute(transaction as &mut PgConnection).await.unwrap();
        sqlx::query!("DELETE FROM aggv2.account_cache").execute(transaction as &mut PgConnection).await.unwrap();
        sqlx::query!("DELETE FROM aggv2.market_cache").execute(transaction as &mut PgConnection).await.unwrap();
        sqlx::query!("DELETE FROM aggv2.order_cache").execute(transaction as &mut PgConnection).await.unwrap();
        sqlx::query!(
            "INSERT INTO aggv2.state_cache VALUES ($1)",
            self.timestamp,
        ).execute(transaction as &mut PgConnection).await.unwrap();
        for (market_id, market) in &self.markets {
            sqlx::query!(
                "INSERT INTO aggv2.market_cache VALUES ($1, $2)",
                market_id.clone().inner(),
                market.last_price.clone().map(|lp| lp.inner()),
            ).execute(transaction as &mut PgConnection).await.unwrap();
            for (order_id, order) in &market.asks {
                let order = order.clone();
                sqlx::query!(
                    "INSERT INTO aggv2.order_cache VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
                    market_id.clone().inner(),
                    true,
                    order_id.clone().inner(),
                    order.last_changed.transaction_version().clone().inner(),
                    order.last_changed.event_index().clone().inner(),
                    order.user,
                    order.custodian_id,
                    order.integrator,
                    order.price.inner(),
                    order.size.inner()
                ).execute(transaction as &mut PgConnection).await.unwrap();
            }
            for (order_id, order) in &market.bids {
                let order = order.clone();
                sqlx::query!(
                    "INSERT INTO aggv2.order_cache VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
                    market_id.clone().inner(),
                    false,
                    order_id.clone().inner(),
                    order.last_changed.transaction_version().clone().inner(),
                    order.last_changed.event_index().clone().inner(),
                    order.user,
                    order.custodian_id,
                    order.integrator,
                    order.price.inner(),
                    order.size.inner()
                ).execute(transaction as &mut PgConnection).await.unwrap();
            }
            for (account_id, account) in &market.accounts {
                sqlx::query!(
                    "INSERT INTO aggv2.account_cache VALUES ($1, $2, $3, $4)",
                    market_id.clone().inner(),
                    account_id,
                    account.base.clone().inner(),
                    account.quote.clone().inner(),
                ).execute(transaction as &mut PgConnection).await.unwrap();
            }
        }
    }
}
