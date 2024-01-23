-- Your SQL goes here

-- Replace old utility functions to use api.coins instead of aggregator.coins to allow the functions to be used by web_anon
CREATE VIEW api.coins AS SELECT * FROM aggregator.coins;


CREATE OR REPLACE FUNCTION integer_price_to_quote_indivisible_subunits(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * tick_size * POW(10,COALESCE(base.decimals, 0))) / lot_size
    FROM market_registration_events
    LEFT JOIN api.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN api.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION quote_indivisible_subunits_to_integer_price(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * POW(10,COALESCE(base.decimals, 0)) * lot_size) / tick_size
    FROM market_registration_events
    LEFT JOIN api.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN api.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION size_to_base_indivisible_subunits(market_id numeric, "size" numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * lot_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION size_and_price_to_quote_indivisible_subunits(market_id numeric, "size" numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * $3 * tick_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_quote_volume_divisor_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT tick_size * POW(10::numeric,decimals::numeric)
    FROM market_registration_events AS m
    INNER JOIN api.coins AS c
    ON m.quote_account_address = c."address"
    AND m.quote_module_name = c.module
    AND m.quote_struct_name = c.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


-- Create utility functions used by the views
CREATE FUNCTION integer_price_to_quote_nominal(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT integer_price_to_quote_indivisible_subunits(market_id, price) / get_quote_volume_divisor_for_market(market_id);
$$ LANGUAGE sql;


CREATE FUNCTION api.get_market_last_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT price
    FROM fill_events
    ORDER BY txn_version DESC, event_idx DESC
    LIMIT 1;
$$ LANGUAGE SQL;


CREATE FUNCTION api.get_market_mid_price(market_id numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT
      (MIN(price) FILTER (WHERE direction = 'ask') + MAX(price) FILTER (WHERE direction = 'bid')) / 2 AS mid_price
    FROM api.orders
    WHERE orders.market_id = $1
    AND order_status = 'open'
$$ LANGUAGE sql;


CREATE FUNCTION api.get_market_liquidity (market_id numeric, depth numeric) RETURNS NUMERIC AS $$
    WITH mid_price AS (
        SELECT api.get_market_mid_price($1) AS mid_price
    )
    SELECT SUM(CASE
        WHEN direction = 'bid' THEN size_and_price_to_quote_indivisible_subunits($1,remaining_size,price)
        ELSE size_and_price_to_quote_indivisible_subunits($1,remaining_size,api.get_market_last_price($1))
    END)
    AS liquidity_in_quote
    FROM api.orders, mid_price
    WHERE order_status = 'open'
    AND market_id = $1
    AND price::numeric BETWEEN mid_price::numeric * (1::numeric - $2::numeric/10000::numeric) AND mid_price::numeric * (1::numeric + $2::numeric/10000::numeric);
$$ LANGUAGE SQL;


CREATE FUNCTION api.get_market_24h_low (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MIN(price)
    FROM fill_events
    WHERE "time" > CURRENT_TIMESTAMP - interval '1 day'
    AND fill_events.market_id = $1;
$$ LANGUAGE SQL;


CREATE FUNCTION api.get_market_24h_high (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MAX(price)
    FROM fill_events
    WHERE "time" > CURRENT_TIMESTAMP - interval '1 day'
    AND fill_events.market_id = $1;
$$ LANGUAGE SQL;


CREATE FUNCTION api.get_market_best_ask_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MIN(price)
    FROM api.orders
    WHERE orders.market_id = $1
    AND order_status = 'open'
    AND direction = 'ask';
$$ LANGUAGE SQL;


CREATE FUNCTION api.get_market_best_bid_price (market_id numeric) RETURNS NUMERIC AS $$
    SELECT MAX(price)
    FROM api.orders
    WHERE orders.market_id = $1
    AND order_status = 'open'
    AND direction = 'bid';
$$ LANGUAGE SQL;


-- Create the views
CREATE VIEW api.tickers AS
SELECT
    market_id,
    base_account_address || '::' || base_module_name || '::' || base_struct_name AS base_currency,
    quote_account_address || '::' || quote_module_name || '::' || quote_struct_name AS quote_currency,
    base_volume_24h AS base_volume,
    quote_volume_24h AS quote_volume,
    integer_price_to_quote_nominal(market_id, api.get_market_last_price(market_id)) AS last_price,
    integer_price_to_quote_nominal(market_id, api.get_market_best_ask_price(market_id)) AS ask,
    integer_price_to_quote_nominal(market_id, api.get_market_best_bid_price(market_id)) AS bid,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_high(market_id)) AS high,
    integer_price_to_quote_nominal(market_id, api.get_market_24h_low(market_id)) AS low,
    api.get_market_liquidity(market_id,200) / get_quote_volume_divisor_for_market(market_id) AS liquidity_in_quote
FROM
    api.markets;


CREATE FUNCTION api.orderbook (market_id numeric, depth numeric) RETURNS TABLE(market_id numeric(20,0), txn_version numeric(20,0), bids numeric[], asks numeric[]) AS $$
    WITH mid_price AS (
        SELECT api.get_market_mid_price($1) AS mid_price
    ),
    t AS (
      SELECT
          price,
          SUM(size_to_base_indivisible_subunits($1,remaining_size)) FILTER (WHERE direction = 'bid') as bid,
          SUM(size_to_base_indivisible_subunits($1,remaining_size)) FILTER (WHERE direction = 'ask') as ask,
          direction
      FROM api.orders, mid_price
      WHERE order_status = 'open'
      AND market_id = $1
      AND price::numeric BETWEEN mid_price::numeric * (1::numeric - $2::numeric/10000::numeric) AND mid_price::numeric * (1::numeric + $2::numeric/10000::numeric)
      GROUP BY direction, price
      ORDER BY price
    )
    SELECT
        $1::numeric(20,0) AS market_id,
        (SELECT * FROM api.user_history_last_indexed_txn) AS txn_version,
        array_agg(ARRAY[price,ask]) FILTER (WHERE direction = 'ask') AS asks,
        array_agg(ARRAY[price,bid]) FILTER (WHERE direction = 'bid') AS bids
    FROM t
$$ LANGUAGE SQL;


CREATE VIEW api.historical_trades AS
SELECT
    txn_version,
    event_idx,
    market_id,
    "time",
    integer_price_to_quote_nominal(market_id, price),
    size_to_base_indivisible_subunits(market_id, "size") AS base_volume,
    size_to_base_indivisible_subunits(market_id, "size") * integer_price_to_quote_nominal(market_id, price) AS quote_volume,
    CASE
        WHEN maker_side = true THEN 'buy'
        ELSE 'sell'
    END AS "type"
FROM fill_events
WHERE emit_address = maker_address;


GRANT
SELECT
  ON api.tickers TO web_anon;


GRANT
SELECT
  ON api.historical_trades TO web_anon;
