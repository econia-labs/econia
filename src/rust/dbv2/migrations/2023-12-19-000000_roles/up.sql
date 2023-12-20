-- Compromised password is fine for cloud setup with private IP networking.
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
This is required for the down migration, at least on GCP Cloud SQL, since
even the root user `postgres` cannot drop an object owned by a role unless
it has the role's privileges.

This also allows PostgREST to execute queries as the `web_anon` role when
connecting over a GCP virtual private cloud network via the connection URL
for the root user.
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
GRANT web_anon TO postgres;
END IF;
END $$;