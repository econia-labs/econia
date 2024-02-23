WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS "market_id",
        $2::timestamptz AS "time",
        $3::numeric(20,0) AS min_ask,
        $4::numeric(20,0) AS max_bid
)
INSERT INTO aggregator.spreads
SELECT
    *
FROM
    parameters;
