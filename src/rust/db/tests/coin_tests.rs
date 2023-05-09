use db::{
    create_coin, establish_connection,
    models::coin::{Coin, NewCoin},
};
use diesel::prelude::*;
use helpers::{load_config, reset_tables};

mod helpers;

#[test]
fn test_create_coin() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    // Delete all entries in the assets table before running tests.
    reset_tables(conn);

    let coin = NewCoin {
        account_address: "0x1",
        module_name: "aptos_coin",
        struct_name: "AptosCoin",
        symbol: "APT",
        name: "Aptos Coin",
        decimals: 8,
    };

    create_coin(conn, &coin).unwrap();

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
