# Using Econia

- [Using Econia](#using-econia)
  - [Core initialization](#core-initialization)
  - [Public entry functions](#public-entry-functions)
  - [Setup](#setup)
    - [Market registration](#market-registration)
    - [User initialization](#user-initialization)
    - [Container registration](#container-registration)
  - [Collateral management](#collateral-management)
    - [Depositing coins](#depositing-coins)
    - [Withdrawing coins](#withdrawing-coins)
  - [Limit orders](#limit-orders)
    - [Ask submission](#ask-submission)
    - [Bid submission](#bid-submission)
    - [Ask cancellation](#ask-cancellation)
    - [Bid cancellation](#bid-cancellation)
  - [Market orders](#market-orders)
    - [Market buy](#market-buy)
    - [Market sell](#market-sell)
  - [Swap wrappers](#swap-wrappers)
    - [Swap buy](#swap-buy)
    - [Swap sell](#swap-sell)

## Core initialization

Before anyone can trade on Econia, it must first be initialized ([`Econia::Init::init_econia()`](../../src/move/econia/build/Econia/docs/Init.md#0xc0deb00c_Init_init_econia)) by the account that published its bytecode to the Aptos blockchain.
For now this will be taking place on the Aptos devnet (which is reset about once weekly), so monitor the [welcome page listing](welcome.md#devnet-account) for the most up-to-date Econia devnet account.
After Econia has been initialized, users may interact with it through the following `public entry` functions:

## Public entry functions

Don't forget to first read the [design overview](https://econia.dev/design-overview) for a quick explanation of how Econia works!

## Setup

### Market registration

[`Econia::Registry::register_market()`](../../src/move/econia/build/Econia/docs/Registry.md#0xc0deb00c_Registry_register_market) registers a market in the Econia registry, if it has not already been registered, and moves an order book to the account of the host who registered it

### User initialization

[`Econia::User::init_user()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_init_user) sets up a user for trading on Econia

### Container registration

[`Econia::User::init_containers()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_init_containers) initializes a user with the resources required to trade on a given market.
Must be executed for each market a user wishes to trade on.

## Collateral management

### Depositing coins

[`Econia::User::deposit()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_deposit) deposits coins into a user's order collateral

### Withdrawing coins

[`Econia::User::withdraw()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_withdraw) withdraws coins from a user's order collateral

## Limit orders

### Ask submission

[`Econia::User::submit_ask()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_submit_ask) submits an ask to the order book for a given market

### Bid submission

[`Econia::User::submit_bid()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_submit_bid) submits a bid to the order book for a given market

### Ask cancellation

[`Econia::User::cancel_ask()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_cancel_ask) cancels an ask on the order book for a given market

### Bid cancellation

[`Econia::User::cancel_bid()`](../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_cancel_bid) cancels a bid on the order book for a given market

## Market orders

### Market buy

[`Econia::Match::submit_market_buy()`](../../src/move/econia/build/Econia/docs/Match.md#0xc0deb00c_Match_submit_market_buy) submits a market buy

### Market sell

[`Econia::Match::submit_market_sell()`](../../src/move/econia/build/Econia/docs/Match.md#0xc0deb00c_Match_submit_market_sell) submits a market sell

## Swap wrappers

### Swap buy

[`Econia::Match::swap_buy()`](../../src/move/econia/build/Econia/docs/Match.md#0xc0deb00c_Match_swap_buy) initializes relevant containers, executes a swap, and withdraws collateral

### Swap sell

[`Econia::Match::swap_sell()`](../../src/move/econia/build/Econia/docs/Match.md#0xc0deb00c_Match_swap_sell) initializes relevant containers, executes a swap, and withdraws collateral