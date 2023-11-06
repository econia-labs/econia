-- This file should undo anything in `up.sql`
DROP TRIGGER new_limit_order_trigger ON aggregator.user_history_limit;
DROP FUNCTION notify_new_limit_order;
DROP TRIGGER new_market_order_trigger ON aggregator.user_history_market;
DROP FUNCTION notify_new_market_order;
DROP TRIGGER new_swap_order_trigger ON aggregator.user_history_swap;
DROP FUNCTION notify_new_swap_order;
DROP TRIGGER updated_limit_order_trigger ON aggregator.user_history_limit;
DROP FUNCTION notify_updated_limit_order;
DROP TRIGGER updated_market_order_trigger ON aggregator.user_history_market;
DROP FUNCTION notify_updated_market_order;
DROP TRIGGER updated_swap_order_trigger ON aggregator.user_history_swap;
DROP FUNCTION notify_updated_swap_order;
DROP TRIGGER updated_order_trigger ON aggregator.user_history;
DROP FUNCTION notify_updated_order;

DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit DROP COLUMN last_increase_stamp;

ALTER TABLE aggregator.user_history_limit DROP COLUMN price;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

GRANT SELECT ON api.limit_orders TO web_anon;
