WITH parameters AS (
    SELECT
        $1::numeric fill_size,
        $2::numeric fill_order_id,
        $3::numeric fill_market_id,
        $4::timestamptz fill_time)
UPDATE
    aggregator.user_history
SET
    remaining_size = remaining_size - fill_size,
    total_filled = total_filled + fill_size,
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
    last_updated_at = fill_time
FROM
    parameters
WHERE
    order_id = fill_order_id
    AND market_id = fill_market_id
