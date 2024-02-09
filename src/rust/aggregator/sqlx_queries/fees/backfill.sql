INSERT INTO aggregator.fees
WITH fees AS (
  SELECT
    sum(taker_quote_fees_paid) AS fees_in_quote_subunits,
    date_trunc('hour', "time") as start_time_1hr_period,
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
  start_time_1hr_period,
  market_id,
  fees_in_quote_subunits
FROM
  fees
ORDER BY
  start_time_1hr_period
ON CONFLICT ON CONSTRAINT fees_pkey DO UPDATE SET
  fees_in_quote_subunits = fees.fees_in_quote_subunits + EXCLUDED.fees_in_quote_subunits;
