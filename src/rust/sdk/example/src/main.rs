use std::str::FromStr;

use aptos_sdk::{
    bcs,
    move_types::{ident_str, language_storage::{ModuleId, StructTag, TypeTag}}, rest_client::{FaucetClient, aptos_api_types::MoveModuleId},
    types::{account_address::AccountAddress, LocalAccount, APTOS_COIN_TYPE, transaction::EntryFunction}
};
use clap::Parser;
use econia_sdk::{EconiaClient, EconiaResult, entry::*, types::order::{Side, Restriction, SelfMatchBehavior}, errors::EconiaError, view::{PriceLevel, EconiaViewClient}};

#[derive(Parser, Debug)]
pub struct Args {
    /// The URL of the Aptos node
    pub url: String,

    /// The URL of the faucet
    pub faucet_url: String,

    /// The address of the Econia contract
    pub address: String,

    /// The address of the Aptos faucet
    pub faucet_address: String,
}

pub struct Init {
    e_apt: TypeTag,
    e_usdc: TypeTag,
    faucet_address: AccountAddress,
    faucet_client: FaucetClient,
    econia_address: AccountAddress,
    econia_client: EconiaClient,
}

macro_rules! print_title {
    ($name:literal) => {
        println!("{:=^50}", $name);
    }
}

macro_rules! wait_for_enter {
    () => {
        {
            println!("Press enter to continue");
            let mut input = String::new();
            std::io::stdin().read_line(&mut input).unwrap();
        }
    }
}

/// Creates the initial variables needed
async fn init(args: &Args) -> Init {
    // Create EAPT and EUSDC `TypeTag`s
    let faucet_address = AccountAddress::from_hex_literal(&args.faucet_address).unwrap();
    let e_apt = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("0x{faucet_address}::test_eth::TestETH")).unwrap(),
    ));
    let e_usdc = TypeTag::Struct(Box::new(
        StructTag::from_str(&format!("0x{faucet_address}::test_usdc::TestUSDC")).unwrap(),
    ));

    // Create a `FaucetClient`
    let faucet_client = FaucetClient::new(
        reqwest::Url::parse(&args.faucet_url).unwrap(),
        reqwest::Url::parse(&args.url).unwrap(),
    );

    // Transform the Econia address from `String` to `AccountAddress`
    let econia_address =
        AccountAddress::from_hex_literal(&args.address).expect("Could not parse address.");

    let (_, econia_client) = account(&faucet_client, &args.url, econia_address.clone()).await;

    Init { e_apt, e_usdc, faucet_address, faucet_client, econia_address, econia_client }
}

/// Creates an account (locally and on the chain) and funds it with APT
pub async fn account(faucet_client: &FaucetClient, url: &str, econia_address: AccountAddress) -> (AccountAddress, EconiaClient) {
    let account = LocalAccount::generate(&mut rand::thread_rng());
    let account_address = account.address();
    faucet_client.create_account(account_address).await.unwrap();
    faucet_client.fund(account_address, 100_000_000_000).await.unwrap();

    let econia_client = EconiaClient::connect(
        reqwest::Url::parse(&url).unwrap(),
        econia_address.clone(),
        account,
        None,
    )
    .await
    .unwrap();

    (account_address, econia_client)
}

/// Funds an amount with the coin specified
pub async fn fund(coin: &TypeTag, amount: u64, econia_client: &mut EconiaClient, faucet_address: AccountAddress) -> EconiaResult<()> {
    let module_id = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::faucet", faucet_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    let entry =
        EntryFunction::new(
            module_id.clone(),
            ident_str!("mint").to_owned(),
            vec![coin.clone().into()],
            vec![
                bcs::to_bytes(&amount)?,
            ],
        );
    econia_client.submit_tx(entry).await?;
    Ok(())
}

/// Returns (best bid level, best ask level)
pub async fn get_best_levels(view_client: EconiaViewClient<'_>, market_id: u64) -> EconiaResult<(Option<PriceLevel>, Option<PriceLevel>)> {
    let levels = view_client.get_price_levels_all(market_id).await?;

    let best_bid_level = if !levels.bids.is_empty() {
        Some(levels.bids.get(0).unwrap().clone())
    } else { None };

    let best_ask_level = if !levels.bids.is_empty() {
        Some(levels.bids.get(0).unwrap().clone())
    } else { None };

    Ok((best_bid_level, best_ask_level))
}

pub async fn place_limit_orders_at_market(view_client: EconiaViewClient<'_>, econia_address: AccountAddress, e_apt: &TypeTag, e_usdc: &TypeTag, market_id: u64, size_lots_of_base: u64, min_bid_price_ticks_of_quote: u64, max_bid_price_ticks_of_quote: u64) -> EconiaResult<(EntryFunction, EntryFunction)> {
    let (best_bid_level, best_ask_level) = get_best_levels(view_client, market_id).await?;

    let bid_entry = if let Some(best_bid_level) = best_bid_level {
        let best_bid_price = best_bid_level.price;
        place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, size_lots_of_base, best_bid_price + 1, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?
    } else {
        place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, size_lots_of_base, min_bid_price_ticks_of_quote, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?
    };

    let ask_entry = if let Some(best_ask_level) = best_ask_level {
        let best_ask_price = best_ask_level.price;
        place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, size_lots_of_base, best_ask_price - 1, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?
    } else {
        place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, size_lots_of_base, max_bid_price_ticks_of_quote, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?
    };

    Ok((bid_entry, ask_entry))
}

pub async fn report_best_price_levels(view_client: EconiaViewClient<'_>, market_id: u64) -> EconiaResult<()> {

    let (best_bid_level, best_ask_level) = get_best_levels(view_client, market_id).await?;

    if best_bid_level.is_none() && best_ask_level.is_none() {
        println!("There is no EAPT being bought or sold right now");
        return Ok(());
    }

    println!("Best price levels:");

    if let Some(best_bid_level) = best_bid_level {
        let best_bid_volume = best_bid_level.size;
        let best_bid_price = best_bid_level.price;
        println!("  Highest BID/BUY @ {best_bid_price} ticks/lot, {best_bid_volume} lots");
    } else {
        println!("  No open bids");
    }

    if let Some(best_ask_level) = best_ask_level {
        let best_ask_volume = best_ask_level.size;
        let best_ask_price = best_ask_level.price;
        println!("  Highest ASK/BUY @ {best_ask_price} ticks/lot, {best_ask_volume} lots");
    } else {
        println!("  No open asks");
    }

    Ok(())
}

#[tokio::main]
async fn main() -> EconiaResult<()> {
    let args = Args::parse();

    let Init { e_apt, e_usdc, faucet_address, faucet_client, econia_address, mut econia_client } = init(&args).await;

    print_title!("Create a market for EAPT/EUSDC");

    let lot_size = 10u64.pow(8 - 3); // eAPT has 8 decimals, want 1/1000th granularity
    let tick_size = 10u64.pow(6 - 3); // eAPT has 6 decimals, want 1/1000th granularity
    let min_size = 1;

    let entry = register_market_base_coin_from_coinstore(econia_address, &e_apt, &e_usdc, &APTOS_COIN_TYPE, lot_size, tick_size, min_size).unwrap();

    econia_client.submit_tx(entry).await?;

    let market_id = econia_client.view_client().get_market_id_base_coin(e_apt.clone().into(), e_usdc.clone().into(), lot_size, tick_size, min_size).await?;

    let market_id = if let Some(market_id) = market_id {
        println!("Market created with ID: {market_id}");
        market_id
    } else {
        panic!("Could not create market."); // Should not happen
    };

    wait_for_enter!();


    print_title!("Set up account A");

    let (account_address_a, mut econia_client_a) = account(&faucet_client, &args.url, econia_address.clone()).await;

    fund(&e_apt, 10u64.pow(18), &mut econia_client_a, faucet_address).await?;
    println!("Minted EAPT to {account_address_a}");

    fund(&e_usdc, 10u64.pow(10), &mut econia_client_a, faucet_address).await?;
    println!("Minted EUSDC to {account_address_a}");

    let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Registered market account for {account_address_a}");

    let e_apt_subunits = 10u64.pow(9);
    let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Deposited EAPT from coinstore for account {account_address_a}");

    let e_usdc_subunits = 10u64.pow(10);
    let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Deposited EUSDC from coinstore for account {account_address_a}");

    println!("{account_address_a} was successfully set up");

    wait_for_enter!();


    print_title!("Place two limit orders with account A");

    let buy_base_lots = 10u64.pow(3);
    let buy_ticks_per_lot = 10u64.pow(3);
    let entry = place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, buy_base_lots, buy_ticks_per_lot, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Placed bid order for account {account_address_a}");

    let sell_base_lots = 10u64.pow(3);
    let sell_ticks_per_lot = 2 * 10u64.pow(3);
    let entry = place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Ask, sell_base_lots, sell_ticks_per_lot, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Placed ask order for account {account_address_a}");

    wait_for_enter!();


    print_title!("Set up account B");

    let (account_address_b, mut econia_client_b) = account(&faucet_client, &args.url, econia_address.clone()).await;

    fund(&e_apt, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;
    println!("Minted EAPT to {account_address_b}");

    fund(&e_usdc, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;
    println!("Minted EUSDC to {account_address_b}");

    let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
    econia_client_b.submit_tx(entry).await?;

    let e_apt_subunits = 10u64.pow(9);
    let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Deposited EAPT from coinstore for account {account_address_b}");

    let e_usdc_subunits = 10u64.pow(10);
    let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Deposited EUSDC from coinstore for account {account_address_b}");

    wait_for_enter!();


    print_title!("Place two market orders with account B");

    let entry = place_market_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Ask, 500, SelfMatchBehavior::CancelMaker)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Placed bid order for account {account_address_b}");

    let entry = place_market_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, 500, SelfMatchBehavior::CancelMaker)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Placed ask order for account {account_address_b}");

    wait_for_enter!();


    print_title!("Check the events for filled orders");

    let market_event_handle_cleation_numbers = econia_client_b.view_client().get_market_event_handle_creation_numbers(account_address_b, market_id, 0).await?.unwrap();

    let events = econia_client_b.get_events_by_creation_number(market_event_handle_cleation_numbers.fill_events_handle_creation_num, econia_client_b.user_account.address(), None, None).await?;

    println!("{} orders were filled", events.len());

    wait_for_enter!();


    print_title!("Cancelling account A's remaining orders");

    let entry = cancel_all_orders_user(econia_address, market_id, Side::Ask)?;
    econia_client_a.submit_tx(entry).await?;

    let entry = cancel_all_orders_user(econia_address, market_id, Side::Bid)?;
    econia_client_a.submit_tx(entry).await?;

    let market_event_handle_cleation_numbers = econia_client_b.view_client().get_market_event_handle_creation_numbers(account_address_b, market_id, 0).await?.unwrap();

    let events = econia_client_a.get_events_by_creation_number(market_event_handle_cleation_numbers.cancel_order_events_handle_creation_num, econia_client_a.user_account.address(), None, None).await?;

    println!("{} orders were cancelled", events.len());

    wait_for_enter!();


    print_title!("Placing competitive limit orders (top-of-book) with account A");

    let (bid_entry, ask_entry) = place_limit_orders_at_market(econia_client.view_client(), econia_address, &e_apt, &e_usdc, market_id, 100, buy_ticks_per_lot, sell_ticks_per_lot).await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (_, start_ask_level) = get_best_levels(econia_client.view_client(), market_id).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(econia_client.view_client(), econia_address, &e_apt, &e_usdc, market_id, 200, buy_ticks_per_lot, sell_ticks_per_lot).await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(econia_client.view_client(), econia_address, &e_apt, &e_usdc, market_id, 300, buy_ticks_per_lot, sell_ticks_per_lot).await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(econia_client.view_client(), econia_address, &e_apt, &e_usdc, market_id, 400, buy_ticks_per_lot, sell_ticks_per_lot).await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(econia_client.view_client(), econia_address, &e_apt, &e_usdc, market_id, 500, buy_ticks_per_lot, sell_ticks_per_lot).await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    report_best_price_levels(econia_client.view_client(), market_id).await?;

    Ok(())
}
