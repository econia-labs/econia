DROP OWNED BY grafana;


DO $$
BEGIN
IF EXISTS (
  SELECT
  FROM
    pg_user
  WHERE
    usename = 'postgres'
) THEN
REVOKE grafana FROM postgres;
END IF;
END $$;


DROP ROLE grafana;