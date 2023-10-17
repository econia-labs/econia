-- Your SQL goes here
DROP ROLE IF EXISTS web_anon;
CREATE ROLE web_anon nologin;


CREATE SCHEMA api;


CREATE VIEW
  api.market_registration_events AS
SELECT
  *
FROM
  market_registration_events;


GRANT usage ON SCHEMA api TO web_anon;


GRANT
SELECT
  ON api.market_registration_events TO web_anon;
