-- Your SQL goes here

CREATE INDEX timeprice ON fill_events (time, price);

CREATE FUNCTION api.price_info(market integer, seconds integer)
RETURNS TABLE(last_price numeric, price_change numeric, high_price numeric, low_price numeric) AS $$
    WITH market_data AS (
        SELECT *
        FROM market_registration_events
        WHERE market_id = market
    ),
    fills AS (
        SELECT *
        FROM fill_events
        WHERE market_id = market
        AND time >= CURRENT_TIMESTAMP - '1 second'::interval * seconds
        ORDER BY txn_version DESC, event_idx DESC
    ),
    last_fill AS (
        SELECT *
        FROM fills
        LIMIT 1
    ),
    first_fill AS (
        SELECT *
        FROM fills
        LIMIT 1
    )
    SELECT
        last_fill.price * market_data.lot_size,
        100::numeric - first_fill.price / last_fill.price * 100,
        MIN(fills.price) * market_data.lot_size,
        MAX(fills.price) * market_data.lot_size
    FROM
        last_fill,
        first_fill,
        market_data,
        fills
    GROUP BY last_fill.price, first_fill.price, market_data.lot_size
$$ LANGUAGE SQL IMMUTABLE;
