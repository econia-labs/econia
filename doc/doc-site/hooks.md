# `move-to-ts` hooks

Econia is designed for use with [Hippo's `move-to-ts` tool], which auto-generates a TypeScript software development kit (SDK) from Move source code.
As such, Econia's Move source code contains the following attributes:

* `#[cmd]`
* `#[method]`
* `#[query]`

In addition to attributed public functions, Econia additionally provides the following SDK hooks for indexing and simulation purposes:

## `OrderBook` methods

* [`orders_vector`] indexes an [`OrderBook`] into a vector of [`SimpleOrder`], for either [`ASK`] or [`BID`]
* [`orders_vectors`] indexes an [`OrderBook`] into a vector of [`SimpleOrder`], for both [`ASK`] and [`BID`]
* [`price_levels_vectors`] indexes an [`OrderBook`] into a vector of [`PriceLevel`], for both [`ASK`] and [`BID`]

## `OrderBook` queries

* [`price_levels_vector`] indexes a vector of [`SimpleOrder`] (the output of [`orders_vector`]) into a vector of [`PriceLevel`]

## Swap simulator

[`swap_coins_simulate`] accepts the same arguments as [`swap_coins`], and is wrapped for SDK generation.

<!---Reference links-->
[`ASK`]:                    ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_ASK
[`BID`]:                    ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_BID
[Hippo's `move-to-ts` tool] https://github.com/hippospace/move-to-ts)
[`OrderBook`]:              ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook
[`orders_vector`]:          ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_orders_vector
[`orders_vectors`]:         ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_orders_vectors
[`price_levels_vector`]:    ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_price_levels_vector
[`price_levels_vectors`]:   ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_price_levels_vectors
[`PriceLevel`]:             ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_PriceLevel
[`SimpleOrder`]:            ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_SimpleOrder
[`swap_coins`]:             ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap_coins
[`swap_coins_simulate`]:    ../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_swap_coins_simulate