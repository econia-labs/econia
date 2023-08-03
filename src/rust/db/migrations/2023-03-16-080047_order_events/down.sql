-- TODO: need to finish this correctly
drop table fills;

drop trigger handle_taker_event_trigger on taker_events;

drop function handle_taker_event;

drop table taker_events;

drop trigger handle_maker_event_trigger on maker_events;

drop function handle_maker_event;

drop table maker_events;

drop type maker_event_type;

drop table orders;

drop type order_state;

drop type side;
