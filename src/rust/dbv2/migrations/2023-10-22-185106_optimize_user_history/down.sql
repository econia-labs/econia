-- This file should undo anything in `up.sql`
DROP TABLE aggregator.user_history_last_indexed_txn;


CREATE TABLE aggregator.aggregated_events (
    txn_version NUMERIC(20) NOT NULL,
    event_idx NUMERIC(20) NOT NULL,
    PRIMARY KEY (txn_version, event_idx)
);
