-- Your SQL goes here
CREATE VIEW api.fees_24h AS
SELECT SUM(fees_in_quote_subunits) AS fees, date_trunc('day', start_time_1hr_period) AS day, market_id FROM api.fees GROUP BY date_trunc('day', start_time_1hr_period), market_id;


GRANT SELECT ON api.fees_24h TO web_anon;


GRANT SELECT ON api.fees_24h TO grafana;
