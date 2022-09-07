# The registry

- [The registry](#the-registry)
  - [General](#general)
  - [Markets](#markets)
  - [Custodians](#custodians)
  - [Asset types](#asset-types)
  - [Market uniqueness](#market-uniqueness)

## General

Econia contains a global [`Registry`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry) that tracks information about [markets](#markets) and [custodians](#custodians).
Once the Econia account initializes the registry, markets and custodian capabilities can be registered permissionlessly.

## Markets

In Econia, markets are specified by a [`TradingPairInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_TradingPairInfo), which designates a base asset, quote asset, lot size, and tick size.
Lot size and tick size are denominated in terms of indivisible subunits of the underlying asset, for example `aptos_framework::coin::Coin.value`, which is an integer (`u64`).
The corresponding [`OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook) for a given [`TradingPairInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_TradingPairInfo) is hosted at the address of the signing account who registers the market, via [`register_market_pure_coin`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_pure_coin) or [`register_market_generic`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_generic).
When a host registers a market, a [`MarketInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_MarketInfo) is added to [`Registry.markets`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry), and a corresponding market ID is generated, with the market ID defined as the 0-indexed vector index in [`Registry.markets`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry).
For example:

| Market ID | Base asset | Quote asset | Lot size | Tick size |
|-----------|------------|-------------|----------|-----------|
| 100       | `wBTC`     | `USDC`      | 100      | 25        |
| 101       | `wBTC`     | `USDT`      | 100      | 25        |
| 102       | `wETH`     | `USDC`      | 1000     | 10        |

## Custodians

Econia manages access control by issuing [`CustodianCapability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_CustodianCapability) resources, with each such capability having a unique serial ID that is generated upon registration.
When a custodian registers via [`register_custodian_capability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_register_custodian_capability), they receive a [`CustodianCapability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_CustodianCapability) with an unalterable ID, which serves as a kind of authentication token for assorted operations throughout Econia.
The number of registered custodian capabilities is tracked by [`Registry.n_custodians`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry).

## Asset types

The base asset and quote asset for a given [`TradingPairInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_TradingPairInfo) are designated by their type info, which is either

1. A phantom coin type for an `aptos_framework::coin::Coin` (e.g. `USDC` in `Coin<USDC>`), or
1. A non-coin type, known as a generic asset type

The type info for both base and quote assets are generated from type arguments during market registration.

A market having both base and quote assets as coin types (e.g. `wBTC/USDC`) is known as a pure coin market, and can be registered via [`register_market_pure_coin`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_pure_coin).
Markets that have at least one generic asset must be registered via [`register_market_generic`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_register_market_generic), which requires a [`CustodianCapability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_CustodianCapability).
Here, a "generic asset transfer custodian" is required to verify deposits, swaps, and withdrawals of generic assets, since it is impossible to verify amounts of non-coin types in the general case.

Presently, both the base and the quote asset for a market can be generic, though in the future, generic quote types will likely be prohibited due to [incentive model considerations](https://github.com/econia-labs/econia/issues/7#issuecomment-1227680515).

## Market uniqueness

For any given pure-coin trading pair, Econia only allows the registration of a single {base, quote, lot size, tick size} tuple:
for example, `wBTC/USD lot size 10, tick size 25` may only be registered once.

For trading pairs having a generic asset, however, there is no such restriction, because in practice generic asset types are a effectively placeholder that allows integrators to register markets for non-coin assets without having to define a new type each time.
For example, a market host can register 4 markets using the provided [`GenericAsset`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_GenericAsset) type flag, all taking the form `GenericAsset/USDC lot size 1, tick size 25`, with each such market representing a different financial instrument:

| Econia Market ID | Base Asset         | Quote Asset |
|------------------|--------------------|-------------|
| 500              | `wBTC put option`  | `USDC`      |
| 501              | `wBTC call option` | `USDC`      |
| 502              | `wETH put option`  | `USDC`      |
| 503              | `wETH call option` | `USDC`      |

Here, a third party maintains their own separate registry to track market metadata, and assuming they are the generic asset transfer custodian for each market, they approve deposits, withdrawals, and swaps for generic assets across all four trading pairs:

![](../diagrams/generic-asset-transfer.png)