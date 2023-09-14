use std::{sync::Arc, time::Duration};

use anyhow::Result;
use data::{markets::MarketsRegisteredPerDay, Data};
use sqlx::PgPool;
use tokio::sync::Mutex;

mod data;

#[tokio::main]
async fn main() -> Result<()> {
    dotenvy::dotenv().ok();

    let pool = PgPool::connect(
        std::env::var("DATABASE_URL")
            .expect("DATABASE_URL should be set")
            .as_str(),
    )
    .await?;

    let default_interval = Duration::from_secs(5);

    let mut data: Vec<Arc<Mutex<dyn Data + Send + Sync>>> = vec![];

    data.push(Arc::new(Mutex::new(MarketsRegisteredPerDay::new(pool.clone()))));

    let mut handles = vec![];

    for data in data {
        handles.push(tokio::spawn(async move {
            let mut data = data.lock().await;

            data.process_and_save_historical_data().await?;

            loop {
                let interval = data.poll_interval().unwrap_or(default_interval);

                tokio::time::sleep(interval).await;

                if data.ready() {
                    data.process_and_save().await?;
                }
            }

            #[allow(unreachable_code)]
            Ok::<(), anyhow::Error>(())
        }));
    }

    for handle in handles {
        handle.await??;
    }

    Ok(())
}
