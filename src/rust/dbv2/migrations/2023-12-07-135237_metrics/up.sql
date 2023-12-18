-- Your SQL goes here
CREATE VIEW aggregator.last_time_indexed AS
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
SELECT MAX("time") AS time FROM maxes;


CREATE TABLE aggregator.daily_rolling_volume_history (
    time timestamptz,
    market_id NUMERIC(20,0),
    volume_in_quote_subunits NUMERIC(20,0)
);


CREATE TABLE aggregator.order_history (
    market_id numeric(20,0) NOT NULL,
    order_id numeric(39,0) NOT NULL,
    "user" text NOT NULL,
    size numeric(20,0) NOT NULL,
    direction order_direction NOT NULL,
    price numeric(20,0) NOT NULL,
    "time" timestamptz NOT NULL,
    PRIMARY KEY ("time", market_id, order_id)
);

CREATE INDEX place_limit_order_events_time ON place_limit_order_events ("time");
CREATE INDEX change_order_size_events_time ON change_order_size_events ("time");
CREATE INDEX cancel_order_events_time ON cancel_order_events ("time");

CREATE TYPE time_version AS (
    "time" timestamptz,
    txn_version numeric(20,0)
);

CREATE FUNCTION make_time_version(t timestamptz, v numeric(20,0)) RETURNS time_version AS
$$
SELECT ROW(t,v);
$$ LANGUAGE sql;

CREATE INDEX place_limit_order_events_make_time_version ON place_limit_order_events (make_time_version("time",txn_version));
CREATE INDEX change_order_size_events_make_time_version ON change_order_size_events (make_time_version("time",txn_version));
CREATE INDEX cancel_order_events_make_time_version ON cancel_order_events (make_time_version("time",txn_version));
CREATE INDEX fill_events_make_time_version ON fill_events (make_time_version("time",txn_version));

CREATE TABLE aggregator.order_history_last_indexed_timestamp (
    "time" timestamptz PRIMARY KEY
);

CREATE TABLE aggregator.daily_rolling_volume_history_last_indexed_timestamp (
    "time" timestamptz PRIMARY KEY
);

CREATE FUNCTION get_denom_for_market(numeric) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT tick_size * POW(10::numeric,decimals::numeric)
    FROM market_registration_events AS m
    INNER JOIN aggregator.coins AS c
    ON m.quote_account_address = c."address"
    AND m.quote_module_name = c.module
    AND m.quote_struct_name = c.struct
    WHERE market_id = $1;
$$ LANGUAGE sql;

CREATE ROLE grafana;
GRANT USAGE ON SCHEMA api TO grafana;
GRANT USAGE ON SCHEMA aggregator TO grafana;
GRANT USAGE ON SCHEMA public TO grafana;
GRANT SELECT ON ALL TABLES IN SCHEMA api TO grafana ;
GRANT SELECT ON ALL TABLES IN SCHEMA aggregator TO grafana ;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana ;
ALTER ROLE grafana SET search_path = public,aggregator,api;

