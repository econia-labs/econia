use bigdecimal::BigDecimal;
use chrono::{TimeZone, Utc};
use db::{
    add_bar, establish_connection,
    models::bar::{Bar, NewBar},
};
use diesel::prelude::*;
use helpers::{load_config, reset_tables, setup_market};

mod helpers;

#[test]
fn test_add_1m_bars() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    for i in 0..3 {
        let start_time = Utc.with_ymd_and_hms(2023, 4, 5, 0, i, 0).unwrap();
        let bar = NewBar {
            market_id: market.market_id.clone(),
            start_time,
            open: BigDecimal::from((i + 2) * 100),
            high: BigDecimal::from((i + 4) * 100),
            low: BigDecimal::from((i + 1) * 100),
            close: BigDecimal::from((i + 3) * 100),
            volume: BigDecimal::from(100),
        };
        add_bar(conn, &bar).unwrap();
    }

    let db_1m_bars = db::schema::bars_1m::dsl::bars_1m
        .load::<Bar>(conn)
        .expect("Could not query 1m bars.");

    assert_eq!(db_1m_bars.len(), 3);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_add_5m_bars() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    for i in 0..10 {
        let start_time = Utc.with_ymd_and_hms(2023, 4, 5, 0, i, 0).unwrap();
        let bar = NewBar {
            market_id: market.market_id.clone(),
            start_time,
            open: BigDecimal::from((i + 2) * 100),
            high: BigDecimal::from((i + 4) * 100),
            low: BigDecimal::from((i + 1) * 100),
            close: BigDecimal::from((i + 3) * 100),
            volume: BigDecimal::from(100),
        };
        add_bar(conn, &bar).unwrap();
    }

    let db_1m_bars = db::schema::bars_1m::dsl::bars_1m
        .load::<Bar>(conn)
        .expect("Could not query 1m bars.");

    assert_eq!(db_1m_bars.len(), 10);

    let db_5m_bars = db::schema::bars_5m::dsl::bars_5m
        .load::<Bar>(conn)
        .expect("Could not query 5m bars.");

    assert_eq!(db_5m_bars.len(), 2);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_add_15m_bars() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    for i in 0..60 {
        let start_time = Utc.with_ymd_and_hms(2023, 4, 5, 0, i, 0).unwrap();
        let bar = NewBar {
            market_id: market.market_id.clone(),
            start_time,
            open: BigDecimal::from((i + 2) * 100),
            high: BigDecimal::from((i + 4) * 100),
            low: BigDecimal::from((i + 1) * 100),
            close: BigDecimal::from((i + 3) * 100),
            volume: BigDecimal::from(100),
        };
        add_bar(conn, &bar).unwrap();
    }

    let db_1m_bars = db::schema::bars_1m::dsl::bars_1m
        .load::<Bar>(conn)
        .expect("Could not query 1m bars.");

    assert_eq!(db_1m_bars.len(), 60);

    let db_5m_bars = db::schema::bars_5m::dsl::bars_5m
        .load::<Bar>(conn)
        .expect("Could not query 5m bars.");

    assert_eq!(db_5m_bars.len(), 12);

    let db_15m_bars = db::schema::bars_15m::dsl::bars_15m
        .load::<Bar>(conn)
        .expect("Could not query 15m bars.");

    assert_eq!(db_15m_bars.len(), 4);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_add_30m_bars() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    for i in 0..90 {
        let start_time = Utc.with_ymd_and_hms(2023, 4, 5, i / 60, i % 60, 0).unwrap();
        let bar = NewBar {
            market_id: market.market_id.clone(),
            start_time,
            open: BigDecimal::from((i + 2) * 100),
            high: BigDecimal::from((i + 4) * 100),
            low: BigDecimal::from((i + 1) * 100),
            close: BigDecimal::from((i + 3) * 100),
            volume: BigDecimal::from(100),
        };
        add_bar(conn, &bar).unwrap();
    }

    let db_1m_bars = db::schema::bars_1m::dsl::bars_1m
        .load::<Bar>(conn)
        .expect("Could not query 1m bars.");

    assert_eq!(db_1m_bars.len(), 90);

    let db_5m_bars = db::schema::bars_5m::dsl::bars_5m
        .load::<Bar>(conn)
        .expect("Could not query 5m bars.");

    assert_eq!(db_5m_bars.len(), 18);

    let db_15m_bars = db::schema::bars_15m::dsl::bars_15m
        .load::<Bar>(conn)
        .expect("Could not query 15m bars.");

    assert_eq!(db_15m_bars.len(), 6);

    let db_30m_bars = db::schema::bars_30m::dsl::bars_30m
        .load::<Bar>(conn)
        .expect("Could not query 30m bars.");

    assert_eq!(db_30m_bars.len(), 3);

    // Clean up tables.
    reset_tables(conn);
}

#[test]
fn test_add_1h_bars() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    // Set up market.
    let market = setup_market(conn);

    for i in 0..180 {
        let start_time = Utc.with_ymd_and_hms(2023, 4, 5, i / 60, i % 60, 0).unwrap();
        let bar = NewBar {
            market_id: market.market_id.clone(),
            start_time,
            open: BigDecimal::from((i + 2) * 100),
            high: BigDecimal::from((i + 4) * 100),
            low: BigDecimal::from((i + 1) * 100),
            close: BigDecimal::from((i + 3) * 100),
            volume: BigDecimal::from(100),
        };
        add_bar(conn, &bar).unwrap();
    }

    let db_1m_bars = db::schema::bars_1m::dsl::bars_1m
        .load::<Bar>(conn)
        .expect("Could not query 1m bars.");

    assert_eq!(db_1m_bars.len(), 180);

    let db_5m_bars = db::schema::bars_5m::dsl::bars_5m
        .load::<Bar>(conn)
        .expect("Could not query 5m bars.");

    assert_eq!(db_5m_bars.len(), 36);

    let db_15m_bars = db::schema::bars_15m::dsl::bars_15m
        .load::<Bar>(conn)
        .expect("Could not query 15m bars.");

    assert_eq!(db_15m_bars.len(), 12);

    let db_30m_bars = db::schema::bars_30m::dsl::bars_30m
        .load::<Bar>(conn)
        .expect("Could not query 30m bars.");

    assert_eq!(db_30m_bars.len(), 6);

    let db_1h_bars = db::schema::bars_1h::dsl::bars_1h
        .load::<Bar>(conn)
        .expect("Could not query 1h bars.");

    assert_eq!(db_1h_bars.len(), 3);

    // Clean up tables.
    reset_tables(conn);
}
