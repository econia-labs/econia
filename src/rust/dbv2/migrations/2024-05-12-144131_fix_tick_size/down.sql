-- This file should undo anything in `up.sql`
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


CREATE OR REPLACE FUNCTION get_quote_volume_divisor_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT tick_size * POW(10::numeric,decimals::numeric)
    FROM market_registration_events AS m
    INNER JOIN api.coins AS c
    ON m.quote_account_address = c."address"
    AND m.quote_module_name = c.module
    AND m.quote_struct_name = c.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE VIEW api.tickers AS
SELECT
    market_id,
    base_account_address || '::' || base_module_name || '::' || base_struct_name AS base_currency,
    quote_account_address || '::' || quote_module_name || '::' || quote_struct_name AS quote_currency,
    base_volume_24h AS base_volume,
    quote_volume_24h AS quote_volume,
    (
        base_volume_24h *
        (SELECT lot_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id) /
        POW(10,base_decimals)
    )
    AS base_volume_nominal,
    (
        quote_volume_24h *
        (SELECT tick_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id) /
        POW(10,quote_decimals)
    )
    AS quote_volume_nominal,
    integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS last_price,
    integer_price_to_quote_nominal(market_id, api.get_market_best_ask_price(market_id)) AS ask,
    integer_price_to_quote_nominal(market_id, api.get_market_best_bid_price(market_id)) AS bid,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_high(market_id)) AS high,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_low(market_id)) AS low,
    api.get_market_liquidity(market_id,200) / get_quote_volume_divisor_for_market(market_id) AS liquidity_in_quote
FROM
    api.markets;


DROP FUNCTION api.quote_indivisible_subunits_to_nominal;


GRANT
SELECT
  ON api.tickers TO web_anon;
