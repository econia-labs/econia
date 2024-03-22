-- This file should undo anything in `up.sql`
ALTER TABLE aggregator.liquidity RENAME COLUMN amount_ask_ticks TO amount_ask_lots;
ALTER TABLE aggregator.liquidity RENAME COLUMN amount_bid_ticks TO amount_bid_lots;

DELETE FROM aggregator.liquidity;
DELETE FROM aggregator.spreads;
DELETE FROM aggregator.order_history_last_indexed_timestamp;
