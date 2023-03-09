use diesel::{pg::Pg, Connection, PgConnection};
use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct Config {
    database_url: String,
}

fn main() {
    let config = load_config();
    println!("{}", config.database_url);

    let _conn = connect(config.database_url);
    println!("Hello, world!");
}

fn load_config() -> Config {
    dotenvy::dotenv().ok();
    match envy::from_env::<Config>() {
        Ok(cfg) => cfg,
        Err(err) => panic!("{:?}", err),
    }
}

fn connect(url: String) -> PgConnection {
    PgConnection::establish(&url)
        .unwrap_or_else(|_| panic!("Could not connect to database {}", url))
}
