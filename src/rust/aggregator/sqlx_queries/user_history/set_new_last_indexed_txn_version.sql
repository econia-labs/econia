WITH parameters AS (
    SELECT
        $1::numeric AS new_max_txn_version)
UPDATE
    aggregator.user_history_last_indexed_txn
SET
    txn_version = new_max_txn_version
FROM
    parameters
