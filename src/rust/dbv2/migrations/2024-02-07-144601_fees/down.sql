-- This file should undo anything in `up.sql`
DROP FUNCTION api.get_market_cumulative_fees;

DROP VIEW api.fees;

DROP TABLE aggregator.fees;

DROP TABLE aggregator.fees_last_indexed_txn;
