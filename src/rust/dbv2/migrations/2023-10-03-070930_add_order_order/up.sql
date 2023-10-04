-- Your SQL goes here
DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit ADD COLUMN prev NUMERIC;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

GRANT SELECT ON api.limit_orders TO web_anon;

CREATE FUNCTION linked_list_last(NUMERIC(20), NUMERIC(20)) RETURNS NUMERIC AS $$
DECLARE last_order_id NUMERIC;
    BEGIN
        SELECT order_id INTO last_order_id
        FROM aggregator.user_history_limit AS a
        WHERE market_id = $1
        AND price = $2
        AND EXISTS (SELECT * FROM aggregator.user_history AS b WHERE a.market_id = b.market_id AND a.order_id = b.order_id AND order_status = 'open')
        AND NOT EXISTS (SELECT * FROM aggregator.user_history_limit AS b WHERE b.market_id = $1 AND b.price = $2 AND b.prev = a.order_id);
        IF COUNT(last_order_id) = 0 THEN
            RETURN NULL;
        END IF;
        RETURN last_order_id;
    END;
$$ LANGUAGE plpgsql;
