-- Your SQL goes here
DROP VIEW api.orders;


ALTER TABLE aggregator.user_history
ADD COLUMN total_fees_paid_in_quote_subunits NUMERIC(20,0);


UPDATE aggregator.user_history AS u
SET total_fees_paid_in_quote_subunits = SUM(taker_quote_fees_paid)
FROM fill_events AS f
WHERE f.taker_order_id = u.order_id
AND f.market_id = u.market_id;


ALTER TABLE aggregator.user_history
ALTER COLUMN total_fees_paid_in_quote_subunits SET NOT NULL;


CREATE VIEW api.orders AS
    SELECT
        *
    FROM
        aggregator.user_history;


GRANT SELECT ON api.orders TO web_anon;
