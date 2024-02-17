-- Your SQL goes here
CREATE OR REPLACE FUNCTION notify_place_limit_order()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'place_limit_order',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_place_limit_order
  AFTER INSERT ON place_limit_order_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_place_limit_order();


CREATE OR REPLACE FUNCTION notify_place_market_order()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'place_market_order',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_place_market_order
  AFTER INSERT ON place_market_order_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_place_market_order();


CREATE OR REPLACE FUNCTION notify_place_swap_order()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'place_swap_order',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_place_swap_order
  AFTER INSERT ON place_swap_order_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_place_swap_order();


CREATE OR REPLACE FUNCTION notify_change_order_size()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'change_order_size',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_change_order_size
  AFTER INSERT ON change_order_size_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_change_order_size();


CREATE OR REPLACE FUNCTION notify_cancel_order()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'cancel_order',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_cancel_order
  AFTER INSERT ON cancel_order_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_cancel_order();


CREATE OR REPLACE FUNCTION notify_fill()
  RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify(
    'fill',
    row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_fill
  AFTER INSERT ON fill_events
  FOR EACH ROW
  EXECUTE PROCEDURE notify_fill();
