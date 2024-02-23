WITH parameters AS (
    SELECT
        $1::timestamptz AS "time"
)
UPDATE aggregator.spreads_last_indexed_timestamp
SET
    "time" = parameters."time"
FROM parameters
