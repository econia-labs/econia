-- This file should undo anything in `up.sql`
DROP TRIGGER recognize_market_events_trigger ON fill_events;
DROP FUNCTION notify_recognize_market_event ();
DROP VIEW api.recognize_market_events;
DROP TABLE recognize_market_events;
