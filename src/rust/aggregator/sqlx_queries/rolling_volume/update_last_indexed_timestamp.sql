INSERT INTO aggregator.daily_rolling_volume_history_last_indexed_timestamp ("time")
SELECT start_time FROM aggregator.candlesticks WHERE resolution = 60 AND start_time + interval '1 minute' < CURRENT_TIMESTAMP ORDER BY start_time DESC LIMIT 1;
