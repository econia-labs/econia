use std::str::FromStr;

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
    types::order::{Restriction, SelfMatchBehavior, Side},
    view::{EconiaViewClient, PriceLevel},
    EconiaClient, EconiaResult,
};

/*
Running the script:

This script is documented at https://econia.dev/off-chain/rust-sdk.

For a quick start, run the following:

# install and run an aptos node
brew install aptos # only if necessary
mkdir aptos && cd aptos
aptos node run-local-testnet --with-faucet

# export urls in env
export APTOS_NODE_URL=http://0.0.0.0:8080
export APTOS_FAUCET_URL=http://0.0.0.0:8081

# get the econia code
git clone https://github.com/econia-labs/econia.git

# deploy a faucet
cd ./econia/src/move/faucet
aptos init --profile econia_faucet_deploy
export FAUCET_ADDR=<ACCOUNT-FROM-ABOVE> # make sure to put 0x at the start
aptos move publish \
        --named-addresses econia_faucet=$FAUCET_ADDR \
        --profile econia_faucet_deploy \
        --assume-yes

# deploy an exchange
cd ./econia/src/move/econia
aptos init --profile econia_exchange_deploy # enter "local" for the chain
export ECONIA_ADDR=<ACCOUNT-FROM-ABOVE> # make sure to put 0x at the start
aptos move publish \
        --override-size-check \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDR \
        --profile econia_exchange_deploy \
        --assume-yes

# run the script
cargo run -- $APTOS_NODE_URL $APTOS_FAUCET_URL $ECONIA_ADDR $FAUCET_ADDR

# note that when passing addresses to the executable, they must be of the form 0x1234...
*/

#[derive(Parser, Debug)]
pub struct Args {
    /// The URL of the Aptos node
    pub node_url: String,

    /// The URL of the faucet
    pub faucet_url: String,

    /// The address of the Econia contract (e.g. 0x1234...)
    pub econia_address: String,

    /// The address of the Aptos faucet (e.g. 0x1234...)
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
    };
}

macro_rules! wait_for_enter {
    ($name:literal) => {{
        println!("Press enter to continue (next step: {})", $name);
        let mut input = String::new();
        std::io::stdin().read_line(&mut input).unwrap();
    }};
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

    Init {
        e_apt,
        e_usdc,
        faucet_address,
        faucet_client,
        econia_address,
        econia_client,
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
        None,
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

/// Returns (best bid level, best ask level)
pub async fn get_best_levels(
    view_client: EconiaViewClient<'_>,
    market_id: u64,
) -> EconiaResult<(Option<PriceLevel>, Option<PriceLevel>)> {
    let levels = view_client.get_price_levels_all(market_id).await?;

    let best_bid_level = if !levels.bids.is_empty() {
        Some(levels.bids.get(0).unwrap().clone())
    } else {
        None
    };

    let best_ask_level = if !levels.asks.is_empty() {
        Some(levels.asks.get(0).unwrap().clone())
    } else {
        None
    };

    Ok((best_bid_level, best_ask_level))
}

pub async fn place_limit_orders_at_market(
    view_client: EconiaViewClient<'_>,
    econia_address: AccountAddress,
    e_apt: &TypeTag,
    e_usdc: &TypeTag,
    market_id: u64,
    size_lots_of_base: u64,
    min_bid_price_ticks_of_quote: u64,
    max_bid_price_ticks_of_quote: u64,
) -> EconiaResult<(EntryFunction, EntryFunction)> {
    let (best_bid_level, best_ask_level) = get_best_levels(view_client, market_id).await?;

    let bid_entry = if let Some(best_bid_level) = best_bid_level {
        let best_bid_price = best_bid_level.price;
        place_limit_order_user_entry(
            econia_address,
            &e_apt,
            &e_usdc,
            market_id,
            &econia_address,
            Side::Bid,
            size_lots_of_base,
            best_bid_price + 1,
            Restriction::NoRestriction,
            SelfMatchBehavior::CancelMaker,
        )?
    } else {
        place_limit_order_user_entry(
            econia_address,
            &e_apt,
            &e_usdc,
            market_id,
            &econia_address,
            Side::Bid,
            size_lots_of_base,
            min_bid_price_ticks_of_quote,
            Restriction::NoRestriction,
            SelfMatchBehavior::CancelMaker,
        )?
    };

    let ask_entry = if let Some(best_ask_level) = best_ask_level {
        let best_ask_price = best_ask_level.price;
        place_limit_order_user_entry(
            econia_address,
            &e_apt,
            &e_usdc,
            market_id,
            &econia_address,
            Side::Ask,
            size_lots_of_base,
            best_ask_price - 1,
            Restriction::NoRestriction,
            SelfMatchBehavior::CancelMaker,
        )?
    } else {
        place_limit_order_user_entry(
            econia_address,
            &e_apt,
            &e_usdc,
            market_id,
            &econia_address,
            Side::Ask,
            size_lots_of_base,
            max_bid_price_ticks_of_quote,
            Restriction::NoRestriction,
            SelfMatchBehavior::CancelMaker,
        )?
    };

    Ok((bid_entry, ask_entry))
}

pub async fn report_best_price_levels(
    view_client: EconiaViewClient<'_>,
    market_id: u64,
) -> EconiaResult<()> {
    let (best_bid_level, best_ask_level) = get_best_levels(view_client, market_id).await?;

    if best_bid_level.is_none() && best_ask_level.is_none() {
        println!("There is no eAPT being bought or sold right now");
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
        println!("  Lowest ASK/SELL @ {best_ask_price} ticks/lot, {best_ask_volume} lots");
    } else {
        println!("  No open asks");
    }

    Ok(())
}

#[tokio::main]
async fn main() -> EconiaResult<()> {
    let args = Args::parse();

    let Init {
        e_apt,
        e_usdc,
        faucet_address,
        faucet_client,
        econia_address,
        econia_client,
    } = init(&args).await;

    print_title!("Create a market for eAPT/eUSDC");

    let lot_size = 10u64.pow(8 - 3); // eAPT has 8 decimals, want 1/1000th granularity
    let tick_size = 10u64.pow(6 - 3); // eAPT has 6 decimals, want 1/1000th granularity
    let min_size = 1;

    let market_id = econia_client
        .view_client()
        .get_market_id_base_coin(
            e_apt.clone().into(),
            e_usdc.clone().into(),
            lot_size,
            tick_size,
            min_size,
        )
        .await?;

    let market_id = if let Some(market_id) = market_id {
        println!("Market already exists, ID: {market_id}");

        let (_, mut econia_client) =
            account(&faucet_client, &args.node_url, econia_address.clone()).await;
        fund(&e_apt, 10u64.pow(19), &mut econia_client, faucet_address).await?;
        fund(&e_usdc, 10u64.pow(19), &mut econia_client, faucet_address).await?;
        let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
        econia_client.submit_tx(entry).await?;
        let e_apt_subunits = 1000 * 10u64.pow(8);
        let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
        econia_client.submit_tx(entry).await?;

        let e_usdc_subunits = 10_000_000 * 10u64.pow(6);
        let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
        econia_client.submit_tx(entry).await?;

        let (bids_level, asks_level) =
            get_best_levels(econia_client.view_client(), market_id).await?;

        if bids_level.is_some() {
            let entry = place_market_order_user_entry(
                econia_address,
                &e_apt,
                &e_usdc,
                market_id,
                &econia_address,
                Side::Ask,
                9000,
                SelfMatchBehavior::CancelMaker,
            )?;
            econia_client.submit_tx(entry).await?;
        }

        if asks_level.is_some() {
            let entry = place_market_order_user_entry(
                econia_address,
                &e_apt,
                &e_usdc,
                market_id,
                &econia_address,
                Side::Bid,
                9000,
                SelfMatchBehavior::CancelMaker,
            )?;
            econia_client.submit_tx(entry).await?;
        }

        println!("Cleared all previous orders.");

        market_id
    } else {
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

        let market_id = econia_client
            .view_client()
            .get_market_id_base_coin(
                e_apt.clone().into(),
                e_usdc.clone().into(),
                lot_size,
                tick_size,
                min_size,
            )
            .await?;

        let market_id = if let Some(market_id) = market_id {
            println!("Market created with ID: {market_id}");
            market_id
        } else {
            panic!("Could not create market."); // Should not happen
        };
        market_id
    };

    wait_for_enter!("Set up account A");

    print_title!("Set up account A");

    let (account_address_a, mut econia_client_a) =
        account(&faucet_client, &args.node_url, econia_address.clone()).await;

    fund(&e_apt, 10u64.pow(18), &mut econia_client_a, faucet_address).await?;
    println!("Minted eAPT to {account_address_a}");

    fund(&e_usdc, 10u64.pow(10), &mut econia_client_a, faucet_address).await?;
    println!("Minted eUSDC to {account_address_a}");

    let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Registered market account for {account_address_a}");

    let e_apt_subunits = 10 * 10u64.pow(8);
    let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Deposited eAPT from coinstore for account {account_address_a}");

    let e_usdc_subunits = 10_000 * 10u64.pow(6);
    let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
    econia_client_a.submit_tx(entry).await?;
    println!("Deposited eUSDC from coinstore for account {account_address_a}");

    println!("{account_address_a} was successfully set up");

    wait_for_enter!("Place two limit orders with account A");

    print_title!("Place two limit orders with account A");

    // Bid to purchase 1 whole eAPT at a price of 1 whole eUSDC per lot
    // = $1000/eAPT ince there are 1000 lots in a wole eAPT & 1 tick = 0.001 USDC
    let buy_base_lots = 10u64.pow(3);
    let buy_ticks_per_lot = 10u64.pow(3);
    let entry = place_limit_order_user_entry(
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        &econia_address,
        Side::Bid,
        buy_base_lots,
        buy_ticks_per_lot,
        Restriction::NoRestriction,
        SelfMatchBehavior::CancelMaker,
    )?;
    econia_client_a.submit_tx(entry).await?;
    println!("Placed bid order for account {account_address_a}");

    // Ask to sell 1 whole eAPT at a price of 2 whole eUSDC per lot
    // = $2000-eAPT since there are 1000 lots in a whole eAPT & 1 tick = 0.001 USDC
    let sell_base_lots = 10u64.pow(3);
    let sell_ticks_per_lot = 2 * 10u64.pow(3);
    let entry = place_limit_order_user_entry(
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        &econia_address,
        Side::Ask,
        sell_base_lots,
        sell_ticks_per_lot,
        Restriction::NoRestriction,
        SelfMatchBehavior::CancelMaker,
    )?;
    econia_client_a.submit_tx(entry).await?;
    println!("Placed ask order for account {account_address_a}");

    wait_for_enter!("Set up account B");

    print_title!("Set up account B");

    let (account_address_b, mut econia_client_b) =
        account(&faucet_client, &args.node_url, econia_address.clone()).await;

    fund(&e_apt, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;
    println!("Minted eAPT to {account_address_b}");

    fund(&e_usdc, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;
    println!("Minted eUSDC to {account_address_b}");

    let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
    econia_client_b.submit_tx(entry).await?;

    let e_apt_subunits = 10 * 10u64.pow(8);
    let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Deposited eAPT from coinstore for account {account_address_b}");

    let e_usdc_subunits = 10_000 * 10u64.pow(6);
    let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
    econia_client_b.submit_tx(entry).await?;
    println!("Deposited eUSDC from coinstore for account {account_address_b}");

    wait_for_enter!("Place two market orders with account B");

    print_title!("Place two market orders with account B");

    let market_event_handle_creation_numbers = econia_client_b
        .view_client()
        .get_market_event_handle_creation_numbers(account_address_b, market_id, 0)
        .await?
        .unwrap();

    let events = econia_client_b
        .get_events_by_creation_number(
            market_event_handle_creation_numbers.fill_events_handle_creation_num,
            econia_client_b.user_account.address(),
            None,
            None,
        )
        .await?;

    let fill_events_before = events.len();

    let entry = place_market_order_user_entry(
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        &econia_address,
        Side::Ask,
        500,
        SelfMatchBehavior::CancelMaker,
    )?; // Buy 0.5 eAPT
    econia_client_b.submit_tx(entry).await?;
    println!("Placed market bid order for account {account_address_b}");

    let entry = place_market_order_user_entry(
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        &econia_address,
        Side::Bid,
        500,
        SelfMatchBehavior::CancelMaker,
    )?; // Sell 0.5 eAPT
    econia_client_b.submit_tx(entry).await?;
    println!("Placed market ask order for account {account_address_b}");

    wait_for_enter!("Check the events for filled orders");

    print_title!("Check the events for filled orders");

    let market_event_handle_creation_numbers = econia_client_b
        .view_client()
        .get_market_event_handle_creation_numbers(account_address_b, market_id, 0)
        .await?
        .unwrap();

    let events = econia_client_b
        .get_events_by_creation_number(
            market_event_handle_creation_numbers.fill_events_handle_creation_num,
            econia_client_b.user_account.address(),
            None,
            None,
        )
        .await?;

    println!("{} orders were filled", events.len() - fill_events_before);

    wait_for_enter!("Cancelling account A's remaining orders");

    print_title!("Cancelling account A's remaining orders");

    let market_event_handle_creation_numbers = econia_client_b
        .view_client()
        .get_market_event_handle_creation_numbers(account_address_b, market_id, 0)
        .await?
        .unwrap();

    let events = econia_client_a
        .get_events_by_creation_number(
            market_event_handle_creation_numbers.cancel_order_events_handle_creation_num,
            econia_client_a.user_account.address(),
            None,
            None,
        )
        .await?;

    let cancelled_before = events.len();

    let entry = cancel_all_orders_user(econia_address, market_id, Side::Ask)?;
    econia_client_a.submit_tx(entry).await?;

    let entry = cancel_all_orders_user(econia_address, market_id, Side::Bid)?;
    econia_client_a.submit_tx(entry).await?;

    let market_event_handle_creation_numbers = econia_client_b
        .view_client()
        .get_market_event_handle_creation_numbers(account_address_b, market_id, 0)
        .await?
        .unwrap();

    let events = econia_client_a
        .get_events_by_creation_number(
            market_event_handle_creation_numbers.cancel_order_events_handle_creation_num,
            econia_client_a.user_account.address(),
            None,
            None,
        )
        .await?;

    println!("{} orders were cancelled", events.len() - cancelled_before);

    wait_for_enter!("Placing competitive limit orders (top-of-book) with account A");

    print_title!("Placing competitive limit orders (top-of-book) with account A");

    report_best_price_levels(econia_client.view_client(), market_id).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(
        econia_client.view_client(),
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        100,
        buy_ticks_per_lot,
        sell_ticks_per_lot,
    )
    .await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(
        econia_client.view_client(),
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        200,
        buy_ticks_per_lot,
        sell_ticks_per_lot,
    )
    .await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(
        econia_client.view_client(),
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        300,
        buy_ticks_per_lot,
        sell_ticks_per_lot,
    )
    .await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(
        econia_client.view_client(),
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        400,
        buy_ticks_per_lot,
        sell_ticks_per_lot,
    )
    .await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    let (bid_entry, ask_entry) = place_limit_orders_at_market(
        econia_client.view_client(),
        econia_address,
        &e_apt,
        &e_usdc,
        market_id,
        500,
        buy_ticks_per_lot,
        sell_ticks_per_lot,
    )
    .await?;

    econia_client_a.submit_tx(bid_entry).await?;
    econia_client_a.submit_tx(ask_entry).await?;

    report_best_price_levels(econia_client.view_client(), market_id).await?;

    Ok(())
}
