-- Tables generated via diesel migration generate --diff-schema.
-- Views generated manually.
CREATE TABLE "balance_updates_by_handle"(
	"txn_version" NUMERIC NOT NULL,
	"handle" VARCHAR(70) NOT NULL,
	"market_id" NUMERIC NOT NULL,
	"custodian_id" NUMERIC NOT NULL,
	"time" TIMESTAMPTZ NOT NULL,
	"base_total" NUMERIC NOT NULL,
	"base_available" NUMERIC NOT NULL,
	"base_ceiling" NUMERIC NOT NULL,
	"quote_total" NUMERIC NOT NULL,
	"quote_available" NUMERIC NOT NULL,
	"quote_ceiling" NUMERIC NOT NULL,
	PRIMARY KEY("txn_version", "handle", "market_id", "custodian_id")
);

CREATE TABLE "market_account_handles"(
	"user" VARCHAR(70) NOT NULL PRIMARY KEY,
	"handle" VARCHAR(70) NOT NULL,
	"creation_time" TIMESTAMPTZ NOT NULL
);

CREATE VIEW api.market_account_handles AS SELECT * FROM market_account_handles;
GRANT SELECT ON api.market_account_handles TO web_anon;

CREATE VIEW api.balance_updates_by_handle AS SELECT * FROM balance_updates_by_handle;
GRANT SELECT ON api.balance_updates_by_handle TO web_anon;

CREATE VIEW api.balance_updates AS SELECT
    "time",
    "txn_version",
    "user",
    "market_id",
    "custodian_id",
    "base_total",
    "base_available",
    "base_ceiling",
    "quote_total",
    "quote_available",
    "quote_ceiling"
FROM api.balance_updates_by_handle NATURAL JOIN api.market_account_handles;
GRANT SELECT ON api.balance_updates TO web_anon;

-- Missing views that should've been in prior migrations.
CREATE VIEW api.change_order_size_events AS SELECT * FROM change_order_size_events;
GRANT SELECT ON api.change_order_size_events TO web_anon;

CREATE VIEW api.place_market_order_events AS SELECT * FROM place_market_order_events;
GRANT SELECT ON api.place_market_order_events TO web_anon;

CREATE VIEW api.place_swap_order_events AS SELECT * FROM place_swap_order_events;
GRANT SELECT ON api.place_swap_order_events TO web_anon;
