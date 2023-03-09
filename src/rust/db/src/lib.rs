use diesel::{prelude::*, Connection, PgConnection};
use models::Coin;
use serde::Deserialize;

use crate::models::NewCoin;

mod models;
mod schema;

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
    symbol: &str,
    name: &str,
    decimals: i16,
    address: &str,
) -> Coin {
    use crate::schema::coins;

    let new_coin = NewCoin {
        symbol,
        name,
        decimals,
        address,
    };

    diesel::insert_into(coins::table)
        .values(&new_coin)
        .get_result(conn)
        .expect("Error adding new coin.")
}
