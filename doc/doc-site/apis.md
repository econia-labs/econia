# APIs

- [APIs](#apis)
  - [Core initialization](#core-initialization)
  - [Move interfaces](#move-interfaces)
    - [Setup](#setup)
      - [Market registration](#market-registration)
      - [Custodian registration](#custodian-registration)
      - [User initialization](#user-initialization)
    - [Collateral management](#collateral-management)
      - [Depositing coins](#depositing-coins)
        - [Standalone coins](#standalone-coins)
        - [From a coin store](#from-a-coin-store)
      - [Withdrawing coins](#withdrawing-coins)
        - [Standalone coins](#standalone-coins-1)
          - [As a signing user](#as-a-signing-user)
          - [As a custodian](#as-a-custodian)
        - [To a coin store](#to-a-coin-store)
    - [Limit orders](#limit-orders)
      - [Placing a limit order](#placing-a-limit-order)
        - [As a signing user](#as-a-signing-user-1)
        - [As a custodian](#as-a-custodian-1)
      - [Cancelling a limit order](#cancelling-a-limit-order)
        - [As a signing user](#as-a-signing-user-2)
        - [As a custodian](#as-a-custodian-2)
    - [Placing a market order](#placing-a-market-order)
        - [As a signing user](#as-a-signing-user-3)
        - [As a custodian](#as-a-custodian-3)
    - [Swaps](#swaps)
  - [SDK hooks](#sdk-hooks)
    - [Book orders](#book-orders)
    - [Book price levels](#book-price-levels)
    - [Swap simulator](#swap-simulator)
  - [TypeScript SDK](#typescript-sdk)

## Core initialization

Before anyone can trade on Econia, it must first be initialized ([`econia::init::init_econia`](../../src/move/econia/build/Econia/docs/init.md#0xc0deb00c_init_init_econia)) by the account that published its bytecode to the Aptos blockchain.
For now this will be taking place on the Aptos devnet (which is reset about once weekly), so monitor the [welcome page listing](welcome.md#devnet-account) for the most up-to-date Econia devnet account.
After Econia has been initialized, users may interact with it through the following:

## Move interfaces

Don't forget to first read the [design overview](https://econia.dev/design-overview) for a quick explanation of how Econia works!

### Setup

#### Market registration

[`econia::market::register_market`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market) registers a market in the Econia registry, if it has not already been registered, and moves an order book to the account of the host who registered it

#### Custodian registration
[`econia::registry::register_custodian_capability`](../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_register_custodian_capability) administers to the caller a custodian capability with a unique ID, and updates the registry accordingly

#### User initialization

[`econia::user::register_market_account`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_register_market_account) sets up a user for trading on Econia, for a given `<B, Q, E>`-style market and custodian

### Collateral management

#### Depositing coins

##### Standalone coins

[`econia::user::deposit_collateral`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_deposit_collateral) deposits standalone coins into a user's collateral

##### From a coin store

[`econia::user::deposit_collateral_coinstore`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_deposit_collateral_coinstore) deposits coins into a user's collateral, from their `aptos_framework::coin::CoinStore`

#### Withdrawing coins

##### Standalone coins

###### As a signing user

[`econia::user::withdraw_collateral_user`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_collateral_user) withdraws coins from a user's collateral, requires the user's signature, and returns standalone coins

###### As a custodian

[`econia::user::withdraw_collateral_custodian`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_collateral_custodian) withdraws coins from a user's collateral, requires the capability of a corresponding custodian, and returns standalone coins

##### To a coin store

[`econia::user::withdraw_collateral_coinstore`](../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_collateral_coinstore) withdraws coins from a user's collateral, depositing them to their `aptos_framework::coin::CoinStore`

### Limit orders

#### Placing a limit order

##### As a signing user

[`econia::market::place_limit_order_user`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_limit_order_user) submits an ask or a bid to the order book for a given market, and requires a user's signature

##### As a custodian

[`econia::market::place_limit_order_custodian`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_limit_order_custodian) submits an ask or a bid to the order book for a given market, and requires the capability of a corresponding custodian

#### Cancelling a limit order

##### As a signing user

[`econia::market::cancel_limit_order_user`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_limit_order_user) cancels an ask or a bid on the order book for a given market, and requires a user's signature

##### As a custodian

[`econia::market::cancel_limit_order_custodian`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_limit_order_custodian) cancels an ask or a bid on the order book for a given market, and requires the capability of a corresponding custodian

### Placing a market order

##### As a signing user

[`econia::market::fill_market_order_user`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_fill_market_order_user) fills a market order against the order book for a given market, and requires a user's signature

##### As a custodian

[`econia::market::fill_market_order_custodian`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_fill_market_order_custodian) fills a market order against the order book for a given market, and requires the capability of a corresponding custodian

### Swaps

[`econia::market::swap`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap) buys or sells against the book without the need for a signature, a custodian capability, a market account, or even a user address (`public fun`)

## SDK hooks

The following private functions provide transpilation hooks for SDK generation:

### Book orders

[`econia::market::book_orders_sdk`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_book_orders_sdk) indexes an order book into a vector of orders

### Book price levels

[`econia::market::book_price_levels_sdk`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_price_levels_sdk) indexes an order book into a vector price levels

### Swap simulator

[`econia::market::simulate_swap_sdk`](../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_simulate_swap_sdk) simulates a swap, calculating the number of coins received after the trade, as well as any leftovers if applicable.

## TypeScript SDK

Econia previously contained an auto-generated TypeScript SDK contributed and maintained by [Manahip](http:github.com/manahip).
With Econia's most recent breaking changes, this SDK no longer works, but a new one is on the way.