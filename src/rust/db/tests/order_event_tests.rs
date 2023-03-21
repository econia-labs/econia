use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::Utc;
use db::{
    add_maker_event, add_taker_event, establish_connection, load_config,
    models::{
        events::{MakerEvent, MakerEventType, TakerEvent},
        order::{Order, OrderState, Side},
    },
};
use diesel::prelude::*;
use helpers::{reset_tables, setup_market};

mod helpers;

#[test]
fn test_place_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
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
    assert_eq!(db_order.side, Side::Bid);
    assert_eq!(db_order.size, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.price, BigDecimal::from_i32(1000).unwrap());
    assert_eq!(db_order.order_state, OrderState::Open);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_change_order_price() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with price 1000.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
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
        &Side::Bid,
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
    reset_tables(conn);
}

#[test]
fn test_change_order_size() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with size 1000.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
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
        &Side::Bid,
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
    reset_tables(conn);
}

#[test]
fn test_cancel_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
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
        &Side::Bid,
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
    reset_tables(conn);
}

#[test]
fn test_evict_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
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
        &Side::Bid,
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
    reset_tables(conn);
}

#[test]
fn test_fill_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
        &100.into(),
        "0x1001",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Place another order to fill the first order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Ask,
        &101.into(),
        "0x1002",
        None,
        &MakerEventType::Place,
        &500.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Fill the order.
    add_taker_event(
        conn,
        &market.market_id,
        &Side::Ask,
        &100.into(),
        "0x1001",
        None,
        &500.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
    let db_maker_events = db::schema::maker_events::dsl::maker_events
        .load::<MakerEvent>(conn)
        .expect("Could not query maker events.");

    assert_eq!(db_maker_events.len(), 2);

    // Check that the maker events table has one entry.
    let db_taker_events = db::schema::taker_events::dsl::taker_events
        .load::<TakerEvent>(conn)
        .expect("Could not query taker events.");

    assert_eq!(db_taker_events.len(), 1);

    // Check that the orders table has two entries.
    let db_orders = db::schema::orders::dsl::orders
        .load::<Order>(conn)
        .expect("Could not query orders.");

    assert_eq!(db_orders.len(), 2);

    let db_order_0 = db_orders.get(0).unwrap();
    let db_order_1 = db_orders.get(1).unwrap();

    // Check that the maker order has the correct parameters.
    assert_eq!(db_order_0.size, BigDecimal::from_i32(500).unwrap());
    assert_eq!(db_order_0.order_state, OrderState::Open);

    // Check that the taker order has the correct parameters.
    assert_eq!(db_order_1.size, BigDecimal::from_i32(500).unwrap());
    assert_eq!(db_order_1.order_state, OrderState::Open);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_fully_fill_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Bid,
        &100.into(),
        "0x1003",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Place another order to fully fill the first order.
    add_maker_event(
        conn,
        &market.market_id,
        &Side::Ask,
        &101.into(),
        "0x1004",
        None,
        &MakerEventType::Place,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Fully fill the order.
    add_taker_event(
        conn,
        &market.market_id,
        &Side::Ask,
        &100.into(),
        "0x1004",
        None,
        &1000.into(),
        &1000.into(),
        &Utc::now(),
    );

    // Check that the maker events table has two entries.
    let db_maker_events = db::schema::maker_events::dsl::maker_events
        .load::<MakerEvent>(conn)
        .expect("Could not query maker events.");

    assert_eq!(db_maker_events.len(), 2);

    // Check that the maker events table has one entry.
    let db_taker_events = db::schema::taker_events::dsl::taker_events
        .load::<TakerEvent>(conn)
        .expect("Could not query taker events.");

    assert_eq!(db_taker_events.len(), 1);

    // Check that the orders table has two entries.
    let db_orders = db::schema::orders::dsl::orders
        .load::<Order>(conn)
        .expect("Could not query orders.");

    assert_eq!(db_orders.len(), 2);

    let db_order_1 = db_orders.get(1).unwrap();

    // Check that the maker order has the correct parameters.
    assert_eq!(db_order_1.size, BigDecimal::from_i32(0).unwrap());
    assert_eq!(db_order_1.order_state, OrderState::Filled);

    // TODO: update taker order.

    // Clean up tables.
    reset_tables(conn);
}
