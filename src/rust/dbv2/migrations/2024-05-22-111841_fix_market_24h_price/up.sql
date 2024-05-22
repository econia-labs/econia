-- Your SQL goes here
CREATE OR REPLACE VIEW api.markets AS
WITH x AS (
    SELECT
        m.market_id,
        m.time AS registration_time,
        m.base_account_address,
        m.base_module_name,
        m.base_struct_name,
        m.base_name_generic,
        m.quote_account_address,
        m.quote_module_name,
        m.quote_struct_name,
        m.lot_size,
        m.tick_size,
        m.min_size,
        m.underwriter_id,
        CASE
            WHEN r.market_id = m.market_id THEN true
            ELSE false
        END AS is_recognized,
        (SELECT price FROM api.prices WHERE prices.market_id = m.market_id AND "start_time_1m_period" < CURRENT_TIMESTAMP - interval '24 hours' ORDER BY "start_time_1m_period" DESC LIMIT 1) AS price_24h_ago,
        -- Begin changes
        (SELECT price FROM fill_events WHERE fill_events.market_id = m.market_id AND "time" > CURRENT_TIMESTAMP - interval '24 hours' ORDER BY txn_version DESC, event_idx DESC LIMIT 1) AS last_fill_price_24hr,
        -- End changes
        v.min_price_24h,
        v.max_price_24h,
        v.base_volume_24h,
        v.quote_volume_24h
    FROM
        market_registration_events AS m
    LEFT JOIN
        aggregator.recognized_markets AS r
    ON
        COALESCE(r.base_account_address, '') = COALESCE(m.base_account_address, '')
    AND
        COALESCE(r.base_module_name, '') = COALESCE(m.base_module_name, '')
    AND
        COALESCE(r.base_struct_name, '') = COALESCE(m.base_struct_name, '')
    AND
        COALESCE(r.base_name_generic, '') = COALESCE(m.base_name_generic, '')
    AND
        r.quote_account_address = m.quote_account_address
    AND
        r.quote_module_name = m.quote_module_name
    AND
        r.quote_struct_name = m.quote_struct_name
    LEFT JOIN
        aggregator.markets_24h_data AS v
    ON
        v.market_id = m.market_id
)
SELECT
    market_id,
    registration_time,
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name,
    lot_size,
    tick_size,
    min_size,
    underwriter_id,
    is_recognized,
    last_fill_price_24hr,
    CASE
        WHEN last_fill_price_24hr IS NULL THEN NULL
        ELSE (last_fill_price_24hr - price_24h_ago) / price_24h_ago * 100
    END AS price_change_as_percent_24hr,
    CASE
        WHEN last_fill_price_24hr IS NULL THEN NULL
        ELSE last_fill_price_24hr - price_24h_ago
    END AS price_change_24hr,
    min_price_24h,
    max_price_24h,
    base_volume_24h,
    quote_volume_24h,
    base.name AS base_name,
    base.decimals AS base_decimals,
    base.symbol AS base_symbol,
    "quote".name AS quote_name,
    "quote".decimals AS quote_decimals,
    "quote".symbol AS quote_symbol
FROM
    x
LEFT JOIN
    aggregator.coins AS base
    ON base.address = COALESCE(x.base_account_address, '')
    AND base.module = COALESCE(x.base_module_name, '')
    AND base.struct = COALESCE(x.base_struct_name, '')
LEFT JOIN
    aggregator.coins AS "quote"
    ON "quote".address = COALESCE(x.quote_account_address, '')
    AND "quote".module = COALESCE(x.quote_module_name, '')
    AND "quote".struct = COALESCE(x.quote_struct_name, '');


GRANT SELECT ON api.markets TO web_anon;
