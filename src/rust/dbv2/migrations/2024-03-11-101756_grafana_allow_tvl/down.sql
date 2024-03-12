-- This file should undo anything in `up.sql`
REVOKE SELECT ON api.tvl_per_market FROM grafana;
REVOKE SELECT ON api.tvl_per_asset FROM grafana;
