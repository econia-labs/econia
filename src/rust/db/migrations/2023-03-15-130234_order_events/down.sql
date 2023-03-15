-- This file should undo anything in `up.sql`
drop table taker_events;

drop trigger place_order_trigger on maker_events;

drop function place_order;

drop table maker_events;

drop type maker_event_type;

drop table orders;

drop type side;
