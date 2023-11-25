-- This file should undo anything in `up.sql`
DROP FUNCTION api.average_execution_price;


DROP VIEW api.orders;


CREATE VIEW api.orders AS
    SELECT
        *
    FROM
        aggregator.user_history;


GRANT SELECT ON api.orders TO web_anon;


CREATE FUNCTION api.average_execution_price(api.orders)
RETURNS numeric AS $$
    SELECT
        SUM(size * price) / SUM(size) AS average_execution_price
    FROM
        fill_events
    WHERE
        maker_address = emit_address
    AND
        fill_events.market_id = $1.market_id
    AND (
            fill_events.maker_order_id = $1.order_id
        OR
            fill_events.taker_order_id = $1.order_id
    )
$$ LANGUAGE SQL;
