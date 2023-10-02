-- This file should undo anything in `up.sql`
DROP TRIGGER change_order_size_events_trigger ON change_order_size_events;
DROP FUNCTION notify_change_order_size_event;
DROP TABLE change_order_size_events;
DROP VIEW api.change_order_size_events;


DROP TRIGGER place_market_order_events_trigger ON place_market_order_events;
DROP FUNCTION notify_place_market_order_event;
DROP TABLE place_market_order_events;
DROP VIEW api.place_market_order_events;


DROP TRIGGER place_swap_order_events_trigger ON place_swap_order_events;
DROP FUNCTION notify_place_swap_order_event;
DROP TABLE place_swap_order_events;
DROP VIEW api.place_swap_order_events;