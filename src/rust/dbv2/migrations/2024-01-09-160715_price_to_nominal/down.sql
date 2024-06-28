-- This file should undo anything in `up.sql`
DROP FUNCTION integer_price_to_quote_indivisible_subunits(numeric, numeric);
DROP FUNCTION quote_indivisible_subunits_to_integer_price(numeric, numeric);
DROP FUNCTION size_to_base_indivisible_subunits(numeric, numeric);
DROP FUNCTION size_and_price_to_quote_indivisible_subunits(numeric, numeric, numeric);
