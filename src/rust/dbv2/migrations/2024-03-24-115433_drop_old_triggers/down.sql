-- This file should undo anything in `up.sql`
CREATE TRIGGER fill_events_trigger
AFTER INSERT ON fill_events FOR EACH ROW
EXECUTE PROCEDURE notify_fill_event ();

CREATE TRIGGER place_limit_order_events_trigger
AFTER INSERT ON place_limit_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_limit_order_event ();

CREATE TRIGGER cancel_order_events_trigger
AFTER INSERT ON cancel_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_cancel_order_event ();

CREATE TRIGGER change_order_size_events_trigger
AFTER INSERT ON change_order_size_events FOR EACH ROW
EXECUTE PROCEDURE notify_change_order_size_event ();

CREATE TRIGGER place_market_order_events_trigger
AFTER INSERT ON place_market_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_market_order_event ();

CREATE TRIGGER place_swap_order_events_trigger
AFTER INSERT ON place_swap_order_events FOR EACH ROW
EXECUTE PROCEDURE notify_place_swap_order_event ();

CREATE TRIGGER updated_order_trigger
AFTER UPDATE ON aggregator.user_history FOR EACH ROW
EXECUTE PROCEDURE notify_updated_order ();

CREATE TRIGGER recognized_market_events_trigger
AFTER INSERT ON recognized_market_events FOR EACH ROW
EXECUTE PROCEDURE notify_recognized_market_event ();

CREATE TRIGGER market_registration_events_trigger
AFTER INSERT ON market_registration_events FOR EACH ROW
EXECUTE PROCEDURE notify_market_registration_event ();
