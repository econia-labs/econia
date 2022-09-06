# Dependencies

The below dependency charts are generated declaratively via `mermaid.js`, and may present occasional rendering artifacts.
Try switching browsers if the text renders in a way that is difficult to read.

## Modules

Econia modules `use` each other as follows:

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart TD

    user --> critbit
    user --> open_table
    user --> order_id
    user --> |friend| registry
    user --> |test-only| assets
    registry --> |test-only| assets
    order_id --> |test-only| critbit
    market --> critbit
    market --> open_table
    market --> order_id
    market --> |friend| registry
    market --> |friend| user
    market --> |test-only| assets

```

## Matching engine

Econia's matching engine is implemented in [`market.move`](sources/market.move), with comprehensive end-to-end testing.

### Functions

The below dependency chart details the relevant matching engine functions, according to the following color schema:

| Color  | Meaning                      |
|--------|------------------------------|
| Purple | Individually tested          |
| Green  | Tested via direct invocation |
| Blue   | End-to-end tested            |

* Functions that simply check the size of inputs are individually tested
* Functions that are wrappers for other functions are simply tested by invocation
* Integrated functions that complexly modify state are tested via end-to-end testing


```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1', 'tertiaryColor': '#808080', 'tertiaryTextColor': '#0d1013'}}}%%

flowchart TB

%% Node relationships

    subgraph From market account

        subgraph Market orders

        place_market_order_custodian --> place_market_order
        place_market_order_user --> place_market_order

        end

        subgraph Limit orders

        place_limit_order_custodian --> place_limit_order
        place_limit_order_user --> place_limit_order
        place_limit_order --> place_limit_order_pre_match
        place_limit_order --> place_limit_order_post_match

        end

    place_limit_order --> match_from_market_account
    place_market_order --> match_from_market_account

    end

    subgraph Swaps

    swap_between_coinstores --> swap
    swap_generic --> swap
    swap_coins --> swap

    end

    match_from_market_account --> match
    match_from_market_account --> match_range_check_fills

    swap_coins --> match_range_check_fills
    swap_between_coinstores --> match_range_check_fills
    swap_generic --> match_range_check_fills
    swap --> match

    subgraph Matching

    match --> match_init
    match -- Looping --> match_loop

        subgraph Loop [ ]

        match_loop --> match_loop_init
        match_loop --> match_loop_order
        match_loop --> match_loop_order_follow_up
        match_loop --> match_loop_break
        match_loop_order --> match_loop_order_fill_size

        end

    match --> match_verify_fills

    end

%% Class definitions

    classDef individually_tested fill:#ff00ff %% Fuchsia
    classDef tested_integrated fill:#00ced1 %% Dark Turquoise
    classDef tested_via_invocation fill:#00ff7f %% Spring Green

    class place_limit_order_pre_match tested_integrated;
    class place_limit_order_post_match tested_integrated;
    class swap_between_coinstores tested_integrated;
    class match_verify_fills individually_tested;
    class swap_coins tested_integrated;
    class swap_generic tested_integrated;
    class match tested_integrated;
    class match_from_market_account tested_integrated;
    class match_init tested_integrated;
    class swap tested_integrated;
    class place_limit_order tested_integrated;
    class place_limit_order_custodian tested_via_invocation;
    class place_limit_order_user tested_via_invocation;
    class place_market_order tested_via_invocation;
    class place_market_order_custodian tested_via_invocation;
    class place_market_order_user tested_via_invocation;
    class match_loop tested_integrated;
    class match_loop_order tested_integrated;
    class match_loop_order_fill_size individually_tested;
    class match_loop_order_follow_up tested_integrated;
    class match_loop_break tested_integrated;
    class match_loop_init tested_integrated;
    class match_range_check_fills individually_tested;

```

### Test functions

The below test functions are used for end-to-end matching engine testing:

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1', 'tertiaryColor': '#808080', 'tertiaryTextColor': '#0d1013'}}}%%

flowchart LR

    subgraph Setup

    register_end_to_end_users_test --> register_end_to_end_market_accounts_test
    register_end_to_end_users_test --> register_end_to_end_orders_test
    register_end_to_end_market_accounts_test --> register_end_to_end_market_account_test
    register_end_to_end_market_account_test --> register_end_to_end_market_account_deposit_test

    end

    register_end_to_end_orders_test --> get_end_to_end_orders_size_price_test
    verify_end_to_end_state_test --> get_end_to_end_orders_size_price_test

    subgraph State verification

    verify_end_to_end_state_test --> get_fill_sizes_test
    get_fill_sizes_test --> get_fill_remaining_test
    verify_end_to_end_state_test --> verify_end_to_end_state_order_user_test
    verify_end_to_end_state_test --> verify_end_to_end_state_user_0_test
    verify_end_to_end_state_order_user_test --> verify_end_to_end_state_collateral_test
    verify_end_to_end_state_user_0_test --> verify_end_to_end_state_collateral_test
    verify_end_to_end_state_test --> verify_end_to_end_state_spread_makers

    end

```