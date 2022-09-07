# `mermaid.js` diagram source

- [`mermaid.js` diagram source](#mermaidjs-diagram-source)
  - [General](#general)
  - [Modules](#modules)
  - [Matching engine](#matching-engine)
  - [Matching engine test functions](#matching-engine-test-functions)

## General

* The below diagrams are generated declaratively via `mermaid.js`, and may present occasional rendering artifacts.

* Most tutorials online present an `%%{init:}` directive on a single line, despite excessive line length.

* The [modules](#modules) diagram theme is matched to GitHub's color schema.

* Recommended disclaimer
    * (If accessing the below diagram via GitBook, you may need to switch web browsers to view an enlarged version, which can be pulled up by clicking on the image.)

* `SVG` diagrams can be generated via [mermaid.live](https://mermaid.live/)

## Modules

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

## Matching engine test functions

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