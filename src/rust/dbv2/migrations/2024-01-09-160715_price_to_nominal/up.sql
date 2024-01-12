-- Your SQL goes here
CREATE FUNCTION integer_price_to_quote_indivisible_subunits(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * tick_size * POW(10,COALESCE(base.decimals, 0))) / lot_size
    FROM market_registration_events
    LEFT JOIN aggregator.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN aggregator.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;

CREATE FUNCTION quote_indivisible_subunits_to_integer_price(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT ($2 * POW(10,COALESCE(base.decimals, 0)) * lot_size) / tick_size
    FROM market_registration_events
    LEFT JOIN aggregator.coins base
    ON base_account_address = base."address" AND base_module_name = base.module AND base_struct_name = base.struct
    INNER JOIN aggregator.coins quote
    ON quote_account_address = quote."address" AND quote_module_name = quote.module AND quote_struct_name = quote.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE FUNCTION size_to_base_indivisible_subunits(market_id numeric, "size" numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * lot_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;


CREATE FUNCTION size_and_price_to_quote_indivisible_subunits(market_id numeric, size numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $2 * $3 * tick_size
    FROM market_registration_events
    WHERE market_id = $1;
$$ LANGUAGE sql;

