-- Your SQL goes here
CREATE FUNCTION api.markets(api.user_balances) RETURNS SETOF api.markets ROWS 1 AS $$
  SELECT * FROM api.markets WHERE markets.market_id = $1.market_id
$$ STABLE LANGUAGE SQL;
