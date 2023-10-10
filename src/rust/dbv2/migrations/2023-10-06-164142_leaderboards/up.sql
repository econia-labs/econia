-- Your SQL goes here
CREATE TABLE competition_metadata (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "start" TIMESTAMPTZ NOT NULL,
    "end" TIMESTAMPTZ NOT NULL,
    "prize" INT NOT NULL,
    "market_id" NUMERIC NOT NULL,
    "integrators_required" TEXT[] NOT NULL
);

CREATE VIEW api.competition_metadata AS SELECT * FROM competition_metadata;

GRANT SELECT ON api.competition_metadata TO web_anon;

CREATE TABLE competition_exclusion_list (
    "user" TEXT NOT NULL UNIQUE PRIMARY KEY,
    "reason" TEXT,
    "competition_id" INT NOT NULL REFERENCES competition_metadata(id)
);

CREATE VIEW api.competition_exclusion_list AS SELECT * FROM competition_exclusion_list;

GRANT SELECT ON api.competition_exclusion_list TO web_anon;

CREATE TABLE competition_leaderboard_users (
    "user" TEXT NOT NULL UNIQUE PRIMARY KEY,
    "volume" NUMERIC NOT NULL,
    "integrators_used" TEXT[] NOT NULL,
    "n_trades" INT NOT NULL,
    "points" NUMERIC NOT NULL GENERATED ALWAYS AS
        (volume * array_length(integrators_used, 1)) STORED,
    "competition_id" INT NOT NULL REFERENCES competition_metadata(id)
);

CREATE VIEW api.competition_leaderboard_users AS SELECT * FROM competition_leaderboard_users;

GRANT SELECT ON api.competition_leaderboard_users TO web_anon;

CREATE TABLE competition_indexed_events (
    "txn_version" NUMERIC NOT NULL,
    "event_idx" NUMERIC NOT NULL,
    "competition_id" INT NOT NULL REFERENCES competition_metadata(id),
    PRIMARY KEY (txn_version, event_idx, competition_id)
);
