WITH parameters AS (
    SELECT
        $1::numeric AS new_max_txn_version)
INSERT INTO aggregator.user_history_last_indexed_txn(txn_version)
SELECT
    new_max_txn_version
FROM
    parameters
