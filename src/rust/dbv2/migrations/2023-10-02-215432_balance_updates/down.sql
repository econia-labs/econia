-- Table drop generated via diesel migration generate --diff-schema.
-- View drops generated manually.
DROP VIEW api.balance_updates;
DROP VIEW api.market_account_handles;
DROP VIEW api.balance_updates_by_handle;

DROP TABLE IF EXISTS "balance_updates_by_handle";
DROP TABLE IF EXISTS "market_account_handles";

-- Old view drops that should've been in prior migrations.
DROP VIEW api.change_order_size_events;
DROP VIEW api.place_market_order_events;
DROP VIEW api.place_swap_order_events;
