DO $$
BEGIN
IF EXISTS (
  SELECT
  FROM
    pg_user
  WHERE
    usename = 'postgres'
) THEN
REVOKE web_anon FROM postgres;
END IF;
END $$;