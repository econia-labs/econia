use diesel::{prelude::*, Connection, PgConnection};
use models::Coin;
use serde::Deserialize;

use crate::models::NewCoin;

pub mod models;
pub mod schema;

#[derive(Deserialize, Debug)]
pub struct Config {
    pub database_url: String,
}

pub fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

pub fn establish_connection(url: String) -> PgConnection {
    PgConnection::establish(&url)
        .unwrap_or_else(|_| panic!("Could not connect to database {}", url))
}

pub fn create_coin(
    conn: &mut PgConnection,
    account_address: &str,
    module_name: &str,
    struct_name: &str,
    symbol: Option<&str>,
    name: Option<&str>,
    decimals: Option<i16>,
) -> Coin {
    use crate::schema::coins;

    let new_coin = NewCoin {
        account_address,
        module_name,
        struct_name,
        symbol,
        name,
        decimals,
    };

    diesel::insert_into(coins::table)
        .values(&new_coin)
        .get_result(conn)
        .expect("Error adding new coin.")
}

// pub fn create_orderbook(
//     conn: &mut PgConnection,
//     id: i32,
//     base: &str,
//     quote: &str,
//     lot_size: i32,
//     tick_size: i32,
//     min_size: i32,
//     underwriter_id: i32,
// ) -> Orderbook {
//     use crate::schema::orderbooks;

//     let new_orderbook = NewOrderbook {
//         id,
//         base,
//         quote,
//         lot_size,
//         tick_size,
//         min_size,
//         underwriter_id,
//     };

//     diesel::insert_into(orderbooks::table)
//         .values(&new_orderbook)
//         .get_result(conn)
//         .expect("Error adding new orderbook.")
// }
