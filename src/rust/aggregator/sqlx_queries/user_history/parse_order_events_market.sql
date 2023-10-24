WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
INSERT INTO aggregator.user_history_market
SELECT
    market_id,
    order_id,
    "user",
    custodian_id,
    direction,
    self_match_behavior
FROM
    parameters,
    place_market_order_events
WHERE
    txn_version > max_txn_version
