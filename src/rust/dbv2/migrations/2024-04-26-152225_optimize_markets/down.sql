-- This file should undo anything in `up.sql`
CREATE OR REPLACE VIEW
  api.markets AS
WITH
  last_fills AS (
    SELECT DISTINCT
      ON (market_id) *
    FROM
      fill_events
    WHERE
      "time" >= CURRENT_TIMESTAMP - '1 day'::INTERVAL
    ORDER BY
      market_id,
      txn_version DESC,
      event_idx DESC
  ),
  first_fills AS (
    SELECT DISTINCT
      ON (market_id) *
    FROM
      fill_events
    WHERE
      "time" >= CURRENT_TIMESTAMP - '1 day'::INTERVAL
    ORDER BY
      market_id,
      txn_version ASC,
      event_idx ASC
  )
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
    WHEN r.market_id = m.market_id THEN TRUE
    ELSE FALSE
  END AS is_recognized,
  l.price AS last_fill_price_24hr,
  (COALESCE(l.price, 1) - COALESCE(f.price, 1)) / COALESCE(f.price, 1) * 100 AS price_change_as_percent_24hr,
  l.price - f.price AS price_change_24hr,
  v.min_price_24h,
  v.max_price_24h,
  v.base_volume_24h,
  v.quote_volume_24h,
  base.name AS base_name,
  base.decimals AS base_decimals,
  base.symbol AS base_symbol,
  "quote".name AS quote_name,
  "quote".decimals AS quote_decimals,
  "quote".symbol AS quote_symbol
FROM
  market_registration_events AS m
  LEFT JOIN aggregator.recognized_markets AS r ON COALESCE(r.base_account_address, '') = COALESCE(m.base_account_address, '')
  AND COALESCE(r.base_module_name, '') = COALESCE(m.base_module_name, '')
  AND COALESCE(r.base_struct_name, '') = COALESCE(m.base_struct_name, '')
  AND COALESCE(r.base_name_generic, '') = COALESCE(m.base_name_generic, '')
  AND r.quote_account_address = m.quote_account_address
  AND r.quote_module_name = m.quote_module_name
  AND r.quote_struct_name = m.quote_struct_name
  LEFT JOIN aggregator.coins AS base ON base.address = COALESCE(m.base_account_address, '')
  AND base.module = COALESCE(m.base_module_name, '')
  AND base.struct = COALESCE(m.base_struct_name, '')
  LEFT JOIN aggregator.coins AS "quote" ON "quote".address = COALESCE(m.quote_account_address, '')
  AND "quote".module = COALESCE(m.quote_module_name, '')
  AND "quote".struct = COALESCE(m.quote_struct_name, '')
  LEFT JOIN first_fills AS f ON f.market_id = m.market_id
  LEFT JOIN last_fills AS l ON l.market_id = m.market_id
  LEFT JOIN aggregator.markets_24h_data AS v ON v.market_id = m.market_id;


DROP INDEX markets_market_id_txn_version_event_idx;


GRANT SELECT ON api.markets TO web_anon;
