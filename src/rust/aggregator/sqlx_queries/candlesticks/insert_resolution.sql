WITH parameters AS (
    SELECT
        $1::interval AS new_resolution)
INSERT INTO aggregator.candlestick_resolutions
SELECT
    new_resolution
FROM
    parameters
