```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#54a7fa', 'lineColor': '#c4dcf1', 'primaryTextColor': '#0d1013', 'secondaryColor': '#c4dcf1'}}}%%

flowchart TD

    incentives --> tablist
    incentives --> |friend| resource_account
    incentives --> |test-only| assets

    registry --> |friend| incentives
    registry --> tablist
    registry --> |test-only| assets

    market --> avl_queue
    market --> |friend| incentives
    market --> |friend| registry
    market --> |friend| resource_account
    market --> tablist
    market --> |friend| user
    market --> |test-only| assets

    user --> |friend| registry
    user --> tablist
    user --> |test-only| assets
    user --> |test-only| avl_queue

```