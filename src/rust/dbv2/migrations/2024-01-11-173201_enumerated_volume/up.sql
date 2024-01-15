-- Your SQL goes here
CREATE TABLE aggregator.enumerated_volume (
    volume_as_base NUMERIC(20,0),
    volume_as_quote NUMERIC(20,0),
    "address" TEXT,
    module TEXT,
    struct TEXT,
    generic_asset_name TEXT,
    last_indexed_txn NUMERIC(20,0) NOT NULL,
    PRIMARY KEY ("address", module, struct, generic_asset_name)
);

CREATE VIEW api.enumerated_volume AS
SELECT * FROM aggregator.enumerated_volume
NATURAL LEFT JOIN aggregator.coins;

CREATE MATERIALIZED VIEW aggregator.enumerated_volume_24h AS
WITH base_volumes AS (
    SELECT
        size_to_base_indivisible_subunits(markets.market_id, SUM("size")) AS volume_as_base,
        base_account_address AS "address",
        base_module_name AS module,
        base_struct_name AS struct,
        base_name_generic AS generic_asset_name
    FROM fill_events, api.markets
    WHERE emit_address = maker_address
    AND fill_events."time" > CURRENT_TIMESTAMP - interval '1 day'
    AND markets.market_id = fill_events.market_id
    GROUP BY
        markets.market_id,
        base_account_address,
        base_module_name,
        base_struct_name,
        base_name_generic
),
quote_volumes AS (
    SELECT
        SUM(size_and_price_to_quote_indivisible_subunits(markets.market_id, "size", price)) AS volume_as_quote,
        quote_account_address AS "address",
        quote_module_name AS module,
        quote_struct_name AS struct
    FROM fill_events, api.markets
    WHERE emit_address = maker_address
    AND fill_events."time" > CURRENT_TIMESTAMP - interval '1 day'
    AND markets.market_id = fill_events.market_id
    GROUP BY
        markets.market_id,
        quote_account_address,
        quote_module_name,
        quote_struct_name
),
latest AS (
    SELECT
        SUM(volume_as_base) AS volume_as_base,
        SUM(volume_as_quote) AS volume_as_quote,
        COALESCE(b."address", q."address") AS "address",
        COALESCE(b.module, q.module) AS module,
        COALESCE(b.struct, q.struct) AS struct,
        b.generic_asset_name
    FROM base_volumes b
    FULL JOIN quote_volumes q
    ON b."address" = q."address"
    AND b.module = q.module
    AND b.struct = q.struct
    GROUP BY
        b."address",
        b.module,
        b.struct,
        b.generic_asset_name,
        q."address",
        q.module,
        q.struct
)
SELECT
    a.volume_as_base AS volume_as_base,
    a.volume_as_quote AS volume_as_quote,
    COALESCE(a."address", '') AS "address", COALESCE(a.module, '') AS module, COALESCE(a.struct, '') AS struct,
    COALESCE(a.generic_asset_name, '') AS generic_asset_name
FROM latest a;


CREATE VIEW api.enumerated_volume_24h AS
SELECT * FROM aggregator.enumerated_volume_24h
NATURAL LEFT JOIN aggregator.coins;

GRANT
SELECT
  ON api.enumerated_volume TO web_anon;

GRANT
SELECT
  ON api.enumerated_volume_24h TO web_anon;
