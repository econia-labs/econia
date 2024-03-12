WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS txn_version_start,
        $2::numeric(20,0) AS txn_version_end
)
SELECT
    txn_version,
    event_idx,
    market_id,
    order_id,
    new_size
FROM
    change_order_size_events,
    parameters
WHERE
    txn_version > txn_version_start
AND
    txn_version <= txn_version_end
ORDER BY
    txn_version,
    event_idx;
