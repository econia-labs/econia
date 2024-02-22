WITH
  parameters AS (
    SELECT
      $1::INT "group_id",
      $2::INT "bps",
      $3::TIMESTAMPTZ "time",
      $4::NUMERIC(20,0) "ask",
      $5::NUMERIC(20,0) "bid"
  )
INSERT INTO aggregator.liquidity (group_id, "time", bps, amount_ask_lots, amount_bid_lots)
SELECT group_id, "time", bps, ask, bid FROM parameters;
