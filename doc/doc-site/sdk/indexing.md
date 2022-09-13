# Indexing

- [Indexing](#indexing)
  - [Move functions](#move-functions)
    - [`OrderBook` methods](#orderbook-methods)
    - [Queries](#queries)
  - [TS SDK functions](#ts-sdk-functions)

## Move functions

### `OrderBook` methods

* [`orders_vector`] indexes an [`OrderBook`] into a vector of [`SimpleOrder`], for either [`ASK`] or [`BID`]
* [`orders_vectors`] indexes an [`OrderBook`] into a vector of [`SimpleOrder`], for both [`ASK`] and [`BID`]
* [`price_levels_vectors`] indexes an [`OrderBook`] into a vector of [`PriceLevel`], for both [`ASK`] and [`BID`]

### Queries

* [`price_levels_vector`] indexes a vector of [`SimpleOrder`] (the output of [`orders_vector`]) into a vector of [`PriceLevel`]

## TS SDK functions

Coming soon!

<!---Reference links-->
[`ASK`]:                  ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_ASK
[`BID`]:                  ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_BID
[`OrderBook`]:            ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook
[`orders_vector`]:        ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_orders_vector
[`orders_vectors`]:       ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_orders_vectors
[`price_levels_vector`]:  ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_price_levels_vector
[`price_levels_vectors`]: ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_price_levels_vectors
[`PriceLevel`]:           ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_PriceLevel
[`SimpleOrder`]:          ../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_SimpleOrder