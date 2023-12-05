-- Your SQL goes here
CREATE or replace FUNCTION api.healthcheck ()
RETURNS boolean AS $$
    SELECT (
        SELECT COALESCE((
            SELECT SUM(total_filled)
            FROM api.orders
        ) = (
            SELECT SUM(size)
            FROM fill_events
            WHERE txn_version <= (
                SELECT txn_version
                FROM aggregator.user_history_last_indexed_txn
            )
        ), true)
    ) AND COALESCE((
        WITH last_candlesticks AS (
            SELECT DISTINCT ON (market_id, resolution)
                volume,
                start_time,
                resolution,
                market_id
            FROM api.candlesticks
            ORDER BY market_id, resolution, start_time DESC
        )
        SELECT
            SUM(CASE WHEN ok THEN 0 ELSE 1 END) = 0
        FROM (
            SELECT SUM(size*price)/2 = volume AS ok
            FROM fill_events, last_candlesticks
            WHERE txn_version <= (
                SELECT txn_version
                FROM aggregator.candlesticks_last_indexed_txn AS i
                WHERE i.resolution = last_candlesticks.resolution
            )
            AND fill_events.market_id = last_candlesticks.market_id
            AND "time" >= start_time
            AND "time" < start_time + '1 second'::interval * resolution
            GROUP BY volume, last_candlesticks.market_id, resolution
        ) AS lool
    ), true);
$$ LANGUAGE SQL;
