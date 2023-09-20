# Events

## Registry events

Econia emits two types of registry events:

| Event                       | Event handle          | Field name                   |
| --------------------------- | --------------------- | ---------------------------- |
| [`MarketRegistrationEvent`] | [`Registry`]          | `market_registration_events` |
| [`RecognizedMarketEvent`]   | [`RecognizedMarkets`] | `recognized_market_events`   |

Event handles for registry events are created via the `@econia` package account, and are stored as fields in `key`-able resources stored under the `@econia` account.
Hence they can be easily queried via the Aptos node [events by event handle API].

## Market events

### Schemas

Econia emits the following market events:

- [`user::CancelOrderEvent`]
- [`user::ChangeOrderSizeEvent`]
- [`user::FillEvent`]
- [`user::PlaceLimitOrderEvent`]
- [`user::PlaceMarketOrderEvent`]
- [`market::PlaceSwapOrderEvent`]

Unlike [limit orders] and [market orders] which are associated with a [market account], [swaps] are not affiliated with a [market account], and can be executed without a signature.

Hence to ensure comprehensive emission of events, Econia provides event handles as follows:

| Handle wrapper                               | Associated table                | Table indexed by                    |
| -------------------------------------------- | ------------------------------- | ----------------------------------- |
| [`user::MarketEventHandlesForMarketAccount`] | [`user::MarketEventHandles`]    | [Market account ID][market account] |
| [`market::MarketEventHandlesForMarket`]      | [`market::MarketEventHandles`]  | [Market ID][markets]                |
| [`market::SwapperEventHandlesForMarket`]     | [`market::SwapperEventHandles`] | [Market ID][markets]                |

Since these event handles are stored inside tables they cannot be queried via the [events by event handle API], and as such must be queried via the [events by creation number API].
Hence Econia provides associated event handle lookup view functions as follows:

| Handle wrapper                               | Creation info view function                           |
| -------------------------------------------- | ----------------------------------------------------- |
| [`user::MarketEventHandlesForMarketAccount`] | [`user::get_market_event_handle_creation_numbers`]    |
| [`market::MarketEventHandlesForMarket`]      | [`market::get_market_event_handle_creation_info`]     |
| [`market::SwapperEventHandlesForMarket`]     | [`market::get_swapper_event_handle_creation_numbers`] |

### Placing a limit order

When a [signing user or a custodian][market account] places a limit order, a [`user::PlaceLimitOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`].

If the order fills across the spread then for each fill a [`user::FillEvent`] is emitted to the [`user::MarketEventHandlesForMarketAccount`] for both the maker and taker side.

If the limit order does not entirely fill during the function call in which it was placed, and if it is ineligible to post to the book, a [`user::CancelOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`] with one of the following cancel reasons:

| Cancel reason                         | Description                                                                                       |
| ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [`CANCEL_REASON_SELF_MATCH_TAKER`]    | A self match required cancelling the remaining order size                                         |
| [`CANCEL_REASON_IMMEDIATE_OR_CANCEL`] | An immediate-or-cancel order did not fill completely across the spread                            |
| [`CANCEL_REASON_MAX_QUOTE_TRADED`]    | No more quote coins can be traded even though there is still base asset to fill across the spread |

If the order posts to the book and evicts the order with the lowest price time priority, then the evicted order is cancelled and a [`user::CancelOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`] with [`CANCEL_REASON_EVICTION`].

### Placing a market order

When a [signing user or a custodian][market account] places a market order, a [`user::PlaceMarketOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`].

For each fill a [`user::FillEvent`] is emitted to the [`user::MarketEventHandlesForMarketAccount`] for both the maker and taker side.

If the market order does not entirely fill during the function call in which it was placed, a [`user::CancelOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`] with one of the following cancel reasons:

| Cancel reason                          | Description                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [`CANCEL_REASON_SELF_MATCH_TAKER`]     | A self match required cancelling the remaining order size                                         |
| [`CANCEL_REASON_NOT_ENOUGH_LIQUIDITY`] | All liquidity on the book was taken by the order                                                  |
| [`CANCEL_REASON_MAX_QUOTE_TRADED`]     | No more quote coins can be traded even though there is still base asset to fill across the spread |

### Placing a swap order (signing swapper)

When a signing swapper places a swap order, a [`market::PlaceSwapOrderEvent`] is emitted to the associated [`market::SwapperEventHandlesForMarket`].

For each fill a [`user::FillEvent`] is emitted to the [`user::MarketEventHandlesForMarketAccount`] for the maker side, and to the [`market::SwapperEventHandlesForMarket`] for the taker side.

If the swap order does not fill the maximum specified base amount during the function call in which it was placed, a [`user::CancelOrderEvent`] is emitted to the associated [`market::SwapperEventHandlesForMarket`] with the same reasons as for a [market order], as well as two additional cancel reasons that only apply to swaps:

| Cancel reason                           | Description                                                                            |
| --------------------------------------- | -------------------------------------------------------------------------------------- |
| [`CANCEL_REASON_TOO_SMALL_TO_FILL_LOT`] | No more base asset can be traded because the amount left to trade is less than one lot |
| [`CANCEL_REASON_VIOLATED_LIMIT_PRICE`]  | The next order on the book to match against violated the swap order limit price        |

### Placing a swap order (non-signing swapper)

When a swap order is not placed by a signing swapper, a [`market::PlaceSwapOrderEvent`] is emitted to the associated [`market::MarketEventHandlesForMarket`].

For each fill a [`user::FillEvent`] is emitted to the [`user::MarketEventHandlesForMarketAccount`] for the maker side only.

If the swap order does not fill the maximum specified base amount during the function call in which it was placed, a [`user::CancelOrderEvent`] is emitted to the associated [`market::MarketEventHandlesForMarket`] with the same reasons as for a [swap order with a signing swapper].

### Maker self cancel

If, during a self match, the maker side of the order gets cancelled, a [`user::CancelOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`] with [`CANCEL_REASON_SELF_MATCH_MAKER`].

### Changing order size

When a [signing user or a custodian][market account] manually changes the size of an open order, a [`user::ChangeOrderSizeEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`].

### Manual order cancel

When a [signing user or a custodian][market account] manually cancels an open order, a [`user::CancelOrderEvent`] is emitted to the associated [`user::MarketEventHandlesForMarketAccount`] with [`CANCEL_REASON_MANUAL_CANCEL`].

[events by creation number api]: https://fullnode.mainnet.aptoslabs.com/v1/spec#/operations/get_events_by_creation_number
[events by event handle api]: https://fullnode.mainnet.aptoslabs.com/v1/spec#/operations/get_events_by_event_handle
[limit orders]: ../overview/matching.md#limit-orders
[market account]: ../overview/market-accounts.md
[market order]: #placing-a-market-order
[market orders]: ../overview/matching.md#market-orders
[markets]: ../overview/registry.md
[swap order with a signing swapper]: #placing-a-swap-order-signing-swapper
[swaps]: ../overview/matching.md#swaps
[`cancel_reason_eviction`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_EVICTION
[`cancel_reason_immediate_or_cancel`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_IMMEDIATE_OR_CANCEL
[`cancel_reason_manual_cancel`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_MANUAL_CANCEL
[`cancel_reason_max_quote_traded`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_MAX_QUOTE_TRADED
[`cancel_reason_not_enough_liquidity`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_NOT_ENOUGH_LIQUIDITY
[`cancel_reason_self_match_maker`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_SELF_MATCH_MAKER
[`cancel_reason_self_match_taker`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_SELF_MATCH_TAKER
[`cancel_reason_too_small_to_fill_lot`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_TOO_SMALL_TO_FILL_LOT
[`cancel_reason_violated_limit_price`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_CANCEL_REASON_VIOLATED_LIMIT_PRICE
[`market::get_market_event_handle_creation_info`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_market_event_handle_creation_info
[`market::get_swapper_event_handle_creation_numbers`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_swapper_event_handle_creation_numbers
[`market::marketeventhandlesformarket`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#struct-marketeventhandlesformarket
[`market::marketeventhandles`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#resource-marketeventhandles
[`market::placeswaporderevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#struct-placeswaporderevent
[`market::swappereventhandlesformarket`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#struct-swappereventhandlesformarket
[`market::swappereventhandles`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#resource-swappereventhandles
[`marketregistrationevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#struct-marketregistrationevent
[`recognizedmarketevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#struct-recognizedmarketevent
[`recognizedmarkets`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#resource-recognizedmarkets
[`registry`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#resource-registry
[`user::cancelorderevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-cancelorderevent
[`user::changeordersizeevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-changeordersizeevent
[`user::fillevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-fillevent
[`user::get_market_event_handle_creation_numbers`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_event_handle_creation_numbers
[`user::marketeventhandlesformarketaccount`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-marketeventhandlesformarketaccount
[`user::marketeventhandles`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#resource-marketeventhandles
[`user::placelimitorderevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-placelimitorderevent
[`user::placemarketorderevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#struct-placemarketorderevent
