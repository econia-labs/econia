-- Table generated via diesel migration generate --diff-schema.
-- Views generated manually.
CREATE TABLE "market_account_handles"(
	"user" VARCHAR(70) NOT NULL PRIMARY KEY,
	"handle" VARCHAR(70) NOT NULL
);

CREATE VIEW api.market_account_handles AS SELECT * FROM market_account_handles;
GRANT SELECT ON api.market_account_handles TO web_anon;

-- Missing views that should've been in prior migrations
CREATE VIEW api.change_order_size_events AS SELECT * FROM change_order_size_events;
GRANT SELECT ON api.change_order_size_events TO web_anon;

CREATE VIEW api.place_market_order_events AS SELECT * FROM place_market_order_events;
GRANT SELECT ON api.place_market_order_events TO web_anon;

CREATE VIEW api.place_swap_order_events AS SELECT * FROM place_swap_order_events;
GRANT SELECT ON api.place_swap_order_events TO web_anon;