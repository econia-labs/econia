- [Incentives.move](#incentivesmove)
  - [Structs](#structs)
  - [Getters](#getters)
  - [Econia admin operations](#econia-admin-operations)
  - [Econia account operations](#econia-account-operations)
  - [Integrator account operations](#integrator-account-operations)
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
verify_utility_coin_type --> is_utility_coin_type

```

## Econia admin operations

```mermaid

flowchart LR

update_incentives --> set_incentive_parameters
init_incentives --> set_incentive_parameters
set_incentive_parameters --> set_incentive_parameters_parse_tiers_vector
set_incentive_parameters --> init_fee_account
set_incentive_parameters --> set_incentive_parameters_range_check_inputs
set_incentive_parameters --> init_utility_coin_store
set_incentive_parameters --> get_n_fee_store_tiers

```

## Econia account operations

```mermaid

flowchart LR

withdraw_econia_fees --> get_fee_account_address
withdraw_econia_fees_all --> get_fee_account_address
withdraw_utility_coins --> get_fee_account_address
withdraw_utility_coins_all --> get_fee_account_address
register_econia_fee_store_entry --> get_fee_account
deposit_utility_coins --> get_fee_account_address
deposit_utility_coins_verified --> verify_utility_coin_type
deposit_utility_coins_verified --> deposit_utility_coins

```

## Integrator account operations

```mermaid

flowchart LR

upgrade_integrator_fee_store --> deposit_utility_coins_verified
withdraw_integrator_fees --> deposit_utility_coins_verified
withdraw_integrator_fees --> get_tier_withdrawal_fee
upgrade_integrator_fee_store_via_coinstore --> upgrade_integrator_fee_store
withdraw_integrator_fees_via_coinstores --> get_integrator_withdrawal_fee
withdraw_integrator_fees_via_coinstores --> withdraw_integrator_fees
deposit_custodian_registration_utility_coins --> deposit_utility_coins_verified
deposit_custodian_registration_utility_coins --> get_custodian_registration_fee
deposit_market_registration_utility_coins --> deposit_utility_coins_verified
deposit_market_registration_utility_coins --> get_market_registration_fee
register_integrator_fee_store --> deposit_utility_coins_verified
register_integrator_fee_store --> get_tier_activation_fee

```

## Match operations

```mermaid

flowchart LR

assess_taker_fees --> get_fee_share_divisor
assess_taker_fees --> get_taker_fee_divisor
assess_taker_fees --> get_fee_account_address
calculate_max_quote_match

```