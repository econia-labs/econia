use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::Utc;
use db::{
    add_maker_event, create_asset, establish_connection, load_config,
    models::{
        events::{MakerEvent, MakerEventType},
        market::MarketRegistrationEvent,
        order::{Order, OrderState, Side},
    },
    register_market,
};
use diesel::prelude::*;

fn reset_order_tables(conn: &mut PgConnection) {
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

    diesel::delete(db::schema::assets::table)
        .execute(conn)
        .expect("Error deleting assets table");
}

fn setup_market(conn: &mut PgConnection) -> MarketRegistrationEvent {
    // Register coins first, so we can satisfy the foreign key constraint in markets.
    let aptos_coin = create_asset(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT"),
        Some("Aptos Coin"),
        Some(8),
    );

    let tusdc_coin = create_asset(
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
    )
}

#[test]
fn test_place_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market
    let market = setup_market(conn);

    add_maker_event(
        conn,
        market.market_id,
        Side::Buy,
        123.into(),
        "0x123",
        None,
        MakerEventType::Place,
        1000.into(),
        1000.into(),
        Utc::now(),
    );

    // Check that the maker events table has one entry.
    let db_maker_events = db::schema::maker_events::dsl::maker_events
        .load::<MakerEvent>(conn)
        .expect("Could not query maker events.");

    assert_eq!(db_maker_events.len(), 1);

    // println!("maker events:");
    // println!("{:?}", db_maker_events);

    // Check that the orders table has one entry.
    let db_orders = db::schema::orders::dsl::orders
        .load::<Order>(conn)
        .expect("Could not query orders.");

    assert_eq!(db_orders.len(), 1);

    println!("orders:");
    println!("{:#?}", db_orders);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_change_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market
    let market = setup_market(conn);

    add_maker_event(
        conn,
        market.market_id.clone(),
        Side::Buy,
        123.into(),
        "0x123",
        None,
        MakerEventType::Place,
        1000.into(),
        1000.into(),
        Utc::now(),
    );

    add_maker_event(
        conn,
        market.market_id,
        Side::Buy,
        123.into(),
        "0x123",
        None,
        MakerEventType::Change,
        2000.into(),
        1000.into(),
        Utc::now(),
    );

    // Check that the maker events table has one entry.
    let db_maker_events = db::schema::maker_events::dsl::maker_events
        .load::<MakerEvent>(conn)
        .expect("Could not query maker events.");

    assert_eq!(db_maker_events.len(), 2);

    // Check that the orders table has one entry.
    let db_orders = db::schema::orders::dsl::orders
        .load::<Order>(conn)
        .expect("Could not query orders.");

    assert_eq!(db_orders.len(), 1);

    let db_order = db_orders.get(0).unwrap();
    assert_eq!(db_order.size, BigDecimal::from_i32(2000).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.order_state, OrderState::Open);

    // Clean up tables.
    reset_order_tables(conn);
}
