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
    swaps.market_id,
    swaps.order_id,
    swaps."time",
    NULL,
    swaps.integrator,
    0,
    DIV(swaps.max_base, markets.lot_size),
    'open',
    'swap',
    swaps.signing_account,
    CASE
        WHEN swaps.direction = true THEN 'sell'::order_direction
        ELSE 'buy'::order_direction
    END,
    swaps.limit_price,
    NULL,
    NULL,
    NULL,
    NULL,
    swaps.min_base,
    swaps.max_base,
    swaps.min_quote,
    swaps.max_quote
FROM
    parameters,
    place_swap_order_events AS swaps
    INNER JOIN market_registration_events AS markets ON markets.market_id = swaps.market_id
WHERE
    swaps.txn_version > max_txn_version
