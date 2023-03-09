use db::{create_coin, establish_connection, load_config};

fn main() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url);

    create_coin(conn, "APT", "Aptos Coin", 8, "0x1::aptos_coin::AptosCoin");
    println!("registered APT to the coins table");
}
