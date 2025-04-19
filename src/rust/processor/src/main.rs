use aptos_indexer_processor_sdk::postgres::basic_processor::process;
use diesel_migrations::{embed_migrations, EmbeddedMigrations};
use processor::process_transactions;

mod events;
mod processor;

// This is just a dummy to pass to the process functions, no migrations will be run
pub const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    process(
        "econia".to_string(),
        MIGRATIONS,
        async |transactions, conn_pool| {
            process_transactions(transactions, conn_pool.clone()).await.unwrap();
            Ok(())
        },
    ).await
}
