-- Your SQL goes here
CREATE TABLE aggregator.fees (
    "time" TIMESTAMPTZ,
    "market_id" NUMERIC(20,0),
    "amount" NUMERIC(39,0),
    PRIMARY KEY ("market_id", "time")
);

CREATE TABLE aggregator.fees_last_indexed_txn (
    "txn_version" NUMERIC (20,0),
    PRIMARY KEY ("txn_version")
);

CREATE VIEW api.fees AS
SELECT * FROM aggregator.fees;


GRANT SELECT ON api.fees TO web_anon;


CREATE FUNCTION api.get_market_cumulative_fees(market_id numeric(20,0), up_to timestamptz) RETURNS NUMERIC AS $$
    SELECT SUM(amount) AS cumulative_fees FROM api.fees WHERE "time" < $2 AND market_id = $1
$$ LANGUAGE SQL;


GRANT
SELECT
  ON ALL TABLES IN SCHEMA aggregator TO grafana;


GRANT
SELECT
  ON ALL TABLES IN SCHEMA api TO grafana;
