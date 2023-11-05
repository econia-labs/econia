-- Your SQL goes here
CREATE FUNCTION api.user_handle (user_address TEXT) RETURNS TEXT AS $$
    SELECT handle FROM market_account_handles WHERE "user" = user_address;
$$ LANGUAGE SQL;


CREATE FUNCTION api.user_balance (
  user_address TEXT,
  market NUMERIC,
  custodian NUMERIC
) RETURNS TABLE (
  base_total NUMERIC,
  base_available NUMERIC,
  base_ceiling NUMERIC,
  quote_total NUMERIC,
  quote_available NUMERIC,
  quote_ceiling NUMERIC
) AS $$
DECLARE
    v_handle text := '';
BEGIN
    SELECT api.user_handle(user_address) INTO v_handle;
    RETURN QUERY SELECT
        b."base_total",
        b."base_available",
        b."base_ceiling",
        b."quote_total",
        b."quote_available",
        b."quote_ceiling"
    FROM
        balance_updates_by_handle AS b
    WHERE
        b.custodian_id = custodian
    AND
        b.market_id = market
    AND
        b.handle = v_handle
    ORDER BY
        b."txn_version" DESC
    LIMIT 1;
END;
$$ LANGUAGE PLPGSQL;


CREATE INDEX user_balance ON balance_updates_by_handle (custodian_id, market_id, handle, txn_version DESC);
