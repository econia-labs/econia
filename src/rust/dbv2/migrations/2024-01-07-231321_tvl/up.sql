-- Your SQL goes here
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

