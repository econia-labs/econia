# Market accounts

When an Econia user places a limit order or a market order (or if a custodian places one on their behalf), the user's assets and orders are tracked in a [`MarketAccount`] that is specific to the given [market] and [custodian].

As explained in the [user module documentation], the concatenated result of market and custodian IDs is known as a "market account ID", which is used for [`MarketAccount`] lookup inside a user's [`MarketAccounts`] as well as inside of a [`Collateral`] resource for any relevant coin types.

## Collateral

A user's [`MarketAccount`] tracks the amount of base and quote assets held, as well as the amount available for withdrawal, but it does not actually store any coins held as collateral.
Instead, a separate [`Collateral`] resource is maintained for each relevant coin asset.
This includes:

- The quote coin type for the market.
- The base coin type for the market, if the base type is not [`GenericAsset`].

Coin [`Collateral`] is stored separately from a user's [`MarketAccount`] to reduce type arguments for assorted functions, and is routed directly between counterparties during a trade.
More specifically, when a user deposits assets to Econia for trading, their assets are held locally rather than in a global vault for the entire order book.
Through this direct peer-to-peer trading approach, Econia:

- Eliminates transaction collisions that would otherwise result from deposits and withdrawals against a global resource.
- Reduces the size of a hypothetical economic attack target (a central vault) by distributing its contents across all users.

## Asset counts

An Econia [`MarketAccount`] tracks a user's open asks and bids, as well as the following fields:

| Field           | Meaning                                               |
| --------------- | ----------------------------------------------------- |
| Base total      | Total base asset holdings                             |
| Base available  | Base asset holdings available for withdrawal          |
| Base ceiling    | Amount base total increases to if all open bids fill  |
| Quote total     | Total quote asset holdings                            |
| Quote available | Quote asset holdings available for withdrawal         |
| Quote ceiling   | Amount quote total increases to if all open asks fill |

For example, consider the following sequence:

1. A user opens a [`MarketAccount`] for an `APT/USDC` market.
1. The user deposits 100.00 `USDC`.
1. The user places a bid for 5.00 `APT` at a price of 4.00 `USDC` per `APT` (20.00 `USDC` total).
1. The bid is completely filled.

| Field           | Before deposit | After deposit | After bid placed | After bid fills |
| --------------- | -------------- | ------------- | ---------------- | --------------- |
| Base total      | 0.00           | 0.00          | 0.00             | 5.00            |
| Base available  | 0.00           | 0.00          | 0.00             | 5.00            |
| Base ceiling    | 0.00           | 0.00          | 5.00             | 5.00            |
| Quote total     | 0.00           | 100.00        | 100.00           | 80.00           |
| Quote available | 0.00           | 100.00        | 80.00            | 80.00           |
| Quote ceiling   | 0.00           | 100.00        | 100.00           | 80.00           |

:::tip

Decimal units are presented here for the sake of illustration, but Econia uses [integer units] internally.

:::

## Collateralization

Econia requires complete collateralization within a given [`MarketAccount`]:
base available and quote available amounts must always be nonnegative.
This means that every position on an Econia order book is fully backed with an asset that cannot be withdrawn unless the corresponding maker cancels their order.

Note, however, that Econia still supports margin trading through its issuance of [custodian] capabilities.
For example, a third party can operate its own internal borrow/lend pool and then trade borrowed assets on a user's behalf as a delegated [custodian], cancelling orders and withdrawing assets to cover lenders in the case of a liquidation event.
Here, there is no risk that an Econia order is unbacked (even in the case of borrowed assets), because a trade cannot be placed until the actual underlying asset is deposited into Econia and marked unavailable for withdrawal.
Instead, the risk of default is assumed by lenders external to Econia.

In addition to taker orders placed via a market order from a [`MarketAccount`], Econia also supports swaps that do not require an underlying [`MarketAccount`] or even an `aptos_framework::coin::CoinStore`:
the amount of collateral required to cover the trade must simply be passed as an argument to the relevant function.

## Generic assets

In the case of a [`GenericAsset`] for the base asset on a market, an [underwriter] is required to certify base asset amounts, either within a [`MarketAccount`] or during a swap.

[custodian]: ./registry#custodians
[integer units]: ./orders#units-and-market-parameters
[market]: ./registry#markets
[underwriter]: ./registry#underwriters
[user module documentation]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md
[`collateral`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_Collateral
[`genericasset`]: ./registry#underwriters
[`marketaccounts`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccounts
[`marketaccount`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
