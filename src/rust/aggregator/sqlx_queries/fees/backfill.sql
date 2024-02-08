INSERT INTO aggregator.fees
WITH fees AS (
  SELECT
    sum(taker_quote_fees_paid) AS fees,
    date_trunc('hour', "time") as "time",
    market_id
  FROM
    fill_events f
  WHERE ((SELECT * FROM aggregator.fees_last_indexed_txn) IS NULL OR f.txn_version > (SELECT * FROM aggregator.fees_last_indexed_txn))
  AND emit_address = maker_address
  GROUP BY
    market_id,
    date_trunc('hour', "time")
)
SELECT
  "time",
  market_id,
  fees
FROM
  fees
ORDER BY
  "time"
ON CONFLICT ON CONSTRAINT fees_pkey DO UPDATE SET
  amount = fees.amount + EXCLUDED.amount;
