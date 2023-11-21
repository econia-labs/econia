WITH parameters AS (
    SELECT
        $1::int AS resolution),
last_txn AS (
    SELECT
        txn_version
    FROM
        aggregator.candlesticks_last_indexed_txn AS c,
        parameters AS p
    WHERE
        c.resolution = p.resolution),
fills AS (
    SELECT
        market_id,
        price,
        "size",
        -- Calculate start_time as now - (now % resolution)
        to_timestamp(extract(epoch from time)::bigint / resolution * resolution) AS start_time
    FROM
        fill_events,
        parameters,
        last_txn
    WHERE -- take only unindexed
        fill_events.txn_version > last_txn.txn_version
    AND -- remove duplicates
        maker_address = emit_address
    ORDER BY fill_events.txn_version, event_idx)
INSERT INTO aggregator.candlesticks
SELECT
    fills.market_id,                                -- market_id
    resolution,                                     -- resolution
    start_time,                                     -- start_time
    FIRST(fills.price),                             -- open
    MAX(fills.price),                               -- high
    MIN(fills.price),                               -- low
    LAST(fills.price),                              -- close
    COALESCE(SUM(fills."size"*fills.price), 0)        -- volume
FROM
    parameters,
    fills
GROUP BY market_id, start_time, resolution
ON CONFLICT ON CONSTRAINT candlesticks_pkey DO
UPDATE SET
    high = GREATEST(EXCLUDED.high,candlesticks.high),
    low = LEAST(EXCLUDED.low,candlesticks.low),
    close = EXCLUDED.close,
    volume = EXCLUDED.volume + candlesticks.volume
