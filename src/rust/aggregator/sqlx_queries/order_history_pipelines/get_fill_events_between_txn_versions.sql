WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS txn_version_start,
        $2::numeric(20,0) AS txn_version_end
)
SELECT
    txn_version,
    event_idx,
    market_id,
    maker_order_id,
    taker_order_id,
    "size",
    price
FROM
    fill_events,
    parameters
WHERE
    txn_version > txn_version_start
AND
    txn_version <= txn_version_end
AND
    emit_address = maker_address
ORDER BY
    txn_version,
    event_idx;
