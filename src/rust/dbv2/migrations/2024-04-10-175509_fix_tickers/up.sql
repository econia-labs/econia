-- Your SQL goes here
GRANT SELECT ON api.liquidity TO web_anon;
GRANT SELECT ON api.liquidity_groups TO web_anon;


CREATE OR REPLACE FUNCTION api.get_market_best_ask_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT min_ask
    FROM api.spreads
    WHERE market_id = $1
    ORDER BY "time" DESC
    LIMIT 1
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION api.get_market_best_bid_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT max_bid
    FROM api.spreads
    WHERE market_id = $1
    ORDER BY "time" DESC
    LIMIT 1
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION api.get_market_liquidity (market_id numeric, depth numeric) RETURNS NUMERIC AS $$
    SELECT (amount_ask_ticks + amount_bid_ticks) / (SELECT tick_size FROM market_registration_events WHERE market_id = $1)
    FROM api.liquidity
    WHERE group_id = (
        SELECT group_id FROM api.liquidity_groups WHERE name = 'all' AND market_id = $1
    )
    AND bps_times_ten = $2 * 10
    ORDER BY "time" DESC
    LIMIT 1;
$$ LANGUAGE SQL;
