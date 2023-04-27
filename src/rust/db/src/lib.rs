use std::fmt::Debug;
use std::ops::Deref;

use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::dsl::sum;
use diesel::{insert_into, prelude::*};
use diesel_async::pooled_connection::deadpool::Pool;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use diesel_async::{AsyncPgConnection, RunQueryDsl};
use models::{
    bar::{Bar, NewBar},
    market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
};
use serde::Deserialize;
use types::bar::Resolution;

use crate::error::DbError;
use crate::models::{
    coin::{Coin, NewCoin},
    events::{MakerEvent, NewMakerEvent, NewTakerEvent, TakerEvent},
};

pub mod error;
pub mod models;
pub mod schema;

pub type Result<T> = std::result::Result<T, DbError>;

#[derive(Deserialize, Debug, Clone)]
pub struct Config {
    pub database_url: String,
}

pub fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

#[derive(Clone)]
pub struct EconiaDbClient(Pool<AsyncPgConnection>);

impl Debug for EconiaDbClient {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("EconiaDbClient").finish()
    }
}

impl Deref for EconiaDbClient {
    type Target = Pool<AsyncPgConnection>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

// TODO make these return Result<...>
impl EconiaDbClient {
    pub async fn connect(Config { database_url }: Config) -> Result<Self> {
        let manager = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
        let pool = Pool::builder(manager).build()?;
        Ok(Self(pool))
    }

    pub async fn create_coin(&self, coin: &NewCoin<'_>) -> Result<Coin> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::coins;
        insert_into(coins::table)
            .values(coin)
            .get_result(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn register_market(
        &self,
        event: &NewMarketRegistrationEvent<'_>,
    ) -> Result<MarketRegistrationEvent> {
        if event.base_name_generic.is_some() {
            assert!(event.base_account_address.is_none());
            assert!(event.base_module_name.is_none());
            assert!(event.base_struct_name.is_none());
        }

        let mut conn = self.get().await.unwrap();
        use crate::schema::market_registration_events;
        insert_into(market_registration_events::table)
            .values(event)
            .get_result(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn add_maker_event(&self, event: &NewMakerEvent<'_>) -> Result<MakerEvent> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::maker_events;
        insert_into(maker_events::table)
            .values(event)
            .get_result(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn add_taker_event(&self, event: &NewTakerEvent<'_>) -> Result<TakerEvent> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::taker_events;
        insert_into(taker_events::table)
            .values(event)
            .get_result(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn add_bar(&self, bar: &NewBar) -> Result<Bar> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::bars_1m;
        insert_into(bars_1m::table)
            .values(bar)
            .get_result(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn get_market_ids(&self) -> Result<Vec<BigDecimal>> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::markets::dsl::*;
        markets
            .select(market_id)
            .distinct()
            .load(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn get_order_history_by_account(
        &self,
        account_address: &str,
    ) -> Result<Vec<models::order::Order>> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::orders::dsl::*;
        orders
            .filter(user_address.eq(account_address))
            .load(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn get_open_orders_by_account(
        &self,
        account_address: &str,
    ) -> Result<Vec<models::order::Order>> {
        let mut conn = self.get().await.unwrap();
        use crate::schema::orders::dsl::*;
        orders
            .filter(user_address.eq(account_address))
            .filter(order_state.eq(models::order::OrderState::Open))
            .load(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn get_market_history(
        &self,
        resolution: Resolution,
        market_id_param: &BigDecimal,
        from: DateTime<Utc>,
        to: DateTime<Utc>,
    ) -> Result<Vec<models::bar::Bar>> {
        let mut conn = self.get().await.unwrap();
        match resolution {
            Resolution::R1m => {
                use crate::schema::bars_1m::dsl::*;
                bars_1m
                    .filter(market_id.eq(market_id_param))
                    .filter(start_time.ge(from))
                    .filter(start_time.lt(to))
                    .load(&mut conn)
                    .await
                    .map_err(DbError::QueryError)
            }
            Resolution::R5m => {
                use crate::schema::bars_5m::dsl::*;
                bars_5m
                    .filter(market_id.eq(market_id_param))
                    .filter(start_time.ge(from))
                    .filter(start_time.lt(to))
                    .load(&mut conn)
                    .await
                    .map_err(DbError::QueryError)
            }
            Resolution::R15m => {
                use crate::schema::bars_15m::dsl::*;
                bars_15m
                    .filter(market_id.eq(market_id_param))
                    .filter(start_time.ge(from))
                    .filter(start_time.lt(to))
                    .load(&mut conn)
                    .await
                    .map_err(DbError::QueryError)
            }
            Resolution::R30m => {
                use crate::schema::bars_30m::dsl::*;
                bars_30m
                    .filter(market_id.eq(market_id_param))
                    .filter(start_time.ge(from))
                    .filter(start_time.lt(to))
                    .load(&mut conn)
                    .await
                    .map_err(DbError::QueryError)
            }
            Resolution::R1h => {
                use crate::schema::bars_1h::dsl::*;
                bars_1h
                    .filter(market_id.eq(market_id_param))
                    .filter(start_time.ge(from))
                    .filter(start_time.lt(to))
                    .load(&mut conn)
                    .await
                    .map_err(DbError::QueryError)
            }
        }
    }

    pub async fn get_fills(
        &self,
        market_id_param: &BigDecimal,
        from: DateTime<Utc>,
        to: DateTime<Utc>,
    ) -> Result<Vec<models::fill::Fill>> {
        let mut conn = self.0.get().await.unwrap();
        use crate::schema::fills::dsl::*;
        fills
            .filter(market_id.eq(market_id_param))
            .filter(time.ge(from))
            .filter(time.lt(to))
            .load(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }

    pub async fn get_order_book_price_levels(
        &self,
        market_id_param: &BigDecimal,
        book_side: models::order::Side,
        depth: i64,
    ) -> Result<Vec<models::market::PriceLevel>> {
        let mut conn = self.0.get().await.unwrap();
        use crate::schema::orders::dsl::*;
        orders
            .filter(market_id.eq(market_id_param))
            .filter(side.eq(book_side))
            .filter(order_state.eq(models::order::OrderState::Open))
            .group_by(price)
            .select((price, sum(size).assume_not_null()))
            .limit(depth)
            .load::<models::market::PriceLevel>(&mut conn)
            .await
            .map_err(DbError::QueryError)
    }
}
