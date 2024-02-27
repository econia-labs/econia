WITH parameters AS (
    SELECT
        $1::NUMERIC(20,0) AS "market_id",
        $2::NUMERIC(20,0) AS "txn_version"
)
SELECT price
FROM fill_events, parameters
WHERE fill_events.market_id = parameters.market_id
AND fill_events.txn_version <= parameters.txn_version
ORDER BY fill_events."time" DESC
LIMIT 1;
