use anyhow::{ensure, Result};
use aptos_sdk::types::APTOS_COIN_TYPE;
use e2e_proc_macro::e2e_test;
use econia_sdk::entry::register_market_base_coin_from_coinstore;
use sqlx::query;

use metadata::Metadata;

use crate::utils::*;

#[e2e_test]
pub async fn test_market_registration<'a>(state: &'a State) -> Result<()> {
    let lot_size = 10u64.pow(8 - 3); // eAPT has 8 decimals, want 1/1000th granularity
    let tick_size = 10u64.pow(6 - 3); // eAPT has 6 decimals, want 1/1000th granularity
    let min_size = state
        .market_size
        .fetch_add(1, std::sync::atomic::Ordering::Relaxed);

    let entry = register_market_base_coin_from_coinstore(
        state.econia_address.clone(),
        &state.e_apt,
        &state.e_usdc,
        &APTOS_COIN_TYPE,
        lot_size,
        tick_size,
        min_size,
    )
    .unwrap();

    let (_, econia_client) =
        account(&state.faucet_client, &state.node_url, state.econia_address).await;

    econia_client.submit_tx(entry).await?;

    std::thread::sleep(TIMEOUT);

    let result = query!("SELECT COUNT(*) AS count FROM market_registration_events")
        .fetch_one(&state.db_pool)
        .await?;

    ensure!(
        result.count.is_some() && result.count.unwrap() > 1,
        "Market not inserted into the database"
    );

    Ok(())
}
