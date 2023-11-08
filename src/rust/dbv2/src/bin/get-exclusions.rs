use dbv2::{
    models::CompetitionExclusion, schema::aggregator::aggregator::competition_exclusion_list,
};
use diesel::{self, pg::PgConnection, prelude::*};
use std::env;

fn main() {
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let connection = &mut PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url));

    let args: Vec<String> = env::args().collect();
    let mut exclusions;
    if args.len() == 1 {
        exclusions = competition_exclusion_list::table
            .load::<CompetitionExclusion>(connection)
            .expect("Error loading exclusions");
    } else if args.len() == 2 {
        let first_s = args.get(1).unwrap();
        let first_i = first_s.parse::<i32>();
        if first_i.is_ok() {
            exclusions = competition_exclusion_list::table
                .filter(competition_exclusion_list::competition_id.eq(first_i.unwrap()))
                .load::<CompetitionExclusion>(connection)
                .expect("Error loading exclusions");
        } else {
            exclusions = competition_exclusion_list::table
                .filter(competition_exclusion_list::user.eq(first_s))
                .load::<CompetitionExclusion>(connection)
                .expect("Error loading exclusions");
        }
    } else if args.len() == 3 {
        let first_s = args.get(1).unwrap();
        let first_i = first_s.parse::<i32>();
        let second_s = args.get(1).unwrap();
        let second_i = first_s.parse::<i32>();
        let i;
        let s;
        if first_i.is_ok() {
            i = first_i.unwrap();
            s = second_s;
        } else {
            i = second_i.unwrap();
            s = first_s;
        }
        exclusions = competition_exclusion_list::table
            .filter(
                competition_exclusion_list::user
                    .eq(s)
                    .and(competition_exclusion_list::competition_id.eq(i)),
            )
            .load::<CompetitionExclusion>(connection)
            .expect("Error loading exclusions");
    } else {
        panic!("Too many arguments")
    }

    exclusions.sort_by(|a, b| (a.competition_id, &a.user).cmp(&(b.competition_id, &b.user)));
    if exclusions.len() == 0 {
        println!("No exclusions match those parameters.")
    } else {
        println!("EXCLUSIONS:");
        for exclusion in exclusions {
            println!(
                "({}) {}: \"{}\"",
                exclusion.competition_id,
                exclusion.user,
                exclusion.reason.unwrap_or(String::from("No reason given"))
            );
        }
    }
}
