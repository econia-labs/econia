-- Your SQL goes here
CREATE OR REPLACE FUNCTION integer_price_to_quote_nominal(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT integer_price_to_quote_indivisible_subunits($1, $2) / POW(10,decimals)
    FROM market_registration_events AS m
    INNER JOIN api.coins AS c
    ON m.quote_account_address = c."address"
    AND m.quote_module_name = c.module
    AND m.quote_struct_name = c.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;
