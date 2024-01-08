-- Your SQL goes here
CREATE MATERIALIZED VIEW aggregator.tvl_per_market AS
SELECT
    SUM(base_total) AS base_value,
    SUM(quote_total) AS quote_value,
    markets.market_id,
    base_account_address ||'::'|| base_module_name ||'::'|| base_struct_name AS base,
    base_name_generic,
    quote_account_address ||'::'|| quote_module_name ||'::'|| quote_struct_name AS quote
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
    SUM(base_total) AS value,
    base_account_address ||'::'|| base_module_name ||'::'|| base_struct_name AS coin
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
    SUM(quote_total) AS value,
    quote_account_address ||'::'|| quote_module_name ||'::'|| quote_struct_name AS coin
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
real_coins AS (
    SELECT SUM(value) AS value, coin
    FROM sums
    GROUP BY coin
),
fake_coins AS (
SELECT
    SUM(base_total) AS value,
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
SELECT value, coin, NULL AS coin_name_generic, NULL AS market_id
FROM real_coins
UNION
SELECT value, NULL AS coin, coin_name_generic, market_id
FROM fake_coins;

CREATE VIEW api.tvl AS
SELECT * FROM aggregator.tvl;

GRANT
SELECT
  ON api.tvl TO web_anon;

