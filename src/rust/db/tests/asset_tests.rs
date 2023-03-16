use db::{create_asset, establish_connection, load_config, models::Asset};
use diesel::prelude::*;

#[test]
fn test_create_asset() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    // Delete all entries in the assets table before running tests.
    diesel::delete(db::schema::assets::table)
        .execute(conn)
        .expect("Error deleting assets table");

    create_asset(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT"),
        Some("Aptos Coin"),
        Some(8),
    );

    // Query the assets table in the database.
    let db_assets = db::schema::assets::dsl::assets
        .load::<Asset>(conn)
        .expect("Could not query assets table.");

    // Assert that the assets table now has one entry.
    assert_eq!(db_assets.len(), 1);

    let db_aptos_coin = db_assets.get(0).unwrap();

    // Assert that the symbol of the database entry matches the entry inserted.
    assert_eq!(db_aptos_coin.symbol, Some("APT".to_string()));
}
