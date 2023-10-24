WITH max_per_table AS (
    SELECT
        MAX(txn_version) AS max
    FROM
        fill_events
    UNION ALL
    SELECT
        MAX(txn_version) AS max
    FROM
        place_limit_order_events
    UNION ALL
    SELECT
        MAX(txn_version) AS max
    FROM
        place_market_order_events
    UNION ALL
    SELECT
        MAX(txn_version) AS max
    FROM
        place_swap_order_events
)
SELECT
    MAX(max) AS max
FROM
    max_per_table
