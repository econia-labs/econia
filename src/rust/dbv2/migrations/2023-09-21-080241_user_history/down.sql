-- This file should undo anything in `up.sql`
DROP VIEW api.orders;
DROP VIEW api.limit_orders;
DROP VIEW api.market_orders;
DROP VIEW api.swap_orders;
DROP TABLE aggregator.aggregated_events;
DROP TABLE aggregator.user_history_limit;
DROP TABLE aggregator.user_history_market;
DROP TABLE aggregator.user_history_swap;
DROP TABLE aggregator.user_history;
DROP TYPE order_status;
DROP TYPE order_type;
