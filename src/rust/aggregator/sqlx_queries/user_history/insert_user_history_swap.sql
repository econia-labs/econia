WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
INSERT INTO aggregator.user_history
SELECT
    swaps.market_id,
    swaps.order_id,
    swaps."time",
    NULL,
    swaps.integrator,
    0,
    DIV(swaps.max_base, markets.lot_size),
    'open',
    'swap'
FROM
    parameters,
    place_swap_order_events AS swaps
    INNER JOIN market_registration_events AS markets ON markets.market_id = swaps.market_id
WHERE
    swaps.txn_version > max_txn_version
