-- Your SQL goes here
ALTER TABLE aggregator.liquidity RENAME COLUMN amount_ask_lots TO amount_ask_ticks;
ALTER TABLE aggregator.liquidity RENAME COLUMN amount_bid_lots TO amount_bid_ticks;


DELETE FROM aggregator.liquidity;
DELETE FROM aggregator.spreads;
DELETE FROM aggregator.order_history_last_indexed_timestamp;
