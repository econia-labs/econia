WITH parameters AS (
    SELECT
        $1::int AS resolution)
INSERT INTO aggregator.candlesticks_last_indexed_txn
SELECT
    resolution, 0
FROM
    parameters
ON CONFLICT DO NOTHING
