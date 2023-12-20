-- This file should undo anything in `up.sql`
DROP VIEW aggregator.order_history_latest_event_timestamp;


DROP TABLE aggregator.daily_rolling_volume_history;


DROP TABLE aggregator.order_history;


DROP INDEX place_limit_order_events_time;
DROP INDEX change_order_size_events_time;
DROP INDEX cancel_order_events_time;


DROP INDEX place_limit_order_events_make_time_version;
DROP INDEX change_order_size_events_make_time_version;
DROP INDEX cancel_order_events_make_time_version;
DROP INDEX fill_events_make_time_version;


DROP FUNCTION make_time_version;


DROP TYPE time_version;


DROP TABLE aggregator.order_history_last_indexed_timestamp;


DROP TABLE aggregator.daily_rolling_volume_history_last_indexed_timestamp;


DROP FUNCTION get_quote_volume_divisor_for_market;

