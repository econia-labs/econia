# Registration

- [Registration](#registration)
  - [The registry](#the-registry)
  - [Custodian capabilities](#custodian-capabilities)
  - [Markets](#markets)
    - [Pure coin markets](#pure-coin-markets)
    - [Generic markets](#generic-markets)
  - [Market accounts](#market-accounts)

## The registry

Before anyone can trade on Econia, the [`Registry`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry) must first be initialized by the account that published Econia to the Aptos blockchain, via [`init_registry`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_init_registry).
For now this will be taking place on the Aptos devnet (which is reset about once weekly), so monitor the [welcome page listing](../welcome.md#devnet-account) for the most up-to-date Econia devnet account.

## Custodian capabilities

Custodian capabilities can be registered via
[`register_custodian_capability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_register_custodian_capability).

## Markets

### Pure coin markets

Pure coin markets can be registered via
[`register_market_pure_coin`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_pure_coin).

### Generic markets

Markets having at least one non-coin asset can be registered via [`register_market_generic`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_generic).

## Market accounts

A [`MarketAccount`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccount) can be registered via [`register_market_account`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_register_market_account).
