WITH parameters AS (
    SELECT
        $1::int AS duration),
fills AS (
    SELECT
        fill_events.*,
        to_timestamp(extract(epoch from time)::bigint / duration * duration) AS start_time
    FROM
        fill_events,
        parameters
    ORDER BY
        market_id
)
INSERT INTO aggregator.candlesticks
SELECT
    fills.market_id,                                -- market_id
    '1 second'::interval * duration,                -- resolution
    start_time,                                     -- start_time
    FIRST(fills.price) OVER w,                      -- open
    MAX(fills.price) OVER w,                        -- high
    MIN(fills.price) OVER w,                        -- low
    LAST(fills.price) OVER w,                       -- close
    COALESCE(SUM(fills.size*fills.price) OVER w, 0) -- volume
FROM
    parameters,
    fills
WINDOW w AS (PARTITION BY start_time, duration)
