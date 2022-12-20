```mermaid

%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#6ed5a3', 'lineColor': '#aaaaaa', 'primaryTextColor': '#020202', 'secondaryColor': '#aaaaaa'}}}%%

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