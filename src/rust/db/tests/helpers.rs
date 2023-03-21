use chrono::Utc;
use db::{create_coin, models::events::MarketRegistrationEvent, register_market};
use diesel::prelude::*;

pub fn reset_tables(conn: &mut PgConnection) {
    diesel::delete(db::schema::fills::table)
        .execute(conn)
        .expect("Error deleting fills events table");

    diesel::delete(db::schema::taker_events::table)
        .execute(conn)
        .expect("Error deleting taker events table");

    diesel::delete(db::schema::maker_events::table)
        .execute(conn)
        .expect("Error deleting maker events table");

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

pub fn setup_market(conn: &mut PgConnection) -> MarketRegistrationEvent {
    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_coin(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        "APT",
        "Aptos Coin",
        8,
    );

    let tusdc_coin = create_coin(
        conn,
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
        "test_usdc",
        "TestUSDCoin",
        "tUSDC",
        "Test USDC",
        6,
    );

    // Register the market. Adding a new market registration event should create
    // a new entry in the markets table as well.
    register_market(
        conn,
        0.into(),
        Utc::now(),
        Some(&aptos_coin.account_address),
        Some(&aptos_coin.module_name),
        Some(&aptos_coin.struct_name),
        None,
        &tusdc_coin.account_address,
        &tusdc_coin.module_name,
        &tusdc_coin.struct_name,
        1000.into(),
        1000.into(),
        1000.into(),
        0.into(),
    )
}
