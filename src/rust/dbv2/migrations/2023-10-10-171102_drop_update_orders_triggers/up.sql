DROP TRIGGER updated_order_trigger ON aggregator.user_history;
DROP FUNCTION notify_updated_order;

DROP TRIGGER updated_market_order_trigger ON aggregator.user_history_market;
DROP FUNCTION notify_updated_market_order;
DROP TRIGGER updated_swap_order_trigger ON aggregator.user_history_swap;
DROP FUNCTION notify_updated_swap_order;

CREATE FUNCTION notify_updated_order () RETURNS TRIGGER AS $$
   DECLARE
      x api.limit_orders%ROWTYPE;
BEGIN
   IF NEW.order_type = 'limit' THEN
      SELECT * INTO x FROM api.limit_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
      PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_limit_order', 'payload', x)::text);
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_order_trigger
AFTER UPDATE ON aggregator.user_history FOR EACH ROW
EXECUTE PROCEDURE notify_updated_order ();