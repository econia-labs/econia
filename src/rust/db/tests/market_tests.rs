use chrono::Utc;
use db::{
    create_coin, establish_connection, load_config,
    models::{
        coin::NewCoin,
        market::{Market, MarketRegistrationEvent, NewMarketRegistrationEvent},
    },
    register_market,
};
use diesel::prelude::*;
use helpers::reset_tables;

mod helpers;

#[test]
fn test_register_coin_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x1".to_string(),
            module_name: "aptos_coin".to_string(),
            struct_name: "AptosCoin".to_string(),
            symbol: "APT".to_string(),
            name: "Aptos Coin".to_string(),
            decimals: 8,
        },
    );

    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
                .to_string(),
            module_name: "test_usdc".to_string(),
            struct_name: "TestUSDCoin".to_string(),
            symbol: "tUSDC".to_string(),
            name: "Test USDC".to_string(),
            decimals: 6,
        },
    );

    // Register the market. Adding a new market registration event should create a new entry
    // in the markets table as well.
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: 0.into(),
            time: Utc::now(),
            base_account_address: Some(aptos_coin.account_address),
            base_module_name: Some(aptos_coin.module_name),
            base_struct_name: Some(aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: tusdc_coin.account_address,
            quote_module_name: tusdc_coin.module_name,
            quote_struct_name: tusdc_coin.struct_name,
            lot_size: 1000.into(),
            tick_size: 1000.into(),
            min_size: 1000.into(),
            underwriter_id: 0.into(),
        },
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

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_register_generic_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Register quote coin.
    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
                .to_string(),
            module_name: "test_usdc".to_string(),
            struct_name: "TestUSDCoin".to_string(),
            symbol: "tUSDC".to_string(),
            name: "Test USDC".to_string(),
            decimals: 6,
        },
    );

    // Register the market. Adding a new market registration event should create a new entry
    // in the markets table as well.
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: 1.into(),
            time: Utc::now(),
            base_account_address: None,
            base_module_name: None,
            base_struct_name: None,
            base_name_generic: Some("APT-PERP".to_string()),
            quote_account_address: tusdc_coin.account_address,
            quote_module_name: tusdc_coin.module_name,
            quote_struct_name: tusdc_coin.struct_name,
            lot_size: 1000.into(),
            tick_size: 1000.into(),
            min_size: 1000.into(),
            underwriter_id: 0.into(),
        },
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

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_register_coin_and_generic_market() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x1".to_string(),
            module_name: "aptos_coin".to_string(),
            struct_name: "AptosCoin".to_string(),
            symbol: "APT".to_string(),
            name: "Aptos Coin".to_string(),
            decimals: 8,
        },
    );

    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
                .to_string(),
            module_name: "test_usdc".to_string(),
            struct_name: "TestUSDCoin".to_string(),
            symbol: "tUSDC".to_string(),
            name: "Test USDC".to_string(),
            decimals: 6,
        },
    );

    // Register a new coin market.
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: 0.into(),
            time: Utc::now(),
            base_account_address: Some(aptos_coin.account_address),
            base_module_name: Some(aptos_coin.module_name),
            base_struct_name: Some(aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: tusdc_coin.account_address.clone(),
            quote_module_name: tusdc_coin.module_name.clone(),
            quote_struct_name: tusdc_coin.struct_name.clone(),
            lot_size: 1000.into(),
            tick_size: 1000.into(),
            min_size: 1000.into(),
            underwriter_id: 0.into(),
        },
    );

    // Register a new generic market.
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: 1.into(),
            time: Utc::now(),
            base_account_address: None,
            base_module_name: None,
            base_struct_name: None,
            base_name_generic: Some("APT-PERP".to_string()),
            quote_account_address: tusdc_coin.account_address,
            quote_module_name: tusdc_coin.module_name,
            quote_struct_name: tusdc_coin.struct_name,
            lot_size: 1000.into(),
            tick_size: 1000.into(),
            min_size: 1000.into(),
            underwriter_id: 0.into(),
        },
    );

    // Check that the market registration events table has one entry.
    let db_market_registration_events =
        db::schema::market_registration_events::dsl::market_registration_events
            .load::<MarketRegistrationEvent>(conn)
            .expect("Could not query market registration events.");

    assert_eq!(db_market_registration_events.len(), 2);

    // Check that the markets table has one entry.
    let db_markets = db::schema::markets::dsl::markets
        .load::<Market>(conn)
        .expect("Could not query markets.");

    assert_eq!(db_markets.len(), 2);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
#[should_panic]
fn test_register_generic_market_with_base_coin_fails() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x1".to_string(),
            module_name: "aptos_coin".to_string(),
            struct_name: "AptosCoin".to_string(),
            symbol: "APT".to_string(),
            name: "Aptos Coin".to_string(),
            decimals: 8,
        },
    );

    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
                .to_string(),
            module_name: "test_usdc".to_string(),
            struct_name: "TestUSDCoin".to_string(),
            symbol: "tUSDC".to_string(),
            name: "Test USDC".to_string(),
            decimals: 6,
        },
    );

    // Attempt to register the market.
    // Any market with a base_name_generic should not include a reference to
    // a base coin, so this should fail.
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: 1.into(),
            time: Utc::now(),
            base_account_address: Some(aptos_coin.account_address),
            base_module_name: Some(aptos_coin.module_name),
            base_struct_name: Some(aptos_coin.struct_name),
            base_name_generic: Some("APT-PERP".to_string()),
            quote_account_address: tusdc_coin.account_address,
            quote_module_name: tusdc_coin.module_name,
            quote_struct_name: tusdc_coin.struct_name,
            lot_size: 1000.into(),
            tick_size: 1000.into(),
            min_size: 1000.into(),
            underwriter_id: 0.into(),
        },
    );
}
