use db::{create_coin, establish_connection, load_config, models::coin::Coin};
use diesel::prelude::*;

fn reset_coin_table(conn: &mut PgConnection) {
    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting coins table");
}

#[test]
fn test_create_coin() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the coins table before running tests.
    reset_coin_table(conn);

    create_coin(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT"),
        Some("Aptos Coin"),
        Some(8),
    );

    // Query the coins table in the database.
    let db_coins = db::schema::coins::dsl::coins
        .load::<Coin>(conn)
        .expect("Could not query coins.");

    // Assert that the coins table now has one entry.
    assert_eq!(db_coins.len(), 1);

    let db_aptos_coin = db_coins.get(0).unwrap();

    // Assert that the symbol of the database entry matches the entry inserted.
    assert_eq!(db_aptos_coin.symbol, Some("APT".to_string()));

    // Clean up table.
    reset_coin_table(conn);
}
