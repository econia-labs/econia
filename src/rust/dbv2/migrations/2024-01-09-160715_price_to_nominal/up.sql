-- Your SQL goes here
CREATE FUNCTION get_price_divisor_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT COALESCE ((
        SELECT POW(10,decimals) / lot_size
        FROM market_registration_events
        INNER JOIN aggregator.coins
        ON base_account_address = address AND base_module_name = module AND base_struct_name = struct
        WHERE market_id = $1
        AND base_name_generic IS NULL
    ),1);
$$ LANGUAGE sql;

