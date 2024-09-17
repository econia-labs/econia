-- This file should undo anything in `up.sql`
ALTER TABLE aggregator.enumerated_volume ADD COLUMN last_indexed_txn NUMERIC(20,0);

UPDATE aggregator.enumerated_volume SET last_indexed_txn = (SELECT txn_version FROM aggregator.enumerated_volume_last_indexed_txn);

DROP TABLE aggregator.enumerated_volume_last_indexed_txn;

ALTER TABLE aggregator.enumerated_volume ALTER COLUMN last_indexed_txn SET NOT NULL;
