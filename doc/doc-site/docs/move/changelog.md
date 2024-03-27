# Changelog

Econia Move source code adheres to [Semantic Versioning] and [Keep a Changelog] standards.

## [v4.3.0]

### Changed

- Change orders and price levels view functions to have public visibility ([#691]).

### Added

- View function struct return decoders for public view functions ([#691]).

## [v4.2.1]

### Fixed

- Cancel event emission logic for max quote traded case ([#629]).

## [v4.2.0]

### Added

- Paginated view functions for open orders and price levels ([#577], [#597]).

## [v4.1.1]

### Added

- Abort for order size change below min size ([#500]).
- Check for empty orders during matching ([#504]).

## [v4.1.0]

### Added

- Assorted view functions ([#287], [#301], [#308], [#321], [#334], [#428], [#429]).
- Assorted user- and market-level events with common order ID ([#321], [#347], [#360], [#366], [#428]).
- Authors field on manifest ([#380]).

### Changed

- Use generic `econia` named address ([#368])
- Fee assessment updated to be processed per fill, rather than per trade ([#321]).
- Market order size is no longer automatically adjusted based on available market account holdings ([#321]).
- Default self match behavior for swaps (signing swapper self match against signing market account) changed from `ABORT` to `CANCEL_TAKER` ([#321]).
- Started using `order_id` instead of `market_order_id` for new implementations ([#321]).
- Replaced `market::NO_MARKET_ACCOUNT` with `market::NO_TAKER_ADDRESS` to account for signing swappers ([#321]).
- Allow limit orders to post less than minimum size if they first fill across the spread ([#347], [#365]).

### Deprecated

- [`market::MakerEvent`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L523) ([#321]).
- [`market::OrderBook.maker_events`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L585) ([#321]).
- [`market::TakerEvent`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L600) ([#321]).
- [`market::OrderBook.taker_events`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L587) ([#321]).
- [`market::Orders`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3337) ([#301]).
- [`market::index_orders_sdk()`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3362) ([#287]).
- [`move-to-ts`](https://github.com/hippospace/move-to-ts) attributes ([#292]).

[#287]: https://github.com/econia-labs/econia/pull/287
[#292]: https://github.com/econia-labs/econia/pull/292
[#301]: https://github.com/econia-labs/econia/pull/301
[#308]: https://github.com/econia-labs/econia/pull/308
[#321]: https://github.com/econia-labs/econia/pull/321
[#334]: https://github.com/econia-labs/econia/pull/334
[#347]: https://github.com/econia-labs/econia/pull/347
[#360]: https://github.com/econia-labs/econia/pull/360
[#365]: https://github.com/econia-labs/econia/pull/365
[#366]: https://github.com/econia-labs/econia/pull/366
[#368]: https://github.com/econia-labs/econia/pull/368
[#380]: https://github.com/econia-labs/econia/pull/380
[#428]: https://github.com/econia-labs/econia/pull/428
[#429]: https://github.com/econia-labs/econia/pull/429
[#500]: https://github.com/econia-labs/econia/pull/500
[#504]: https://github.com/econia-labs/econia/pull/504
[#577]: https://github.com/econia-labs/econia/pull/577
[#597]: https://github.com/econia-labs/econia/pull/597
[#629]: https://github.com/econia-labs/econia/pull/629
[#691]: https://github.com/econia-labs/econia/pull/691
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[v4.1.0]: https://github.com/econia-labs/econia/compare/v4.0.2-audited...v4.1.0-audited
[v4.1.1]: https://github.com/econia-labs/econia/compare/v4.1.0-audited...v4.1.1-audited
[v4.2.0]: https://github.com/econia-labs/econia/compare/v4.1.1-audited...v4.2.0-audited
[v4.2.1]: https://github.com/econia-labs/econia/compare/v4.2.0-audited...v4.2.1-audited
[v4.3.0]: https://github.com/econia-labs/econia/compare/v4.2.1-audited...v4.3.0-audited
