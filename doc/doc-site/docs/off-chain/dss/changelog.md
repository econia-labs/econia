# Changelog

Stable DSS builds are tracked on the [`dss-stable`] branch with tags like [`dss-v1.3.0`][v1.3.0].

## Release procedure

1. Create preparatory pull request (PR) into `main` branch of `econia` repo (like [#653]).
   1. [Rebuild REST API docs][docs site readme].
   1. Bump changelog.
      1. Add new pull requests since last release:
         1. From [`econia` repo].
         1. From [processor submodule].
      1. Note if a hot upgrade is possible relative to the last release.
      1. Verify all new links by manually following them on a
         [live local docs build][docs site readme].
      1. Run `mdformat` on changelog.
1. Tag `main` with an annotated release candidate tag like [dss-v2.1.0-rc.1].
1. Merge `main` into `dss-stable`.
1. Push annotated tag to head of `dss-stable`.

## [v2.2.0] (hot upgradable)

### Changed

- Improve performance of `/markets` endpoint ([#760], [#772]).

### Fixed

- `/tickers` endpoint `base_volume_nominal` field ([#761]).
- `/tickers` endpoint `price` field ([#766]).
- fixed nominal issues when tickers isn't 1 ([#767]).
- fixed potential duplicates in `daily_rolling_volume_history`([#765]).

### Internal

- Added dynamic batch sizing to avoid crashes during high usage ([#762]).
- Updated Rust dependencies ([#764]).
- Optimize daily volume calculations wrapped query ([#768]).
- Fork base, to include upstream processor changes ([#775], [Processor #27]).

## [v2.1.0] (hot upgradable)

### Added

- Price level events over MQTT (disabled by default, enable by adding `MQTT_PRICE_LEVELS=yes`, see `src/docker/example.env`) ([#753]).
- `/tickers` endpoint optimizations ([#729]).
- Suspend and resume functionality for the DSS when deployed on GCP ([#736]).
- More details in aggregator logging ([#738]).
- Default support for the `all` liquidity group on all markets ([#728]).

### Changed

- Fork base, to include upstream processor changes ([#725], [#744], [Processor #24]).

### Fixed

- `/tickers` endpoint `base_volume_nominal` and `quote_volume_nominal` fields ([#746], [#749]).
- Balance reporting for market account handles starting with `0x0` ([#732], [Processor #25]).
- Liquidity calculation logic ([#730]).

### Deprecated

- Market registration pipeline, an unused development stub that counted markets registered per day ([#727]).

## [v2.0.1] (hot upgradable)

### Fixed

- MQTT order ID rounding ([#719]).

### Added

- MQTT rebuild in hot upgrade script ([#720]).
- `fees` function ([#717]).
- MQTT over WebSockets support ([#723]).

## [v2.0.0]

### Added

- `/fees` endpoint and `get_market_cumulative_fees` function ([#693]).
- `/prices` endpoint ([#697]).
- `/spreads` endpoint ([#700]).
- `base_volume_nominal` and `quote_volume_nominal` fields in `/tickers` endpoint ([#705]).
- MQTT support ([#702]).
- `/fees_24h` endpoint ([#708]).
- Assorted Grafana configurations ([#709], [#711]).

### Fixed

- Empty transaction panics introduced by upstream gRPC changes ([processor #23], [#710]).
- Quote escaping in Terraform scripts ([#704], [#706]).

### Changed

- Restructure Docker compose configuration files ([#699], [#701], [#702]).
- Refactor liquidity calculations with groups, less granularity, for performance ([#703], [#707]).

### Deprecated

- WebSockets support ([#702]).
- Unused indices from PostgreSQL database ([#712]).

## [v1.6.1]

### Fixed

- Processing of events that are not a struct type ([#694], [processor #22]).

## [v1.6.0]

### Added

- Assorted CoinGecko endpoints ([#675]).
- Assorted TVL endpoints ([#670], [#674]).
- Price conversion endpoint ([#672]).
- Assorted volume endpoints ([#669], [#682]).
- Grafana annotation support ([#667]).

### Changed

- Optimize `/user_balances` queries ([#685], [#688]).
- Allow `/coins` endpoint to be queried from assorted PostgreSQL roles ([#687], [#688]).
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
[#693]: https://github.com/econia-labs/econia/pull/693
[#694]: https://github.com/econia-labs/econia/pull/694
[#697]: https://github.com/econia-labs/econia/pull/697
[#699]: https://github.com/econia-labs/econia/pull/699
[#700]: https://github.com/econia-labs/econia/pull/700
[#701]: https://github.com/econia-labs/econia/pull/701
[#702]: https://github.com/econia-labs/econia/pull/702
[#703]: https://github.com/econia-labs/econia/pull/703
[#704]: https://github.com/econia-labs/econia/pull/704
[#705]: https://github.com/econia-labs/econia/pull/705
[#706]: https://github.com/econia-labs/econia/pull/706
[#707]: https://github.com/econia-labs/econia/pull/707
[#708]: https://github.com/econia-labs/econia/pull/708
[#709]: https://github.com/econia-labs/econia/pull/709
[#710]: https://github.com/econia-labs/econia/pull/710
[#711]: https://github.com/econia-labs/econia/pull/711
[#712]: https://github.com/econia-labs/econia/pull/712
[#717]: https://github.com/econia-labs/econia/pull/717
[#719]: https://github.com/econia-labs/econia/pull/719
[#720]: https://github.com/econia-labs/econia/pull/720
[#723]: https://github.com/econia-labs/econia/pull/723
[#725]: https://github.com/econia-labs/econia/pull/725
[#727]: https://github.com/econia-labs/econia/pull/727
[#728]: https://github.com/econia-labs/econia/pull/728
[#729]: https://github.com/econia-labs/econia/pull/729
[#730]: https://github.com/econia-labs/econia/pull/730
[#732]: https://github.com/econia-labs/econia/pull/732
[#736]: https://github.com/econia-labs/econia/pull/736
[#738]: https://github.com/econia-labs/econia/pull/738
[#744]: https://github.com/econia-labs/econia/pull/744
[#746]: https://github.com/econia-labs/econia/pull/746
[#749]: https://github.com/econia-labs/econia/pull/749
[#753]: https://github.com/econia-labs/econia/pull/753
[#760]: https://github.com/econia-labs/econia/pull/760
[#761]: https://github.com/econia-labs/econia/pull/761
[#762]: https://github.com/econia-labs/econia/pull/762
[#764]: https://github.com/econia-labs/econia/pull/764
[#765]: https://github.com/econia-labs/econia/pull/765
[#766]: https://github.com/econia-labs/econia/pull/766
[#767]: https://github.com/econia-labs/econia/pull/767
[#768]: https://github.com/econia-labs/econia/pull/768
[#772]: https://github.com/econia-labs/econia/pull/772
[#775]: https://github.com/econia-labs/econia/pull/775
[docs site readme]: https://github.com/econia-labs/econia/blob/main/doc/doc-site/README.md
[dss-v2.1.0-rc.1]: https://github.com/econia-labs/econia/releases/tag/dss-v2.1.0-rc.1
[processor #19]: https://github.com/econia-labs/aptos-indexer-processors/pull/19
[processor #20]: https://github.com/econia-labs/aptos-indexer-processors/pull/20
[processor #21]: https://github.com/econia-labs/aptos-indexer-processors/pull/21
[processor #22]: https://github.com/econia-labs/aptos-indexer-processors/pull/22
[processor #23]: https://github.com/econia-labs/aptos-indexer-processors/pull/23
[processor #24]: https://github.com/econia-labs/aptos-indexer-processors/pull/24
[processor #25]: https://github.com/econia-labs/aptos-indexer-processors/pull/25
[processor #27]: https://github.com/econia-labs/aptos-indexer-processors/pull/27
[processor submodule]: https://github.com/econia-labs/aptos-indexer-processors/pulls?q=is%3Aclosed
[v1.3.0]: https://github.com/econia-labs/econia/releases/tag/dss-v1.3.0
[v1.4.0]: https://github.com/econia-labs/econia/compare/dss-v1.3.0...dss-v1.4.0
[v1.5.0]: https://github.com/econia-labs/econia/compare/dss-v1.4.0...dss-v1.5.0
[v1.6.0]: https://github.com/econia-labs/econia/compare/dss-v1.5.0...dss-v1.6.0
[v1.6.1]: https://github.com/econia-labs/econia/compare/dss-v1.6.0...dss-v1.6.1
[v2.0.0]: https://github.com/econia-labs/econia/compare/dss-v1.6.1...dss-v2.0.0
[v2.0.1]: https://github.com/econia-labs/econia/compare/dss-v2.0.0...dss-v2.0.1
[v2.1.0]: https://github.com/econia-labs/econia/compare/dss-v2.0.1...dss-v2.1.0
[v2.2.0]: https://github.com/econia-labs/econia/compare/dss-v2.1.0...dss-v2.2.0
[`dss-stable`]: https://github.com/econia-labs/econia/tree/dss-stable
[`econia` repo]: https://github.com/econia-labs/econia/pulls?q=is%3Aclosed


