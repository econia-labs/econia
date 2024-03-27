-- This file should undo anything in `up.sql`
DROP TRIGGER notify_place_limit_order ON place_limit_order_events;

DROP FUNCTION notify_place_limit_order;


DROP TRIGGER notify_place_market_order ON place_market_order_events;

DROP FUNCTION notify_place_market_order;


DROP TRIGGER notify_place_swap_order ON place_swap_order_events;

DROP FUNCTION notify_place_swap_order;


DROP TRIGGER notify_change_order_size ON change_order_size_events;

DROP FUNCTION notify_change_order_size;


DROP TRIGGER notify_cancel_order ON cancel_order_events;

DROP FUNCTION notify_cancel_order;


DROP TRIGGER notify_fill ON fill_events;

DROP FUNCTION notify_fill;
