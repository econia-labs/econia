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