-- Your SQL goes here
CREATE INDEX fill_events_maker_order_id ON fill_events (maker_order_id);


CREATE INDEX fill_events_taker_order_id ON fill_events (taker_order_id);


CREATE FUNCTION api.execution_price(api.orders)
RETURNS numeric AS $$
    SELECT
        SUM(size * price) / SUM(size) AS execution_price
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
