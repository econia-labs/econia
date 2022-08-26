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