-- This file should undo anything in `up.sql`
ALTER TABLE processor_status DROP COLUMN last_transaction_timestamp;
