use crate::models::{Coin, MarketRegistrationEvent, NewCoin, NewMarketRegistrationEvent};
use bigdecimal::BigDecimal;
use chrono::NaiveDateTime;
use diesel::{prelude::*, Connection, PgConnection};
use serde::Deserialize;

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

pub fn create_coin(
    conn: &mut PgConnection,
    account_address: &str,
    module_name: &str,
    struct_name: &str,
    symbol: Option<&str>,
    name: Option<&str>,
    decimals: Option<i16>,
) -> Coin {
    use crate::schema::coins;

    let new_coin = NewCoin {
        account_address,
        module_name,
        struct_name,
        symbol,
        name,
        decimals,
    };

    diesel::insert_into(coins::table)
        .values(&new_coin)
        .get_result(conn)
        .expect("Error adding new coin.")
}

pub fn register_market(
    conn: &mut PgConnection,
    market_id: BigDecimal,
    time: NaiveDateTime,
    base_id: i32,
    base_name_generic: Option<&str>,
    quote_id: i32,
    lot_size: BigDecimal,
    tick_size: BigDecimal,
    min_size: BigDecimal,
    underwriter_id: BigDecimal,
) -> MarketRegistrationEvent {
    use crate::schema::market_registration_events;

    let new_market_registration_event = NewMarketRegistrationEvent {
        market_id,
        time,
        base_id,
        base_name_generic,
        quote_id,
        lot_size,
        tick_size,
        min_size,
        underwriter_id,
    };

    diesel::insert_into(market_registration_events::table)
        .values(&new_market_registration_event)
        .get_result(conn)
        .expect("Error adding market registration event.")
}
