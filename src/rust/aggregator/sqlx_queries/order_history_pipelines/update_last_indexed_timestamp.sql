WITH parameters AS (
    SELECT
        $1::timestamptz AS "time"
)
UPDATE aggregator.order_history_last_indexed_timestamp
SET
    "time" = parameters."time"
FROM parameters
