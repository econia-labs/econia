# Asset management

- [Asset management](#asset-management)
  - [Coin deposits](#coin-deposits)
    - [From a `CoinStore`](#from-a-coinstore)
    - [Standalone coins](#standalone-coins)
  - [Generic asset deposits](#generic-asset-deposits)
  - [Coin withdrawals](#coin-withdrawals)
    - [To a `CoinStore`](#to-a-coinstore)
    - [Standalone coins, signing user](#standalone-coins-signing-user)
    - [Standalone coins, custodian](#standalone-coins-custodian)
  - [Generic asset withdrawals](#generic-asset-withdrawals)

## Coin deposits

### From a `CoinStore`

Coins can be deposited from a user's `aptos_framework::coin::CoinStore` into their [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) via [`deposit_from_coinstore`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_deposit_from_coinstore).

### Standalone coins

Standalone coins can be deposited to a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) via
[`deposit_coins`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_deposit_coins).

## Generic asset deposits

Generic assets can be deposited to a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) via
[`deposit_generic_asset`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_deposit_generic_asset).

## Coin withdrawals

### To a `CoinStore`

Coins can be withdrawn from a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) into their `aptos_framework::coin::CoinStore` via [`withdraw_to_coinstore`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_to_coinstore).

### Standalone coins, signing user

Coins can be withdrawn from a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) and returned as standalone `aptos_framework::coin::Coin` instances (under the authority of a signing user via) [`withdraw_coins_user`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_coins_user).


### Standalone coins, custodian

Coins can be withdrawn from a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) and returned as standalone `aptos_framework::coin::Coin` instances (under the authority of a general custodian) via [`withdraw_coins_custodian`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_coins_custodian).

## Generic asset withdrawals

Generic assets can be withdrawn from a user's [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) via
[`withdraw_generic_asset`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_withdraw_generic_asset).