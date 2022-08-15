# Structure

This is a temporary directory for storing modules that have unresolved dependencies, during revisions to lower-level dependencies.

## Color codes

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart LR

    id0[Before revisions]

    id1[Modified but not renamed]
    style id1 fill:#ff00ff
```


# `user.move` dependencies

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart LR

%% Class definitions

    classDef modified_but_not_renamed fill:#ff00ff

%% Node definitions
    Collateral[Collateral]
    MarketAccount[MarketAccount]
    MarketAccountInfo[MarketAccountInfo]
    MarketAccounts[MarketAccounts]

%% Class definitions
    class Collateral modified_but_not_renamed;
    class MarketAccount modified_but_not_renamed;
    class MarketAccountInfo modified_but_not_renamed;
    class MarketAccounts modified_but_not_renamed;

%% Relationships
    deposit_collateral_coinstore --> deposit_collateral
    deposit_collateral_coinstore --> Collateral
    deposit_collateral_coinstore --> MarketAccounts

    register_market_account --> Collateral
    register_market_account --> MarketAccounts
    register_market_account --> registry::market_info
    register_market_account --> registry::is_registered
    register_market_account --> registry::is_valid_custodian_id
    register_market_account --> register_market_accounts_entry
    register_market_account --> register_collateral_entry

    withdraw_collateral_coinstore --> Collateral
    withdraw_collateral_coinstore --> MarketAccounts
    withdraw_collateral_coinstore --> market_account_info
    withdraw_collateral_coinstore --> withdraw_collateral

    withdraw_collateral_user --> MarketAccountInfo
    withdraw_collateral_user --> Collateral
    withdraw_collateral_user --> MarketAccounts
    withdraw_collateral_user --> withdraw_collateral

    add_order_internal --> MarketAccounts
    add_order_internal --> market_account_info
    add_order_internal --> range_check_order_fills

    deposit_collateral --> MarketAccountInfo
    deposit_collateral --> Collateral
    deposit_collateral --> MarketAccounts
    deposit_collateral --> borrow_coin_counts_mut

    fill_order_internal --> Collateral
    fill_order_internal --> MarketAccounts
    fill_order_internal --> fill_order_update_market_account
    fill_order_internal --> fill_order_route_collateral

    market_account_info --> MarketAccountInfo

    remove_order_internal --> MarketAccounts
    remove_order_internal --> market_account_info

    withdraw_collateral_custodian --> Collateral
    withdraw_collateral_custodian --> MarketAccounts
    withdraw_collateral_custodian --> MarketAccountInfo
    withdraw_collateral_custodian --> withdraw_collateral

    withdraw_collateral_internal --> Collateral
    withdraw_collateral_internal --> MarketAccounts
    withdraw_collateral_internal --> MarketAccountInfo
    withdraw_collateral_internal --> withdraw_collateral

    borrow_coin_counts_mut --> MarketAccountInfo
    borrow_coin_counts_mut --> MarketAccount
    borrow_coin_counts_mut --> registry::coin_is_base_coin

    exists_market_account --> MarketAccountInfo
    exists_market_account --> MarketAccounts

    fill_order_route_collateral --> MarketAccountInfo
    fill_order_route_collateral --> Collateral
    fill_order_route_collateral --> fill_order_route_collateral_single

    fill_order_route_collateral_single --> MarketAccountInfo
    fill_order_route_collateral_single --> Collateral

    fill_order_update_market_account --> MarketAccountInfo
    fill_order_update_market_account --> MarketAccounts

    register_collateral_entry --> MarketAccountInfo
    register_collateral_entry --> Collateral

    register_market_accounts_entry --> MarketAccountInfo
    register_market_accounts_entry --> MarketAccounts
    register_market_accounts_entry --> registry::scale_factor_from_market_info

    withdraw_collateral --> MarketAccountInfo
    withdraw_collateral --> Collateral
    withdraw_collateral --> MarketAccounts
    withdraw_collateral --> exists_market_account
    withdraw_collateral --> borrow_coin_counts_mut

    get_collateral_amount_test --> Collateral
    get_collateral_amount_test --> market_account_info

    get_collateral_amounts_test --> Collateral

    get_collateral_counts_test --> MarketAccounts
    get_collateral_counts_test --> coin_is_base_coin

    get_collateral_state_test --> Collateral
    get_collateral_state_test --> MarketAccounts
    get_collateral_state_test --> get_collateral_amounts_test
    get_collateral_state_test --> get_collateral_counts_test

    has_order_test --> MarketAccounts
    has_order_test --> market_account_info

    order_base_parcels_test --> MarketAccounts
    order_base_parcels_test --> market_account_info

    test_add_order_internal_no_collateral --> Collateral
    test_add_order_internal_no_collateral --> MarketAccounts
    test_add_order_internal_no_collateral --> registry::register_test_market_internal
    test_add_order_internal_no_collateral --> register_market_account
    test_add_order_internal_no_collateral --> add_order_internal

    test_add_order_internal_no_market_account --> Collateral
    test_add_order_internal_no_market_account --> MarketAccounts
    test_add_order_internal_no_market_account --> registry::register_test_market_internal
    test_add_order_internal_no_market_account --> register_market_account
    test_add_order_internal_no_market_account --> add_order_internal

    test_add_order_internal_no_market_accounts --> MarketAccounts
    test_add_order_internal_no_market_accounts --> add_order_internal

    test_add_order_internal_not_enough_collateral --> Collateral
    test_add_order_internal_not_enough_collateral --> MarketAccounts
    test_add_order_internal_not_enough_collateral --> registry::register_test_market_internal
    test_add_order_internal_not_enough_collateral --> register_market_account
    test_add_order_internal_not_enough_collateral --> add_order_internal

    test_add_remove_order_internal_ask --> Collateral
    test_add_remove_order_internal_ask --> MarketAccounts
    test_add_remove_order_internal_ask --> registry::register_test_market_internal
    test_add_remove_order_internal_ask --> registry::scale_factor
    test_add_remove_order_internal_ask --> market_account_info
    test_add_remove_order_internal_ask --> register_market_account
    test_add_remove_order_internal_ask --> deposit_collateral
    test_add_remove_order_internal_ask --> add_order_internal
    test_add_remove_order_internal_ask --> remove_order_internal

    test_add_remove_order_internal_bid --> Collateral
    test_add_remove_order_internal_bid --> MarketAccounts
    test_add_remove_order_internal_bid --> registry::register_test_market_internal
    test_add_remove_order_internal_bid --> registry::scale_factor
    test_add_remove_order_internal_bid --> market_account_info
    test_add_remove_order_internal_bid --> register_market_account
    test_add_remove_order_internal_bid --> deposit_collateral
    test_add_remove_order_internal_bid --> add_order_internal
    test_add_remove_order_internal_bid --> remove_order_internal

    test_deposit_collateral_no_market_account --> Collateral
    test_deposit_collateral_no_market_account --> MarketAccounts
    test_deposit_collateral_no_market_account --> registry::market_info
    test_deposit_collateral_no_market_account --> coins::init_coin_types
    test_deposit_collateral_no_market_account --> deposit_collateral
    test_deposit_collateral_no_market_account --> coins::mint

    test_deposit_collateral --> Collateral
    test_deposit_collateral --> MarketAccounts
    test_deposit_collateral --> registry::register_test_market_internal
    test_deposit_collateral --> MarketAccountInfo
    test_deposit_collateral --> register_market_account
    test_deposit_collateral --> deposit_collateral
    test_deposit_collateral --> coin::register_for_test
    test_deposit_collateral --> coin::deposit
    test_deposit_collateral --> deposit_collateral_coinstore
    test_deposit_collateral --> get_collateral_counts_test

    test_fill_order_internal_ask --> Collateral
    test_fill_order_internal_ask --> MarketAccounts
    test_fill_order_internal_ask --> registry::register_test_market_internal
    test_fill_order_internal_ask --> registry::scale_factor
    test_fill_order_internal_ask --> market_account_info
    test_fill_order_internal_ask --> register_market_account
    test_fill_order_internal_ask --> deposit_collateral
    test_fill_order_internal_ask --> add_order_internal
    test_fill_order_internal_ask --> fill_order_internal
    test_fill_order_internal_ask --> order_base_parcels_test
    test_fill_order_internal_ask --> get_collateral_amounts_test

    test_fill_order_internal_bids --> Collateral
    test_fill_order_internal_bids --> MarketAccounts
    test_fill_order_internal_bids --> registry::register_test_market_internal
    test_fill_order_internal_bids --> registry::scale_factor
    test_fill_order_internal_bids --> market_account_info
    test_fill_order_internal_bids --> register_market_account
    test_fill_order_internal_bids --> deposit_collateral
    test_fill_order_internal_bids --> add_order_internal
    test_fill_order_internal_bids --> fill_order_internal
    test_fill_order_internal_bids --> order_base_parcels_test
    test_fill_order_internal_bids --> get_collateral_amounts_test

    test_range_check_order_fills --> range_check_order_fills

    test_range_check_order_fills_base_parcels_0 --> range_check_order_fills

    test_range_check_order_fills_overflow_base --> range_check_order_fills

    test_range_check_order_fills_overflow_quote --> range_check_order_fills

    test_range_check_order_fills_price_0 --> range_check_order_fills

    test_register_collateral_entry --> Collateral
    test_register_collateral_entry --> MarketAccountInfo
    test_register_collateral_entry --> register_collateral_entry

    test_register_collateral_entry_already_registered --> Collateral
    test_register_collateral_entry_already_registered --> MarketAccountInfo
    test_register_collateral_entry_already_registered --> register_collateral_entry

    test_register_market_account_invalid_custodian_id --> Collateral
    test_register_market_account_invalid_custodian_id --> MarketAccounts
    test_register_market_account_invalid_custodian_id --> registry::register_test_market_internal
    test_register_market_account_invalid_custodian_id --> register_market_account

    test_register_market_account_no_market --> Collateral
    test_register_market_account_no_market --> MarketAccounts
    test_register_market_account_no_market --> register_market_account

    test_register_market_accounts --> Collateral
    test_register_market_accounts --> MarketAcounts
    test_register_market_accounts --> registry::register_test_market_internal
    test_register_market_accounts --> registry::register_custodian_capability
    test_register_market_accounts --> register_market_account
    test_register_market_accounts --> market_account_info

    test_register_market_accounts_entry --> MarketAccounts
    test_register_market_accounts_entry --> MarketAccountInfo
    test_register_market_accounts_entry --> register_market_accounts_entry

    test_register_market_accounts_entry_already_registered --> MarketAccounts
    test_register_market_accounts_entry_already_registered --> MarketAccountInfo
    test_register_market_accounts_entry_already_registered --> register_market_accounts_entry

    test_withdraw_collateral_success --> Collateral
    test_withdraw_collateral_success --> MarketAccounts
    test_withdraw_collateral_success --> registry::register_test_market_internal
    test_withdraw_collateral_success --> register_market_account
    test_withdraw_collateral_success --> deposit_collateral
    test_withdraw_collateral_success --> withdraw_collateral_user
    test_withdraw_collateral_success --> withdraw_collateral_coinstore

    test_withdraw_collateral_custodian_unauthorized --> Collateral
    test_withdraw_collateral_custodian_unauthorized --> MarketAccounts
    test_withdraw_collateral_custodian_unauthorized --> MarketAccountInfo
    test_withdraw_collateral_custodian_unauthorized --> registry_get_custodian_capability
    test_withdraw_collateral_custodian_unauthorized --> withdraw_collateral_custodian
    test_withdraw_collateral_custodian_unauthorized --> registry::destroy_custodian_capability

    test_withdraw_collateral_no_market_account --> Collateral
    test_withdraw_collateral_no_market_account --> MarketAccounts
    test_withdraw_collateral_no_market_account --> MarketAccountInfo
    test_withdraw_collateral_no_market_account --> withdraw_collateral_user

    test_withdraw_collateral_not_enough_collateral --> Collateral
    test_withdraw_collateral_not_enough_collateral --> MarketAccounts
    test_withdraw_collateral_not_enough_collateral --> registry::register_test_market_internal
    test_withdraw_collateral_not_enough_collateral --> registry::register_custodian_capability
    test_withdraw_collateral_not_enough_collateral --> register_market_account
    test_withdraw_collateral_not_enough_collateral --> withdraw_collateral_custodian
    test_withdraw_collateral_not_enough_collateral --> registry::destroy_custodian_capability

    test_withdraw_collateral_user_override --> Collateral
    test_withdraw_collateral_user_override --> MarketAccounts
    test_withdraw_collateral_user_override --> MarketAccountInfo
    test_withdraw_collateral_user_override --> withdraw_collateral_user
```