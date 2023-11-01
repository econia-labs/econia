WITH parameters AS (
    SELECT
        $1::int AS resolution)
UPDATE aggregator.candlesticks_last_indexed_txn
SET
    txn_version = COALESCE((SELECT (MAX(txn_version)) FROM fill_events), txn_version)
FROM
    parameters
WHERE candlesticks_last_indexed_txn.resolution = parameters.resolution
