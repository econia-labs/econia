# Rust SDK

The code for the Rust SDK lives in [`/econia/src/rust/sdk`](https://github.com/econia-labs/econia/tree/main/src/rust/sdk/example).
The SDK provides direct access to the Econia protocol, and comes with an example script described below.

# Structure

- The main struct of the SDK is `EconiaClient`.
  This allows you to submit transactions, query events and get a view client (`EconiaViewClient`).
  To create a new `EconiaClient`, you need a node URL, the Econia package address, an `aptos_sdk::types::LocalAccount`, and you can optionally pass a client config.
  You can also pass an API key, that you can get on the [Aptos Developer Portal](https://developers.aptoslabs.com).

- In `econia_sdk::entry`, you can find helper functions to create transactions for every entry function of the Econia package.
  These can then be submitted using the `EconiaClient::submit_tx`.

- To access view functions, you can use `EconiaClient::view_client`, which will return an `EconiaViewClient`, which has bindings for every view function in the Econia client.

# Example script

You can see the source of the script [here](https://github.com/econia-labs/econia/blob/main/src/rust/sdk/example/src/main.rs).
It is recommended that you follow the tutorial with the source code opened in another window.

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

You'll also have the option of entering these as prompts of the script, but the environment variable is preferred because it's easier to run multiple times.
It's time to deploy our own Econia Faucet to the local chain:

```bash
git clone https://github.com/econia-labs/econia.git # only if necessary
cd ./econia/src/move/faucet
aptos init --profile econia_faucet_deploy # enter "local" for the chain
export FAUCET_ADDR=<ACCOUNT-FROM-ABOVE> # make sure to put 0x at the start
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
export ECONIA_ADDR=<ACCOUNT-FROM-ABOVE> # make sure to put 0x at the start
# deploy the exchange (all one command)
aptos move publish \
        --override-size-check \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDR \
        --profile econia_exchange_deploy \
        --assume-yes
```

It's time to run the script!
Setting our environment variables will have cleared the initial setup prompts for us.
In order to run, go into the `econia/src/rust/sdk/example` folder and run `cargo run -- $APTOS_NODE_URL $APTOS_FAUCET_URL $ECONIA_ADDR $FAUCET_ADDR`.

## Understanding the example script

The script is separated in steps.
To go to the next step, press enter.

### Initialization

Before the first step, there is an initialization phase where the Rust code creates the necessary variables for the rest of the code, and creates and funds a main account.
This is handled by the `init` helper function.
The `account` helper function creates a new Aptos account and funds it through the faucet.

### Step 1: Create a market

First, we'll create a new market on the freshly deployed Econia package.

To do this, we will create an `EntryFunction`.
This is a struct passed to `EconiaClient::submit_tx` in order to call a Move package's function.
To do this, we use the helper function `econia_sdk::entry::register_market_base_coin_from_store`.

Once that is done, we can use the result to call the `submit_tx` function.

We then use an `EconiaViewClient` (that is dropped as soon as we finish using it) to get the market ID of the created market.

Expected output:

```
==========Create a market for eAPT/eUSDC==========
Market created with ID: 1
Press enter to continue (next step: Set up account A)
```

The expected output might differ if you already ran the script once without resetting the chain.

Now, the first step is finished.
To go to the next step, press enter.
You will have to do this after each step.

### Step 2: Set up account A

We will use the `account` helper function (you can find its definition in the script's source).
The function initiates an account with some funds from the Aptos faucet.
The function returns a tuple with the address of the newly created account and an `EconiaClient` corresponding to that account.
In order to make a call with this account, you'll have to use this client.
You will have to use multiple clients **and it is important not to mix them up**.

Next, we'll fund the accounts with some example coins (eAPT and eUSDC).
To do so, we use the `fund` helper function (you can find its definition in the script's source).

Now that that's out of the way, we'll register the account to the market.
This is an important step that all accounts have to do before participating in a market.
For this, we'll use the `register_market_account` function that will create the appropriate `EntryFunction` for us.
We then submit it.

We'll deposit some coins to be used to open orders.
For this, we use `deposit_from_coinstore`.

You should see the following (`ADDR_A` would be a randomly generated address):

```
=================Set up account A=================
Minted eAPT to ADDR_A
Minted eUSDC to ADDR_A
Registered market account for ADDR_A
367
Deposited eAPT from coinstore for account ADDR_A
Deposited eUSDC from coinstore for account ADDR_A
ADDR_A was successfully set up
Press enter to continue (next step: Place two limit orders with account A)
```

Account A is now set up and ready to be used.

### Step 3: Place two limit orders with account A

As the title says, it's showtime.
Let's place some orders.

```
======Place two limit orders with account A=======
Placed bid order for account ADDR_A
Placed ask order for account ADDR_A
Press enter to continue (next step: Set up account B)
```

This is a bit more complex than previous code.
Let's inspect the `place_limit_order_user_entry` function.
Its first argument is the Econia package address, as is the case for all other functions in the `entry` module.
Then comes two type arguments, base and quote.
These are Aptos type arguments: see the `init` function to review how they are created,
or look into the Aptos docs for more details.
Next we have the market ID which is a simple integer.
Then comes the integrator.
You can read more about integrators [here](../overview/incentives.md), but for now, we'll just set this to the Econia address.
We then have side, size, and price which are integer values.
You can read more about these [here](../overview/orders.md#units-and-market-parameters).
Next up is [restrictions](../overview/matching#restrictions) and [self match behavior](../overview/matching#self-match-behavior).

### Step 4: Set up account B

We'll now set up a second account.
As this is the same procedure as before, we're not going to explain it again.

```
=================Set up account B=================
Minted eAPT to ADDR_B
Minted eUSDC to ADDR_B
Deposited eAPT from coinstore for account ADDR_B
Deposited eUSDC from coinstore for account ADDR_B
Press enter to continue (next step: Place two market orders with account B)
```

### Step 5: Place two market orders with account A

We'll now place two market orders.
For this, you've probably guessed it, we'll use the `place_market_order_user_entry` function.

```
======Place two market orders with account B======
Placed market bid order for account ADDR_B
Placed market ask order for account ADDR_B
Press enter to continue (next step: Check the events for filled orders)
```

Here, the first 7 arguments are the same.
Then we have self matching behavior as the last argument.

### Step 6: Check the events for filled orders

We'll now check that two orders were filled, as expected.

```
========Check the events for filled orders========
2 orders were filled
Press enter to continue (next step: Cancelling account A's remaining orders)
```

For this, we'll query the filled order events, and check that there are two of them.
To do this, you could simply use the Aptos SDK, but we have a helper function in `EconiaClient`.
First, we get the creation number of different event types, and then we use the `EconiaClient::get_events_by_creation_number` function.

You can see that we use `market_event_handle_creation_numbers.fill_events_handle_creation_num` as an argument to the function, and we get the right type of events.
Last two variables are for pagination, but they're optional, and since we do not need pagination here we'll leave them as `None`.

### Step 7: Cancelling account A's remaining orders

Let's see how we cancel an order.
By now, you should be used to the procedure.
First, create an `EntryFunction`, then submit it.

We'll also query events to make sure we did right.

```
=====Cancelling account A's remaining orders======
2 orders were cancelled
Press enter to continue (next step: Placing competitive limit orders (top-of-book) with account A)
```

Here, just like before, we use `EconiaViewClient::get_market_event_handle_creation_numbers`, but now we pass `market_event_handle_creation_numbers.cancel_order_events_handle_creation_num` as an argument instead.

### Step 8: Placing competitive limit orders (top-of-book) with account A

Lastly, we'll place some more orders.

There are three functions we created here:

- `get_best_levels`: makes use of the `get_price_levels_all` view function to get the best prices and sizes on the market.
- `place_limit_orders_at_market`: uses the previously mentioned `get_best_levels` function to place two limit orders (ask and bid) at a competitive price.
- `report_best_price_levels`: uses `get_best_levels` to print the state of the market.

```
Placing competitive limit orders (top-of-book) with account A
There is no eAPT being bought or sold right now
Best price levels:
  Highest BID/BUY @ 1004 ticks/lot, 500 lots
  Lowest ASK/SELL @ 1996 ticks/lot, 500 lots
```

## Congratulations

You have finished the Rust SDK walkthrough !
