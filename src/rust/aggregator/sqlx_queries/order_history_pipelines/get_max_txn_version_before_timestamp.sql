WITH max_place AS (
    SELECT
        txn_version
    FROM
        place_limit_order_events
    WHERE
        make_time_version("time", txn_version) < make_time_version($1, 0)
    ORDER BY
        make_time_version("time", txn_version) DESC
    LIMIT 1
),
max_fill AS (
    SELECT
        txn_version
    FROM
        fill_events
    WHERE
        make_time_version("time", txn_version) < make_time_version($1, 0)
    ORDER BY
        make_time_version("time", txn_version) DESC
    LIMIT 1
),
max_change AS (
    SELECT
        txn_version
    FROM
        change_order_size_events
    WHERE
        make_time_version("time", txn_version) < make_time_version($1, 0)
    ORDER BY
        make_time_version("time", txn_version) DESC
    LIMIT 1
),
max_cancel AS (
    SELECT
        txn_version
    FROM
        cancel_order_events
    WHERE
        make_time_version("time", txn_version) < make_time_version($1, 0)
    ORDER BY
        make_time_version("time", txn_version) DESC
    LIMIT 1
),
maxes AS (
    SELECT
        *
    FROM
        max_place
    UNION
    SELECT
        *
    FROM
        max_fill
    UNION
    SELECT
        *
    FROM
        max_change
    UNION
    SELECT
        *
    FROM
        max_cancel
)
SELECT
    MAX(txn_version) AS txn_version
FROM
    maxes;
