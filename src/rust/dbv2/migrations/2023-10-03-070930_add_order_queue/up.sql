-- Your SQL goes here
DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit ADD COLUMN price NUMERIC(20) NOT NULL;

ALTER TABLE aggregator.user_history_limit ADD COLUMN last_increase_time TIMESTAMPTZ NOT NULL;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

GRANT SELECT ON api.limit_orders TO web_anon;
