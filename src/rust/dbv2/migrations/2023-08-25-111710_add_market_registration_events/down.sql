-- This file should undo anything in `up.sql`
DROP TRIGGER market_registration_events_trigger ON market_registration_events;


DROP FUNCTION notify_market_registration_event ();


DROP TABLE market_registration_events;


DROP TABLE IF EXISTS processor_status;


DROP TABLE IF EXISTS ledger_infos;


REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE USAGE ON SCHEMA public FROM anon;
DROP ROLE anon;