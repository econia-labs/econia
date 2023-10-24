WITH parameters AS (
    SELECT
        $1::numeric change_new_size,
        $2::numeric change_order_id,
        $3::numeric change_market_id,
        $4::timestamptz change_time)
UPDATE
    aggregator.user_history
SET
    last_updated_at = change_time,
    remaining_size = change_new_size
FROM
    parameters
WHERE
    order_id = change_order_id
    AND market_id = change_market_id
