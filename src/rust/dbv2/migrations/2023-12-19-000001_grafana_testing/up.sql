-- This compromised password is not problematic for a cloud deployment with private IP networking
CREATE ROLE grafana ENCRYPTED PASSWORD 'grafana' LOGIN;


GRANT USAGE ON SCHEMA api TO grafana;


GRANT USAGE ON SCHEMA aggregator TO grafana;


GRANT USAGE ON SCHEMA public TO grafana;


GRANT
SELECT
  ON ALL TABLES IN SCHEMA api TO grafana;


GRANT
SELECT
  ON ALL TABLES IN SCHEMA aggregator TO grafana;


GRANT
SELECT
  ON ALL TABLES IN SCHEMA public TO grafana;


ALTER ROLE grafana
SET
  search_path = public,
  aggregator,
  api;


/*
This is required for the down migration, at least on GCP Cloud SQL, since even
the root user `postgres` cannot drop an object unless it has the `grafana` role
 */
DO $$
BEGIN
IF EXISTS (
  SELECT
  FROM
    pg_user
  WHERE
    usename = 'postgres'
) THEN
GRANT grafana TO postgres;
END IF;
END $$;