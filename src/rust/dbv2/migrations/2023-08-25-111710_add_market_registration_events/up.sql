-- Your SQL goes here
-- Corresponds to econia::registry::MarketRegistrationEvent

CREATE TABLE ledger_infos (chain_id BIGINT UNIQUE PRIMARY KEY NOT NULL);

CREATE TABLE processor_status (
  processor VARCHAR(50) UNIQUE PRIMARY KEY NOT NULL,
  last_success_version BIGINT NOT NULL,
  last_updated TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE
  market_registration_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
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


CREATE TABLE
  fill_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    emit_address VARCHAR(70) NOT NULL,
    time timestamptz NOT NULL,
    maker_address VARCHAR(70) NOT NULL,
    maker_custodian_id NUMERIC(20) NOT NULL,
    maker_order_id NUMERIC(40) NOT NULL,
    maker_side BOOLEAN NOT NULL,
    market_id NUMERIC(20) NOT NULL,
    price NUMERIC(20) NOT NULL,
    trade_sequence_number NUMERIC(20) NOT NULL,
    size NUMERIC(20) NOT NULL,
    taker_address VARCHAR(70) NOT NULL,
    taker_custodian_id NUMERIC(20) NOT NULL,
    taker_order_id NUMERIC(40) NOT NULL,
    taker_quote_fees_paid NUMERIC(20) NOT NULL
  );

CREATE FUNCTION notify_fill_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('fill_event'::text, row_to_json(NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER fill_events_trigger
AFTER INSERT ON fill_events FOR EACH ROW
EXECUTE PROCEDURE notify_fill_event ();


CREATE TABLE
  place_limit_order_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    time timestamptz NOT NULL,
    market_id NUMERIC(20) NOT NULL,
    maker_address VARCHAR(70) NOT NULL,
    maker_custodian_id NUMERIC(20) NOT NULL,
    maker_order_id NUMERIC(40) NOT NULL,
    maker_side BOOLEAN NOT NULL,
    integrator_address VARCHAR(70) NOT NULL,
    initial_size NUMERIC(20) NOT NULL,
    price NUMERIC(20) NOT NULL,
    restriction NUMERIC(20) NOT NULL,
    self_match_behavior NUMERIC(20) NOT NULL,
    posted_size NUMERIC(20) NOT NULL
  );

CREATE FUNCTION notify_place_limit_order_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('place_limit_order_event'::text, row_to_json(NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER place_limit_order_events_trigger
AFTER INSERT ON place_limit_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_limit_order_event ();

CREATE ROLE anon;
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
