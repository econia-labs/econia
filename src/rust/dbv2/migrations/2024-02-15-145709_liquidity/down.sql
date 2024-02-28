-- This file should undo anything in `up.sql`
DROP FUNCTION aggregator.add_member_to_liquidity_group;

DROP FUNCTION aggregator.remove_member_from_liquidity_group;

DROP FUNCTION aggregator.create_liquidity_group;

DROP FUNCTION aggregator.remove_liquidity_group;

DROP TABLE aggregator.liquidity_group_members;

DROP TABLE aggregator.liquidity;

DROP TABLE aggregator.liquidity_groups;


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


CREATE TABLE aggregator.order_history (
    market_id numeric(20,0) NOT NULL,
    order_id numeric(39,0) NOT NULL,
    "user" text NOT NULL,
    "size" numeric(20,0) NOT NULL,
    direction order_direction NOT NULL,
    price numeric(20,0) NOT NULL,
    "time" timestamptz NOT NULL,
    PRIMARY KEY ("time", market_id, order_id)
);
