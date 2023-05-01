use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::Utc;
use db::{
    add_maker_event, add_taker_event, establish_connection,
    models::{
        events::{MakerEvent, MakerEventType, NewMakerEvent, NewTakerEvent, TakerEvent},
        fill::Fill,
        order::{Order, OrderState, Side},
    },
};
use diesel::prelude::*;
use helpers::{load_config, reset_tables, setup_market};

mod helpers;

#[test]
fn test_place_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &100.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

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
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with price 1000.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id.clone(),
            side: Side::Bid,
            market_order_id: &101.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Change the price to 1500.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &101.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Change,
            size: &1000.into(),
            price: &1500.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

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
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market
    let market = setup_market(conn);

    // Place an order with size 1000.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &102.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Change the size of the order to 2000.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &102.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Change,
            size: &2000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

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
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &104.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Cancel the order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &place_event.market_order_id,
            user_address: &place_event.user_address,
            custodian_id: None,
            event_type: MakerEventType::Cancel,
            size: &place_event.size,
            price: &place_event.price,
            time: Utc::now(),
        },
    )
    .unwrap();

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
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    let place_event = add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &105.into(),
            user_address: "0x123",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Cancel the order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &place_event.market_order_id,
            user_address: &place_event.user_address,
            custodian_id: None,
            event_type: MakerEventType::Evict,
            size: &place_event.size,
            price: &place_event.price,
            time: Utc::now(),
        },
    )
    .unwrap();

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
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &100.into(),
            user_address: "0x1001",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Place another order to fill the first order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Ask,
            market_order_id: &101.into(),
            user_address: "0x1002",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &500.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Fill the order.
    add_taker_event(
        conn,
        &NewTakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &100.into(),
            maker: "0x1001",
            custodian_id: None,
            size: &500.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

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

    // Check that the fills table has one entry.
    let db_fills = db::schema::fills::dsl::fills
        .load::<Fill>(conn)
        .expect("Could not query fills");

    assert_eq!(db_fills.len(), 1);

    let db_fill_0 = db_fills.get(0).unwrap();

    // Check that the fill has the correct parameters.
    assert_eq!(db_fill_0.maker_order_id, BigDecimal::from_i32(100).unwrap());
    assert_eq!(db_fill_0.maker, "0x1001");

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_fully_fill_order() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    // Place an order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Bid,
            market_order_id: &100.into(),
            user_address: "0x1003",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Place another order to fully fill the first order.
    add_maker_event(
        conn,
        &NewMakerEvent {
            market_id: &market.market_id,
            side: Side::Ask,
            market_order_id: &101.into(),
            user_address: "0x1004",
            custodian_id: None,
            event_type: MakerEventType::Place,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

    // Fully fill the order.
    add_taker_event(
        conn,
        &NewTakerEvent {
            market_id: &market.market_id,
            side: Side::Ask,
            market_order_id: &100.into(),
            maker: "0x1004",
            custodian_id: None,
            size: &1000.into(),
            price: &1000.into(),
            time: Utc::now(),
        },
    )
    .unwrap();

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
