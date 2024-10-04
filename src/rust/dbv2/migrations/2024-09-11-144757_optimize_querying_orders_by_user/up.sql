-- Your SQL goes here
CREATE INDEX user_history_user_market_id ON aggregator.user_history ("user", market_id);
