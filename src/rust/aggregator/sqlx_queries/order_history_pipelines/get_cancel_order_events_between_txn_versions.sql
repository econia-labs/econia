WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS txn_version_start,
        $2::numeric(20,0) AS txn_version_end
)
SELECT
    market_id,
    order_id
FROM
    cancel_order_events,
    parameters
WHERE
    txn_version > txn_version_start
AND
    txn_version <= txn_version_end;
