use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use dbv2::{models::CompetitionMetadata, schema::aggregator::aggregator::competition_metadata};
use diesel::{self, pg::PgConnection, prelude::*};
use serde::Deserialize;
use std::env;
use std::fs;

#[derive(Deserialize, Insertable)]
#[diesel(table_name = competition_metadata)]
struct NewCompetitionMetadata {
    start: DateTime<Utc>,
    end: DateTime<Utc>,
    prize: i32,
    market_id: BigDecimal,
    integrators_required: Vec<Option<String>>,
}

fn main() {
    let metadata_json = fs::read_to_string("./competition-metadata.json").expect("No config");
    let metadata: NewCompetitionMetadata =
        serde_json::from_str(&metadata_json).expect("Unable to parse");
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let connection = &mut PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url));
    let inserted_metadata = diesel::insert_into(competition_metadata::table)
        .values(&metadata)
        .returning(CompetitionMetadata::as_returning())
        .get_result(connection)
        .expect("Error creating new config");
    println!("New competition: {:#?}", inserted_metadata);
}
