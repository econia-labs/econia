-- TODO: need to finish this correctly

DROP TABLE fills;

DROP TRIGGER handle_taker_event_trigger ON taker_events;

DROP FUNCTION handle_taker_event;

DROP TABLE taker_events;

DROP TRIGGER handle_maker_event_trigger ON maker_events;

DROP FUNCTION handle_maker_event;

DROP TABLE maker_events;

DROP TYPE maker_event_type;

DROP TABLE orders;

DROP TYPE order_state;

DROP TYPE side;
