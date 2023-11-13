# Changelog

## DSS

### V1.2

#### Breaking changes

- removed `/{limit,market,swap}_orders` endpoints

#### Important changes

- add all fields from `/{limit,market,swap}_orders` to `/orders`. N/A fields are null.
- add `average_execution_price` as a field that is always returned. It is not needed to explicitly request it on each request.

#### Misc

- improved overall performance
