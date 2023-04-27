use std::ops::Deref;

use diesel::insert_into;
use diesel_async::pooled_connection::deadpool::Pool;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use diesel_async::{AsyncPgConnection, RunQueryDsl};
use models::{
    bar::{Bar, NewBar},
    market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
};
use serde::Deserialize;

use crate::models::{
    coin::{Coin, NewCoin},
    events::{MakerEvent, NewMakerEvent, NewTakerEvent, TakerEvent},
};

pub mod error;
pub mod models;
pub mod schema;

#[derive(Deserialize, Debug)]
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

pub struct EconiaDbClient(Pool<AsyncPgConnection>);

impl Deref for EconiaDbClient {
    type Target = Pool<AsyncPgConnection>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl EconiaDbClient {
    pub async fn connect(Config { database_url }: Config) -> Self {
        let manager = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
        let pool = Pool::builder(manager)
            .build()
            .expect("Failed to create database pool.");
        Self(pool)
    }

    pub async fn create_coin(&self, coin: &NewCoin<'_>) -> Coin {
        let mut conn = self.get().await.unwrap();
        use crate::schema::coins;
        insert_into(coins::table)
            .values(coin)
            .get_result(&mut conn)
            .await
            .expect("Error adding coin.")
    }

    pub async fn register_market(
        &self,
        event: &NewMarketRegistrationEvent<'_>,
    ) -> MarketRegistrationEvent {
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
            .expect("Error adding market registration event.")
    }

    pub async fn add_maker_event(&self, event: &NewMakerEvent<'_>) -> MakerEvent {
        let mut conn = self.get().await.unwrap();
        use crate::schema::maker_events;
        insert_into(maker_events::table)
            .values(event)
            .get_result(&mut conn)
            .await
            .expect("Error adding maker event.")
    }

    pub async fn add_taker_event(&self, event: &NewTakerEvent<'_>) -> TakerEvent {
        let mut conn = self.get().await.unwrap();
        use crate::schema::taker_events;
        insert_into(taker_events::table)
            .values(event)
            .get_result(&mut conn)
            .await
            .expect("Error adding taker event.")
    }

    pub async fn add_bar(&self, bar: &NewBar) -> Bar {
        let mut conn = self.get().await.unwrap();
        use crate::schema::bars_1m;
        insert_into(bars_1m::table)
            .values(bar)
            .get_result(&mut conn)
            .await
            .expect("Error adding bar.")
    }
}
