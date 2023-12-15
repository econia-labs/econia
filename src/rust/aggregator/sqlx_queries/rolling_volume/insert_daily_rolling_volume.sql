INSERT INTO aggregator.daily_rolling_volume_history
("time", "market_id", "volume_in_quote_subunits")
WITH times AS (
    SELECT
        DATE_TRUNC('minute', dd) AS time
    FROM
        generate_series((SELECT "time" FROM fill_events ORDER BY "time" LIMIT 1), (SELECT * FROM aggregator.last_time_indexed), '1 minute'::interval) dd
    WHERE
        (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp) IS NOT NULL
    OR
        dd > (SELECT * FROM aggregator.daily_rolling_volume_history_last_indexed_timestamp)
)
SELECT
    times."time",
    fill_events.market_id,
    SUM(fill_events.size * fill_events.price) * market_registration_events.tick_size AS volume_in_quote_subunits
FROM
    fill_events,
    market_registration_events,
    times
WHERE
    fill_events.maker_address = fill_events.emit_address
AND
    fill_events."time" BETWEEN (times."time" - '1 day'::interval) AND times."time"
AND
    market_registration_events.market_id = fill_events.market_id
GROUP BY
    fill_events.market_id,
    market_registration_events.tick_size,
    times."time";
