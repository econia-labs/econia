-- Your SQL goes here
DROP VIEW api.market_orders;


DROP VIEW api.swap_orders;


CREATE VIEW
  api.market_orders AS
SELECT
  market_id,
  order_id,
  "user",
  custodian_id,
  CASE
    WHEN direction = TRUE THEN 'sell'
    ELSE 'buy'
  END AS direction,
  self_matching_behavior,
  created_at,
  last_updated_at,
  integrator,
  total_filled,
  remaining_size,
  order_status,
  order_type
FROM
  aggregator.user_history_market
  NATURAL JOIN aggregator.user_history;


CREATE VIEW
  api.swap_orders AS
SELECT
  market_id,
  order_id,
  CASE
    WHEN direction = TRUE THEN 'sell'
    ELSE 'buy'
  END AS direction,
  limit_price,
  signing_account,
  min_base,
  max_base,
  min_quote,
  max_quote,
  created_at,
  last_updated_at,
  integrator,
  total_filled,
  remaining_size,
  order_status,
  order_type
FROM
  aggregator.user_history_swap
  NATURAL JOIN aggregator.user_history;


GRANT
SELECT
  ON api.market_orders TO web_anon;


GRANT
SELECT
  ON api.swap_orders TO web_anon;
