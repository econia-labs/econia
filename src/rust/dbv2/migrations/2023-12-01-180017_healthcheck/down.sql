-- This file should undo anything in `up.sql`
DROP FUNCTION api.data_is_consistent;


DROP VIEW
  api.user_history_last_indexed_txn;


DROP VIEW
  api.candlesticks_last_indexed_txn;


DROP VIEW
  api.data_status;
