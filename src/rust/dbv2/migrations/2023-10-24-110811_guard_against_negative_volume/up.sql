-- Your SQL goes here
ALTER TABLE aggregator.competition_leaderboard_users
DROP COLUMN points CASCADE;


ALTER TABLE aggregator.competition_leaderboard_users
ADD COLUMN "points" NUMERIC GENERATED ALWAYS AS (
  CASE
    WHEN volume <= 0 THEN 0
    ELSE POWER(2, LOG10(volume)) * COALESCE(ARRAY_LENGTH(integrators_used, 1), 0)
  END
) STORED;


CREATE VIEW
  api.competition_leaderboard_users AS
SELECT
  *,
  RANK() OVER (
    PARTITION BY
      competition_id
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
