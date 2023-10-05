-- Your SQL goes here
DROP VIEW api.limit_orders;

ALTER TABLE aggregator.user_history_limit ADD COLUMN price NUMERIC(20) NOT NULL;

ALTER TABLE aggregator.user_history_limit ADD COLUMN last_increase_time TIMESTAMPTZ NOT NULL;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

GRANT SELECT ON api.limit_orders TO web_anon;


CREATE FUNCTION notify_new_limit_order () RETURNS TRIGGER AS $$
   DECLARE x api.limit_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.limit_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'new_limit_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER new_limit_order_trigger
AFTER INSERT ON aggregator.user_history_limit FOR EACH ROW
EXECUTE PROCEDURE notify_new_limit_order ();


CREATE FUNCTION notify_new_market_order () RETURNS TRIGGER AS $$
   DECLARE x api.market_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.market_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'new_market_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER new_market_order_trigger
AFTER INSERT ON aggregator.user_history_market FOR EACH ROW
EXECUTE PROCEDURE notify_new_market_order ();


CREATE FUNCTION notify_new_swap_order () RETURNS TRIGGER AS $$
   DECLARE x api.swap_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.swap_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'new_swap_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER new_swap_order_trigger
AFTER INSERT ON aggregator.user_history_swap FOR EACH ROW
EXECUTE PROCEDURE notify_new_swap_order ();


CREATE FUNCTION notify_updated_limit_order () RETURNS TRIGGER AS $$
   DECLARE x api.limit_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.limit_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_limit_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_limit_order_trigger
AFTER UPDATE ON aggregator.user_history_limit FOR EACH ROW
EXECUTE PROCEDURE notify_updated_limit_order ();


CREATE FUNCTION notify_updated_market_order () RETURNS TRIGGER AS $$
   DECLARE x api.market_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.market_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_market_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_market_order_trigger
AFTER UPDATE ON aggregator.user_history_market FOR EACH ROW
EXECUTE PROCEDURE notify_updated_market_order ();


CREATE FUNCTION notify_updated_swap_order () RETURNS TRIGGER AS $$
   DECLARE x api.swap_orders%ROWTYPE;
BEGIN
   SELECT * INTO x FROM api.swap_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
   PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_swap_order', 'payload', x)::text);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_swap_order_trigger
AFTER UPDATE ON aggregator.user_history_swap FOR EACH ROW
EXECUTE PROCEDURE notify_updated_swap_order ();



CREATE FUNCTION notify_updated_order () RETURNS TRIGGER AS $$
   DECLARE
      x api.limit_orders%ROWTYPE;
      y api.market_orders%ROWTYPE;
      z api.swap_orders%ROWTYPE;
BEGIN
   IF NEW.order_type = 'limit' THEN
      SELECT * INTO x FROM api.limit_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
      PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_limit_order', 'payload', x)::text);
   END IF;
   IF NEW.order_type = 'market' THEN
      SELECT * INTO y FROM api.market_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
      PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_market_order', 'payload', y)::text);
   END IF;
   IF NEW.order_type = 'swap' THEN
      SELECT * INTO z FROM api.swap_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
      PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_swap_order', 'payload', z)::text);
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_order_trigger
AFTER UPDATE ON aggregator.user_history FOR EACH ROW
EXECUTE PROCEDURE notify_updated_order ();
