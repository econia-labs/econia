# Matching

Econia's matching engine is atomic, which means that taker orders either fill against maker orders during the transaction in which they were placed, or do not fill at all.
This fully-autonomous process eliminates the need for a so-called "crank" sometimes required by other on-chain order books, which rely on third parties to trigger the matching process via external transactions.
In practice, this means that Econia matching operations can be stacked back-to-back within a single transaction, for maximum composability.

Moreover, Econia's matching engine routes assets directly between counterparties, rather than updating units of account within a central vault.
This peer-to-peer approach reduces the size of an economic attack target (the vault) by distributing assets among constituents, and eliminates transaction collisions against the matching engine that would otherwise result from user deposits or withdrawals against a global resource.
Econia's matching engine is additionally parallelized across markets, such that `APT/USDC` orders and `wBTC/USDC` orders, for example, can fill concurrently.

Econia's matching engine operates purely on integers, thus eliminating potential arithmetic errors incurred by floating point operations.
This efficient computational strategy is essentially implemented as a loop over head of the [AVL queue] for a market, as seen in [`match()`].

## Functions

Econia's [market module documentation] contains a comprehensive breakdown of the functions associated with Econia's matching engine, with a dependency chart that is duplicated here:

![](/img/matching.svg)

Assorted wrappers allow for orders to be placed by a signing user, by a [custodian], in a `public fun` or in a `public entry fun`, etc.

## Limit orders

Econia supports limit orders with a side, size, price, and restriction, per [`place_limit_order()`].
Notably, this include a size in [lots] and an [integer price].

Depending on the price and restriction, a limit order will first match across the spread as a taker, then will post as a maker order.

### Restrictions

Econia supports the following limit order restriction flags:

| Flag                    | Meaning                                                             |
|-------------------------|---------------------------------------------------------------------|
| [`NO_RESTRICTION`]      | Optionally fill as a taker, then post to the book as a maker        |
| [`FILL_OR_ABORT`]       | Abort if any size posts as a maker (only fill)                      |
| [`POST_OR_ABORT`]       | Abort if any size fills as a taker (only post)                      |
| [`IMMEDIATE_OR_CANCEL`] | Fill as a taker as much as possible, then cancel any remaining size |

### Passive advance limit orders

Econia supports a special type of limit order known as a "passive advance limit order", which allows a user to place a passive limit order that advances a specified amount into the spread.
As described in [`place_limit_order_passive_advance()`], a user can specify a passive advance amount either in ticks or as a percent of the maximum possible advance into the spread, resulting in a passive advance price that is then input to [`place_limit_order()`] as a post-or-abort order.

For example, consider placing a passive advance limit order on a market where the maximum bid price is 100 and the minimum ask price is 106:

| Order side | Advance style | Advance amount | Passive advance price |
|------------|---------------|----------------|-----------------------|
| Bid        | Ticks         | 0              | 100                   |
| Bid        | Ticks         | 1              | 101                   |
| Bid        | Percent       | 100            | 105                   |
| Bid        | Percent       | 80             | 104                   |
| Ask        | Ticks         | 0              | 106                   |
| Ask        | Ticks         | 2              | 104                   |
| Ask        | Percent       | 100            | 101                   |
| Ask        | Percent       | 60             | 103                   |

Passive advance limit orders enable the following scenarios, without any knowledge of the maximum bid or minimum ask price:

* Providing liquidity at the best price offered by the market (0% advance).
* Providing liquidity at the least-aggressive price required to take price-time priority (1 tick advance).
* Providing liquidity at the most-aggressive price while ensuring passivity (100% advance).
* Providing liquidity at the mid price (50% advance).

In the presence of miner extractable value (MEV)-style front-running, any passive advance limit order is essentially converted to a 100% passive advance:
continuing the above example, if someone places a 0% passive advance bid, a front-runner simply needs to place a bid at price 105, execute the legitimate transaction, then cancel their malicious bid, to ensure that the passive advance limit order posts at a price of 105 instead of 100.
Notably, however, even if the legitimate order holder has their bid filled at a price of 105, they will still end up buying at a better price than if they were to place a market order (which would fill against the minimum ask at a price of 106).
Hence passive advance orders can, in the presence of MEV, be used to effectively eliminate paying taker fees, if a user is willing to risk that their order might not fill.

## Taker-only orders

Per [`place_market_order()`], Econia supports taker-only market orders that fill from a user's [market account].
Econia also supports taker-only swaps per assorted wrappers for [`swap()`], which fill from [coins or generic assets] held outside of a [market account].

Like [limit orders], taker-only orders specify an [integer price], but instead of specifying a size in [lots], taker-only orders indicate a minimum and maximum amount of [base and quote asset] to trade.
This is like saying "I am willing to buy up to 36 oranges (maximum base) but no fewer than 12 (minimum base), and I am willing to spend up to $3.50 (maximum quote) but no more than $1.50 per dozen (price)".

## Self match behavior

Econia's matching supports configurable self match behavior, with a self match defined as a hypothetical fill where taker and maker assets are derived from the same market account.
Hence since [limit orders] and [market orders] can both fill as a taker, they require one of the following self match behavior flags:

| Flag             | Behavior during self match     |
|------------------|--------------------------------|
| [`ABORT`]        | Abort                          |
| [`CANCEL_BOTH`]  | Cancel maker and taker orders  |
| [`CANCEL_MAKER`] | Cancel maker order only        |
| [`CANCEL_TAKER`] | Cancel taker order only        |

Note that self matching only applies within a [market account]:
one custodian cannot adversarially cancel orders placed by a different custodian for the same user and market.

<!---Alphabetized reference links-->

[AVL queue]:                             ./orders#order-book-structure
[base and quote asset]:                  ./orders#units-and-market-parameters
[coins or generic assets]:               ./registry#markets
[custodian]:                             ./registry#custodians
[integer price]:                         ./orders#units-and-market-parameters
[limit orders]:                          #limit-orders
[market orders]:                         #taker-only-orders
[lots]:                                  ./orders#units-and-market-parameters
[market account]:                        ./market-account
[market module documentation]:           https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md
[`ABORT`]:                               https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_ABORT
[`CANCEL_BOTH`]:                         https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_CANCEL_BOTH
[`CANCEL_MAKER`]:                        https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_CANCEL_MAKER
[`CANCEL_TAKER`]:                        https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_CANCEL_TAKER
[`FILL_OR_ABORT`]:                       https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_FILL_OR_ABORT
[`IMMEDIATE_OR_CANCEL`]:                 https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_IMMEDIATE_OR_CANCEL
[`NO_RESTRICTION`]:                      https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_NO_RESTRICTION
[`POST_OR_ABORT`]:                       https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_POST_OR_ABORT
[`match()`]:                             https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_match
[`place_limit_order()`]:                 https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order
[`place_limit_order_passive_advance()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_passive_advance
[`place_market_order()`]:                https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_market_order
[`swap()`]:                              https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_swap