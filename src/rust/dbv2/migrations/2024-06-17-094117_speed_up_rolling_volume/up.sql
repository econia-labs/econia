-- Your SQL goes here
CREATE INDEX candlesticks_resolution_60_start_time ON aggregator.candlesticks (start_time) WHERE resolution = 60;
