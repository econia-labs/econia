-- This file should undo anything in `up.sql`
DROP VIEW api.orders;


ALTER TABLE aggregator.user_history
DROP COLUMN total_fees_paid_in_quote_subunits;


CREATE VIEW api.orders AS
    SELECT
        *
    FROM
        aggregator.user_history;


GRANT SELECT ON api.orders TO web_anon;
