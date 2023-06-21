# Off-chain interfaces

## APIs

For REST and Websocket APIs, see the [Econia API reference].

## Registry events

Econia emits two types of registry events:

| Event                       | Event handle          | Field name                   |
| --------------------------- | --------------------- | ---------------------------- |
| [`MarketRegistrationEvent`] | [`Registry`]          | `market_registration_events` |
| [`RecognizedMarketEvent`]   | [`RecognizedMarkets`] | `recognized_market_events`   |

Event handles for registry events are created via the `@econia` package account, and are stored as fields in `key`-able resources stored under the `@econia` account.
Hence they can be easily queried via the Aptos node [events by event handle API].

## Market events

Econia emits two types of market events:

| Event          | Event handle  | Field name     |
| -------------- | ------------- | -------------- |
| [`MakerEvent`] | [`OrderBook`] | `maker_events` |
| [`TakerEvent`] | [`OrderBook`] | `taker_events` |

Unlike registry event handles, market event handles are created via a resource account, since the `@econia` signature is not available each time a new [`OrderBook`] is permissionlessly initialized.
Each [`OrderBook`] is stored as a table entry in the [`OrderBooks`] map stored under the resource account, such that market events should be queried via the Aptos node [events by creation number API].

:::tip

The signing capability for the resource account is stored under the `@econia` account in a [`SignerCapabilityStore`], such that the account number can be easily queried off chain.

:::

Since the resource account is initialized with an `aptos_framework::account::Account`, event stream creation numbers 0 and 1 are reserved for `coin_register_events` and `key_rotation_events` handles.
Hence, for 1-indexed market id $n$, maker events have creation number $2n$ and taker events have creation number $2n + 1$:

| Market ID | [`MakerEvent`] handle creation number | [`TakerEvent`] handle creation number |
| --------- | ------------------------------------- | ------------------------------------- |
| 1         | 2                                     | 3                                     |
| 2         | 4                                     | 5                                     |
| 10        | 20                                    | 21                                    |
| $n$       | $2n$                                  | $2n + 1$                              |

### Example 1

1. Ace places an ask of size 1 price 1000 via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`] against an empty book.
   1. Ace's ask posts to the book: `Order{size: 1, price: 1000, user: 0xace, ...}`.
   1. An event is emitted: `MakerEvent{side: ASK, user: 0xace..., type: PLACE, size: 1, price: 1000, ...}`.
1. Bee places a bid of size 2 price 1000, also via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`].
   Bee's limit order first crosses the spread, matching as a taker buy against Ace's ask and clearing out the book.
   Then the remaining size posts as a bid:
   1. Bee's limit order matches fully against Ace's ask, clearing the book.
   1. An event is emitted: `TakerEvent{side: ASK, maker: 0xace..., size: 1, price: 1000, ...}`.
   1. Bee's remaining order size posts to the book as a bid: `Order{size: 1, price: 1000, user: 0xbee, ...}`.
   1. An event is emitted: `MakerEvent{side: BID, user: 0xbee..., type: PLACE, size: 1, price: 1000, ...}`.

Here, the event stream contains all adequate information for maintaining the order book's depth chart state (e.g. how much size to fill at what price).

### Example 2

1. Ace places an ask of size 1 price 1000 via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`] against an empty book.
   1. Ace's ask posts to the book: `Order{size: 1, price: 1000, user: 0xace, ...}`.
   1. An event is emitted: `MakerEvent{side: ASK, user: 0xace..., type: PLACE, size: 1, price: 1000, ...}`.
1. A DAO treasury management function autonomously submits a market buy of size 1 price 1000 via [`swap_coins()`], which matches against Ace's order.
   1. The swap buy matches fully against Ace's ask, clearing the book.
   1. An event is emitted: `TakerEvent{side: ASK, maker: 0xace..., size: 1, price: 1000, ...}`.
1. Bee places a bid of size 1 price 1000 via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`] against an empty book.
   1. Bee's bid posts to the book: `Order{size: 1, price: 1000, user: 0xbee, ...}`.
   1. An event is emitted: `MakerEvent{side: BID, user: 0xbee..., type: PLACE, size: 1, price: 1000, ...}`.

:::note

Ignoring `market_id`, `market_order_id`, and `custodian_id` fields for both event types, this example emits an event stream identical to that of example 1, hence the order book depth chart state is identical at the conclusion of both examples.

:::

### Example 3

1. Ace places an ask of size 1 price 1000 via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`] against an empty book.
   1. Ace's ask posts to the book: `Order{size: 1, price: 1000, user: 0xace, ...}`.
   1. An event is emitted: `MakerEvent{side: ASK, user: 0xace..., type: PLACE, size: 1, price: 1000, ...}`.
1. A DAO treasury management function autonomously submits a market buy of size 1 price 1000 via [`swap_coins()`], which matches against Ace's order.
   1. The swap buy matches fully against Ace's ask, clearing the book.
   1. An event is emitted: `TakerEvent{side: ASK, maker: 0xace..., size: 1, price: 1000, ...}`.
1. Bee places a bid of size 2 price 1000 via [`place_limit_order_user_entry()`] with restriction [`NO_RESTRICTION`] against an empty book.
   1. Bee's bid posts to the book: `Order{size: 2, price: 1000, user: 0xbee, ...}`.
   1. An event is emitted: `MakerEvent{side: BID, user: 0xbee..., type: PLACE, size: 2, price: 1000, ...}`.
1. Bee changes the size of her order to 1 via [`change_order_size_user()`].
   1. Bee's bid size on the book is updated to: `Order{size: 1, price: 1000, user: 0xbee, ...}`.
   1. An event is emitted: `MakerEvent{side: BID, user: 0xbee..., type: CHANGE, size: 1, price: 1000, ...}`.

:::note

This sequence results in the same final order book depth chart state as in examples 1 and 2, despite a different event stream.

:::

[econia api reference]: https://docs.econia.exchange/#introduction
[events by creation number api]: https://fullnode.testnet.aptoslabs.com/v1/spec#/operations/get_events_by_creation_number
[events by event handle api]: https://fullnode.testnet.aptoslabs.com/v1/spec#/operations/get_events_by_event_handle
[`change_order_size_user()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_change_order_size_user
[`makerevent`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_MakerEvent
[`marketregistrationevent`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_MarketRegistrationEvent
[`no_restriction`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_NO_RESTRICTION
[`orderbooks`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBooks
[`orderbook`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook
[`place_limit_order_user_entry()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_user_entry
[`recognizedmarketevent`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_RecognizedMarketEvent
[`recognizedmarkets`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_RecognizedMarkets
[`registry`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_Registry
[`signercapabilitystore`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore
[`swap_coins()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_swap_coins
[`takerevent`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_TakerEvent
