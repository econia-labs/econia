-- Your SQL goes here
CREATE FUNCTION api.fees (market_id numeric(20,0), "time" timestamptz) RETURNS TABLE(daily NUMERIC(20,0), total NUMERIC(20,0)) AS $$
    SELECT
        (SELECT SUM(fees_in_quote_subunits) FROM api.fees WHERE market_id = $1 AND start_time_1hr_period BETWEEN $2 - interval '1 day' AND $2) AS daily,
        (SELECT SUM(fees_in_quote_subunits) FROM api.fees WHERE market_id = $1 AND start_time_1hr_period < $2);
$$ LANGUAGE SQL;
