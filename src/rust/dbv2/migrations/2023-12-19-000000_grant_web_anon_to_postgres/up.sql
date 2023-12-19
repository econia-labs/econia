/*
This allows PostgREST to execute queries as the `web_anon` role when
connecting over a GCP virtual private cloud network via the database URL
for the root user, who is named `postgres` on GCP Cloud SQL.
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
GRANT web_anon TO postgres;
END IF;
END $$;