-- This file should undo anything in `up.sql`
DROP FUNCTION api.average_execution_price(api.limit_orders);


DROP FUNCTION api.average_execution_price(api.market_orders);


DROP FUNCTION api.average_execution_price(api.swap_orders);
