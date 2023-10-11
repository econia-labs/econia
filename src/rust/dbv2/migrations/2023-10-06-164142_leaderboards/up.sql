-- Your SQL goes here
CREATE TABLE competition_metadata (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "start" TIMESTAMPTZ NOT NULL,
    "end" TIMESTAMPTZ NOT NULL,
    "prize" INT NOT NULL,
    "market_id" NUMERIC(20) NOT NULL,
    "integrators_required" TEXT[] NOT NULL
);

CREATE VIEW api.competition_metadata AS SELECT * FROM competition_metadata;

GRANT SELECT ON api.competition_metadata TO web_anon;

CREATE TABLE competition_leaderboard_users (
    "user" TEXT NOT NULL,
    "volume" NUMERIC NOT NULL,
    "integrators_used" TEXT[] NOT NULL,
    "n_trades" INT NOT NULL,
    "points" NUMERIC GENERATED ALWAYS AS
        (volume * array_length(integrators_used, 1)) STORED,
    "competition_id" INT NOT NULL REFERENCES competition_metadata("id"),
    PRIMARY KEY ("user", "competition_id")
);

CREATE VIEW api.competition_leaderboard_users AS SELECT * FROM competition_leaderboard_users;

GRANT SELECT ON api.competition_leaderboard_users TO web_anon;

CREATE TABLE competition_exclusion_list (
    "user" TEXT NOT NULL,
    "reason" TEXT,
    "competition_id" INT NOT NULL REFERENCES competition_metadata("id"),
    PRIMARY KEY ("user", "competition_id"),
    FOREIGN KEY ("user", "competition_id") REFERENCES competition_leaderboard_users("user", "competition_id")
);

CREATE VIEW api.competition_exclusion_list AS SELECT * FROM competition_exclusion_list;

GRANT SELECT ON api.competition_exclusion_list TO web_anon;

CREATE TABLE competition_indexed_events (
    "txn_version" NUMERIC NOT NULL,
    "event_idx" NUMERIC NOT NULL,
    "competition_id" INT NOT NULL REFERENCES competition_metadata("id"),
    PRIMARY KEY ("txn_version", "event_idx", "competition_id")
);

CREATE FUNCTION api.volume(competition_metadata)
RETURNS int AS $$
  SELECT SUM(volume) FROM competition_leaderboard_users WHERE competition_id = $1.id;
$$ LANGUAGE SQL;
