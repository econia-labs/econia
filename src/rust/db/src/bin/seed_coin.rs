use db::{create_coin, establish_connection, load_config, schema::coins};
use diesel::prelude::*;

fn main() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    diesel::delete(coins::table)
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
    println!("registered APT to the coins table");

    create_coin(
        conn,
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
        "test_usdc",
        "TestUSDCoin",
        Some("tUSDC"),
        Some("Test USDC"),
        Some(6),
    );
    println!("registered tUSDC to the coins table");

    create_coin(
        conn,
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
        "test_eth",
        "TestETHCoin",
        Some("tETH"),
        Some("Test ETH"),
        Some(6),
    );
    println!("registered tETH to the coins table");
}
