-- Your SQL goes here
-- Corresponds to econia::registry::MarketRegistrationEvent
CREATE TABLE
  market_registration_events (
    id serial NOT NULL PRIMARY KEY,
    market_id NUMERIC(20) NOT NULL,
    time timestamptz NOT NULL,
    base_account_address VARCHAR(70),
    base_module_name TEXT,
    base_struct_name TEXT,
    base_name_generic TEXT,
    quote_account_address VARCHAR(70) NOT NULL,
    quote_module_name TEXT NOT NULL,
    quote_struct_name TEXT NOT NULL,
    lot_size NUMERIC(20) NOT NULL,
    tick_size NUMERIC(20) NOT NULL,
    min_size NUMERIC(20) NOT NULL,
    underwriter_id NUMERIC(20) NOT NULL
  );


CREATE FUNCTION notify_market_registration_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('market_registration_event'::text, row_to_json(NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER market_registration_events_trigger
AFTER INSERT ON market_registration_events FOR EACH ROW
EXECUTE PROCEDURE notify_market_registration_event ();
