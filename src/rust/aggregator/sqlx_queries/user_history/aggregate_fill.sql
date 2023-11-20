WITH parameters AS (
    SELECT
        $1::numeric fill_size,
        $2::numeric fill_order_id,
        $3::numeric fill_market_id,
        $4::timestamptz fill_time,
        $5::numeric fill_price)
UPDATE
    aggregator.user_history
SET
    order_status = CASE order_type
    WHEN 'limit' THEN
        CASE remaining_size - fill_size
        WHEN 0 THEN
            'closed'
        ELSE
            order_status
        END
    ELSE
        'closed'
    END,
    last_updated_at = fill_time,
    average_execution_price = (total_filled * COALESCE(average_execution_price, 0) + fill_size * fill_price) / (total_filled + fill_size),
    total_filled = total_filled + fill_size,
    remaining_size = remaining_size - fill_size
FROM
    parameters
WHERE
    order_id = fill_order_id
    AND market_id = fill_market_id
