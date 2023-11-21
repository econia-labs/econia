-- This file should undo anything in `up.sql`
DROP INDEX fill_events_maker_order_id;


DROP INDEX fill_events_taker_order_id;


DROP FUNCTION api.execution_price;
