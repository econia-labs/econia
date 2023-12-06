CREATE VIEW
  api.user_balances AS
SELECT DISTINCT
  ON ("user", market_id, custodian_id) "user",
  market_id,
  custodian_id,
  base_total,
  base_available,
  base_ceiling,
  quote_total,
  quote_available,
  quote_ceiling,
  "time" AS last_update_time,
  "txn_version" AS last_update_txn_version
FROM
  api.balance_updates
ORDER BY
  "user" ASC,
  market_id ASC,
  custodian_id ASC,
  txn_version DESC;


GRANT
SELECT
  ON api.user_balances TO web_anon;