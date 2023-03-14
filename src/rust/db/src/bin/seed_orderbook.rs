use db::{
    create_coin, create_orderbook, establish_connection, load_config,
    schema::{coins, orderbooks},
};
use diesel::prelude::*;

fn main() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    diesel::delete(orderbooks::table)
        .execute(conn)
        .expect("Error deleting orderbooks table");

    diesel::delete(coins::table)
        .execute(conn)
        .expect("Error deleting coins table");

    create_coin(conn, "APT", "Aptos Coin", 8, "0x1::aptos_coin::AptosCoin");
    create_coin(conn, "tUSDC", "TestUSDCoin", 6, "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_usdc::TestUSDCoin");

    let orderbook = create_orderbook(conn, 0, "APT", "tUSDC", 1000, 1000, 1000, 0);

    println!(
        "Inserted {}/{} orderbook into db",
        orderbook.base, orderbook.quote
    );
}
