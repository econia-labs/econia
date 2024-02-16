-- This file should undo anything in `up.sql`
DROP VIEW api.spreads;
DROP TABLE aggregator.spreads;
DROP VIEW aggregator.spreads_latest_event_timestamp;
DROP TABLE aggregator.spreads_last_indexed_timestamp;
