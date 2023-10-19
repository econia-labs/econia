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
      CASE volume
        WHEN 0 THEN 0
        ELSE POWER(2,LOG10(volume)) * COALESCE(ARRAY_LENGTH(integrators_used, 1), 0)
      END
    ) STORED, -- Having 10 times the volume gives you 2 times the points
    "competition_id" INT NOT NULL REFERENCES aggregator.competition_metadata ("id"),
    PRIMARY KEY ("user", "competition_id")
  );


CREATE TABLE
  aggregator.competition_exclusion_list (
    "user" TEXT NOT NULL,
    "reason" TEXT,
    "competition_id" INT NOT NULL REFERENCES aggregator.competition_metadata ("id"),
    PRIMARY KEY ("user", "competition_id")
  );


CREATE VIEW
  api.competition_leaderboard_users AS
SELECT
  *,
  RANK() OVER (
    PARTITION BY competition_id
    ORDER BY
      points DESC,
      volume DESC,
      n_trades DESC
  ) AS RANK
FROM
  aggregator.competition_leaderboard_users AS users
WHERE
  NOT EXISTS (
    SELECT
      *
    FROM
      aggregator.competition_exclusion_list AS ex
    WHERE
      users."user" = ex."user"
      AND users.competition_id = ex.competition_id
  )
ORDER BY
  points DESC,
  volume DESC,
  n_trades DESC;


GRANT
SELECT
  ON api.competition_leaderboard_users TO web_anon;


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
CREATE FUNCTION aggregator.fills (INT) RETURNS SETOF fill_events AS $$
DECLARE
    comp aggregator.competition_metadata%ROWTYPE;
BEGIN
    SELECT * INTO comp FROM aggregator.competition_metadata WHERE id = $1;
    RETURN QUERY
      select *
      from fill_events
      where maker_address = emit_address
      and not exists (
        select *
        from aggregator.competition_indexed_events
        where fill_events.txn_version = competition_indexed_events.txn_version
        and fill_events.event_idx = competition_indexed_events.event_idx
        and competition_indexed_events.competition_id = comp.id
      )
      and market_id = comp.market_id
      and time > comp.start
      and time < comp."end";
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION aggregator.places (INT) RETURNS TABLE (
  "user" CHARACTER VARYING(70),
  integrator CHARACTER VARYING(70),
  "time" timestamptz,
  txn_version NUMERIC,
  event_idx NUMERIC
) AS $$
DECLARE
    comp aggregator.competition_metadata%ROWTYPE;
BEGIN
    SELECT * INTO comp FROM aggregator.competition_metadata WHERE id = $1;
    RETURN QUERY
      select ploe."user", ploe."integrator", ploe.time, ploe.txn_version, ploe.event_idx
      from place_limit_order_events as ploe
      where not exists (
        select *
        from aggregator.competition_indexed_events
        where ploe.txn_version = competition_indexed_events.txn_version
        and ploe.event_idx = competition_indexed_events.event_idx
        and competition_indexed_events.competition_id = comp.id
      )
      and ploe.market_id = comp.market_id
      and ploe.time > comp.start
      and ploe.time < comp."end"
      union all
      select pmoe."user", pmoe."integrator", pmoe.time, pmoe.txn_version, pmoe.event_idx
      from place_market_order_events as pmoe
      where not exists (
        select *
        from aggregator.competition_indexed_events
        where pmoe.txn_version = competition_indexed_events.txn_version
        and pmoe.event_idx = competition_indexed_events.event_idx
        and competition_indexed_events.competition_id = comp.id
      )
      and pmoe.market_id = comp.market_id
      and pmoe.time > comp.start
      and pmoe.time < comp."end"
      union all
      select psoe."signing_account", psoe."integrator", psoe.time, psoe.txn_version, psoe.event_idx
      from place_swap_order_events as psoe
      where not exists (
        select *
        from aggregator.competition_indexed_events
        where psoe.txn_version = competition_indexed_events.txn_version
        and psoe.event_idx = competition_indexed_events.event_idx
        and competition_indexed_events.competition_id = comp.id
      )
      and psoe.market_id = comp.market_id
      and psoe.time > comp.start
      and psoe.time < comp."end";
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION aggregator.user_volume (INT) RETURNS TABLE (volume NUMERIC, "user" TEXT) AS $$
BEGIN
    RETURN QUERY
        select
          sum (price*size) as volume,
          competition_leaderboard_users."user"
        from aggregator.competition_leaderboard_users, aggregator.fills($1)
        where (
            fills.taker_address = competition_leaderboard_users."user"
          or
            fills.maker_address = competition_leaderboard_users."user"
        )
        and competition_leaderboard_users.competition_id = $1
        group by competition_leaderboard_users."user";
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION aggregator.user_trades (INT) RETURNS TABLE (trades BIGINT, "user" TEXT) AS $$
BEGIN
    RETURN QUERY
        select
          count(txn_version) as trades,
          competition_leaderboard_users."user"
        from aggregator.competition_leaderboard_users, aggregator.fills($1)
        where (
            fills.taker_address = competition_leaderboard_users."user"
          or
            fills.maker_address = competition_leaderboard_users."user"
        )
        and competition_leaderboard_users.competition_id = $1
        group by competition_leaderboard_users."user";
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION aggregator.user_integrators (INT) RETURNS TABLE (integrators CHARACTER VARYING[], "user" TEXT) AS $$
BEGIN
    RETURN QUERY
        select
          array_agg(distinct integrator) as integrators,
          competition_leaderboard_users."user"
        from aggregator.competition_leaderboard_users, aggregator.places($1)
        where places."user" = competition_leaderboard_users."user"
        group by competition_leaderboard_users."user";
END;
$$ LANGUAGE plpgsql;


-- Create index to speed up user ranking
CREATE INDEX ranking_idx ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_trades DESC);


CREATE INDEX competition_indexed_events_comp_id ON aggregator.competition_indexed_events (competition_id);


CREATE INDEX competition_indexed_events_tx_ev ON aggregator.competition_indexed_events (txn_version, event_idx);


CREATE INDEX fills_market_id ON fill_events (market_id);
