use anyhow::Result;
use aptos_sdk::bcs;
use aptos_sdk::move_types::ident_str;
use aptos_sdk::move_types::language_storage::ModuleId;
use aptos_sdk::rest_client::aptos_api_types::MoveModuleId;
use aptos_sdk::rest_client::FaucetClient;
use aptos_sdk::types::account_address::AccountAddress;
use aptos_sdk::types::transaction::EntryFunction;
use aptos_sdk::types::LocalAccount;
use aptos_sdk::{
    move_types::language_storage::{StructTag, TypeTag},
    types::APTOS_COIN_TYPE,
};
use econia_sdk::entry::{self, deposit_from_coinstore, register_market_base_coin_from_coinstore};
use econia_sdk::errors::EconiaError;
use econia_sdk::{EconiaClient, EconiaResult};
use std::thread;
use std::time::Duration;
use std::{
    env,
    io::{self, BufRead},
    str::FromStr,
};

#[tokio::main]
async fn main() -> EconiaResult<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 {
        panic!("Expected lot size, tick size and min size arguments (use 0 for each to default)");
    }
    let mut lot_size = args
        .get(1)
        .unwrap()
        .parse::<u64>()
        .expect("Lot size should be an integer");
    if lot_size == 0 {
        lot_size = 100000;
    }
    let mut tick_size = args
        .get(2)
        .unwrap()
        .parse::<u64>()
        .expect("Tick size should be an integer");
    if tick_size == 0 {
        tick_size = 1;
    }
    let mut min_size = args
        .get(3)
        .unwrap()
        .parse::<u64>()
        .expect("Min size should be an integer");
    if min_size == 0 {
        min_size = 500;
    }
    let env_econia_addr = "ECONIA_ADDR";
    let env_faucet_addr = "FAUCET_ADDR";
    let env_node_url = "APTOS_NODE_URL";
    let env_faucet_url = "APTOS_FAUCET_URL";

    let econia_addr = match env::var(env_econia_addr) {
        Ok(val) if !val.trim().is_empty() => val,
        _ => {
            prompt_for_input(
                "Enter the address of an Econia exchange deployment",
                env_econia_addr,
                "0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40",
            )
            .await
        }
    };
    let faucet_addr = match env::var(env_faucet_addr) {
        Ok(val) if !val.trim().is_empty() => val,
        _ => {
            prompt_for_input(
                "Enter the address of an Econia faucet deployment",
                env_faucet_addr,
                "0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878",
            )
            .await
        }
    };
    let node_url = match env::var(env_node_url) {
        Ok(val) if !val.trim().is_empty() => val,
        _ => {
            prompt_for_input(
                "Enter the URL of an Aptos node server",
                env_node_url,
                "http://0.0.0.0:8080/v1",
            )
            .await
        }
    };
    let faucet_url = match env::var(env_faucet_url) {
        Ok(val) if !val.trim().is_empty() => val,
        _ => {
            prompt_for_input(
                "Enter the URL of an Aptos faucet server",
                env_faucet_url,
                "http://0.0.0.0:8081",
            )
            .await
        }
    };

    let econia_address =
        AccountAddress::from_hex_literal(&econia_addr).expect("Could not parse Econia address.");
    let faucet_address =
        AccountAddress::from_hex_literal(&econia_addr).expect("Could not parse Faucet address.");

    let account_maker = LocalAccount::generate(&mut rand::thread_rng());
    let account_taker = LocalAccount::generate(&mut rand::thread_rng());

    let faucet_client = FaucetClient::new(
      reqwest::Url::parse(&faucet_url).unwrap(),
      reqwest::Url::parse(&node_url).unwrap(),
  );

    println!("Connected to faucet...");

    faucet_client
        .create_account(account_maker.address())
        .await
        .unwrap();
    faucet_client
        .create_account(account_taker.address())
        .await
        .unwrap();
    faucet_client
        .fund(account_maker.address(), 100_000_000_000)
        .await
        .unwrap();
    faucet_client
        .fund(account_taker.address(), 100_000_000_000)
        .await
        .unwrap();

    println!("Created & funded wallets...");

    let mut client_maker = EconiaClient::connect(
        reqwest::Url::parse(&node_url).unwrap(),
        econia_address.clone(),
        account_maker,
        None,
    )
    .await
    .unwrap();

    let mut client_taker = EconiaClient::connect(
        reqwest::Url::parse(&node_url).unwrap(),
        econia_address.clone(),
        account_taker,
        None,
    )
    .await
    .unwrap();

    println!("Connected to node...");

    

    let e_apt = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("{faucet_addr}::example_apt::ExampleAPT")).unwrap(),
    ));
    let e_usdc = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("{faucet_addr}::example_usdc::ExampleUSDC")).unwrap(),
    ));

    let mut market_id_opt = client_maker
        .view_client()
        .get_market_id_base_coin(
            e_apt.clone().into(),
            e_usdc.clone().into(),
            lot_size,
            tick_size,
            min_size,
        )
        .await?;
    if market_id_opt == None {
        println!("Creating market...");
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
        client_maker.submit_tx(entry).await?;
        market_id_opt = client_maker
            .view_client()
            .get_market_id_base_coin(
                e_apt.clone().into(),
                e_usdc.clone().into(),
                lot_size,
                tick_size,
                min_size,
            )
            .await?;
        println!("Created market {}.", market_id_opt.unwrap())
    } else {
        println!("Market {} existed.", market_id_opt.unwrap())
    }
    let market_id = market_id_opt.unwrap();

    fund(&e_apt, std::u64::MAX, &mut client_maker, faucet_address)
        .await
        .expect("Failed to fund maker with eAPT");
    fund(&e_usdc, std::u64::MAX, &mut client_taker, faucet_address)
        .await
        .expect("Failed to fund taker with eUSDC");
    println!("Funded maker & taker with sufficient funds...");

    tokio::spawn(async move {
        // Infinite loop
        loop {
            let entry_deposit_maker =
                deposit_from_coinstore(econia_address, &e_apt, market_id, 0, 100 * 10_u64.pow(8))
                    .expect("Failed to create deposit transaction payload (maker)");
            let res = client_maker.submit_tx(entry_deposit_maker).await;
            match res {
                Ok(_) => println!("Deposited to the maker's account."),
                Err(_) => {
                    println!("Failed to deposit to the maker's account (trying again later).")
                }
            }
            thread::sleep(Duration::from_secs(11));
        }
    });

    tokio::spawn(async move {
        // Infinite loop
        loop {
            let entry_deposit_taker =
                deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, 600 * 10_u64.pow(6))
                    .expect("Failed to create deposit transaction payload (taker)");
            let res = client_taker.submit_tx(entry_deposit_taker).await;
            match res {
                Ok(_) => println!("Deposited to the taker's account."),
                Err(_) => {
                    println!("Failed to deposit to the taker's account (trying again later).")
                }
            }
            thread::sleep(Duration::from_secs(11));
        }
    });

    println!("Set up the auto-deposit loops...");
    Ok(())
}

async fn prompt_for_input(
    prompt: &'static str,
    env_var: &'static str,
    default_value: &'static str,
) -> String {
    println!(
        "{} (Enter nothing to default to local OR re-run with {} env var)",
        prompt, env_var
    );

    let stdin = io::stdin();
    let mut input = String::new();
    stdin.read_line(&mut input).expect("Failed to read input!");
    input = String::from(input.trim());
    if input.is_empty() {
        String::from(default_value)
    } else {
        input
    }
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