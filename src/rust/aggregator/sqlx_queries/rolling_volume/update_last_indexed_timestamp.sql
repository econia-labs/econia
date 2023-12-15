INSERT INTO aggregator.daily_rolling_volume_history_last_indexed_timestamp ("time")
SELECT * FROM (SELECT * FROM aggregator.last_time_indexed) a WHERE "time" IS NOT NULL;
