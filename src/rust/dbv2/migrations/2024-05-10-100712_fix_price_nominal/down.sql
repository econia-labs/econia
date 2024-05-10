-- This file should undo anything in `up.sql`
CREATE OR REPLACE FUNCTION integer_price_to_quote_nominal(market_id numeric, price numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT integer_price_to_quote_indivisible_subunits(market_id, price) / get_quote_volume_divisor_for_market(market_id);
$$ LANGUAGE sql;
