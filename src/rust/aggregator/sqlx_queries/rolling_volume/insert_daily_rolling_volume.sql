INSERT INTO aggregator.daily_rolling_volume_history
("time", "market_id", "volume_in_quote_subunits")
-- Measured in ticks
WITH volume_per_minute AS (
    SELECT volume, start_time AS "minute", market_id FROM aggregator.candlesticks WHERE resolution = 60 AND (
        start_time > COALESCE((SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp), '0001-01-01') - interval '1 day'
    )
    AND start_time + interval '1 minute' < CURRENT_TIMESTAMP
    ORDER BY start_time
),
volume_totals_per_minute_per_market AS (
    SELECT
        "minute",
        market_id,
        SUM(volume) OVER (PARTITION BY market_id ORDER BY "minute" RANGE BETWEEN '1 day' PRECEDING AND CURRENT ROW) AS volume
    FROM volume_per_minute
)
SELECT
    "minute",
    market_id,
    volume * (
        SELECT tick_size
        FROM market_registration_events m
        WHERE m.market_id = v.market_id
    )
FROM volume_totals_per_minute_per_market v
WHERE (
        (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp) IS NULL
    OR
        "minute" > (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp)
)
ON CONFLICT ON CONSTRAINT daily_rolling_volume_history_pkey DO UPDATE
SET volume_in_quote_subunits = EXCLUDED.volume_in_quote_subunits;
