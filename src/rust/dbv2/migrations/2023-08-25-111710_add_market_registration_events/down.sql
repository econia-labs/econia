-- This file should undo anything in `up.sql`
DROP TRIGGER market_registration_events_trigger ON market_registration_events;


DROP FUNCTION notify_market_registration_event ();


DROP TABLE market_registration_events;


DROP TRIGGER fill_events_trigger ON fill_events;


DROP FUNCTION notify_fill_event ();


DROP TABLE fill_events;


DROP TRIGGER place_limit_order_events_trigger ON place_limit_order_events;


DROP FUNCTION notify_place_limit_order_event ();


DROP TABLE place_limit_order_events;


DROP TRIGGER cancel_order_events_trigger ON cancel_order_events;


DROP FUNCTION notify_cancel_order_event ();


DROP TABLE cancel_order_events;


DROP TABLE IF EXISTS processor_status;


DROP TABLE IF EXISTS ledger_infos;


REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE USAGE ON SCHEMA public FROM anon;
DROP ROLE anon;