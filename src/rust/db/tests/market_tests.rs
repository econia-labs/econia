use chrono::Utc;
use db::{
    create_coin, establish_connection, load_config,
    models::{Market, MarketRegistrationEvent},
    register_market,
};
use diesel::prelude::*;
use types::constants::ECONIA_ADDRESS;

fn reset_market_databases(conn: &mut PgConnection) {
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

#[test]
fn test_register_coin_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_market_databases(conn);

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

#[test]
fn test_register_generic_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_market_databases(conn);

    // Register GenericAsset to coins table to satisfy foreign key constraint.
    create_coin(
        conn,
        ECONIA_ADDRESS,
        "registry",
        "GenericAsset",
        None,
        None,
        None,
    );

    // Register quote coin.
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
        1.into(),
        Utc::now(),
        ECONIA_ADDRESS,
        "registry",
        "GenericAsset",
        Some("APT-PERP"),
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

#[test]
#[should_panic]
fn test_register_generic_market_with_invalid_address() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_market_databases(conn);

    // Register GenericAsset.
    create_coin(
        conn,
        ECONIA_ADDRESS,
        "registry",
        "GenericAsset",
        None,
        None,
        None,
    );

    // Register quote coin.
    let tusdc_coin = create_coin(
        conn,
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
        "test_usdc",
        "TestUSDCoin",
        Some("tUSDC"),
        Some("Test USDC"),
        Some(6),
    );

    // Attempt to register the market.
    // Any market with a base_name_generic should reference the resource
    // <econia_address>::registry::GenericAsset, so this should fail.
    register_market(
        conn,
        1.into(),
        Utc::now(),
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT-PERP"),
        &tusdc_coin.account_address,
        &tusdc_coin.module_name,
        &tusdc_coin.struct_name,
        1000.into(),
        1000.into(),
        1000.into(),
        0.into(),
    );
}
