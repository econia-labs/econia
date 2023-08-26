# Registration

## Registration fee lookup

- [`get_custodian_registration_fee()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#function-get_custodian_registration_fee)
- [`get_market_registration_fee()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#function-get_market_registration_fee)
- [`get_underwriter_registration_fee()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#function-get_underwriter_registration_fee)
- [`is_utility_coin_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#function-is_utility_coin_type)
- [`verify_utility_coin_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#function-verify_utility_coin_type)

## Capability registration

- [`register_custodian_capability()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-register_custodian_capability)
- [`register_underwriter_capability()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-register_underwriter_capability)

## Integrator fee store registration

- [`register_integrator_fee_store()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-register_integrator_fee_store)
- [`register_integrator_fee_store_base_tier()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-register_integrator_fee_store_base_tier)
- [`register_integrator_fee_store_from_coinstore()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-register_integrator_fee_store_from_coinstore)

## Market registration

- [`register_market_base_coin()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-register_market_base_coin)
- [`register_market_base_generic()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-register_market_base_generic)
- [`register_market_base_coin_from_coinstore()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-register_market_base_coin_from_coinstore)

## Markets

### Market lookup

- [`get_market_counts()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_market_counts)
- [`get_market_info()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_market_info)
- [`get_market_id_base_coin()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_market_id_base_coin)
- [`get_market_id_base_generic()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_market_id_base_generic)

### Recognized markets existence checkers

- [`get_recognized_market_id_base_coin()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_id_base_coin)
- [`get_recognized_market_id_base_generic()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_id_base_generic)
- [`has_recognized_market_base_coin()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-has_recognized_market_base_coin)
- [`has_recognized_market_base_coin_by_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-has_recognized_market_base_coin_by_type)
- [`has_recognized_market_base_generic()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-has_recognized_market_base_generic)
- [`has_recognized_market_base_generic_by_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-has_recognized_market_base_generic_by_type)

### Recognized market info getters

- [`get_recognized_market_info_base_coin()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_info_base_coin)
- [`get_recognized_market_info_base_coin_by_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_info_base_coin_by_type)
- [`get_recognized_market_info_base_generic()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_info_base_generic)
- [`get_recognized_market_info_base_generic_by_type()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_recognized_market_info_base_generic_by_type)

## Market accounts

### Registration

- [`init_market_event_handles_if_missing()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-init_market_event_handles_if_missing)
- [`register_market_account()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-register_market_account)
- [`register_market_account_generic_base()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-register_market_account_generic_base)

### Market account info lookup

- [`get_market_account_market_info_custodian()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_account_market_info_custodian)
- [`get_market_account_market_info_user()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_account_market_info_user)

### Market account ID lookup

- [`get_all_market_account_ids_for_market_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_all_market_account_ids_for_market_id)
- [`get_all_market_account_ids_for_user()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_all_market_account_ids_for_user)
- [`has_market_account_by_market_account_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-has_market_account_by_market_account_id)
- [`has_market_account_by_market_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-has_market_account_by_market_id)

### Market account lookup

- [`get_market_account()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_account)
- [`get_market_accounts()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_accounts)
- [`has_market_account()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-has_market_account)
