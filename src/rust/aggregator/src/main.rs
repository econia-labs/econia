use std::{
    sync::Arc,
    time::{Duration, SystemTime},
};

use anyhow::Result;
use data::{
    candlesticks::Candlesticks, leaderboards::Leaderboards, user_history::UserHistory, Data,
};
use sqlx::PgPool;
use tokio::{sync::Mutex, task::JoinSet};

mod data;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();
    tracing::info!("Started up.");
    dotenvy::dotenv().ok();

    let pool = PgPool::connect(
        std::env::var("DATABASE_URL")
            .expect("DATABASE_URL should be set")
            .as_str(),
    )
    .await?;
    tracing::info!("Connected to DB.");

    let default_interval = Duration::from_secs(5);

    let data: Vec<Arc<Mutex<dyn Data + Send + Sync>>> = vec![
        Arc::new(Mutex::new(UserHistory::new(pool.clone()))),
        Arc::new(Mutex::new(Candlesticks::new(pool.clone()))),
        Arc::new(Mutex::new(Leaderboards::new(pool.clone()))),
    ];

    let mut handles = JoinSet::new();

    for data in data {
        handles.spawn(async move {
            let mut data = data.lock().await;

            tracing::info!(
                "[{}] Starting process & save (historical).",
                data.model_name()
            );
            data.process_and_save_historical_data().await?;
            tracing::info!(
                "[{}] Finished process & save (historical).",
                data.model_name()
            );

            loop {
                let interval = data.poll_interval().unwrap_or(default_interval);

                tokio::time::sleep(interval).await;

                if data.ready() {
                    tracing::info!("[{}] Starting process & saving.", data.model_name());
                    let start = SystemTime::now();
                    data.process_and_save().await?;
                    let time = start
                        .elapsed()
                        .unwrap_or(Duration::from_secs(0))
                        .as_millis();
                    tracing::info!(
                        "[{}] Finished process & saving in {}ms.",
                        data.model_name(),
                        time
                    );
                } else {
                    tracing::info!("[{}] Data is not ready.", data.model_name());
                }
            }

            #[allow(unreachable_code)]
            Ok::<(), anyhow::Error>(())
        });
    }

    while let Some(res) = handles.join_next().await {
        res??;
    }

    Ok(())
}
