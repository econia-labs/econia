-- This file should undo anything in `up.sql`
DROP TABLE aggv2.order_cache;
DROP TABLE aggv2.account_cache;
DROP TABLE aggv2.market_cache;
DROP TABLE aggv2.state_cache;
DROP TABLE aggv2.spread;
DROP TABLE aggv2.volume;
DROP TABLE aggv2.liquidity;
DROP TABLE aggv2.events;

DROP SCHEMA aggv2;
