WITH parameters AS (
    SELECT
        $1::numeric change_market_id,
        $2::numeric change_order_id
)
SELECT
    order_type AS "order_type: OrderType",
    remaining_size
FROM
    parameters,
    aggregator.user_history
WHERE
    market_id = change_market_id
    AND order_id = change_order_id
