-- This file should undo anything in `up.sql`
DROP INDEX fill_events_time;
DROP INDEX fill_events_price;
DROP INDEX fill_events_maker_address;
DROP INDEX fill_events_maker_order_id;
DROP INDEX fill_events_taker_address;
DROP INDEX fill_events_taker_order_id;
DROP INDEX balance_updates_by_handle_handle_custodian_id_market_id_txn_ver;
DROP INDEX balance_updates_by_handle_handle;
DROP INDEX market_account_handles_handle;
DROP INDEX market_registration_event;
DROP INDEX market_registration_base;
DROP INDEX market_registration_quote;
DROP INDEX market_registration_base_quote;
DROP INDEX recognized_market_events_all;
DROP INDEX aggregator.user_history_created_at;
DROP INDEX aggregator.user_history_order_status;
DROP INDEX aggregator.user_history_order_type;
DROP INDEX aggregator.user_history_order_status_order_type;
DROP INDEX aggregator.user_history_user_custodian_id_market_id;
DROP INDEX aggregator.user_history_user_price;
DROP INDEX aggregator.user_history_user_market_id_direction;
DROP INDEX aggregator.competition_leaderboard_users_points_volume_n_trades;


CREATE INDEX timeprice ON fill_events ("time", price);
CREATE INDEX txnv_fills ON fill_events (txn_version);
CREATE INDEX txnv_limit ON place_limit_order_events (txn_version);
CREATE INDEX txnv_market ON place_market_order_events (txn_version);
CREATE INDEX txnv_swap ON place_swap_order_events (txn_version);
CREATE INDEX user_balance ON balance_updates_by_handle (custodian_id, market_id, handle, txn_version DESC);
CREATE INDEX fill_events_taker_order_id ON fill_events (taker_order_id);
CREATE INDEX fill_events_maker_order_id ON fill_events (maker_order_id);
CREATE INDEX price_levels ON aggregator.user_history (order_status);
CREATE INDEX ranking_idx ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_trades DESC);

CREATE TABLE aggregator.user_history_limit (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    "user" TEXT NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    side BOOL NOT NULL,
    self_matching_behavior SMALLINT NOT NULL,
    restriction SMALLINT NOT NULL,
    price NUMERIC(20) NOT NULL
);

CREATE TABLE aggregator.user_history_market (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    "user" TEXT NOT NULL,
    custodian_id NUMERIC(20) NOT NULL,
    direction BOOL NOT NULL,
    self_matching_behavior SMALLINT NOT NULL
);

CREATE TABLE aggregator.user_history_swap (
    market_id NUMERIC(20) NOT NULL,
    order_id NUMERIC(39) NOT NULL,
    PRIMARY KEY (market_id, order_id),
    direction BOOL NOT NULL,
    limit_price NUMERIC(20) NOT NULL,
    signing_account TEXT NOT NULL,
    min_base NUMERIC(20) NOT NULL,
    max_base NUMERIC(20) NOT NULL,
    min_quote NUMERIC(20) NOT NULL,
    max_quote NUMERIC(20) NOT NULL
);

INSERT INTO aggregator.user_history_limit (
    market_id,
    order_id,
    "user",
    custodian_id,
    side,
    self_matching_behavior,
    restriction,
    price
)
SELECT
    market_id,
    order_id,
    "user",
    custodian_id,
    CASE
        WHEN direction = 'ask' THEN true
        ELSE false
    END AS side,
    self_match_behavior,
    restriction,
    price
FROM
    aggregator.user_history
WHERE
    order_type = 'limit';

INSERT INTO aggregator.user_history_market (
    market_id,
    order_id,
    "user",
    custodian_id,
    direction,
    self_matching_behavior
)
SELECT
    market_id,
    order_id,
    "user",
    custodian_id,
    CASE
        WHEN direction = 'buy' THEN true
        ELSE false
    END AS side,
    self_match_behavior
FROM
    aggregator.user_history
WHERE
    order_type = 'market';

INSERT INTO aggregator.user_history_swap (
    market_id,
    order_id,
    direction,
    limit_price,
    signing_account,
    min_base,
    max_base,
    min_quote,
    max_quote
)
SELECT
    market_id,
    order_id,
    CASE
        WHEN direction = 'buy' THEN true
        ELSE false
    END AS side,
    price,
    "user",
    min_base,
    max_base,
    min_quote,
    max_quote

FROM
    aggregator.user_history
WHERE
    order_type = 'swap';

DROP VIEW api.orders;
DROP VIEW api.price_levels;

ALTER TABLE aggregator.user_history
DROP COLUMN "user";

ALTER TABLE aggregator.user_history
DROP COLUMN direction;

ALTER TABLE aggregator.user_history
DROP COLUMN price;

ALTER TABLE aggregator.user_history
DROP COLUMN average_execution_price;

ALTER TABLE aggregator.user_history
DROP COLUMN custodian_id;

ALTER TABLE aggregator.user_history
DROP COLUMN self_match_behavior;

ALTER TABLE aggregator.user_history
DROP COLUMN restriction;

ALTER TABLE aggregator.user_history
DROP COLUMN last_increase_stamp;

ALTER TABLE aggregator.user_history
DROP COLUMN min_base;

ALTER TABLE aggregator.user_history
DROP COLUMN max_base;

ALTER TABLE aggregator.user_history
DROP COLUMN min_quote;

ALTER TABLE aggregator.user_history
DROP COLUMN max_quote;

CREATE VIEW api.limit_orders AS
    SELECT * FROM aggregator.user_history_limit NATURAL JOIN aggregator.user_history;

CREATE VIEW api.market_orders AS
    SELECT * FROM aggregator.user_history_market NATURAL JOIN aggregator.user_history;

CREATE VIEW api.swap_orders AS
    SELECT * FROM aggregator.user_history_swap NATURAL JOIN aggregator.user_history;

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
        price
    ORDER BY
        market_id,
        side,
        price;

GRANT
SELECT
  ON api.price_levels TO web_anon;

CREATE VIEW api.orders AS
    SELECT
        -- Common to all
        u.market_id,
        u.order_id,
        u.created_at,
        u.last_updated_at,
        u.integrator,
        u.total_filled,
        u.remaining_size,
        u.order_status,
        u.order_type,

        -- Common to all but with different names
        CASE
            WHEN u.order_type = 'limit' THEN l."user"
            WHEN u.order_type = 'market' THEN m."user"
            WHEN u.order_type = 'swap' THEN s.signing_account
        END AS "user",
        CASE
            WHEN u.order_type = 'limit' THEN
                CASE
                    WHEN l.side = true THEN 'ask'
                    ELSE 'bid'
                END
            WHEN u.order_type = 'market' THEN
                CASE
                    WHEN m.direction = true THEN 'sell'
                    ELSE 'buy'
                END
            WHEN u.order_type = 'swap' THEN
                CASE
                    WHEN s.direction = true THEN 'sell'
                    ELSE 'buy'
                END
        END AS direction,

        -- Common to some
        CASE
            WHEN u.order_type = 'limit' THEN l.price
            WHEN u.order_type = 'market' THEN NULL
            WHEN u.order_type = 'swap' THEN s.limit_price
        END AS price,
        CASE
            WHEN u.order_type = 'limit' THEN l.custodian_id
            WHEN u.order_type = 'market' THEN m.custodian_id
            WHEN u.order_type = 'swap' THEN NULL
        END AS custodian_id,
        CASE
            WHEN u.order_type = 'limit' THEN l.self_matching_behavior
            WHEN u.order_type = 'market' THEN m.self_matching_behavior
            WHEN u.order_type = 'swap' THEN NULL
        END AS self_matching_behavior,

        -- Particular to limit orders
        l.restriction,

        -- Particular to swap orders
        s.min_base,
        s.max_base,
        s.min_quote,
        s.max_quote
    FROM
        aggregator.user_history AS u
    NATURAL LEFT JOIN
        aggregator.user_history_limit AS l
    NATURAL LEFT JOIN
        aggregator.user_history_market AS m
    NATURAL LEFT JOIN
        aggregator.user_history_swap AS s;


GRANT SELECT ON api.orders TO web_anon;


CREATE FUNCTION api.average_execution_price(api.orders)
RETURNS numeric AS $$
    SELECT
        SUM(size * price) / SUM(size) AS average_execution_price
    FROM
        fill_events
    WHERE
        maker_address = emit_address
    AND
        fill_events.market_id = $1.market_id
    AND (
            fill_events.maker_order_id = $1.order_id
        OR
            fill_events.taker_order_id = $1.order_id
    )
$$ LANGUAGE SQL;


DROP TRIGGER updated_order_trigger ON aggregator.user_history;
DROP FUNCTION notify_updated_order;

CREATE FUNCTION notify_updated_order () RETURNS TRIGGER AS $$
   DECLARE
      x api.limit_orders%ROWTYPE;
BEGIN
   IF NEW.order_type = 'limit' THEN
      SELECT * INTO x FROM api.limit_orders AS lo WHERE lo.market_id = NEW.market_id AND lo.order_id = NEW.order_id;
      PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_limit_order', 'payload', x)::text);
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER updated_order_trigger
AFTER UPDATE ON aggregator.user_history FOR EACH ROW
EXECUTE PROCEDURE notify_updated_order ();


DROP TYPE order_direction;
