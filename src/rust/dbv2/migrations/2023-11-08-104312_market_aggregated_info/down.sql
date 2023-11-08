-- This file should undo anything in `up.sql`
DROP FUNCTION api.market_aggregated_info;


CREATE FUNCTION api.price_info(market integer, "seconds" integer)
    RETURNS TABLE(
        last_price numeric,
        price_change numeric,
        high_price numeric,
        low_price numeric
    )
    AS $$
    WITH market_data AS(
        SELECT
            *
        FROM
            market_registration_events
        WHERE
            market_id = market
),
fills AS(
    SELECT
        *
    FROM
        fill_events
    WHERE
        market_id = market
        AND "time" >= CURRENT_TIMESTAMP - '1 second'::interval * seconds
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
    MAX(fills.price)
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

