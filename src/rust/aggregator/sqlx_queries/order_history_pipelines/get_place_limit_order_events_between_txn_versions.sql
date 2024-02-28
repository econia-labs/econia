WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS txn_version_start,
        $2::numeric(20,0) AS txn_version_end
)
SELECT
    market_id,
    order_id,
    initial_size AS "size",
    side,
    price,
    "user"
FROM
    place_limit_order_events,
    parameters
WHERE
    txn_version > txn_version_start
AND
    txn_version <= txn_version_end;
