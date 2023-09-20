-- Your SQL goes here
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

CREATE VIEW api.fill_events AS SELECT * FROM fill_events;


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

CREATE VIEW api.place_limit_order_events AS SELECT * FROM place_limit_order_events;


CREATE TABLE
  cancel_order_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    time timestamptz NOT NULL,
    market_id NUMERIC(20) NOT NULL,
    maker_address VARCHAR(70) NOT NULL,
    maker_custodian_id NUMERIC(20) NOT NULL,
    maker_order_id NUMERIC(40) NOT NULL,
    reason NUMERIC(20) NOT NULL
  );

CREATE FUNCTION notify_cancel_order_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('cancel_order_event'::text, row_to_json(NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cancel_order_events_trigger
AFTER INSERT ON cancel_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_cancel_order_event ();

CREATE VIEW api.cancel_order_events AS SELECT * FROM cancel_order_events;