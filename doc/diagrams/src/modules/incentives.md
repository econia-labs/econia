- [Incentives.move](#incentivesmove)
  - [Structs](#structs)
  - [Getters](#getters)
  - [Incentive parameter setters](#incentive-parameter-setters)
  - [Econia fee account operations](#econia-fee-account-operations)
  - [Registrant operations](#registrant-operations)
  - [Integrator fee store operations](#integrator-fee-store-operations)
  - [Match operations](#match-operations)

# Incentives.move

## Structs

```mermaid

flowchart LR

EconiaFeeStore
FeeAccountSignerCapabilityStore
IncentiveParameters
IntegratorFeeStore
IntegratorFeeStores
IntegratorFeeStoreTierParameters
UtilityCoinStore

```

## Getters

```mermaid

flowchart LR

get_cost_to_upgrade_integrator_fee_store --> get_tier_activation_fee
get_custodian_registration_fee
get_fee_account_address
get_fee_share_divisor
get_integrator_withdrawal_fee --> get_tier_withdrawal_fee
get_market_registration_fee
get_n_fee_store_tiers
get_taker_fee_divisor
get_underwriter_registration_fee
verify_utility_coin_type --> is_utility_coin_type

```

## Incentive parameter setters

```mermaid

flowchart LR

update_incentives --> set_incentive_parameters
init_module --> set_incentive_parameters
set_incentive_parameters --> set_incentive_parameters_parse_tiers_vector
set_incentive_parameters --> init_fee_account
set_incentive_parameters --> set_incentive_parameters_range_check_inputs
set_incentive_parameters --> init_utility_coin_store
set_incentive_parameters --> get_n_fee_store_tiers

```

## Econia fee account operations

```mermaid

flowchart LR

withdraw_econia_fees --> withdraw_econia_fees_internal
withdraw_econia_fees_all --> withdraw_econia_fees_internal
withdraw_econia_fees_internal --> get_fee_account_address
withdraw_utility_coins --> withdraw_utility_coins_internal
withdraw_utility_coins_all --> withdraw_utility_coins_internal
withdraw_utility_coins_internal --> get_fee_account_address
register_econia_fee_store_entry --> get_fee_account
deposit_utility_coins --> get_fee_account_address
deposit_utility_coins --> range_check_coin_merge
deposit_utility_coins_verified --> verify_utility_coin_type
deposit_utility_coins_verified --> deposit_utility_coins

```

## Registrant operations

```mermaid

flowchart LR

deposit_custodian_registration_utility_coins --> deposit_utility_coins_verified
deposit_custodian_registration_utility_coins --> get_custodian_registration_fee
deposit_market_registration_utility_coins --> deposit_utility_coins_verified
deposit_market_registration_utility_coins --> get_market_registration_fee
deposit_underwriter_registration_utility_coins --> deposit_utility_coins_verified
deposit_underwriter_registration_utility_coins --> get_underwriter_registration_fee

```

## Integrator fee store operations

```mermaid

flowchart LR

upgrade_integrator_fee_store --> deposit_utility_coins_verified
withdraw_integrator_fees --> deposit_utility_coins_verified
withdraw_integrator_fees --> get_tier_withdrawal_fee
upgrade_integrator_fee_store_via_coinstore --> upgrade_integrator_fee_store
withdraw_integrator_fees_via_coinstores --> get_integrator_withdrawal_fee
withdraw_integrator_fees_via_coinstores --> withdraw_integrator_fees
register_integrator_fee_store --> deposit_utility_coins_verified
register_integrator_fee_store --> get_tier_activation_fee

```

## Match operations

```mermaid

flowchart LR

assess_taker_fees --> get_fee_share_divisor
assess_taker_fees --> get_taker_fee_divisor
assess_taker_fees --> get_fee_account_address
assess_taker_fees --> range_check_coin_merge
calculate_max_quote_match

```