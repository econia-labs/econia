use db::{create_coin, establish_connection, load_config, models::coin::Coin};
use diesel::prelude::*;
use helpers::reset_tables;

mod helpers;

#[test]
fn test_create_coin() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the assets table before running tests.
    reset_tables(conn);

    create_coin(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        "APT",
        "Aptos Coin",
        8,
    );

    // Query the assets table in the database.
    let db_coins = db::schema::coins::dsl::coins
        .load::<Coin>(conn)
        .expect("Could not query assets table.");

    // Assert that the assets table now has one entry.
    assert_eq!(db_coins.len(), 1);

    let db_aptos_coin = db_coins.get(0).unwrap();

    // Assert that the symbol of the database entry matches the entry inserted.
    assert_eq!(db_aptos_coin.symbol, "APT".to_string());
}
