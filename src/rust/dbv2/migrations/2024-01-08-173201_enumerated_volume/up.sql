-- Your SQL goes here
CREATE MATERIALIZED VIEW aggregator.enumerated_volume AS
WITH base_volumes AS (
    SELECT
        SUM(size) AS base_volume,
        base_account_address AS address,
        base_module_name AS module,
        base_struct_name AS struct,
        base_name_generic AS name_generic
    FROM fill_events, api.markets
    WHERE emit_address = maker_address
    AND markets.market_id = fill_events.market_id
    GROUP BY
        base_account_address,
        base_module_name,
        base_struct_name,
        base_name_generic
),
quote_volumes AS (
    SELECT
        SUM(size*price) AS quote_volume,
        quote_account_address AS address,
        quote_module_name AS module,
        quote_struct_name AS struct
    FROM fill_events, api.markets
    WHERE emit_address = maker_address
    AND markets.market_id = fill_events.market_id
    GROUP BY
        quote_account_address,
        quote_module_name,
        quote_struct_name
)
SELECT
    SUM(base_volume) AS base_volume,
    SUM(quote_volume) AS quote_volume,
    COALESCE(b.address, q.address) AS address,
    COALESCE(b.module, q.module) AS module,
    COALESCE(b.struct, q.struct) AS struct,
    b.name_generic
FROM base_volumes b
FULL JOIN quote_volumes q
ON b.address = q.address
AND b.module = q.module
AND b.struct = q.struct
GROUP BY
    b.address,
    b.module,
    b.struct,
    b.name_generic,
    q.address,
    q.module,
    q.struct;

CREATE VIEW api.enumerated_volume AS
SELECT * FROM aggregator.enumerated_volume;

GRANT
SELECT
  ON api.enumerated_volume TO web_anon;
