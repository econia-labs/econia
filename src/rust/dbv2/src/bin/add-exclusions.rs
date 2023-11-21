use dbv2::{
    models::CompetitionExclusion, schema::aggregator::aggregator::competition_exclusion_list,
};
use diesel::{self, pg::PgConnection, prelude::*};
use std::env;
use std::fs;

fn main() {
    let exclusion_json =
        fs::read_to_string("./competition-additional-exclusions.json").expect("No config");
    let exclusions: Vec<CompetitionExclusion> =
        serde_json::from_str(&exclusion_json).expect("Unable to parse");
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let connection = &mut PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url));
    let inserted_exclusions = diesel::insert_into(competition_exclusion_list::table)
        .values(&exclusions)
        .returning(CompetitionExclusion::as_returning())
        .get_results(connection)
        .expect("Error creating new exclusions");
    println!("New exclusions: {:#?}", inserted_exclusions);
}
