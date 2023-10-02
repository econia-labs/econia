-- Table generated via diesel migration generate --diff-schema.
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

CREATE VIEW api.balance_updates_by_handle AS SELECT * FROM balance_updates_by_handle;
GRANT SELECT ON api.balance_updates_by_handle TO web_anon;

CREATE VIEW api.balance_updates AS
    SELECT * FROM api.balance_updates_by_handle NATURAL JOIN api.market_account_handles;
GRANT SELECT ON api.balance_updates TO web_anon;
