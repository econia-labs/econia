use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::{prelude::*, Connection, PgConnection};
use models::{
    events::{MakerEvent, MakerEventType},
    order::Side,
};
use serde::Deserialize;
use types::constants::ECONIA_ADDRESS;

use crate::models::{
    asset::{Asset, NewAsset},
    events::NewMakerEvent,
    market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
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

pub fn create_asset(
    conn: &mut PgConnection,
    account_address: &str,
    module_name: &str,
    struct_name: &str,
    symbol: Option<&str>,
    name: Option<&str>,
    decimals: Option<i16>,
) -> Asset {
    use crate::schema::assets;

    let new_asset = NewAsset {
        account_address,
        module_name,
        struct_name,
        symbol,
        name,
        decimals,
    };

    diesel::insert_into(assets::table)
        .values(&new_asset)
        .get_result(conn)
        .expect("Error adding new asset.")
}

pub fn register_market(
    conn: &mut PgConnection,
    market_id: BigDecimal,
    time: DateTime<Utc>,
    base_account_address: &str,
    base_module_name: &str,
    base_struct_name: &str,
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
        assert_eq!(base_account_address, ECONIA_ADDRESS);
        assert_eq!(base_module_name, "registry");
        assert_eq!(base_struct_name, "GenericAsset");
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

pub fn add_maker_event(
    conn: &mut PgConnection,
    market_id: BigDecimal,
    side: Side,
    market_order_id: BigDecimal,
    user_address: &str,
    custodian_id: Option<BigDecimal>,
    event_type: MakerEventType,
    size: BigDecimal,
    price: BigDecimal,
    time: DateTime<Utc>,
) -> MakerEvent {
    use crate::schema::maker_events;

    let new_maker_event = NewMakerEvent {
        market_id,
        side,
        market_order_id,
        user_address,
        custodian_id,
        event_type,
        size,
        price,
        time,
    };

    diesel::insert_into(maker_events::table)
        .values(&new_maker_event)
        .get_result(conn)
        .expect("Error adding maker event.")
}
