INSERT INTO aggregator.daily_rolling_volume_history
("time", "market_id", "volume_in_quote_subunits")
WITH vpm AS (
    SELECT
        SUM(size * price) volume,
        DATE_TRUNC('minute', "time") AS minute,
        market_id
    FROM fill_events
    WHERE emit_address = maker_address
    AND (
            (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp) IS NULL
        OR
            DATE_TRUNC('minute', "time") >= DATE_TRUNC('minute', (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp)) - interval '1 day'
    )
    GROUP BY DATE_TRUNC('minute', "time"), market_id
    ORDER BY DATE_TRUNC('minute', "time")
),
t AS (
    SELECT
        minute,
        market_id,
        SUM(volume) OVER (PARTITION BY market_id ORDER BY minute RANGE BETWEEN '24 hours' PRECEDING AND CURRENT ROW) AS volume
    FROM vpm
)
SELECT * FROM t
WHERE (
        (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp) IS NULL
    OR
        "minute" >= DATE_TRUNC('minute', (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp))
)
ON CONFLICT ON CONSTRAINT daily_rolling_volume_history_pkey DO UPDATE
SET volume_in_quote_subunits = EXCLUDED.volume_in_quote_subunits;
