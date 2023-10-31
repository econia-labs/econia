WITH parameters AS (
    SELECT
        $1::interval AS resolution)
SELECT
    COALESCE(MAX(start_time), (SELECT MIN(time) - parameters.resolution FROM fill_events, parameters GROUP BY parameters.resolution)) as start
FROM
    aggregator.candlesticks AS c,
    parameters AS p
WHERE
    p.resolution = c.resolution
