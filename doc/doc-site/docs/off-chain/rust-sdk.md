# Rust SDK

The code for the Rust SDK lives in `/econia/src/rust/sdk`. This code provides programmatic access to Econia exchanges, in addition to offering an example to put it all together shown later in this document.

# Structure

- The main struct of the SDK is `EconiaClient`. This allows you to submit transactions, query events and get a view client (`EconiaViewClient`). To create a new `EconiaClient`, you need a node URL, the Econia contract's address, an `aptos_sdk::types::LocalAccount` and you can optionally pass a client config.

- In `econia_sdk::entry`, you can find helper functions to create transactions for every entry function of the Econia contract. These can then be submitted using the `EconiaClient::submit_tx`.

- To access view functions, you can use `EconiaClient::view_client`, which will return an `EconiaViewClient`, which has bindings for every view function in the Econia client.

# Example script

You can see the source of the script [here]().

## Setup

To run the example script, you first need to run a local Aptos node:

```bash
brew install aptos # only if necessary
mkdir aptos && cd aptos
aptos node run-local-testnet --with-faucet
```

In another terminal, run the following:

```bash
export APTOS_NODE_URL=http://0.0.0.0:8080
export APTOS_FAUCET_URL=http://0.0.0.0:8081
```

You'll also have the option of entering these as prompts of the script, but the environment variable is preferred because it's easier to run multiple times. It's time to deploy our own Econia Faucet to the local chain:

```bash
git clone https://github.com/econia-labs/econia.git # only if necessary
cd ./econia/src/move/faucet
aptos init --profile econia_faucet_deploy # enter "local" for the chain
export FAUCET_ADDR=<ACCOUNT-FROM-ABOVE>
# deploy the faucet (all one command)
aptos move publish \
        --named-addresses econia_faucet=$FAUCET_ADDR \
        --profile econia_faucet_deploy \
        --assume-yes
```

You also need to deploy Econia:

```bash
cd ./econia/src/move/econia
aptos init --profile econia_exchange_deploy # enter "local" for the chain
export ECONIA_ADDR=<ACCOUNT-FROM-ABOVE>
# deploy the exchange (all one command)
aptos move publish \
        --override-size-check \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDR \
        --profile econia_exchange_deploy \
        --assume-yes
```

It's time to run the script! Setting our environment variables will have cleared the initial setup prompts for us. In order to run, go into the `econia/src/rust/sdk/example` folder and run `cargo run -- $APTOS_NODE_URL $APTOS_FAUCET_URL $ECONIA_ADDR $FAUCET_ADDR`.

## Understanding the example script

The script is separated in steps. To go to the next step, press enter.

### Initialization

Before the first step, there is an initialization phase where the Rust code creates the necessary variables for the rest of the code, and creates and funds a main account. This is handled by the `init` helper function. The `account` helper function creates a new Aptos account and funds it through the faucet.

```rust
let args = Args::parse();

let Init { e_apt, e_usdc, faucet_address, faucet_client, econia_address, mut econia_client } = init(&args).await;
```

### Step 1: Create a market

First, we'll create a new market on the freshly deployed Econia contract.

To do this, we will create an `EntryFunction`. This is a struct passed to `EconiaClient::submit_tx` in order to call a contract's function. To do this, we use the helper function `econia_sdk::entry::register_market_base_coin_from_store`:

```rust
let lot_size = 10u64.pow(8 - 3); // eAPT has 8 decimals, want 1/1000th granularity
let tick_size = 10u64.pow(6 - 3); // eAPT has 6 decimals, want 1/1000th granularity
let min_size = 1;

let entry = register_market_base_coin_from_coinstore(econia_address, &e_apt, &e_usdc, &APTOS_COIN_TYPE, lot_size, tick_size, min_size).unwrap();
```

Once that is done, we can use the result to call the `submit_tx` function:

```rust
econia_client.submit_tx(entry).await?;
```

We then use an `EconiaViewClient` (that is dropped as soon as we finish using it) to get the market ID of the created market.

```rust
let market_id = econia_client.view_client().get_market_id_base_coin(e_apt.clone().into(), e_usdc.clone().into(), lot_size, tick_size, min_size).await?;

let market_id = if let Some(market_id) = market_id {
        market_id
} else {
        panic!("Could not create market."); // Should not happen
};
```

Now, the first step is finished. To go to the next step, press enter. You will have to do this after each step.

### Step 2: Set up account A

We will use the `account` helper function (you can find its definition in the script's source). The function initiates an account with some funds from the Aptos faucet. The function returns a tuple with the address of the newly created account and an `EconiaClient` corresponding to that account. In order to make a call with this account, you'll have to use this client. You will have to use multiple clients **and it is important not to mix them up**.

```rust
let (account_address_a, mut econia_client_a) = account(&faucet_client, &args.url, econia_address.clone()).await;
```

Next, we'll fund the accounts with some example coins (eAPT and eUSDC). To do so, we use the `fund` helper function (you can find its definition in the script's source).

```rust
fund(&e_apt, 10u64.pow(18), &mut econia_client_a, faucet_address).await?;

fund(&e_usdc, 10u64.pow(10), &mut econia_client_a, faucet_address).await?;
```

Now that that's out of the way, we'll register the account to the market. This is an important step that all accounts have to do before participating in a market. For this, we'll use the `register_market_account` function that will create the appropriate `EntryFunction` for us. We then submit it.

```rust
let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
econia_client_a.submit_tx(entry).await?;
```

We'll deposit some coins to be used to open orders. For this, we use `deposit_from_coinstore`.

```rust
let e_apt_subunits = 10u64.pow(9);
let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
econia_client_a.submit_tx(entry).await?;

let e_usdc_subunits = 10u64.pow(10);
let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
```

Account A is now set up and ready to be used.

### Step 3: Place two limit orders with account A

As the title says, it's showtime. Let's place some orders.

```rust
let buy_base_lots = 10u64.pow(3);
let buy_ticks_per_lot = 10u64.pow(3);
let entry = place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, buy_base_lots, buy_ticks_per_lot, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?;
econia_client_a.submit_tx(entry).await?;

let sell_base_lots = 10u64.pow(3);
let sell_ticks_per_lot = 2 * 10u64.pow(3);
let entry = place_limit_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Ask, sell_base_lots, sell_ticks_per_lot, Restriction::NoRestriction, SelfMatchBehavior::CancelMaker)?;
econia_client_a.submit_tx(entry).await?;
```

This is a bit more complex than previous code. Let's inspect the `place_limit_order_user_entry` function. It's first argument, as all first arguments of functions in the `entry` module is the Econia contract address. Then comes two type arguments, base and quote. These are Aptos type arguments, you can see in the `init` function how to create a type argument, or look into the Aptos docs for more details. Next we have the market ID which is a simple integer. Then comes the integrator. You can read more about integrators [here](), but for now, we'll just set this to the Econia address. We then have side, size and price which are all pretty self-explanatory. Next up is restrictions and self match behavior. You can read more about each of these enums variants [here](https://github.com/econia-labs/econia/blob/6256710b2ebe306d2861e6d02d72f95373500ab6/src/move/econia/sources/market.move#L859-L942).

### Step 4: Set up account B

We'll now set up a second account. As this is the same procedure as before, we're not going to explain it again.

```rust
let (account_address_b, mut econia_client_b) = account(&faucet_client, &args.url, econia_address.clone()).await;

fund(&e_apt, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;

fund(&e_usdc, 10u64.pow(19), &mut econia_client_b, faucet_address).await?;

let entry = register_market_account(econia_address, &e_apt, &e_usdc, market_id, 0)?;
econia_client_b.submit_tx(entry).await?;

let e_apt_subunits = 10u64.pow(9);
let entry = deposit_from_coinstore(econia_address, &e_apt, market_id, 0, e_apt_subunits)?;
econia_client_b.submit_tx(entry).await?;

let e_usdc_subunits = 10u64.pow(10);
let entry = deposit_from_coinstore(econia_address, &e_usdc, market_id, 0, e_usdc_subunits)?;
econia_client_b.submit_tx(entry).await?;
```

### Step 5: Place two market orders with account A

We'll now place to market orders. For this, you've probably guessed it, we'll use the `place_market_order_user_entry` function as follows:

```rust
let entry = place_market_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Ask, 500, SelfMatchBehavior::CancelMaker)?;
econia_client_b.submit_tx(entry).await?;

let entry = place_market_order_user_entry(econia_address, &e_apt, &e_usdc, market_id, &econia_address, Side::Bid, 500, SelfMatchBehavior::CancelMaker)?;
econia_client_b.submit_tx(entry).await?;
```

Here, the first 7 arguments are the same. Then we have self matching behavior as the last argument.

### Step 6: Check the events for filled orders

We'll now check that two orders were filled, as expected. For this, we'll query the filled order events, and check that there are two of them. To do this, you could simply use the Aptos SDK, but we have a helper function in `EconiaClient`. First, we get the creation number of different event types, and then we use the `EconiaClient::get_events_by_creation_number` function as follows:

```rust
let market_event_handle_creation_numbers = econia_client_b.view_client().get_market_event_handle_creation_numbers(account_address_b, market_id, 0).await?.unwrap();

let events = econia_client_b.get_events_by_creation_number(market_event_handle_creation_numbers.fill_events_handle_creation_num, econia_client_b.user_account.address(), None, None).await?;

println!("{} orders were filled", events.len());
```

You can see that we use `market_event_handle_creation_numbers.fill_events_handle_creation_num` as an argument to the function, and we get the right type of events. Last two variables are for pagination, but they're optional, and since we do not need pagination here we'll leave them as `None`.

### Step 7: Cancelling account A's remaining orders

Let's see how we cancel an order. By now, you should be used to the procedure. First, create an `EntryFunction`, then submit it:

```rust
let entry = cancel_all_orders_user(econia_address, market_id, Side::Ask)?;
econia_client_a.submit_tx(entry).await?;

let entry = cancel_all_orders_user(econia_address, market_id, Side::Bid)?;
econia_client_a.submit_tx(entry).await?;

```

We'll also query events to make sure we did right:

```rust
let market_event_handle_creation_numbers = econia_client_b.view_client().get_market_event_handle_creation_numbers(account_address_b, market_id, 0).await?.unwrap();

let events = econia_client_a.get_events_by_creation_number(market_event_handle_creation_numbers.cancel_order_events_handle_creation_num, econia_client_a.user_account.address(), None, None).await?;

println!("{} orders were cancelled", events.len());
```

Here, just like before, we use `EconiaViewClient::get_market_event_handle_creation_numbers`, but now we pass `market_event_handle_creation_numbers.cancel_order_events_handle_creation_num` as an argument instead.

### Step 8: Placing competitive limit orders (top-of-book) with account A

Lastly, we'll place some more orders.

There are three functions we created here:

- `get_best_levels`: makes use of the `get_price_levels_all` view function to get the best prices and sizes on the market.
- `place_limit_orders_at_market`: uses the previously mentioned `get_best_levels` function to place two limit orders (ask and bid) at a competitive price.
- `report_best_price_levels`: uses `get_best_levels` to print the state of the market.

## Congratulations

You have finished the Rust SDK walkthrough !
