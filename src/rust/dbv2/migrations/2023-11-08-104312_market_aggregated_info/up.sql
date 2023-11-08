-- Your SQL goes here
DROP FUNCTION api.price_info;


CREATE FUNCTION api.market_aggregated_info(market integer, "seconds" integer)
RETURNS TABLE(
    last_price numeric,
    price_change numeric,
    high_price numeric,
    low_price numeric,
    base_volume numeric,
    quote_volume numeric
)
AS $$
WITH fills AS(
    SELECT
        *
    FROM
        fill_events
    WHERE
        market_id = market
        AND "time" >= CURRENT_TIMESTAMP - '1 second'::interval * seconds
        AND emit_address = maker_address
),
last_fill AS(
    SELECT
        *
    FROM
        fills
    ORDER BY
        txn_version DESC,
        event_idx DESC
    LIMIT 1
),
first_fill AS(
    SELECT
        *
    FROM
        fills
    ORDER BY
        txn_version ASC,
        event_idx ASC
    LIMIT 1
)
SELECT
    last_fill.price,
    (last_fill.price - first_fill.price) / first_fill.price * 100,
    MIN(fills.price),
    MAX(fills.price),
    SUM(fills.size),
    SUM(fills.size * fills.price)
FROM
    last_fill,
    first_fill,
    fills
GROUP BY
    last_fill.price,
    first_fill.price
$$
LANGUAGE SQL
IMMUTABLE;
