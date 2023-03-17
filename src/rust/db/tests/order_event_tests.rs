use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::Utc;
use db::{
    add_maker_event, create_coin, establish_connection, load_config,
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

    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting coins table");
}

fn setup_market(conn: &mut PgConnection) -> MarketRegistrationEvent {
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

#[test]
fn test_place_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &100.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Check that the maker events table has one entry.
    let db_maker_events = db::schema::maker_events::dsl::maker_events
        .load::<MakerEvent>(conn)
        .expect("Could not query maker events.");

    assert_eq!(db_maker_events.len(), 1);

    // Check that the orders table has one entry.
    let db_orders = db::schema::orders::dsl::orders
        .load::<Order>(conn)
        .expect("Could not query orders.");

    assert_eq!(db_orders.len(), 1);

    let db_order = db_orders.get(0).unwrap();

    // Check that the order has the specified parameters.
    assert_eq!(db_order.side, Side::Buy);
    assert_eq!(db_order.size, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.order_state, OrderState::Open);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_change_order_price() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with price 1000.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &101.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Change the size of the price to 1500.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &101.into(),
        "0x123",
        None,
        &MakerEventType::Change,
        &1000.into(),
        &1500.into(),
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
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

    // Check that the order has the updated parameters.
    assert_eq!(db_order.size, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1500).unwrap());
    assert_eq!(db_order.order_state, OrderState::Open);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_change_order_size() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with size 1000.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &102.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Change the size of the order to 2000.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &102.into(),
        "0x123",
        None,
        &MakerEventType::Change,
        &2000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
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

    // Check that the order has the updated parameters.
    assert_eq!(db_order.size, BigDecimal::from_i32(2000).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.order_state, OrderState::Open);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_change_order_to_remaining_size_zero() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &103.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Change the size of the order to zero.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &103.into(),
        "0x123",
        None,
        &MakerEventType::Change,
        &0.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
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
    assert_eq!(db_order.size, BigDecimal::from_i32(0).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.remaining_size, BigDecimal::from_i32(0).unwrap());
    assert_eq!(db_order.order_state, OrderState::Filled);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_cancel_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &104.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Cancel the order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &place_event.market_order_id,
        &place_event.user_address,
        None,
        &MakerEventType::Cancel,
        &place_event.size,
        &place_event.price,
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
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

    // Check that the order is cancelled.
    assert_eq!(db_order.order_state, OrderState::Cancelled);

    // Clean up tables.
    reset_order_tables(conn);
}

#[test]
fn test_evict_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_order_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &105.into(),
        "0x123",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Cancel the order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Buy,
        &place_event.market_order_id,
        &place_event.user_address,
        None,
        &MakerEventType::Evict,
        &place_event.size,
        &place_event.price,
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
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

    // Check that the order is cancelled.
    assert_eq!(db_order.order_state, OrderState::Evicted);

    // Clean up tables.
    reset_order_tables(conn);
}
