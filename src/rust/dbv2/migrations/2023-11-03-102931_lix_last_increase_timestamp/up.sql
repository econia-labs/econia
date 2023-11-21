-- Your SQL goes here
DROP VIEW api.limit_orders ;


ALTER TABLE aggregator.user_history_limit ALTER COLUMN last_increase_stamp TYPE numeric(39,0);


CREATE VIEW api.limit_orders AS
    SELECT
        market_id,
        order_id,
        "user",
        custodian_id,
        self_matching_behavior,
        restriction,
        created_at,
        last_updated_at,
        integrator,
        total_filled,
        remaining_size,
        order_status,
        order_type,
        price,
        last_increase_stamp,
        CASE
            WHEN side = true THEN 'ask'
            ELSE 'bid'
        END AS side
    FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;


GRANT SELECT ON api.limit_orders TO web_anon;
