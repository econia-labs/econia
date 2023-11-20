# Changelog

## DSS

### v1.3.0

#### Added

- Add materialized view support for 24hr market price/volume fields.
- Add assorted market price/volume fields to `/markets` endpoint.
- Incorporated average execution price as a field in `/orders` endpoint.

### v1.2.0

#### Breaking changes

- removed `/{limit,market,swap}_orders` endpoints.
- renamed `side` to `direction` in `/price_levels`.

#### Important changes

- add all fields from `/{limit,market,swap}_orders` to `/orders`. N/A fields are null.
- add `average_execution_price` as a field that is always returned. It is not needed to explicitly request it on each request.

#### Misc

- improved overall performance.
