-- Your SQL goes here
DROP FUNCTION api.average_execution_price;


DROP VIEW api.orders;


CREATE VIEW api.orders AS
    SELECT
        -- Common to all
        u.market_id,
        u.order_id,
        u.created_at,
        u.last_updated_at,
        u.integrator,
        u.total_filled,
        u.remaining_size,
        u.order_status,
        u.order_type,

        -- Common to all but with different names
        CASE
            WHEN u.order_type = 'limit' THEN l."user"
            WHEN u.order_type = 'market' THEN m."user"
            WHEN u.order_type = 'swap' THEN s.signing_account
        END AS "user",
        CASE
            WHEN u.order_type = 'limit' THEN
                CASE
                    WHEN l.side = true THEN 'ask'
                    ELSE 'bid'
                END
            WHEN u.order_type = 'market' THEN
                CASE
                    WHEN m.direction = true THEN 'buy'
                    ELSE 'sell'
                END
            WHEN u.order_type = 'swap' THEN
                CASE
                    WHEN s.direction = true THEN 'buy'
                    ELSE 'sell'
                END
        END AS direction,

        -- Common to some
        CASE
            WHEN u.order_type = 'limit' THEN l.price
            WHEN u.order_type = 'market' THEN NULL
            WHEN u.order_type = 'swap' THEN s.limit_price
        END AS price,
        CASE
            WHEN u.order_type = 'limit' THEN l.custodian_id
            WHEN u.order_type = 'market' THEN m.custodian_id
            WHEN u.order_type = 'swap' THEN NULL
        END AS custodian_id,
        CASE
            WHEN u.order_type = 'limit' THEN l.self_matching_behavior
            WHEN u.order_type = 'market' THEN m.self_matching_behavior
            WHEN u.order_type = 'swap' THEN NULL
        END AS self_matching_behavior,

        -- Particular to limit orders
        l.restriction,

        -- Particular to swap orders
        s.min_base,
        s.max_base,
        s.min_quote,
        s.max_quote
    FROM
        aggregator.user_history AS u
    NATURAL LEFT JOIN
        aggregator.user_history_limit AS l
    NATURAL LEFT JOIN
        aggregator.user_history_market AS m
    NATURAL LEFT JOIN
        aggregator.user_history_swap AS s;


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
