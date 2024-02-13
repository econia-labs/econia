UPDATE aggregator.prices_last_indexed_txn
SET txn_version = (SELECT txn_version FROM fill_events ORDER BY txn_version DESC LIMIT 1);
