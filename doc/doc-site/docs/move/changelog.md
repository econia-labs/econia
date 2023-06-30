# Changelog

Econia Move source code adheres to [Semantic Versioning] and [Keep a Changelog] standards.

## [Unreleased]

### Added

- Assorted view functions ([#287], [#301], [#315]).
- Fill events with common market order ID ([#315]).

### Deprecated

- [`market::OrderBook.taker_events`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L587) ([#315])
- [`market::Orders`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3337) ([#301])
- [`market::TakerEvent`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L600) ([#315])
- [`market::index_orders_sdk()`](https://github.com/econia-labs/econia/blob/v4.0.2-audited/src/move/econia/sources/market.move#L3362) ([#287])
- [`move-to-ts`](https://github.com/hippospace/move-to-ts) attributes ([#292])

[#287]: https://github.com/econia-labs/econia/pull/287
[#292]: https://github.com/econia-labs/econia/pull/292
[#301]: https://github.com/econia-labs/econia/pull/301
[#315]: https://github.com/econia-labs/econia/pull/315
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[unreleased]: https://github.com/econia-labs/econia/compare/v4.0.2-audited...HEAD
