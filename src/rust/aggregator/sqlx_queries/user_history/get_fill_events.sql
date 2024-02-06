WITH parameters AS (
    SELECT
        $1::numeric AS txn_version_start,
        $2::numeric AS txn_version_stop
)
SELECT
    *
FROM
    parameters,
    fill_events
WHERE
    txn_version > txn_version_start
AND
    txn_version <= txn_version_stop
ORDER BY
    txn_version,
    event_idx
