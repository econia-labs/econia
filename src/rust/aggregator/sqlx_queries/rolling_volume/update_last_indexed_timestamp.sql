INSERT INTO aggregator.daily_rolling_volume_history_last_indexed_timestamp ("time")
SELECT * FROM (SELECT * FROM aggregator.order_history_latest_event_timestamp) a WHERE "time" IS NOT NULL;
