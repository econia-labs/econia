-- This file should undo anything in `up.sql`
DROP INDEX fill_events_time ON fill_events ("time");
DROP INDEX fill_events_price ON fill_events (price);
DROP INDEX fill_events_maker_address ON fill_events (maker_address, maker_custodian_id);
DROP INDEX fill_events_maker_order_id ON fill_events (maker_order_id);
DROP INDEX fill_events_taker_address ON fill_events (taker_address, taker_custodian_id);
DROP INDEX fill_events_taker_order_id ON fill_events (taker_order_id);


DROP INDEX balance_updates_by_handle_handle_custodian_id_market_id_txn_version ON balance_updates_by_handle (handle, custodian_id, market_id, txn_version DESC);
DROP INDEX balance_updates_by_handle_handle ON balance_updates_by_handle (handle);


DROP INDEX market_account_handles_handle ON market_account_handles (handle);


DROP INDEX market_registration_event ON market_registration_events (market_id);
DROP INDEX market_registration_base ON market_registration_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic
);
DROP INDEX market_registration_quote ON market_registration_events (
    quote_account_address,
    quote_module_name,
    quote_struct_name
);
DROP INDEX market_registration_base_quote ON market_registration_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name
);


DROP INDEX recognized_market_events_all ON recognized_market_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name,
    txn_version DESC,
    event_idx DESC
);


DROP INDEX user_history_created_at ON aggregator.user_history (created_at);
DROP INDEX user_history_order_status ON aggregator.user_history (order_status);
DROP INDEX user_history_order_type ON aggregator.user_history (order_type);
DROP INDEX user_history_order_status_order_type ON aggregator.user_history (order_status, order_type);

DROP INDEX user_history_limit_user_custodian_id_market_id ON aggregator.user_history_limit ("user", custodian_id, market_id);
DROP INDEX user_history_limit_side ON aggregator.user_history_limit (side);
DROP INDEX user_history_limit_price ON aggregator.user_history_limit (price);


DROP INDEX user_history_market_user_custodian_id_market_id ON aggregator.user_history_market ("user", custodian_id, market_id);
DROP INDEX user_history_market_market_id_direction ON aggregator.user_history_market (market_id, direction);


DROP INDEX user_history_swap_user_market_id ON aggregator.user_history_swap (signing_account, market_id);
DROP INDEX user_history_swap_market_id_direction ON aggregator.user_history_swap (market_id, direction);


DROP INDEX competition_leaderboard_users_points_volume_n_trades ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_trades DESC);


CREATE INDEX timeprice ON fill_events("time", price);
CREATE INDEX fill_events_maker_order_id ON fill_events (maker_order_id);
CREATE INDEX fill_events_taker_order_id ON fill_events (taker_order_id);
CREATE INDEX user_balance ON balance_updates_by_handle (custodian_id, market_id, handle, txn_version DESC);
CREATE INDEX ranking_idx ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_tr DESC);
CREATE INDEX txnv_fills ON fill_events (txn_version);
CREATE INDEX txnv_limit ON place_limit_order_events (txn_version);
CREATE INDEX txnv_market ON place_market_order_events (txn_version);
CREATE INDEX txnv_swap ON place_swap_order_events (txn_version);
CREATE INDEX price_levels ON aggregator.user_history (order_status);
