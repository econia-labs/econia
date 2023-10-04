-- This file should undo anything in `up.sql`
DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit DROP COLUMN prev;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

DROP FUNCTION linked_list_last;
