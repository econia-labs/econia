WITH parameters AS (
    SELECT
        $1::interval AS resolution)
SELECT
    MAX(start_time) as start
FROM
    aggregator.candlesticks AS c,
    parameters AS p
WHERE
    p.resolution = c.resolution
