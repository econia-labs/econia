CREATE TABLE aggregator.candlesticks(
    "market_id" numeric NOT NULL,
    "resolution" int NOT NULL,
    "start_time" timestamptz NOT NULL,
    PRIMARY KEY ("market_id", "start_time", "resolution"),
    "open" numeric,
    "high" numeric,
    "low" numeric,
    "close" numeric,
    "volume" numeric NOT NULL
);

CREATE TABLE aggregator.candlesticks_last_indexed_txn(
    "resolution" int NOT NULL UNIQUE PRIMARY KEY,
    "txn_version" numeric(20) NOT NULL
);

CREATE VIEW api.candlestick_resolutions AS
SELECT DISTINCT
    "resolution"
FROM
    aggregator.candlesticks
ORDER BY "resolution";

CREATE VIEW api.candlesticks AS
SELECT
    *
FROM
    aggregator.candlesticks;

GRANT SELECT ON api.candlestick_resolutions, api.candlesticks TO web_anon;

CREATE OR REPLACE FUNCTION first_agg (anyelement, anyelement)
RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
    SELECT $1;
$$;

CREATE AGGREGATE first (
    sfunc    = first_agg,
    basetype = anyelement,
    stype    = anyelement
);

CREATE OR REPLACE FUNCTION last_agg (anyelement, anyelement)
RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
    SELECT $2;
$$;

CREATE AGGREGATE last (
    sfunc    = last_agg,
    basetype = anyelement,
    stype    = anyelement
);
