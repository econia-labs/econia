-- We can assume that everything before this timestamp was indexed, since
-- there's nothing to index.
INSERT INTO aggregator.order_history_last_indexed_timestamp ("time")
SELECT
    DATE_TRUNC('minute', "time")
FROM
    place_limit_order_events
ORDER BY
    "time"
LIMIT 1
