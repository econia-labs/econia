# Changelog

Econia Move source code adheres to [Semantic Versioning] and [Keep a Changelog] standards.

## [Unreleased]

### Added

- Assorted view functions ([#287], [#301], [#321], [#334]).
- Assorted user- and market-level events with common order ID ([#321], [#347], [#360], [#366]).

### Changed

- Fee assessment updated to be processed per fill, rather than per trade ([#321]).
- Market order size is no longer automatically adjusted based on available market account holdings ([#321]).
- Default self match behavior for swaps (signing swapper self match against signing market account) changed from `ABORT` to `CANCEL_TAKER` ([#321]).
- Started using `order_id` instead of `market_order_id` for new implementations ([#321]).
- Replaced `market::NO_MARKET_ACCOUNT` with `market::NO_TAKER_ADDRESS` to account for signing swappers ([#321]).

### Deprecated

- [`market::OrderBook.taker_events`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L587) ([#321]).
- [`market::Orders`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3337) ([#301]).
- [`market::TakerEvent`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L600) ([#321]).
- [`market::index_orders_sdk()`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3362) ([#287]).
- [`move-to-ts`](https://github.com/hippospace/move-to-ts) attributes ([#292]).

[#287]: https://github.com/econia-labs/econia/pull/287
[#292]: https://github.com/econia-labs/econia/pull/292
[#301]: https://github.com/econia-labs/econia/pull/301
[#321]: https://github.com/econia-labs/econia/pull/321
[#334]: https://github.com/econia-labs/econia/pull/334
[#347]: https://github.com/econia-labs/econia/pull/347
[#360]: https://github.com/econia-labs/econia/pull/360
[#366]: https://github.com/econia-labs/econia/pull/366
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[unreleased]: https://github.com/econia-labs/econia/compare/v4.0.2-audited...HEAD
