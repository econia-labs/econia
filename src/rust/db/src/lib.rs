use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::{prelude::*, Connection, PgConnection};
use serde::Deserialize;

use crate::models::{Coin, MarketRegistrationEvent, NewCoin, NewMarketRegistrationEvent};

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

pub fn create_coin(
    conn: &mut PgConnection,
    account_address: &str,
    module_name: &str,
    struct_name: &str,
    symbol: &str,
    name: &str,
    decimals: i16,
) -> Coin {
    use crate::schema::coins;

    let new_asset = NewCoin {
        account_address,
        module_name,
        struct_name,
        symbol,
        name,
        decimals,
    };

    diesel::insert_into(coins::table)
        .values(&new_asset)
        .get_result(conn)
        .expect("Error adding new asset.")
}

pub fn register_market(
    conn: &mut PgConnection,
    market_id: BigDecimal,
    time: DateTime<Utc>,
    base_account_address: Option<&str>,
    base_module_name: Option<&str>,
    base_struct_name: Option<&str>,
    base_name_generic: Option<&str>,
    quote_account_address: &str,
    quote_module_name: &str,
    quote_struct_name: &str,
    lot_size: BigDecimal,
    tick_size: BigDecimal,
    min_size: BigDecimal,
    underwriter_id: BigDecimal,
) -> MarketRegistrationEvent {
    use crate::schema::market_registration_events;

    if base_name_generic.is_some() {
        assert!(base_account_address.is_none());
        assert!(base_module_name.is_none());
        assert!(base_struct_name.is_none());
    }

    let new_market_registration_event = NewMarketRegistrationEvent {
        market_id,
        time,
        base_account_address,
        base_module_name,
        base_struct_name,
        base_name_generic,
        quote_account_address,
        quote_module_name,
        quote_struct_name,
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
