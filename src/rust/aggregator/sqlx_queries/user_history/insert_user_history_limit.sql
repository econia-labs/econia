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
    initial_size,
    'open',
    'limit'
FROM
    parameters,
    place_limit_order_events
WHERE
    txn_version > max_txn_version
