INSERT INTO aggregator.prices
SELECT
    market_id,
    date_trunc('minute', "time"),
    AVG(price),
    SUM(size)
FROM fill_events
WHERE emit_address = maker_address
AND txn_version > COALESCE((SELECT * FROM aggregator.prices_last_indexed_txn), 0)
GROUP BY date_trunc('minute', "time"), market_id
ORDER BY date_trunc('minute', "time"), market_id
ON CONFLICT ON CONSTRAINT prices_pkey DO UPDATE SET
price = (EXCLUDED.price * EXCLUDED.weight + prices.price * prices.weight) / (EXCLUDED.weight + prices.weight);
