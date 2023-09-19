-- Your SQL goes here

CREATE TABLE
  fill_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx),
    emit_address VARCHAR(70) NOT NULL,
    time timestamptz NOT NULL,
    maker_address VARCHAR(70) NOT NULL,
    maker_custodian_id NUMERIC(20) NOT NULL,
    maker_order_id NUMERIC(20) NOT NULL,
    maker_side BOOLEAN NOT NULL,
    market_id NUMERIC(20) NOT NULL,
    price NUMERIC(20) NOT NULL,
    trade_sequence_number NUMERIC(20) NOT NULL,
    size NUMERIC(20) NOT NULL,
    taker_address VARCHAR(70) NOT NULL,
    taker_custodian_id NUMERIC(20) NOT NULL,
    taker_order_id NUMERIC(20) NOT NULL,
    taker_quote_fees_paid NUMERIC(20) NOT NULL,
  );