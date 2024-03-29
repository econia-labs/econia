WITH parameters AS (
    SELECT
        $1::numeric last_txn_version)
INSERT INTO
  aggregator.user_balances (
      address,
      custodian_id,
      market_id,
      handle,
      base_total,
      base_available,
      base_ceiling,
      quote_total,
      quote_available,
      quote_ceiling
    )
WITH b AS (
  SELECT DISTINCT
    ON (handle, market_id, custodian_id) handle,
    market_id,
    custodian_id,
    base_total,
    base_available,
    base_ceiling,
    quote_total,
    quote_available,
    quote_ceiling
  FROM
    balance_updates_by_handle,
    parameters
  WHERE txn_version > parameters.last_txn_version
  ORDER BY
    handle ASC,
    market_id ASC,
    custodian_id ASC,
    txn_version DESC
)
SELECT
    m."user",
    b.custodian_id,
    b.market_id,
    m.handle,
    b.base_total,
    b.base_available,
    b.base_ceiling,
    b.quote_total,
    b.quote_available,
    b.quote_ceiling
FROM b NATURAL JOIN market_account_handles AS m
ON CONFLICT ON CONSTRAINT user_balances_pkey DO UPDATE SET
base_total = EXCLUDED.base_total,
base_available = EXCLUDED.base_available,
base_ceiling = EXCLUDED.base_ceiling,
quote_total = EXCLUDED.quote_total,
quote_available = EXCLUDED.quote_available,
quote_ceiling = EXCLUDED.quote_ceiling;
