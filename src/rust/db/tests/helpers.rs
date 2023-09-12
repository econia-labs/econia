use chrono::Utc;
use db::{
    add_market_registration_event, create_coin,
    models::{
        coin::NewCoin,
        market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
    },
};
use diesel::prelude::*;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
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

fn reset_bar_tables(conn: &mut PgConnection) {
    diesel::delete(db::schema::bars_1h::table)
        .execute(conn)
        .expect("Error deleting bars_1h table");

    diesel::delete(db::schema::bars_30m::table)
        .execute(conn)
        .expect("Error deleting bars_30m table");

    diesel::delete(db::schema::bars_15m::table)
        .execute(conn)
        .expect("Error deleting bars_15m table");

    diesel::delete(db::schema::bars_5m::table)
        .execute(conn)
        .expect("Error deleting bars_5m table");

    diesel::delete(db::schema::bars_1m::table)
        .execute(conn)
        .expect("Error deleting bars_1m table");
}

pub fn reset_tables(conn: &mut PgConnection) {
    reset_bar_tables(conn);

    diesel::delete(db::schema::market_registration_events::table)
        .execute(conn)
        .expect("Error deleting market registration events table");

    diesel::delete(db::schema::recognized_market_events::table)
        .execute(conn)
        .expect("Error deleting recognized market events table");

    diesel::delete(db::schema::change_order_size_events::table)
        .execute(conn)
        .expect("Error deleting change order size events table");

    diesel::delete(db::schema::cancel_order_events::table)
        .execute(conn)
        .expect("Error deleting cancel order events table");

    diesel::delete(db::schema::fill_events::table)
        .execute(conn)
        .expect("Error deleting fill events table");

    diesel::delete(db::schema::place_limit_order_events::table)
        .execute(conn)
        .expect("Error deleting place limit order events table");

    diesel::delete(db::schema::place_market_order_events::table)
        .execute(conn)
        .expect("Error deleting place market order events table");

    diesel::delete(db::schema::place_swap_order_events::table)
        .execute(conn)
        .expect("Error deleting place swap order events table");

    diesel::delete(db::schema::orders::table)
        .execute(conn)
        .expect("Error deleting orders table");

    diesel::delete(db::schema::market_registration_events::table)
        .execute(conn)
        .expect("Error deleting market registration event table");

    diesel::delete(db::schema::markets::table)
        .execute(conn)
        .expect("Error deleting markets table");

    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting coins table");
}

#[allow(dead_code)]
pub fn setup_market(conn: &mut PgConnection) -> MarketRegistrationEvent {
    let aptos_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x1",
            module_name: "aptos_coin",
            struct_name: "AptosCoin",
            symbol: "APT",
            name: "Aptos Coin",
            decimals: 8,
        },
    )
    .unwrap();

    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
            module_name: "test_usdc",
            struct_name: "TestUSDCoin",
            symbol: "tUSDC",
            name: "Test USDC",
            decimals: 6,
        },
    )
    .unwrap();

    add_market_registration_event(
        conn,
        &NewMarketRegistrationEvent {
            market_id: &0.into(),
            time: Utc::now(),
            base_account_address: Some(&aptos_coin.account_address),
            base_module_name: Some(&aptos_coin.module_name),
            base_struct_name: Some(&aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap()
}
