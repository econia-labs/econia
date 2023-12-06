WITH
  parameters AS (
    SELECT
      $1::TEXT "name",
      $2::TEXT symbol,
      $3::SMALLINT decimals,
      $4::TEXT "address",
      $5::TEXT module,
      $6::TEXT struct
  )
INSERT INTO
  aggregator.coins
SELECT
  *
FROM
  parameters