-- Your SQL goes here
CREATE SCHEMA aggregator;

CREATE TABLE aggregator.markets_registered_per_day (
    date date NOT NULL PRIMARY KEY,
    markets bigint NOT NULL
);
