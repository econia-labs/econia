-- This file should undo anything in `up.sql`
DROP VIEW api.market_registration_events;


DROP FUNCTION api.jwt;


DROP SCHEMA api;


DROP ROLE web_anon;


DROP EXTENSION pgjwt;


DROP ROLE IF EXISTS web_anon;