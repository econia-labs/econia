WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version
)
SELECT
    *
FROM
    parameters,
    fill_events
WHERE
    txn_version > max_txn_version
ORDER BY
    txn_version,
    event_idx
