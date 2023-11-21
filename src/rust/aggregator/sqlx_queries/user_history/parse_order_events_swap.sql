WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
INSERT INTO aggregator.user_history_swap
SELECT
    market_id,
    order_id,
    direction,
    limit_price,
    signing_account,
    min_base,
    max_base,
    min_quote,
    max_quote
FROM
    parameters,
    place_swap_order_events
WHERE
    txn_version > max_txn_version
