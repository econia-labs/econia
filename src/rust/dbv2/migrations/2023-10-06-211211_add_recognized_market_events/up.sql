-- Your SQL goes here
CREATE TABLE
  recognized_market_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    time timestamptz NOT NULL,
    base_account_address VARCHAR(70),
    base_module_name TEXT,
    base_struct_name TEXT,
    base_name_generic TEXT,
    quote_account_address VARCHAR(70) NOT NULL,
    quote_module_name TEXT NOT NULL,
    quote_struct_name TEXT NOT NULL,
    market_id NUMERIC(20),
    lot_size NUMERIC(20),
    tick_size NUMERIC(20),
    min_size NUMERIC(20),
    underwriter_id NUMERIC(20)
  );

CREATE FUNCTION notify_recognized_market_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('econiaws', json_build_object('channel', 'recognized_market_event', 'payload', NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recognized_market_events_trigger
AFTER INSERT ON recognized_market_events FOR EACH ROW
EXECUTE PROCEDURE notify_recognized_market_event ();

CREATE VIEW api.recognized_market_events AS SELECT * FROM recognized_market_events;

GRANT SELECT ON api.recognized_market_events TO web_anon;