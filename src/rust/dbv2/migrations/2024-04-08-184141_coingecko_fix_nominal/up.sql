-- Your SQL goes here
DROP VIEW api.tickers;


CREATE OR REPLACE FUNCTION api.get_market_last_price (market_id numeric) RETURNS NUMERIC STABLE AS $$
    SELECT price
    FROM fill_events
    ORDER BY txn_version DESC, event_idx DESC
    LIMIT 1;
$$ LANGUAGE SQL;


CREATE VIEW api.tickers AS
SELECT
    market_id,
    base_account_address || '::' || base_module_name || '::' || base_struct_name AS base_currency,
    quote_account_address || '::' || quote_module_name || '::' || quote_struct_name AS quote_currency,
    base_volume_24h AS base_volume,
    quote_volume_24h AS quote_volume,
    -- all_24h_volume_in_base_nominal = (quote_in_ticks * tick_size / 10^quote_decimals / price_nominal * 10^base_decimals + base_in_lots * lot_size) / 10^base_decimals
    (
            quote_volume_24h *
            (SELECT tick_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id) /
            POW(10,quote_decimals) /
            integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) *
            POW(10,base_decimals)
        +
            base_volume_24h *
            (SELECT lot_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
    ) / POW(10,base_decimals) AS all_24h_volume_in_base_nominal,
    -- all_24h_volume_in_quote_nominal = (quote_in_ticks * tick_size + base_in_lots * lot_size / 10^base_decimals * price_nominal * 10^qoute_decimals) / 10^quote_decimals
    (
            quote_volume_24h *
            (SELECT tick_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
        +
            base_volume_24h *
            (SELECT lot_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id) /
            POW(10,base_decimals) *
            integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) *
            POW(10,quote_decimals)
    ) / POW(10,quote_decimals) AS all_24h_volume_in_quote_nominal,
    -- base_24h_volume_in_base_nominal = (base_in_lots * lot_size) / 10^base_decimals
    (
        base_volume_24h *
        (SELECT lot_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
    ) / POW(10,quote_decimals) AS base_24h_volume_in_base_nominal,
    -- base_24h_volume_in_quote_nominal = (base_in_lots * lot_size) / 10^base_decimals * price_nominal
    (
        base_volume_24h *
        (SELECT lot_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
    ) / POW(10,quote_decimals) * integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS base_24h_volume_in_quote_nominal,
    -- quote_24h_volume_in_quote_nominal = (quote_in_ticks * tick_size) / 10^quote_decimals
    (
        quote_volume_24h *
        (SELECT tick_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
    ) / POW(10,quote_decimals) AS quote_24h_volume_in_quote_nominal,
    -- quote_24h_volume_in_base_nominal = (quote_in_ticks * tick_size) / 10^quote_decimals / price_nominal
    (
        quote_volume_24h *
        (SELECT tick_size FROM market_registration_events AS x WHERE x.market_id = markets.market_id)
    ) / POW(10,quote_decimals) / integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS quote_24h_volume_in_base_nominal,
    integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS last_price,
    integer_price_to_quote_nominal(market_id, api.get_market_best_ask_price(market_id)) AS ask,
    integer_price_to_quote_nominal(market_id, api.get_market_best_bid_price(market_id)) AS bid,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_high(market_id)) AS high,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_low(market_id)) AS low,
    api.get_market_liquidity(market_id,200) / get_quote_volume_divisor_for_market(market_id) AS liquidity_in_quote
FROM
    api.markets;

GRANT SELECT ON api.tickers TO web_anon;
