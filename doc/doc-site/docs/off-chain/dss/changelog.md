# Changelog

Stable DSS builds are tracked on the [`dss-stable`] branch with tags like [`dss-v1.3.0`][v1.3.0].

## [v1.4.0]

### Added

- Add coins pipeline with `APTOS_NETWORK` environment variable.
- Coin fields to `/markets` endpoint.
- Add `/user_balances` endpoint.

### Changed

- Refactor aggregator Dockerfile for `APTOS_NETWORK` environment variable, multi-stage build.

## [v1.3.0]

### Added

- Add materialized view support for 24hr market price/volume fields.
- Add assorted market price/volume fields to `/markets` endpoint.
- Incorporate average execution price as a field in `/orders` endpoint.

## v1.2.0

### Breaking changes

- Remove `/{limit,market,swap}_orders` endpoints.
- Rename `side` to `direction` in `/price_levels`.

### Important changes

- Add all fields from `/{limit,market,swap}_orders` to `/orders`.
  N/A fields are null.
- Add `average_execution_price` as a field that is always returned.
  It is not needed to explicitly request it on each request.

### Misc

- Improve overall performance.

[v1.3.0]: https://github.com/econia-labs/econia/releases/tag/dss-v1.3.0
[v1.4.0]: https://github.com/econia-labs/econia/compare/dss-v1.3.0...dss-v1.4.0
[`dss-stable`]: https://github.com/econia-labs/econia/tree/dss-stable
