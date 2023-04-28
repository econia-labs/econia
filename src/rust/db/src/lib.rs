use diesel::{prelude::*, Connection, PgConnection};
use models::{
    bar::{Bar, NewBar},
    market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
};
#[cfg(feature = "config-loader")]
use serde::Deserialize;

use crate::{
    error::DbError,
    models::{
        coin::{Coin, NewCoin},
        events::{MakerEvent, NewMakerEvent, NewTakerEvent, TakerEvent},
    },
};

pub mod error;
pub mod models;
pub mod schema;

pub type Result<T> = std::result::Result<T, DbError>;

#[derive(Debug)]
#[cfg_attr(feature = "config-loader", derive(Deserialize))]
pub struct Config {
    pub database_url: String,
}

#[cfg(feature = "config-loader")]
pub fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

pub fn establish_connection(url: String) -> Result<PgConnection> {
    PgConnection::establish(&url).map_err(DbError::ConnectionError)
}

pub fn create_coin(conn: &mut PgConnection, coin: &NewCoin) -> Result<Coin> {
    use crate::schema::coins;
    diesel::insert_into(coins::table)
        .values(coin)
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn register_market(
    conn: &mut PgConnection,
    event: &NewMarketRegistrationEvent,
) -> Result<MarketRegistrationEvent> {
    use crate::schema::market_registration_events;

    if event.base_name_generic.is_some() {
        assert!(event.base_account_address.is_none());
        assert!(event.base_module_name.is_none());
        assert!(event.base_struct_name.is_none());
    }

    diesel::insert_into(market_registration_events::table)
        .values(event)
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_maker_event(conn: &mut PgConnection, event: &NewMakerEvent) -> Result<MakerEvent> {
    use crate::schema::maker_events;
    diesel::insert_into(maker_events::table)
        .values(event)
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_taker_event(conn: &mut PgConnection, event: &NewTakerEvent) -> Result<TakerEvent> {
    use crate::schema::taker_events;
    diesel::insert_into(taker_events::table)
        .values(event)
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_bar(conn: &mut PgConnection, bar: &NewBar) -> Result<Bar> {
    use crate::schema::bars_1m;
    diesel::insert_into(bars_1m::table)
        .values(bar)
        .get_result(conn)
        .map_err(DbError::QueryError)
}
