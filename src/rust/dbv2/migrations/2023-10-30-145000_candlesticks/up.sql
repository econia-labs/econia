CREATE TABLE aggregator.candlestick_resolutions(
    "resolution" interval PRIMARY KEY
);

CREATE TABLE aggregator.candlestick_last_indexed_txn_version(
    txn_version numeric PRIMARY KEY
);

CREATE TABLE aggregator.candlestick_start_times(
    "resolution" interval NOT NULL REFERENCES aggregator.candlestick_resolutions("resolution"),
    "start_time" timestamptz NOT NULL,
    PRIMARY KEY ("start_time", "resolution")
);

CREATE TABLE aggregator.candlesticks(
    "market_id" numeric NOT NULL,
    "resolution" interval NOT NULL,
    "start_time" timestamptz NOT NULL,
    PRIMARY KEY ("market_id", "start_time", "resolution"),
    FOREIGN KEY ("resolution", "start_time") REFERENCES aggregator.candlestick_start_times("resolution", "start_time"),
    "open" numeric,
    "high" numeric,
    "low" numeric,
    "close" numeric,
    "volume" numeric
);

-- Most recent candlestick for {market_id, resolution} that was ongoing during last aggregator pass.
CREATE TABLE aggregator.candlesticks_pending(
    "market_id" numeric NOT NULL,
    "resolution" interval NOT NULL,
    PRIMARY KEY ("market_id", "resolution"),
    "start_time" timestamptz NOT NULL,
    FOREIGN KEY ("market_id", "resolution", "start_time") REFERENCES aggregator.candlesticks("market_id", "resolution", "start_time")
);

CREATE VIEW api.candlestick_resolutions AS
SELECT
    *
FROM
    aggregator.candlestick_resolutions;

CREATE VIEW api.candlestick_start_times AS
SELECT
    *
FROM
    aggregator.candlestick_start_times;

CREATE VIEW api.candlesticks AS
SELECT
    *
FROM
    aggregator.candlesticks;

GRANT SELECT ON api.candlestick_resolutions, api.candlestick_start_times, api.candlesticks TO web_anon;

