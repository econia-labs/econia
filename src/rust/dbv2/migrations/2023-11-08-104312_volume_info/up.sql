-- Your SQL goes here
CREATE FUNCTION api.volume_info(market integer, "seconds" integer)
RETURNS TABLE(
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
)
SELECT
    SUM(size) AS base_volume,
    SUM(size * price) AS quote_volume
FROM
    fills
$$
LANGUAGE SQL
IMMUTABLE;

