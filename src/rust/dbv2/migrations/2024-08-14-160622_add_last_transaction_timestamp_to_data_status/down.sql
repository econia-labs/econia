-- This file should undo anything in `up.sql`
DROP VIEW api.data_status;

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
