BEGIN;
CREATE TEMP TABLE tmp_table
ON COMMIT DROP
AS
SELECT *
FROM grafana_annotations
WITH NO DATA;

\COPY tmp_table FROM 'annotations.csv' WITH DELIMITER ',' NULL 'null';

INSERT INTO grafana_annotations
SELECT * FROM tmp_table
ON CONFLICT DO NOTHING;
COMMIT;
