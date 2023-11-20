WITH parameters AS (
    SELECT
        $1::numeric change_market_id,
        $2::numeric change_order_id,
        $3::numeric change_increase_stamp)
UPDATE
    aggregator.user_history
SET
    last_increase_stamp = change_increase_stamp
FROM
    parameters
WHERE
    market_id = change_market_id
    AND order_id = change_order_id
