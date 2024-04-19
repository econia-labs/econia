WITH
  parameters AS (
    SELECT
      $1::INT "group_id",
      $2::INT "bps_times_ten",
      $3::TIMESTAMPTZ "time",
      $4::NUMERIC(20,0) "ask",
      $5::NUMERIC(20,0) "bid"
  )
INSERT INTO aggregator.liquidity (group_id, "time", bps_times_ten, amount_ask_ticks, amount_bid_ticks)
SELECT group_id, "time", bps_times_ten, ask, bid FROM parameters;
