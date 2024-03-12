-- This file should undo anything in `up.sql`
DROP VIEW api.prices;
DROP TABLE aggregator.prices_last_indexed_txn;
DROP TABLE aggregator.prices;
