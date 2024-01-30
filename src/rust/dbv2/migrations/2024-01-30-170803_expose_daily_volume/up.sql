-- Your SQL goes here
CREATE VIEW api.daily_rolling_volume_history AS
SELECT * FROM aggregator.daily_rolling_volume_history;

GRANT SELECT ON api.daily_rolling_volume_history TO web_anon;
