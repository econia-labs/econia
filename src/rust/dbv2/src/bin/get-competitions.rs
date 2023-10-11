use dbv2::{models::CompetitionMetadata, schema::competition_metadata::dsl::*};
use diesel::{self, pg::PgConnection, prelude::*};
use std::env;

fn main() {
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let connection = &mut PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url));
    let metadatas = competition_metadata
        .load::<CompetitionMetadata>(connection)
        .expect("Unable to load");
    println!("Existing competitions:");
    for metadata in metadatas {
        println!("{:#?}", metadata);
    }
}
