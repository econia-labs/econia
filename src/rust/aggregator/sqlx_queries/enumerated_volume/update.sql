INSERT INTO aggregator.enumerated_volume (volume_as_base, volume_as_quote, "address", module, struct, generic_asset_name)
WITH relevant_fills AS (
    SELECT * FROM fill_events, aggregator.enumerated_volume_last_indexed_txn WHERE fill_events.txn_version > enumerated_volume_last_indexed_txn.txn_version
),
base_volumes AS (
    SELECT
        size_to_base_indivisible_subunits(markets.market_id, SUM("size")) AS volume_as_base,
        base_account_address AS "address",
        base_module_name AS module,
        base_struct_name AS struct,
        base_name_generic AS generic_asset_name
    FROM relevant_fills AS fill_events, market_registration_events AS markets
    WHERE emit_address = maker_address
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
    FROM relevant_fills AS fill_events, market_registration_events AS markets
    WHERE emit_address = maker_address
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
    COALESCE(a.volume_as_base, 0) + COALESCE(b.volume_as_base,0),
    COALESCE(a.volume_as_quote, 0) + COALESCE(b.volume_as_quote,0),
    COALESCE(a."address", ''), COALESCE(a.module, ''), COALESCE(a.struct, ''),
    COALESCE(a.generic_asset_name, '')
FROM latest a
LEFT JOIN
aggregator.enumerated_volume b
ON (b."address" = a."address"
AND b.module = a.module
AND b.struct = a.struct
AND a.generic_asset_name IS NULL)
OR (a."address" IS NULL
AND a.module IS NULL
AND a.struct IS NULL
AND a.generic_asset_name = b.generic_asset_name)
ON CONFLICT ON CONSTRAINT enumerated_volume_pkey DO
UPDATE SET
    volume_as_base = EXCLUDED.volume_as_base,
    volume_as_quote = EXCLUDED.volume_as_quote;
