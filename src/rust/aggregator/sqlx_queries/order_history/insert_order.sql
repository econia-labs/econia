WITH parameters AS (
    SELECT
        $1::numeric(20,0) AS market_id,
        $2::numeric(39,0) AS order_id,
        $3::text AS user,
        $4::numeric(20,0) AS "size",
        $5::order_direction AS direction,
        $6::numeric(20,0) AS price,
        $7::timestamptz AS "time"
)
INSERT INTO aggregator.order_history (market_id, order_id, "user", "size", direction, price, "time")
SELECT
    *
FROM
    parameters;
