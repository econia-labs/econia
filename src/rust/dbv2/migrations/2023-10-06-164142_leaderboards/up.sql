-- Your SQL goes here
CREATE TABLE
  aggregator.competition_metadata (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "start" TIMESTAMPTZ NOT NULL,
    "end" TIMESTAMPTZ NOT NULL,
    "prize" INT NOT NULL,
    "market_id" NUMERIC NOT NULL,
    "integrators_required" TEXT[] NOT NULL
  );


CREATE VIEW
  api.competition_metadata AS
SELECT
  *
FROM
  aggregator.competition_metadata;


GRANT
SELECT
  ON api.competition_metadata TO web_anon;


CREATE TABLE
  aggregator.competition_leaderboard_users (
    "user" TEXT NOT NULL,
    "volume" NUMERIC NOT NULL,
    "integrators_used" TEXT[] NOT NULL,
    "n_trades" INT NOT NULL,
    "points" NUMERIC GENERATED ALWAYS AS (
      volume * COALESCE(ARRAY_LENGTH(integrators_used, 1), 0)
    ) STORED,
    "competition_id" INT NOT NULL REFERENCES aggregator.competition_metadata ("id"),
    PRIMARY KEY ("user", "competition_id")
  );


CREATE VIEW
  api.competition_leaderboard_users AS
SELECT
  *,
  rank() OVER (ORDER BY points DESC, volume DESC, n_trades DESC) AS rank
FROM
  aggregator.competition_leaderboard_users
ORDER BY points DESC, volume DESC, n_trades DESC;


GRANT
SELECT
  ON api.competition_leaderboard_users TO web_anon;


CREATE TABLE
  aggregator.competition_exclusion_list (
    "user" TEXT NOT NULL,
    "reason" TEXT,
    "competition_id" INT NOT NULL REFERENCES aggregator.competition_metadata ("id"),
    PRIMARY KEY ("user", "competition_id")
  );


CREATE VIEW
  api.competition_exclusion_list AS
SELECT
  *
FROM
  aggregator.competition_exclusion_list;


GRANT
SELECT
  ON api.competition_exclusion_list TO web_anon;


CREATE TABLE
  aggregator.competition_indexed_events (
    "txn_version" NUMERIC NOT NULL,
    "event_idx" NUMERIC NOT NULL,
    "competition_id" INT NOT NULL REFERENCES aggregator.competition_metadata ("id"),
    PRIMARY KEY ("txn_version", "event_idx", "competition_id")
  );


-- Generated columns. This can be included when querying the tables.
CREATE FUNCTION api.volume (api.competition_metadata) RETURNS NUMERIC AS $$
  SELECT COALESCE(SUM(volume), 0) FROM api.competition_leaderboard_users WHERE competition_id = $1.id AND NOT EXISTS(
    SELECT *
    FROM api.competition_exclusion_list
    WHERE api.competition_exclusion_list.competition_id = api.competition_leaderboard_users.competition_id
    AND api.competition_exclusion_list."user" = api.competition_leaderboard_users."user"
  );
$$ LANGUAGE SQL;


CREATE FUNCTION api.is_eligible (api.competition_leaderboard_users) RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS(
        SELECT *
        FROM api.competition_exclusion_list
        WHERE api.competition_exclusion_list.competition_id = $1.competition_id
        AND api.competition_exclusion_list."user" = $1."user"
    );
END;
$$ LANGUAGE plpgsql;


-- Helper views and functions for the aggregator
CREATE VIEW
  aggregator.homogenous_fills AS
SELECT DISTINCT
  txn_version,
  event_idx,
  taker_address AS "user",
  size,
  price,
  TIME,
  taker_order_id AS "order_id"
FROM
  fill_events
UNION
SELECT DISTINCT
  txn_version,
  event_idx,
  maker_address AS "user",
  size,
  price,
  TIME,
  maker_order_id AS "order_id"
FROM
  fill_events;


CREATE VIEW
  aggregator.homogenous_places AS
SELECT DISTINCT
  txn_version,
  event_idx,
  "user",
  integrator,
  TIME
FROM
  place_limit_order_events
UNION
SELECT DISTINCT
  txn_version,
  event_idx,
  "user",
  integrator,
  TIME
FROM
  place_market_order_events
UNION
SELECT DISTINCT
  txn_version,
  event_idx,
  signing_account AS "user",
  integrator,
  TIME
FROM
  place_swap_order_events;


CREATE FUNCTION aggregator.current_fills (INT, timestamptz, timestamptz) RETURNS TABLE (
  txn_version NUMERIC,
  event_idx NUMERIC,
  "user" VARCHAR(70),
  size NUMERIC,
  price NUMERIC,
  "time" timestamptz,
  order_id NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM aggregator.homogenous_fills
    WHERE NOT EXISTS(
        SELECT * FROM aggregator.competition_indexed_events
        WHERE homogenous_fills.txn_version = competition_indexed_events.txn_version
        AND homogenous_fills.event_idx = competition_indexed_events.event_idx
        AND competition_indexed_events.competition_id = $1
    )
    AND homogenous_fills.time > $2 AND homogenous_fills.time < $3;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION aggregator.current_places (INT, timestamptz, timestamptz) RETURNS TABLE (
  txn_version NUMERIC,
  event_idx NUMERIC,
  "user" VARCHAR(70),
  integrator VARCHAR(70),
  "time" timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM aggregator.homogenous_places
    WHERE NOT EXISTS(
        SELECT * FROM aggregator.competition_indexed_events
        WHERE homogenous_places.txn_version = competition_indexed_events.txn_version
        AND homogenous_places.event_idx = competition_indexed_events.event_idx
        AND competition_indexed_events.competition_id = $1
    )
    AND homogenous_places.time > $2 AND homogenous_places.time < $3;
END;
$$ LANGUAGE plpgsql;


-- Create index to speed up user ranking
CREATE INDEX idx_ranking ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_trades DESC);
