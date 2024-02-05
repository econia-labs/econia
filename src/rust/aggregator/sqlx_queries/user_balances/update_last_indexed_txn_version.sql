UPDATE
    aggregator.user_balances_last_indexed_txn
SET
    txn_version = (SELECT txn_version FROM balance_updates_by_handle ORDER BY txn_version DESC LIMIT 1)
