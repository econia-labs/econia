-- Your SQL goes here
CREATE TABLE
  change_order_size_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    market_id NUMERIC(20) NOT NULL,
    TIME timestamptz NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    USER VARCHAR(70) NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    side BOOLEAN NOT NULL,
    new_size NUMERIC(20) NOT NULL
  );


CREATE TABLE
  place_market_order_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    market_id NUMERIC(20) NOT NULL,
    TIME timestamptz NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    USER VARCHAR(70) NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    integrator VARCHAR(70) NOT NULL,
    direction BOOLEAN NOT NULL,
    size NUMERIC(20) NOT NULL,
    self_match_behavior SMALLINT NOT NULL,
  );
