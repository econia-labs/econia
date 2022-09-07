# Utility functions

- [Utility functions](#utility-functions)
  - [Custodian ID](#custodian-id)
  - [Market account ID](#market-account-id)
    - [Construction](#construction)
    - [Encoded market ID](#encoded-market-id)
    - [Encoded general custodian ID](#encoded-general-custodian-id)

## Custodian ID

[`custodian_id`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_custodian_id) returns the custodian ID of a
[`CustodianCapability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_CustodianCapability).

## Market account ID

### Construction

[`get_market_account_id`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_get_market_account_id) returns the market account ID for a given market ID and general custodian ID.

### Encoded market ID

[`get_market_id`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_get_market_id) returns the market ID encoded in a market account ID.

### Encoded general custodian ID

[`get_general_custodian_id`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_get_general_custodian_id) returns the general custodian ID encoded in a market account ID.