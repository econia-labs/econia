-- This file should undo anything in `up.sql`
REVOKE SELECT ON api.coins FROM grafana;


REVOKE SELECT ON api.coins FROM web_anon;
