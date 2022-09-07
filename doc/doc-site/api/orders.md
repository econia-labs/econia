# Order management

- [Order management](#order-management)
  - [Placing a limit order](#placing-a-limit-order)
    - [As a signing user](#as-a-signing-user)
    - [As a general custodian](#as-a-general-custodian)
  - [Cancelling a limit order](#cancelling-a-limit-order)
    - [As a signing user](#as-a-signing-user-1)
    - [As a general custodian](#as-a-general-custodian-1)
  - [Cancelling all limit orders](#cancelling-all-limit-orders)
    - [As a signing user](#as-a-signing-user-2)
    - [As a general custodian](#as-a-general-custodian-2)
  - [Placing a market order](#placing-a-market-order)
    - [As a signing user](#as-a-signing-user-3)
    - [As a general custodian](#as-a-general-custodian-3)
  - [Swaps](#swaps)
    - [Standalone coins](#standalone-coins)
    - [From one `CoinStore` to another](#from-one-coinstore-to-another)
    - [Generic asset](#generic-asset)

## Placing a limit order

### As a signing user

[`place_limit_order_user`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_limit_order_user) places an ask or a bid, under the authority of a signing user.

### As a general custodian

[`place_limit_order_custodian`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_limit_order_custodian) places an ask or a bid, under the authority of a general custodian.

## Cancelling a limit order

### As a signing user

[`cancel_limit_order_user`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_limit_order_user) cancels an ask or a bid, under the authority of a signing user.

### As a general custodian

[`cancel_limit_order_custodian`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_limit_order_custodian) cancels an ask or a bid, under the authority of a general custodian.

## Cancelling all limit orders

### As a signing user

[`cancel_all_limit_orders_user`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_all_limit_orders_user) cancels all of a user's asks or a bids, under the authority of a signing user.

### As a general custodian

[`cancel_all_limit_orders_custodian`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_cancel_all_limit_orders_custodian) cancels all of a user's asks or a bids, under the authority of a general custodian.

## Placing a market order

### As a signing user

[`place_market_order_user`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_market_order_user) places a market buy or sell, under the authority of a signing user.

### As a general custodian

[`place_market_order_custodian`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_place_market_order_custodian) places a market buy or sell, under the authority of a general custodian.

## Swaps

### Standalone coins

[`swap_coins`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap_coins) swaps one coin for another, and does not require a user with a [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount).

### From one `CoinStore` to another

[`swap_between_coinstores`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap_between_coinstores) swaps one coin for another, between a user's `aptos_framework::coin::Coinstore` for each coin, and does not require a user to have a [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount).

### Generic asset

[`swap_generic`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap_generic) executes a swaps on a market with at least one generic asset, and does not require a user with a [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount).