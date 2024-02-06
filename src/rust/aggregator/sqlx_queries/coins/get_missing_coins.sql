WITH
  market_coins AS (
    SELECT DISTINCT
      base_account_address AS "address",
      base_module_name AS module,
      base_struct_name AS struct
    FROM
      market_registration_events
    WHERE
      base_account_address IS NOT NULL
      AND base_module_name IS NOT NULL
      AND base_struct_name IS NOT NULL
    UNION
    SELECT DISTINCT
      quote_account_address AS "address",
      quote_module_name AS module,
      quote_struct_name AS struct
    FROM
      market_registration_events
  )
SELECT
  *
FROM
  market_coins AS m
WHERE
  NOT EXISTS (
    SELECT
      *
    FROM
      aggregator.coins AS c
    WHERE
      c."address" = m."address"
      AND c.module = m.module
      AND c.struct = m.struct
  )
