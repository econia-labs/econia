-- Generated via diesel migration generate --diff-schema
CREATE TABLE "market_account_handles"(
	"user" VARCHAR(70) NOT NULL PRIMARY KEY,
	"handle" VARCHAR(70) NOT NULL
);