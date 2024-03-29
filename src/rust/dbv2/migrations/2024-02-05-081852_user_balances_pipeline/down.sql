-- This file should undo anything in `up.sql`
DROP TABLE aggregator.user_balances CASCADE;


DROP TABLE aggregator.user_balances_last_indexed_txn;


CREATE MATERIALIZED VIEW
  api.user_balances AS
WITH b AS (
  SELECT DISTINCT
    ON (handle, market_id, custodian_id) handle,
    market_id,
    custodian_id,
    base_total,
    base_available,
    base_ceiling,
    quote_total,
    quote_available,
    quote_ceiling,
    "time" AS last_update_time,
    "txn_version" AS last_update_txn_version
  FROM
    balance_updates_by_handle
  ORDER BY
    handle ASC,
    market_id ASC,
    custodian_id ASC,
    txn_version DESC
)
SELECT
    m."user",
    b.market_id,
    b.custodian_id,
    b.base_total,
    b.base_available,
    b.base_ceiling,
    b.quote_total,
    b.quote_available,
    b.quote_ceiling,
    b.last_update_time,
    b.last_update_txn_version
FROM b NATURAL JOIN market_account_handles AS m;


GRANT SELECT ON api.user_balances TO web_anon;


-- Recreate objects that depended on api.user_balances
CREATE MATERIALIZED VIEW aggregator.tvl_per_market AS
SELECT
    SUM(base_total) AS base_value,
    SUM(quote_total) AS quote_value,
    markets.market_id,
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name
FROM
    api.user_balances,
    api.markets
WHERE
    user_balances.market_id = markets.market_id
GROUP BY
    markets.market_id,
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name;


CREATE MATERIALIZED VIEW aggregator.tvl_per_asset AS
WITH sums AS (
SELECT
    SUM(base_total) AS "value",
    base_account_address AS "address",
    base_module_name AS module,
    base_struct_name AS struct
FROM
    api.user_balances,
    api.markets
WHERE
    user_balances.market_id = markets.market_id
AND
    base_name_generic IS NULL
GROUP BY
    markets.market_id,
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic
UNION
SELECT
    SUM(quote_total) AS "value",
    quote_account_address AS "address",
    quote_module_name AS module,
    quote_struct_name AS struct
FROM
    api.user_balances,
    api.markets
WHERE
    user_balances.market_id = markets.market_id
GROUP BY
    quote_account_address,
    quote_module_name,
    quote_struct_name,
    markets.market_id
),
coin_assets AS (
    SELECT SUM("value") AS "value", "address", module, struct
    FROM sums
    GROUP BY "address", module, struct
),
generic_assets AS (
SELECT
    SUM(base_total) AS "value",
    base_name_generic AS coin_name_generic,
    markets.market_id
FROM
    api.user_balances,
    api.markets
WHERE
    user_balances.market_id = markets.market_id
AND
    base_name_generic IS NOT NULL
GROUP BY
    base_name_generic,
    markets.market_id
)
SELECT
    "value",
    "address",
    module,
    struct,
    NULL AS coin_name_generic,
    NULL AS market_id
FROM coin_assets
UNION
SELECT
    "value",
    NULL AS "address",
    NULL AS module,
    NULL AS struct,
    coin_name_generic,
    market_id
FROM generic_assets;

CREATE VIEW api.tvl_per_market AS
SELECT
    tvl.*,
    base.name AS base_name,
    base.symbol AS base_symbol,
    base.decimals AS base_decimals,
    quote.name AS quote_name,
    quote.symbol AS quote_symbol,
    quote.decimals AS quote_decimals
FROM aggregator.tvl_per_market tvl
LEFT JOIN aggregator.coins base
ON base_account_address = base.address
AND base_module_name = base.module
AND base_struct_name = base.struct
INNER JOIN aggregator.coins quote
ON quote_account_address = quote.address
AND quote_module_name = quote.module
AND quote_struct_name = quote.struct;

GRANT
SELECT
  ON api.tvl_per_market TO web_anon;

CREATE VIEW api.tvl_per_asset AS
SELECT * FROM aggregator.tvl_per_asset
NATURAL LEFT JOIN aggregator.coins;

GRANT
SELECT
  ON api.tvl_per_asset TO web_anon;


CREATE FUNCTION api.markets(api.user_balances) RETURNS SETOF api.markets ROWS 1 AS $$
  SELECT * FROM api.markets WHERE markets.market_id = $1.market_id
$$ STABLE LANGUAGE SQL;
