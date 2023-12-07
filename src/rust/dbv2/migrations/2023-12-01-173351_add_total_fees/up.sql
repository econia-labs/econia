-- Your SQL goes here
DROP VIEW api.orders;


ALTER TABLE aggregator.user_history
ADD COLUMN total_fees_paid_in_quote_subunits NUMERIC(20,0);


UPDATE aggregator.user_history
SET total_fees_paid_in_quote_subunits = 0;


WITH total_fees AS (
    SELECT
        SUM(taker_quote_fees_paid) AS total_fees_paid_in_quote_subunits,
        taker_order_id,
        market_id
    FROM
        fill_events AS f,
        aggregator.user_history_last_indexed_txn AS last_txn
    WHERE f.maker_address = f.emit_address
    AND f.txn_version <= last_txn.txn_version
    GROUP BY market_id, taker_order_id
)
UPDATE aggregator.user_history AS u
SET total_fees_paid_in_quote_subunits = f.total_fees_paid_in_quote_subunits
FROM total_fees AS f
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
