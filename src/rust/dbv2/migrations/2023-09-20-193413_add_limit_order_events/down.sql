-- This file should undo anything in `up.sql`
DROP TRIGGER fill_events_trigger ON fill_events;
DROP FUNCTION notify_fill_event ();
DROP VIEW api.fill_events;
DROP TABLE fill_events;

DROP TRIGGER place_limit_order_events_trigger ON place_limit_order_events;
DROP FUNCTION notify_place_limit_order_event ();
DROP VIEW api.place_limit_order_events;
DROP TABLE place_limit_order_events;


DROP TRIGGER cancel_order_events_trigger ON cancel_order_events;
DROP FUNCTION notify_cancel_order_event ();
DROP VIEW api.cancel_order_events;
DROP TABLE cancel_order_events;