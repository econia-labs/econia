INSERT INTO aggregator.enumerated_volume (volume_as_base, volume_as_quote, "address", module, struct, generic_asset_name, last_indexed_txn)
WITH base_volumes AS (
    SELECT
        size_to_base_indivisible_subunits(markets.market_id, SUM("size")) AS volume_as_base,
        base_account_address AS "address",
        base_module_name AS module,
        base_struct_name AS struct,
        base_name_generic AS generic_asset_name
    FROM fill_events, api.markets
    WHERE emit_address = maker_address
    AND markets.market_id = fill_events.market_id
    AND fill_events.txn_version > COALESCE((
        SELECT last_indexed_txn
        FROM aggregator.enumerated_volume
        WHERE (
            markets.base_account_address = enumerated_volume."address"
            AND markets.base_module_name = enumerated_volume.module
            AND markets.base_struct_name = enumerated_volume.struct
            AND enumerated_volume.generic_asset_name = ''
        )
        OR (
            enumerated_volume."address" = ''
            AND enumerated_volume.module = ''
            AND enumerated_volume.struct = ''
            AND enumerated_volume.generic_asset_name = markets.base_name_generic
        )
    ), 0)
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
    AND fill_events.txn_version > COALESCE((
        SELECT last_indexed_txn
        FROM aggregator.enumerated_volume
        WHERE
            markets.quote_account_address = enumerated_volume."address"
            AND markets.quote_module_name = enumerated_volume.module
            AND markets.quote_struct_name = enumerated_volume.struct
    ), 0)
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
    a.volume_as_base + COALESCE(b.volume_as_base,0),
    a.volume_as_quote + COALESCE(b.volume_as_quote,0),
    COALESCE(a."address", ''), COALESCE(a.module, ''), COALESCE(a.struct, ''),
    COALESCE(a.generic_asset_name, ''),
    (SELECT txn_version FROM fill_events ORDER BY txn_version DESC LIMIT 1)
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
    volume_as_quote = EXCLUDED.volume_as_quote,
    last_indexed_txn = EXCLUDED.last_indexed_txn;
