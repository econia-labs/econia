WITH parameters AS (
    SELECT
        $1::numeric AS max_txn_version)
UPDATE
    aggregator.user_history AS user_history
SET
    order_status = 'cancelled',
    last_updated_at = cancel_order_events."time"
FROM
    parameters,
    cancel_order_events
WHERE
    cancel_order_events.txn_version > max_txn_version
    AND user_history.order_id = cancel_order_events.order_id
    AND user_history.market_id = cancel_order_events.market_id;

