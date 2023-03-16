use chrono::Utc;
use db::{
    create_coin, establish_connection, load_config,
    models::{Market, MarketRegistrationEvent},
    register_market,
};
use diesel::prelude::*;

#[test]
fn test_register_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    diesel::delete(db::schema::markets::table)
        .execute(conn)
        .expect("Error deleting markets table");

    diesel::delete(db::schema::market_registration_events::table)
        .execute(conn)
        .expect("Error deleting market registration event table");

    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting coins table");

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_coin(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT"),
        Some("Aptos Coin"),
        Some(8),
    );

    let tusdc_coin = create_coin(
        conn,
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
        "test_usdc",
        "TestUSDCoin",
        Some("tUSDC"),
        Some("Test USDC"),
        Some(6),
    );

    // Register the market. Adding a new market registration event should create a new entry
    // in the markets table as well.
    register_market(
        conn,
        0.into(),
        Utc::now(),
        &aptos_coin.account_address,
        &aptos_coin.module_name,
        &aptos_coin.struct_name,
        None,
        &tusdc_coin.account_address,
        &tusdc_coin.module_name,
        &tusdc_coin.struct_name,
        1000.into(),
        1000.into(),
        1000.into(),
        0.into(),
    );

    // Check that the market registration events table has one entry.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(conn)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 1);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(conn)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 1);
}
