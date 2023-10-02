-- Table generated via diesel migration generate --diff-schema
-- Views written manually
CREATE TABLE "market_account_handles"(
	"user" VARCHAR(70) NOT NULL PRIMARY KEY,
	"handle" VARCHAR(70) NOT NULL
);

CREATE VIEW api.market_account_handles AS SELECT * FROM market_account_handles;
GRANT SELECT ON api.place_limit_order_events TO web_anon;