-- Your SQL goes here

DROP TABLE aggregator.aggregated_events;


CREATE TABLE aggregator.user_history_last_indexed_txn (
    txn_version NUMERIC(20) NOT NULL PRIMARY KEY
);
