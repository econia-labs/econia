-- Your SQL goes here
CREATE SCHEMA aggv2;

CREATE TABLE aggv2.order_cache (
    market_id NUMERIC NOT NULL,
    is_ask BOOLEAN NOT NULL,
    order_id NUMERIC NOT NULL,
    last_changed_transaction_version NUMERIC NOT NULL,
    last_changed_event_id NUMERIC NOT NULL,
    "user" TEXT NOT NULL,
    custodian_id NUMERIC NOT NULL,
    integrator TEXT NOT NULL,
    price NUMERIC NOT NULL,
    size NUMERIC NOT NULL,
    PRIMARY KEY (market_id, order_id)
);

CREATE TABLE aggv2.account_cache (
    market_id NUMERIC NOT NULL,
    "user" TEXT NOT NULL,
    base NUMERIC NOT NULL,
    quote NUMERIC NOT NULL,
    PRIMARY KEY (market_id, "user")
);

CREATE TABLE aggv2.market_cache (
    market_id NUMERIC NOT NULL,
    last_price NUMERIC,
    PRIMARY KEY (market_id)
);

CREATE TABLE aggv2.state_cache (
    time TIMESTAMPTZ NOT NULL,
    transaction_version NUMERIC NOT NULL,
    PRIMARY KEY (time, transaction_version)
);

CREATE TABLE aggv2.spread (
    time TIMESTAMPTZ NOT NULL,
    market_id NUMERIC NOT NULL,
    min_ask NUMERIC,
    max_bid NUMERIC,
    PRIMARY KEY (time, market_id)
);

CREATE TABLE aggv2.volume (
    time TIMESTAMPTZ NOT NULL,
    market_id NUMERIC NOT NULL,
    cumulative NUMERIC NOT NULL,
    period NUMERIC NOT NULL,
    PRIMARY KEY (time, market_id)
);

CREATE TABLE aggv2.liquidity (
    time TIMESTAMPTZ NOT NULL,
    market_id NUMERIC NOT NULL,
    base NUMERIC NOT NULL,
    quote NUMERIC NOT NULL,
    bps_times_ten INT NOT NULL,
    PRIMARY KEY (time, market_id, bps_times_ten)
);

CREATE TABLE aggv2.events (
    transaction_verson NUMERIC NOT NULL,
    event_index NUMERIC NOT NULL,
    "time" TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (transaction_verson, event_index)
);

CREATE INDEX events_time ON aggv2.events ("time");
