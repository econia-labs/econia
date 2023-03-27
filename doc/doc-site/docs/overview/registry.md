# The registry

Econia contains a global [`Registry`] that tracks information about [markets], [custodians], and [underwriters], all of which can be registered permissionlessly.
An additional [recognized markets] registry provides additional functionality for certain markets that are recognized as following best practices for [market size parameters].

## Markets

Each Econia market is designated by a unique [`MarketInfo`] and a corresponding serial market ID.
A [`MarketInfo`] specifies the base and quote asset types for a market, as well as the corresponding [market size parameters].
While the quote asset must be an `aptos_framework::coin::Coin`, the base asset can be a `Coin` or a "generic asset".
In the latter case, the base type is considered [`GenericAsset`], the market is registered with a corresponding generic base name, and a market-wide [underwriter] ID is specified, which indicates the serial ID of the [underwriter] required to verify generic asset amounts for the market.

Given that the [`Registry`] is a global resource, access to it is gated in the interest of reducing of contentious transactions during runtime.
Hence market parameters are copied to [`MarketAccount`] and [`OrderBook`] structures to reduce lookup queries against the global registry, which could inhibit registration operations via colliding transactions.

To inspect info about a market from the [`Registry`] in the general case, it should either be done off-chain or via the following functions:

- [`get_market_account_market_info_custodian()`]
- [`get_market_account_market_info_user()`]

:::tip

First register a [`MarketAccount`] under the corresponding market ID before calling either function.

:::

## Custodians

Within a given market, a user may register a [`MarketAccount`] where their signature is required to approve order operations and withdrawals.
They may also register additional market accounts, within the same market, under the authority of as many third-party custodians as they want.
The premier use case for a market account with custody delegated to a third party is margin trading, whereby custodians manage their own borrow/lend pools and cancel orders accordingly during liquidation events.

Custodians manage orders and withdrawals on behalf of a user, via a [`CustodianCapability`] with a unique serial ID that is assigned upon issuance.
Via this custodian ID approach only a single entity (either signing user or a delegated custodian), has authority over a certain market account, such that access control can be gated across practically infinite market accounts within a given market.
For example, consider a user with the following market accounts:

| Market ID | Custodian ID     | Authority     |
| --------- | ---------------- | ------------- |
| 123       | [`NO_CUSTODIAN`] | Signing user  |
| 123       | 456              | Custodian 456 |
| 123       | 789              | Custodian 789 |

## Underwriters

As described in [markets], an Econia market can have a `Coin` type base asset or a "generic asset".
The premier use case for generic base assets is for derivatives markets, whereby it is impractical to publish a module with a new `Coin` definition each time a market is to be registered.
Instead, for a derivatives market, Econia allows a third-party underwriter to verify generic asset amounts, which can then be traded from a user's [`MarketAccount`].
Here, a third party is required to underwrite amounts because unlike with `Coin` assets, there is no public API that can verify the amount thereof:
when a user deposits `Coin` assets to their market account, the `Coin.value` getter function returns the amount deposited.
Conversely, for a non-`Coin` asset an underwriter is required to certify the amount deposited to a [`MarketAccount`].

Underwriter operations are facilitated via an [`UnderwriterCapability`] with a unique serial ID that is particular to a given market.
Here, an underwriter presides over asset amount verifications for an entire market, in the case of a generic market:

| Market ID | Underwriter ID     | Asset amount verification authority |
| --------- | ------------------ | ----------------------------------- |
| 123       | [`NO_UNDERWRITER`] | `aptos_framework::coin::Coin` API   |
| 234       | 456                | Underwriter 456                     |
| 345       | 789                | Underwriter 789                     |

## Market uniqueness

A given base type and quote type combination is known as a [`TradingPair`], with a [`MarketInfo`] containing the same fields as well as [market size parameters], and in the case of a generic market, an underwriter ID.
Note that the [`MarketInfo`] for a given market must be unique, but this does not mean that the [`TradingPair`] for a market must be unique.
For example, Econia support registration of the following two pure coin markets:

| Base coin | Quote coin | Lot size    | Tick size   | Minimum order size |
| --------- | ---------- | ----------- | ----------- | ------------------ |
| `APT`     | `USDC`     | 0.1 `APT`   | 0.01 `USDC` | 0.5 `APT`          |
| `APT`     | `USDC`     | 0.01 `APT`  | 0.01 `USDC` | 0.05 `APT`         |
| `APT`     | `USDC`     | 0.001 `APT` | 0.01 `USDC` | 0.005 `APT`        |

As a permissionless system, Econia allows market registrants to select whatever [market size parameters] they want, to provide for a frictionless registration experience if market conditions change:
if the `USDC`-denominated price of asset were to increase 100x, then a given lot size and minimum order size may no longer be appropriate, so here all one has to do is permissionlessly register a new market.

A potential result of this loosely-defined market uniqueness is liquidity fracturing:
if two markets both have reasonable [market size parameters], then market makers and takers may split liquidity between the two venues, leading to price discovery inefficiencies.
To remedy this drawback, Econia additionally tabulates [recognized markets].

## Base asset types

Econia only supports `aptos_framework::coin::Coin`-type quote assets, but base assets do not have to be a `Coin`.
This design enables spot markets, as well as derivatives markets where it is not practical to define a new `Coin` type for each new market.

In the case of a spot market, where both the base asset and the quote asset are `Coin` types, a new market can be registered via [`register_market_base_coin()`], or [`register_market_base_coin_from_coinstore()`], simply by passing in the base `Coin` phantom `CoinType` as a type argument.

When registering a market where the base asset is not a `Coin` type, a new market can be registered via [`register_market_base_generic()`], which instead requires passing in a string denoting the base asset name.
Note that this function also requires an immutable reference to an [underwriter] capability for the underwriter who will certify base asset amounts on the given market.

The corresponding [`MarketInfo`] fields generated for the market then correspond to:

| Field               | If base asset is coin                   | If base asset is not coin         |
| ------------------- | --------------------------------------- | --------------------------------- |
| `base_type`         | Phantom `CoinType` type info for `Coin` | [`GenericAsset`] type info        |
| `base_name_generic` | Empty string                            | Name provided during registration |

## Recognized markets

In addition to a permissionless global [`Registry`], Econia also defines a [`RecognizedMarkets`] structure that tabulates info for markets recognized as having proper [market size parameters]:
for a given [`TradingPair`] there can be only one recognized market, such that, continuing the above example, only one `APT/USDC` market may be considered recognized.

Unlike the [`Registry`], which is a contended global resource, the [`RecognizedMarkets`] is almost always read-only, such that assorted getter functions can be used to look up the recognized market for a given [`TradingPair`].
Here, users can simply decide what assets they want to trade, then look up the corresponding recognized market ID from the [`RecognizedMarkets`] structure.

[custodians]: #custodians
[market size parameters]: ./orders#units-and-market-parameters
[markets]: #markets
[recognized markets]: #recognized-markets
[underwriter]: #underwriters
[underwriters]: #underwriters
[`custodiancapability`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_CustodianCapability
[`genericasset`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_GenericAsset
[`get_market_account_market_info_custodian()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_get_market_account_market_info_custodian
[`get_market_account_market_info_user()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_get_market_account_market_info_user
[`marketaccount`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
[`marketinfo`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_MarketInfo
[`no_custodian`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_NO_CUSTODIAN
[`no_underwriter`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_NO_UNDERWRITER
[`orderbook`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook
[`recognizedmarkets`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_RecognizedMarkets
[`register_market_base_coin()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_coin
[`register_market_base_coin_from_coinstore()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore
[`register_market_base_generic()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_generic
[`registry`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_Registry
[`tradingpair`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_TradingPair
[`underwritercapability`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_UnderwriterCapability
