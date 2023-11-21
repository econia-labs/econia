WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version,
        64::numeric AS SHIFT_TXN_VERSION)
INSERT INTO aggregator.user_history_limit
SELECT
    market_id,
    order_id,
    "user",
    custodian_id,
    side,
    self_match_behavior,
    restriction,
    price,
(txn_version * POWER(2, SHIFT_TXN_VERSION) + event_idx)
FROM
    parameters,
    place_limit_order_events
WHERE
    txn_version > max_txn_version
