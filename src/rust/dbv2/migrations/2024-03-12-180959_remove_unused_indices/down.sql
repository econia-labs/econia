-- This file should undo anything in `up.sql`
CREATE INDEX balance_updates_by_handle_handle_custodian_id_market_id_txn_ver ON balance_updates_by_handle (handle, custodian_id, market_id, txn_version DESC);
CREATE INDEX fill_events_maker_address ON fill_events (maker_address);
CREATE INDEX fill_events_maker_order_id ON fill_events (maker_order_id);
CREATE INDEX fill_events_price ON fill_events (price);
CREATE INDEX fill_events_taker_address ON fill_events (taker_address);
CREATE INDEX user_history_created_at ON aggregator.user_history (created_at);
CREATE INDEX user_history_order_type ON aggregator.user_history (order_type);
CREATE INDEX user_history_user_price ON aggregator.user_history (price);
CREATE INDEX user_history_user_custodian_id_market_id ON aggregator.user_history ("user", custodian_id, market_id);;
CREATE INDEX user_history_user_market_id_direction ON aggregator.user_history (market_id, direction);
