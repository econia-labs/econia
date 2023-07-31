use chrono::Utc;
use db::{
    EconiaDb,
    models::{
        coin::NewCoin,
        market::{Market, MarketRegistrationEvent, NewMarketRegistrationEvent},
    },
};
use diesel::prelude::*;
use helpers::{load_config, reset_tables};

mod helpers;

#[test]
fn test_register_coin_market() {
    let config = load_config();
    let mut db = EconiaDb::establish(&config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(&mut db);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = db.create_coin(
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

    let tusdc_coin = db.create_coin(
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

    // Register the market. Adding a new market registration event should create a new entry
    // in the markets table as well.
    db.add_market_registration_event(
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
    .unwrap();

    // Check that the market registration events table has one entry.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(&mut *db)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 1);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(&mut *db)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 1);

    // Clean up tables.
    reset_tables(&mut db);
}

#[test]
fn test_register_generic_market() {
    let config = load_config();
    let mut db = EconiaDb::establish(&config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(&mut db);

    // Register quote coin.
    let tusdc_coin = db.create_coin(
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

    // Register the market. Adding a new market registration event should create a new entry
    // in the markets table as well.
    db.add_market_registration_event(
        &NewMarketRegistrationEvent {
            market_id: &1.into(),
            time: Utc::now(),
            base_account_address: None,
            base_module_name: None,
            base_struct_name: None,
            base_name_generic: Some("APT-PERP"),
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // Check that the market registration events table has one entry.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(&mut *db)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 1);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(&mut *db)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 1);

    // Clean up tables.
    reset_tables(&mut db);
}

#[test]
fn test_register_multiple_markets() {
    let config = load_config();
    let mut db = EconiaDb::establish(&config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(&mut db);

    let aptos_coin = db.create_coin(
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

    let tusdc_coin = db.create_coin(
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

    let teth_coin = db.create_coin(
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
            module_name: "test_eth",
            struct_name: "TestETHCoin",
            symbol: "tETH",
            name: "Test ETH",
            decimals: 6,
        },
    )
    .unwrap();

    // APT-tUSDC market
    db.add_market_registration_event(
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
    .unwrap();

    // tETH-tUSDC market
    db.add_market_registration_event(
        &NewMarketRegistrationEvent {
            market_id: &1.into(),
            time: Utc::now(),
            base_account_address: Some(&teth_coin.account_address),
            base_module_name: Some(&teth_coin.module_name),
            base_struct_name: Some(&teth_coin.struct_name),
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
    .unwrap();

    // APT-tETH market
    db.add_market_registration_event(
        &NewMarketRegistrationEvent {
            market_id: &2.into(),
            time: Utc::now(),
            base_account_address: Some(&aptos_coin.account_address),
            base_module_name: Some(&aptos_coin.module_name),
            base_struct_name: Some(&aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: &teth_coin.account_address,
            quote_module_name: &teth_coin.module_name,
            quote_struct_name: &teth_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // Check that the market registration events table has three entries.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(&mut *db)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 3);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(&mut *db)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 3);

    // Clean up tables.
    reset_tables(&mut db);
}

#[test]
fn test_register_coin_and_generic_market() {
    let config = load_config();
    let mut db = EconiaDb::establish(&config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(&mut db);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = db.create_coin(
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

    let tusdc_coin = db.create_coin(
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

    // Register a new coin market.
    db.add_market_registration_event(
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
    .unwrap();

    // Register a new generic market.
    db.add_market_registration_event(
        &NewMarketRegistrationEvent {
            market_id: &1.into(),
            time: Utc::now(),
            base_account_address: None,
            base_module_name: None,
            base_struct_name: None,
            base_name_generic: Some("APT-PERP"),
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // Check that the market registration events table has one entry.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(&mut *db)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 2);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(&mut *db)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 2);

    // Clean up tables.
    reset_tables(&mut db);
}

#[test]
#[should_panic]
fn test_register_generic_market_with_base_coin_fails() {
    let config = load_config();
    let mut db = EconiaDb::establish(&config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(&mut db);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = db.create_coin(
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

    let tusdc_coin = db.create_coin(
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

    // Attempt to register the market.
    // Any market with a base_name_generic should not include a reference to
    // a base coin, so this should fail.
    db.add_market_registration_event(
        &NewMarketRegistrationEvent {
            market_id: &1.into(),
            time: Utc::now(),
            base_account_address: Some(&aptos_coin.account_address),
            base_module_name: Some(&aptos_coin.module_name),
            base_struct_name: Some(&aptos_coin.struct_name),
            base_name_generic: Some("APT-PERP"),
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();
}
