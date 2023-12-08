-- Your SQL goes here
CREATE VIEW
  api.user_history_last_indexed_txn AS
SELECT
  *
FROM
  aggregator.user_history_last_indexed_txn;


GRANT
SELECT
  ON api.user_history_last_indexed_txn TO web_anon;


CREATE VIEW
  api.candlesticks_last_indexed_txn AS
SELECT
  *
FROM
  aggregator.candlesticks_last_indexed_txn;


GRANT
SELECT
  ON api.candlesticks_last_indexed_txn TO web_anon;


CREATE FUNCTION api.data_is_consistent ()
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
                FROM api.user_history_last_indexed_txn
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
            SELECT SUM(size*price) = volume AS ok
            FROM fill_events, last_candlesticks
            WHERE txn_version <= (
                SELECT txn_version
                FROM api.candlesticks_last_indexed_txn AS i
                WHERE i.resolution = last_candlesticks.resolution
            )
            AND fill_events.market_id = last_candlesticks.market_id
            AND "time" >= start_time
            AND "time" < start_time + '1 second'::interval * resolution
            AND maker_address = emit_address
            GROUP BY volume, last_candlesticks.market_id, resolution
        ) AS lool
    ), true) AS is_data_consistent;
$$ LANGUAGE SQL;


CREATE VIEW api.data_status AS
SELECT
    CURRENT_TIMESTAMP AS current_time,
    processor_status.last_success_version AS processor_last_txn_version_processed,
    user_history_last_indexed_txn.txn_version AS aggregator_user_history_last_txn_version_processed,
    array_agg(ARRAY[resolution, candlesticks_last_indexed_txn.txn_version]) AS aggregator_candlesticks_last_txn_version_processed
FROM
    processor_status,
    aggregator.user_history_last_indexed_txn,
    aggregator.candlesticks_last_indexed_txn
WHERE
    processor_status.processor = 'econia_processor'
GROUP BY
    user_history_last_indexed_txn.txn_version,
    processor_status.last_success_version;


GRANT
SELECT
  ON api.data_status TO web_anon;
