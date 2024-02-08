INSERT INTO aggregator.fees_last_indexed_txn
SELECT txn_version FROM fill_events ORDER BY txn_version DESC LIMIT 1
ON CONFLICT ON CONSTRAINT fees_last_indexed_txn_pkey DO NOTHING;
