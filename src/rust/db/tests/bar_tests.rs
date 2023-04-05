use bigdecimal::BigDecimal;
use chrono::{TimeZone, Utc};
use db::{add_bar, establish_connection, load_config, models::bar::NewBar};
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
        add_bar(conn, &bar);
    }

    // Clean up tables.
    // reset_tables(conn);
}
