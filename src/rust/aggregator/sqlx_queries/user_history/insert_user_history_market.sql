WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
INSERT INTO aggregator.user_history
SELECT
    market_id,
    order_id,
    "time",
    NULL,
    integrator,
    0,
    "size",
    'open',
    'market'
FROM
    parameters,
    place_market_order_events
WHERE
    txn_version > max_txn_version
