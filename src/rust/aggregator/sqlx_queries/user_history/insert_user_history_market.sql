WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
INSERT INTO aggregator.user_history (
    market_id,
    order_id,
    created_at,
    last_updated_at,
    integrator,
    total_filled,
    remaining_size,
    order_status,
    order_type,
    "user",
    direction,
    price,
    average_execution_price,
    custodian_id,
    self_match_behavior,
    restriction,
    min_base,
    max_base,
    min_quote,
    max_quote
)
SELECT
    market_id,
    order_id,
    "time",
    NULL,
    integrator,
    0,
    "size",
    'open',
    'market',
    "user",
    CASE
        WHEN direction = true THEN 'sell'::order_direction
        ELSE 'buy'::order_direction
    END,
    NULL,
    NULL,
    custodian_id,
    self_match_behavior,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
FROM
    parameters,
    place_market_order_events
WHERE
    txn_version > max_txn_version
