-- Your SQL goes here
CREATE TABLE aggregator.spreads (
    "market_id" NUMERIC(20,0),
    "time" TIMESTAMPTZ,
    "min_ask" NUMERIC(20,0),
    "max_bid" NUMERIC(20,0)
);

CREATE VIEW aggregator.spreads_latest_event_timestamp AS
WITH place_max AS (
    SELECT "time" FROM place_limit_order_events ORDER BY "time" DESC LIMIT 1
), cancel_max AS (
    SELECT "time" FROM cancel_order_events ORDER BY "time" DESC LIMIT 1
),
change_max AS (
    SELECT "time" FROM change_order_size_events ORDER BY "time" DESC LIMIT 1
),
fill_max AS (
    SELECT "time" FROM fill_events ORDER BY "time" DESC LIMIT 1
),
maxes AS (
    SELECT * FROM place_max
    UNION
    SELECT * FROM cancel_max
    UNION
    SELECT * FROM change_max
    UNION
    SELECT * FROM fill_max
)
SELECT MAX("time") AS "time" FROM maxes;

CREATE TABLE aggregator.spreads_last_indexed_timestamp (
    "time" timestamptz PRIMARY KEY
);

CREATE VIEW api.spreads AS
SELECT * FROM aggregator.spreads;

GRANT SELECT ON api.spreads TO web_anon;
GRANT SELECT ON aggregator.spreads TO grafana;
GRANT SELECT ON api.spreads TO grafana;
