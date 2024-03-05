-- This file should undo anything in `up.sql`
DROP VIEW api.tickers;


CREATE VIEW api.tickers AS
SELECT
    market_id,
    base_account_address || '::' || base_module_name || '::' || base_struct_name AS base_currency,
    quote_account_address || '::' || quote_module_name || '::' || quote_struct_name AS quote_currency,
    base_volume_24h AS base_volume,
    quote_volume_24h AS quote_volume,
    integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS last_price,
    integer_price_to_quote_nominal(market_id, api.get_market_best_ask_price(market_id)) AS ask,
    integer_price_to_quote_nominal(market_id, api.get_market_best_bid_price(market_id)) AS bid,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_high(market_id)) AS high,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_low(market_id)) AS low,
    api.get_market_liquidity(market_id,200) / get_quote_volume_divisor_for_market(market_id) AS liquidity_in_quote
FROM
    api.markets;

GRANT SELECT ON api.tickers TO web_anon;
