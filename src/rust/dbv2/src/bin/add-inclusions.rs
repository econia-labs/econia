use dbv2::schema::aggregator::aggregator::competition_exclusion_list;
use diesel::{self, pg::PgConnection, prelude::*};
use serde::Deserialize;
use std::env;
use std::fs;

#[derive(Deserialize)]
struct CompetitionInclusion {
    user: String,
    competition_id: i32,
}

fn main() {
    let inclusions_json =
        fs::read_to_string("./competition-additional-inclusions.json").expect("No config");
    let inclusions: Vec<CompetitionInclusion> =
        serde_json::from_str(&inclusions_json).expect("Unable to parse");
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let connection = &mut PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url));

    connection
        .transaction(|conn| {
            // for every inclusion, drop that row from the database
            for inclusion in &inclusions {
                let size = diesel::delete(competition_exclusion_list::table.filter(
                    competition_exclusion_list::user.eq(&inclusion.user).and(
                        competition_exclusion_list::competition_id.eq(inclusion.competition_id),
                    ),
                ))
                .execute(conn)
                .expect("Error deleting exclusion");
                if size != 0 {
                    println!("Now included: {}", &inclusion.user);
                } else {
                    println!("Already included: {}", &inclusion.user);
                }
            }
            Ok::<(), diesel::result::Error>(()) // Return OK from the transaction closure
        })
        .expect("Error in transaction");
}
