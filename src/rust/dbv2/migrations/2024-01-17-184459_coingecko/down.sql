-- This file should undo anything in `up.sql`
DROP VIEW api.historical_trades;
DROP FUNCTION api.orderbook;
DROP VIEW api.tickers;
DROP FUNCTION api.get_market_mid_price;
DROP FUNCTION api.get_market_liquidity;
DROP FUNCTION api.get_market_24h_low;
DROP FUNCTION api.get_market_24h_high;
DROP FUNCTION api.get_market_best_bid_price;
DROP FUNCTION api.get_market_best_ask_price;
DROP FUNCTION api.get_market_last_price;
DROP FUNCTION integer_price_to_quote_nominal;


CREATE OR REPLACE FUNCTION integer_price_to_quote_indivisible_subunits(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * tick_size * POW(10,COALESCE(base.decimals, 0))) / lot_size
    FROM market_registration_events
    LEFT JOIN aggregator.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN aggregator.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION quote_indivisible_subunits_to_integer_price(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * POW(10,COALESCE(base.decimals, 0)) * lot_size) / tick_size
    FROM market_registration_events
    LEFT JOIN aggregator.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN aggregator.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION size_to_base_indivisible_subunits(market_id numeric, "size" numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * lot_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION size_and_price_to_quote_indivisible_subunits(market_id numeric, "size" numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * $3 * tick_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_quote_volume_divisor_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT tick_size * POW(10::numeric,decimals::numeric)
    FROM market_registration_events AS m
    INNER JOIN aggregator.coins AS c
    ON m.quote_account_address = c."address"
    AND m.quote_module_name = c.module
    AND m.quote_struct_name = c.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


DROP VIEW api.coins;
