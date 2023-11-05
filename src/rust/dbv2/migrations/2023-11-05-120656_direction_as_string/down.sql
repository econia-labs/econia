-- This file should undo anything in `up.sql`
DROP VIEW api.market_orders;


DROP VIEW api.swap_orders;


CREATE VIEW
  api.market_orders AS
SELECT
  *
FROM
  aggregator.user_history_market
  NATURAL JOIN aggregator.user_history;


CREATE VIEW
  api.swap_orders AS
SELECT
  *
FROM
  aggregator.user_history_swap
  NATURAL JOIN aggregator.user_history;


GRANT
SELECT
  ON api.market_orders TO web_anon;


GRANT
SELECT
  ON api.swap_orders TO web_anon;
