# The registry

## General

Econia contains a global registry ([`econia::registry::Registry`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry)) that tracks information about [markets](#markets) and [custodians](#custodians).
Once the Econia account initializes the registry via [`econia::registry::init_registry`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_init_registry), markets and custodian capabilities can be registered permissionlessly.

## Markets

In Econia, markets have an [`econia::registry::TradingPairInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_TradingPairInfo), which designates a base type, quote type, lot size and tick size.
The corresponding order book ([`econia::market::OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook)) for a given `TradingPairInfo` is hosted at the address of the signing account who registers the market, via [`econia::market::register_market_pure_coin`](../../../src/move/Econia/build/docs/market.md#0xc0deb00c_market_register_market_pure_coin) or [`econia::market::register_market_generic`](../../../src/move/Econia/build/docs/market.md#0xc0deb00c_market_register_market_generic).
When a host registers a market, an [`econia::registry::MarketInfo`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_MarketInfo) is added to [`econia::registry::Registry.markets`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_Registry), and a corresponding market ID is generated, with the market ID defined as the 0-indexed vector index in `Registry.markets`.

## Custodians

## Generic markets