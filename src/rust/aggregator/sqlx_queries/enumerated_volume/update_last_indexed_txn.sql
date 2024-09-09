UPDATE aggregator.enumerated_volume_last_indexed_txn SET txn_version = COALESCE((SELECT txn_version FROM fill_events ORDER BY txn_version DESC LIMIT 1), 0);
