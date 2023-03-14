use db::{
    create_coin,
    establish_connection,
    load_config,
    models::Coin,
    // schema::coins::dsl::*,
};
use diesel::prelude::*;

#[test]
fn test_create_coin() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    diesel::delete(db::schema::coins::table)
        .execute(conn)
        .expect("Error deleting coins");

    create_coin(
        conn,
        "0x1",
        "aptos_coin",
        "AptosCoin",
        Some("APT"),
        Some("Aptos Coin"),
        Some(8),
    );

    let db_coins = db::schema::coins::dsl::coins
        .load::<Coin>(conn)
        .expect("Could not query coins.");

    assert_eq!(db_coins.len(), 1);

    let db_aptos_coin = db_coins.get(0).unwrap();
    assert_eq!(db_aptos_coin.symbol, Some("APT".to_string()));
}
