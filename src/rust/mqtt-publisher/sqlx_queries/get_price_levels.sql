WITH levels AS (
    SELECT
        market_id,
        direction::text,
        price,
        SUM(remaining_size) AS total_size
    FROM
        aggregator.user_history
    WHERE
        order_status = 'open'
    GROUP BY
        market_id,
        direction,
        price
    ORDER BY
        market_id,
        direction,
        CASE
            WHEN direction = 'ask' THEN price
            ELSE -1 * price
        END
),
numbered_levels AS (
    SELECT
        *,
        row_number() OVER (PARTITION BY market_id, direction) AS level
    FROM
        levels
)
SELECT * FROM numbered_levels WHERE level <= 10;
