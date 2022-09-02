# Module dependencies

Econia modules `use` each other as follows:

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart TD

    user --> open_table
    user --> critbit
    user --> order_id
    user --> |friend| registry
    user --> |test-only| assets
    registry --> |test-only| assets
    order_id --> |test-only| critbit
    market --> critbit
    market --> open_table
    market --> |friend| registry
    market --> |test-only| assets
    market --> |friend| user
    market --> order_id

```

# Old matching engine

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart TD

    fill_market_order_custodian --> fill_market_order_from_market_account
    swap --> fill_market_order
    fill_market_order_user --> fill_market_order_from_market_account
    fill_market_order --> fill_market_order_init
    fill_market_order --> fill_market_order_traverse_loop
    fill_market_order_from_market_account --> fill_market_order
    fill_market_order_process_loop_order --> fill_market_order_check_base_parcels_to_fill
    fill_market_order_traverse_loop --> fill_market_order_process_loop_order
    fill_market_order_traverse_loop --> fill_market_order_loop_order_follow_up
    fill_market_order_traverse_loop --> fill_market_order_break_cleanup

```
# New matching engine

If a node has two lines, the second line is the function signature from the old matching engine.

| Color        | Meaning                |
|--------------|------------------------|
| Gray         | To review              |
| Green        | Individually tested    |
| Spring green | Tested via invocation  |
| Blue         | End-to-end tested      |
| Orange       | To test via invocation |
| Gold         | To test end-to-end     |

```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart TD

%% Node definitions

    match[match <br/> fill_market_order]
    match_from_market_account[match_from_market_account <br/> fill_market_order_from_market_account]
    match_init[match_init <br> fill_market_order_init]
    swap[swap]
    place_market_order[place_market_order]
    place_market_order_custodian[place_market_order_custodian <br/> fill_market_order_custodian]
    place_market_order_user[place_market_order_user <br/> fill_market_order_user]
    place_limit_order[place_limit_order]
    place_limit_order_custodian[place_limit_order_custodian]
    place_limit_order_user[place_limit_order_user]
    match_loop[match_loop <br/> fill_market_order_traverse_loop]
    match_loop_order[match_loop_order <br/> fill_market_order_process_loop_order]
    match_loop_order_fill_size[match_loop_order_fill_size <br/> fill_market_order_check_base_parcels_to_fill]
    match_loop_order_follow_up[match_loop_order_follow_up <br/> fill_market_order_loop_order_follow_up]
    match_loop_break[match_loop_break <br/> fill_market_order_break_cleanup]
    swap_coins[swap_coins]
    swap_generic[swap_generic]
    match_verify_fills[match_verify_fills]
    match_loop_init[match_loop_init]
    match_range_check_fills[match_range_check_fills]
    swap_between_coinstores[swap_between_coinstores]
    place_limit_order_pre_match[place_limit_order_pre_match]
    place_limit_order_post_match[place_limit_order_post_match]

%% Class definitions

    classDef tested_integrated fill:#87cefa %% Light Sky Blue
    classDef to_test_integrated fill:#ffd700 %% Gold
    classDef individually_tested fill:#32cd32 %% Lime Green
    classDef to_review fill:#708090 %% Slate Gray
    classDef to_test_via_invocation fill:#ffa500 %% Orange
    classDef tested_via_invocation fill:#00ff7f %% Spring Green

    class place_limit_order_pre_match to_test_integrated;
    class place_limit_order_post_match to_test_integrated;
    class swap_between_coinstores to_test_integrated;
    class match_verify_fills individually_tested;
    class swap_coins to_test_integrated;
    class swap_generic to_test_integrated;
    class match to_test_integrated;
    class match_from_market_account to_test_integrated;
    class match_init to_test_integrated;
    class swap to_test_integrated;
    class place_limit_order to_test_integrated;
    class place_limit_order_custodian to_test_via_invocation;
    class place_limit_order_user to_test_via_invocation;
    class place_market_order to_test_integrated;
    class place_market_order_custodian to_test_via_invocation;
    class place_market_order_user to_test_via_invocation;
    class match_loop to_test_integrated;
    class match_loop_order to_test_integrated;
    class match_loop_order_fill_size individually_tested;
    class match_loop_order_follow_up to_test_integrated;
    class match_loop_break to_test_integrated;
    class match_loop_init to_test_integrated;
    class match_range_check_fills individually_tested;

%% Node relationships

    swap_between_coinstores --> swap
    swap_between_coinstores --> match_range_check_fills
    match --> match_verify_fills
    swap_generic --> match_range_check_fills
    swap_generic --> swap
    swap_coins --> swap
    swap_coins --> match_range_check_fills
    place_limit_order_user --> place_limit_order
    place_limit_order_custodian --> place_limit_order
    place_limit_order --> match_from_market_account
    place_limit_order --> place_limit_order_pre_match
    place_limit_order --> place_limit_order_post_match
    place_market_order --> match_from_market_account
    place_market_order_custodian --> place_market_order
    swap --> match
    place_market_order_user --> place_market_order
    match --> match_init
    match --> match_loop
    match_from_market_account --> match
    match_from_market_account --> match_range_check_fills
    match_loop_order --> match_loop_order_fill_size
    match_loop --> match_loop_init
    match_loop --> match_loop_order
    match_loop --> match_loop_order_follow_up
    match_loop --> match_loop_break

```