-- Your SQL goes here
CREATE OR REPLACE FUNCTION api.volume_history (market_id numeric(20,0), "time" timestamptz) RETURNS TABLE(daily NUMERIC(20,0), total NUMERIC(20,0)) AS $$
    SELECT
        (SELECT SUM(volume) * (SELECT tick_size FROM market_registration_events WHERE market_id = $1) FROM api.candlesticks WHERE market_id = $1 AND resolution = 60 AND start_time BETWEEN $2 - interval '1 day' AND $2) AS daily,
        (SELECT SUM(volume) * (SELECT tick_size FROM market_registration_events WHERE market_id = $1) FROM api.candlesticks WHERE market_id = $1 AND resolution = 60 AND start_time < $2) AS total;
$$ LANGUAGE SQL;
