-- This file should undo anything in `up.sql`
ALTER TABLE aggregator.liquidity_groups
DROP CONSTRAINT liquidity_groups_unique;


DROP VIEW api.liquidity;


DROP VIEW api.liquidity_groups;


CREATE OR REPLACE FUNCTION api.get_market_liquidity (market_id numeric, depth numeric) RETURNS NUMERIC AS $$
    WITH mid_price AS (
        SELECT api.get_market_mid_price($1) AS mid_price
    )
    SELECT SUM(CASE
        WHEN direction = 'bid' THEN size_and_price_to_quote_indivisible_subunits($1,remaining_size,price)
        ELSE size_and_price_to_quote_indivisible_subunits($1,remaining_size,api.get_market_last_price($1))
    END)
    AS liquidity_in_quote
    FROM api.orders, mid_price
    WHERE order_status = 'open'
    AND market_id = $1
    AND price::numeric BETWEEN mid_price::numeric * (1::numeric - $2::numeric/10000::numeric) AND mid_price::numeric * (1::numeric + $2::numeric/10000::numeric);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION api.get_market_best_ask_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MIN(price)
    FROM api.orders
    WHERE orders.market_id = $1
    AND order_status = 'open'
    AND direction = 'ask';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION api.get_market_best_bid_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MAX(price)
    FROM api.orders
    WHERE orders.market_id = $1
    AND order_status = 'open'
    AND direction = 'bid';
$$ LANGUAGE SQL;
