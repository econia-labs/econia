DROP VIEW api.place_market_order_events;
DROP VIEW api.place_swap_order_events;

CREATE VIEW api.place_market_order_events AS SELECT * FROM place_market_order_events;
GRANT SELECT ON api.place_market_order_events TO web_anon;

CREATE VIEW api.place_swap_order_events AS SELECT * FROM place_swap_order_events;
GRANT SELECT ON api.place_swap_order_events TO web_anon;
