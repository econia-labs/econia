-- This file should undo anything in `up.sql`
DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit DROP COLUMN last_increase_time;

ALTER TABLE aggregator.user_history_limit DROP COLUMN price;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;
