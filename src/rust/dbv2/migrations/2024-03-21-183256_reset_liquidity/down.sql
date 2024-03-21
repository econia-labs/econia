-- This file should undo anything in `up.sql`
DELETE FROM aggregator.liquidity;
DELETE FROM aggregator.spreads;
DELETE FROM aggregator.order_history_last_indexed_timestamp;
