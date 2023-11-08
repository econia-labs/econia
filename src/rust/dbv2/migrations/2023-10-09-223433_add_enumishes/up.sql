-- Your SQL goes here
DROP VIEW api.place_market_order_events;
DROP VIEW api.place_swap_order_events;

CREATE VIEW api.place_market_order_events AS
SELECT
  txn_version,
  event_idx,
  market_id,
  "time",
  order_id,
  "user",
  custodian_id,
  integrator,
  CASE
    WHEN direction = true THEN 'sell'
    ELSE 'buy'
  END AS direction,
  "size",
  self_match_behavior
FROM place_market_order_events;
GRANT SELECT ON api.place_market_order_events TO web_anon;

CREATE VIEW api.place_swap_order_events AS
SELECT
  txn_version,
  event_idx,
  market_id,
  "time",
  order_id,
  signing_account,
  integrator,
  CASE
    WHEN direction = true THEN 'sell'
    ELSE 'buy'
  END AS direction,
  min_base,
  max_base,
  min_quote,
  max_quote,
  limit_price
FROM place_swap_order_events;
GRANT SELECT ON api.place_swap_order_events TO web_anon;