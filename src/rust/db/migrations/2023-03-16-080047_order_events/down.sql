drop table place_swap_order_events;

drop trigger handle_place_market_order_event_trigger on place_market_order_events;

drop function handle_place_market_order_event;

drop table place_market_order_events;

drop trigger handle_place_limit_order_event_trigger on place_limit_order_events;

drop function handle_place_limit_order_event;

drop table place_limit_order_events;

drop trigger handle_fill_event_trigger on fill_events;

drop function handle_fill_event;

drop table fill_events;

drop trigger handle_change_order_size_event_trigger on change_order_size_events;

drop function handle_change_order_size_event;

drop table change_order_size_events;

drop trigger handle_cancel_order_event_trigger on cancel_order_events;

drop function handle_cancel_order_event;

drop table cancel_order_events;

drop table orders;

drop type cancel_reason;

drop type self_match_behavior;

drop type restriction;

drop type order_state;

drop type side;
