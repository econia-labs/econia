-- Your SQL goes here
CREATE INDEX price_levels ON aggregator.user_history (order_status);


CREATE VIEW api.price_levels AS
    SELECT
        market_id,
        CASE
            WHEN side = true THEN 'ask'
            ELSE 'bid'
        END AS side,
        price,
        SUM(remaining_size) AS total_size,
        (SELECT txn_version FROM aggregator.user_history_last_indexed_txn LIMIT 1) AS version
    FROM
        aggregator.user_history_limit
    NATURAL JOIN
        aggregator.user_history
    WHERE
        order_status = 'open'
    GROUP BY
        market_id,
        side,
        price;


GRANT
SELECT
  ON api.price_levels TO web_anon;
