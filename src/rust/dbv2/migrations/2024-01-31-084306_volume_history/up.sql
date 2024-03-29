-- Your SQL goes here
CREATE VIEW api.daily_rolling_volume_history AS SELECT * FROM aggregator.daily_rolling_volume_history;


GRANT SELECT ON api.daily_rolling_volume_history TO web_anon;


CREATE FUNCTION api.volume_history (market_id numeric(20,0), "time" timestamptz) RETURNS TABLE(daily NUMERIC(20,0), total NUMERIC(20,0)) AS $$
    SELECT
        (SELECT volume_in_quote_subunits FROM api.daily_rolling_volume_history WHERE market_id = $1 AND $2 BETWEEN "time" AND "time" + interval '1 minute' ORDER BY "time" DESC LIMIT 1) AS daily,
        (SELECT SUM(volume) * (SELECT tick_size FROM market_registration_events WHERE market_id = $1) FROM api.candlesticks WHERE market_id = $1 AND resolution = 60 AND start_time < $2);
$$ LANGUAGE SQL;
