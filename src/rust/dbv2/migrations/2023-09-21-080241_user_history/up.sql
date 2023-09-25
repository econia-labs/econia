-- Your SQL goes here
CREATE TYPE order_status AS ENUM ('open', 'closed', 'cancelled');

CREATE TABLE aggregator.aggregated_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx)
);

CREATE TABLE aggregator.user_history (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    created_at TIMESTAMPTZ NOT NULL,
    last_updated_at TIMESTAMPTZ,
    integrator TEXT NOT NULL,
    total_filled NUMERIC(20) NOT NULL,
    remaining_size NUMERIC(20) NOT NULL,
    order_status order_status NOT NULL
);

CREATE TABLE aggregator.user_history_limit (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    "user" TEXT NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    side BOOL NOT NULL,
    self_matching_behavior SMALLINT NOT NULL,
    restriction SMALLINT NOT NULL
);

CREATE TABLE aggregator.user_history_market (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    "user" TEXT NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    direction BOOL NOT NULL,
    self_matching_behavior SMALLINT NOT NULL
);

CREATE TABLE aggregator.user_history_swap (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    direction BOOL NOT NULL,
    limit_price NUMERIC(20) NOT NULL,
    signing_account TEXT NOT NULL,
    min_base NUMERIC(20) NOT NULL,
    max_base NUMERIC(20) NOT NULL,
    min_quote NUMERIC(20) NOT NULL,
    max_quote NUMERIC(20) NOT NULL
);

CREATE VIEW api.orders AS
    SELECT * FROM aggregator.user_history;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

CREATE VIEW api.market_orders AS
    SELECT * FROM aggregator.user_history_market NATURAL JOIN aggregator.user_history;

CREATE VIEW api.swap_orders AS
    SELECT * FROM aggregator.user_history_swap NATURAL JOIN aggregator.user_history;
