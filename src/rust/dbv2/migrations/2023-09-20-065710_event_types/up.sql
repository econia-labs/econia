-- Your SQL goes here
CREATE TABLE
  change_order_size_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    market_id NUMERIC(20) NOT NULL,
    TIME timestamptz NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    "user" VARCHAR(70) NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    side BOOLEAN NOT NULL,
    new_size NUMERIC(20) NOT NULL
  );


CREATE FUNCTION notify_change_order_size_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('econiaws', json_build_object('channel', 'change_order_size_event', 'payload', NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER change_order_size_events_trigger
AFTER INSERT ON change_order_size_events FOR EACH ROW
EXECUTE PROCEDURE notify_change_order_size_event ();

CREATE VIEW api.change_order_size_events AS SELECT * FROM change_order_size_events;
GRANT SELECT ON api.change_order_size_events TO web_anon;

CREATE TABLE
  place_market_order_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    market_id NUMERIC(20) NOT NULL,
    TIME timestamptz NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    "user" VARCHAR(70) NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    integrator VARCHAR(70) NOT NULL,
    direction BOOLEAN NOT NULL,
    size NUMERIC(20) NOT NULL,
    self_match_behavior SMALLINT NOT NULL
  );


CREATE FUNCTION notify_place_market_order_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('econiaws', json_build_object('channel', 'place_market_order_event', 'payload', NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER place_market_order_events_trigger
AFTER INSERT ON place_market_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_market_order_event ();

CREATE VIEW api.place_market_order_event AS SELECT * FROM place_market_order_event;
GRANT SELECT ON api.place_market_order_event TO web_anon;


CREATE TABLE
  place_swap_order_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    market_id NUMERIC(20) NOT NULL,
    TIME timestamptz NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    signing_account VARCHAR(70) NOT NULL,
    integrator VARCHAR(70) NOT NULL,
    direction BOOLEAN NOT NULL,
    min_base NUMERIC(20) NOT NULL,
    max_base NUMERIC(20) NOT NULL,
    min_quote NUMERIC(20) NOT NULL,
    max_quote NUMERIC(20) NOT NULL,
    limit_price NUMERIC(20) NOT NULL
  );


CREATE FUNCTION notify_place_swap_order_event () RETURNS TRIGGER AS $$
BEGIN
   PERFORM pg_notify('econiaws', json_build_object('channel', 'place_swap_order_event', 'payload', NEW)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER place_swap_order_events_trigger
AFTER INSERT ON place_swap_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_swap_order_event ();

CREATE VIEW api.place_swap_order_event AS SELECT * FROM place_swap_order_event;
GRANT SELECT ON api.place_swap_order_event TO web_anon;