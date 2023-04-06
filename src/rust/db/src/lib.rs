use diesel::{prelude::*, Connection, PgConnection};
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

pub fn establish_connection(url: String) -> PgConnection {
    PgConnection::establish(&url)
        .unwrap_or_else(|_| panic!("Could not connect to database {}", url))
}

pub fn create_coin(conn: &mut PgConnection, coin: &NewCoin) -> Coin {
    use crate::schema::coins;
    diesel::insert_into(coins::table)
        .values(coin)
        .get_result(conn)
        .expect("Error adding new asset.")
}

pub fn register_market(
    conn: &mut PgConnection,
    event: &NewMarketRegistrationEvent,
) -> MarketRegistrationEvent {
    use crate::schema::market_registration_events;

    if event.base_name_generic.is_some() {
        assert!(event.base_account_address.is_none());
        assert!(event.base_module_name.is_none());
        assert!(event.base_struct_name.is_none());
    }

    diesel::insert_into(market_registration_events::table)
        .values(event)
        .get_result(conn)
        .expect("Error adding market registration event.")
}

pub fn add_maker_event(conn: &mut PgConnection, event: &NewMakerEvent) -> MakerEvent {
    use crate::schema::maker_events;
    diesel::insert_into(maker_events::table)
        .values(event)
        .get_result(conn)
        .expect("Error adding maker event.")
}

pub fn add_taker_event(conn: &mut PgConnection, event: &NewTakerEvent) -> TakerEvent {
    use crate::schema::taker_events;
    diesel::insert_into(taker_events::table)
        .values(event)
        .get_result(conn)
        .expect("Error adding taker event.")
}

pub fn add_bar(conn: &mut PgConnection, bar: &NewBar) -> Bar {
    use crate::schema::bars_1m;
    diesel::insert_into(bars_1m::table)
        .values(bar)
        .get_result(conn)
        .expect("Error adding bar.")
}
