use std::{str::FromStr, time::Duration};

use anyhow::{ensure, Result};
use aptos_sdk::{
    bcs,
    move_types::{
        ident_str,
        language_storage::{ModuleId, StructTag, TypeTag},
    },
    rest_client::{aptos_api_types::MoveModuleId, FaucetClient},
    types::{
        account_address::AccountAddress, transaction::EntryFunction, LocalAccount, APTOS_COIN_TYPE,
    },
};
use clap::Parser;
use econia_sdk::{
    entry::*,
    errors::EconiaError,
    EconiaClient, EconiaResult,
};
use sqlx::{PgPool, query};

const TIMEOUT: Duration = Duration::from_secs(1);

#[derive(Parser, Debug)]
pub struct Args {
    /// The URL of the Aptos node
    pub node_url: String,

    /// The URL of the faucet
    pub faucet_url: String,

    /// The address of the Econia contract
    pub econia_address: String,

    /// The address of the Aptos faucet
    pub faucet_address: String,

    /// The database URL
    pub db_url: String,
}

pub struct Init {
    e_apt: TypeTag,
    e_usdc: TypeTag,
    faucet_address: AccountAddress,
    faucet_client: FaucetClient,
    econia_address: AccountAddress,
    econia_client: EconiaClient,
    db_pool: PgPool
}

/// Creates the initial variables needed
async fn init(args: &Args) -> Init {
    // Create eAPT and eUSDC `TypeTag`s
    let faucet_address = AccountAddress::from_hex_literal(&args.faucet_address).unwrap();
    let e_apt = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("0x{faucet_address}::example_apt::ExampleAPT")).unwrap(),
    ));
    let e_usdc = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("0x{faucet_address}::example_usdc::ExampleUSDC")).unwrap(),
    ));

    // Create a `FaucetClient`
    let faucet_client = FaucetClient::new(
        reqwest::Url::parse(&args.faucet_url).unwrap(),
        reqwest::Url::parse(&args.node_url).unwrap(),
    );

    // Transform the Econia address from `String` to `AccountAddress`
    let econia_address =
        AccountAddress::from_hex_literal(&args.econia_address).expect("Could not parse address.");

    let (_, econia_client) = account(&faucet_client, &args.node_url, econia_address.clone()).await;

    let db_pool = PgPool::connect(&args.db_url).await.expect("Could not connect to the database.");

    Init {
        e_apt,
        e_usdc,
        faucet_address,
        faucet_client,
        econia_address,
        econia_client,
        db_pool,
    }
}

/// Creates an account (locally and on the chain) and funds it with APT
pub async fn account(
    faucet_client: &FaucetClient,
    node_url: &str,
    econia_address: AccountAddress,
) -> (AccountAddress, EconiaClient) {
    let account = LocalAccount::generate(&mut rand::thread_rng());
    let account_address = account.address();
    faucet_client.create_account(account_address).await.unwrap();
    faucet_client
        .fund(account_address, 100_000_000_000)
        .await
        .unwrap();

    let econia_client = EconiaClient::connect(
        reqwest::Url::parse(&node_url).unwrap(),
        econia_address.clone(),
        account,
        None,
    )
    .await
    .unwrap();

    (account_address, econia_client)
}

/// Funds an amount with the coin specified
pub async fn fund(
    coin: &TypeTag,
    amount: u64,
    econia_client: &mut EconiaClient,
    faucet_address: AccountAddress,
) -> EconiaResult<()> {
    let module_id = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::faucet", faucet_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    let entry = EntryFunction::new(
        module_id.clone(),
        ident_str!("mint").to_owned(),
        vec![coin.clone().into()],
        vec![bcs::to_bytes(&amount)?],
    );
    econia_client.submit_tx(entry).await?;
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    let Init {
        e_apt,
        e_usdc,
        faucet_address,
        faucet_client,
        econia_address,
        mut econia_client,
        db_pool,
    } = init(&args).await;

    let lot_size = 10u64.pow(8 - 3); // eAPT has 8 decimals, want 1/1000th granularity
    let tick_size = 10u64.pow(6 - 3); // eAPT has 6 decimals, want 1/1000th granularity
    let min_size = 1;

    let entry = register_market_base_coin_from_coinstore(
        econia_address,
        &e_apt,
        &e_usdc,
        &APTOS_COIN_TYPE,
        lot_size,
        tick_size,
        min_size,
    )
    .unwrap();

    econia_client.submit_tx(entry).await?;

    std::thread::sleep(TIMEOUT);

    let result = query!("SELECT COUNT(*) AS count FROM market_registration_events").fetch_one(&db_pool).await?;

    ensure!(result.count == Some(1), "Market not inserted into the database");

    Ok(())
}
