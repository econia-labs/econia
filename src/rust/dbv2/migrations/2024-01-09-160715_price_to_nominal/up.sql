-- Your SQL goes here
CREATE FUNCTION get_price_divisor_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT COALESCE ((
        SELECT 1 / ((tick_size / POW(10,quote.decimals)) / (lot_size / POW(10,base.decimals)))
        FROM market_registration_events
        INNER JOIN aggregator.coins base
        ON base_account_address = address AND base_module_name = module AND base_struct_name = struct
        INNER JOIN aggregator.coins quote
        ON quote_account_address = address AND quote_module_name = module AND quote_struct_name = struct
        WHERE market_id = $1
        AND base_name_generic IS NULL
    ),1);
$$ LANGUAGE sql;

