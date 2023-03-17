use db::{create_coin, establish_connection, load_config, models::coin::Coin};
use diesel::prelude::*;

#[test]
fn test_create_asset() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the assets table before running tests.
    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting assets table");

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
    let db_assets = db::schema::coins::dsl::coins
        .load::<Coin>(conn)
        .expect("Could not query assets table.");

    // Assert that the assets table now has one entry.
    assert_eq!(db_assets.len(), 1);

    let db_aptos_coin = db_assets.get(0).unwrap();

    // Assert that the symbol of the database entry matches the entry inserted.
    assert_eq!(db_aptos_coin.symbol, "APT".to_string());
}
