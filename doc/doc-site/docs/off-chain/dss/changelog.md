# Changelog

Stable DSS builds are tracked on the [`dss-stable`] branch with tags like [`dss-v1.3.0`][v1.3.0].

## Release procedure

1. Create preparatory pull request (PR) into `main` branch of `econia` repo (like [#653]).
   1. Rebuild REST API docs.
   1. Bump changelog with PRs since last preparatory PR:
      1. In `econia` repo.
      1. In processor submodule.
1. Merge `main` into `dss-stable`.
1. Push annotated tag to head of `dss-stable`.

## [v1.6.0]

### Added

- Assorted CoinGecko endpoints ([#675]).
- Assorted TVL endpoints ([#670], [#674]).
- Price conversion endpoint ([#672]).
- Assorted volume endpoints ([#669], [#682]).
- Grafana annotation support ([#667]).

### Changed

- Make `/user_balances` endpoint a pipeline ([#685], [#688]).
- Grant `SELECT` on `api.coins` to `web_anon` and `grafana` ([#687], [#688]).
- Reduce aggregator memory consumption via batched operations ([#688], [#689]).
- Make rolling volume a default pipeline ([#683], [#684]).

## [v1.5.0]

### Added

- Optional rolling volume pipeline ([#658], [#663]).
- Global order history snapshot pipeline ([#658], [#664]).
- Health check endpoints ([#651]).
- Fees in `/user_history` endpoint ([#650]).
- Hot restart support ([#657], [#659]).
- CI/CD Terraform project with walkthrough ([#657]).
- Automatic schema reloading for PostgREST ([#661]).
- Demo Grafana configuration ([#657]).

### Changed

- Docker compose and processor config style, associated docs ([#659], [#665], [#660]).

## [v1.4.0]

### Added

- Add coins pipeline with `APTOS_NETWORK` environment variable, add coin fields to `/markets` endpoint ([#624], [#625]).
- Add `/user_balances` endpoint ([#641]).
- Force local Docker compose services to wait for `diesel` completion ([#644], [#648]).
- Function for getting `/markets` endpoint info when querying `/user_balances` endpoint ([#645]).
- Retry mechanism for serialized PostgreSQL transaction failure ([#643], [Processor #21]).
- Sanitize event type address in processor ([Processor #19], [Processor #20]).

### Fixed

- Reverse migrations ([#638]).

### Changed

- Refactor aggregator Dockerfile for `APTOS_NETWORK` environment variable, multi-stage build ([#625]).

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

[#624]: https://github.com/econia-labs/econia/pull/624
[#625]: https://github.com/econia-labs/econia/pull/625
[#638]: https://github.com/econia-labs/econia/pull/638
[#641]: https://github.com/econia-labs/econia/pull/641
[#643]: https://github.com/econia-labs/econia/pull/643
[#644]: https://github.com/econia-labs/econia/pull/644
[#645]: https://github.com/econia-labs/econia/pull/645
[#648]: https://github.com/econia-labs/econia/pull/648
[#650]: https://github.com/econia-labs/econia/pull/650
[#651]: https://github.com/econia-labs/econia/pull/651
[#653]: https://github.com/econia-labs/econia/pull/653
[#657]: https://github.com/econia-labs/econia/pull/657
[#658]: https://github.com/econia-labs/econia/pull/658
[#659]: https://github.com/econia-labs/econia/pull/659
[#660]: https://github.com/econia-labs/econia/pull/661
[#661]: https://github.com/econia-labs/econia/pull/661
[#663]: https://github.com/econia-labs/econia/pull/663
[#664]: https://github.com/econia-labs/econia/pull/664
[#665]: https://github.com/econia-labs/econia/pull/665
[#667]: https://github.com/econia-labs/econia/pull/667
[#669]: https://github.com/econia-labs/econia/pull/669
[#670]: https://github.com/econia-labs/econia/pull/670
[#672]: https://github.com/econia-labs/econia/pull/672
[#674]: https://github.com/econia-labs/econia/pull/674
[#675]: https://github.com/econia-labs/econia/pull/675
[#682]: https://github.com/econia-labs/econia/pull/682
[#683]: https://github.com/econia-labs/econia/pull/683
[#684]: https://github.com/econia-labs/econia/pull/684
[#685]: https://github.com/econia-labs/econia/pull/685
[#687]: https://github.com/econia-labs/econia/pull/687
[#688]: https://github.com/econia-labs/econia/pull/688
[#689]: https://github.com/econia-labs/econia/pull/689
[processor #19]: https://github.com/econia-labs/aptos-indexer-processors/pull/19
[processor #20]: https://github.com/econia-labs/aptos-indexer-processors/pull/20
[processor #21]: https://github.com/econia-labs/aptos-indexer-processors/pull/21
[v1.3.0]: https://github.com/econia-labs/econia/releases/tag/dss-v1.3.0
[v1.4.0]: https://github.com/econia-labs/econia/compare/dss-v1.3.0...dss-v1.4.0
[v1.5.0]: https://github.com/econia-labs/econia/compare/dss-v1.4.0...dss-v1.5.0
[v1.6.0]: https://github.com/econia-labs/econia/compare/dss-v1.5.0...dss-v1.6.0
[`dss-stable`]: https://github.com/econia-labs/econia/tree/dss-stable
