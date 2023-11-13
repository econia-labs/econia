-- Your SQL goes here
DROP INDEX timeprice;
DROP INDEX txnv_fills;
DROP INDEX txnv_limit;
DROP INDEX txnv_market;
DROP INDEX txnv_swap;
DROP INDEX user_balance;
DROP INDEX fill_events_taker_order_id;
DROP INDEX fill_events_maker_order_id;
DROP INDEX aggregator.price_levels;
DROP INDEX aggregator.ranking_idx;


CREATE TYPE order_direction AS ENUM('sell', 'buy', 'ask', 'bid');

ALTER TABLE aggregator.user_history
ADD COLUMN "user" text;

ALTER TABLE aggregator.user_history
ADD COLUMN direction order_direction;

ALTER TABLE aggregator.user_history
ADD COLUMN price numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN average_execution_price numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN custodian_id numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN self_match_behavior smallint;

ALTER TABLE aggregator.user_history
ADD COLUMN restriction smallint;

ALTER TABLE aggregator.user_history
ADD COLUMN last_increase_stamp numeric(39,0);

ALTER TABLE aggregator.user_history
ADD COLUMN min_base numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN max_base numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN min_quote numeric(20,0);

ALTER TABLE aggregator.user_history
ADD COLUMN max_quote numeric(20,0);

UPDATE aggregator.user_history AS u
SET
    "user" = l."user",
    direction = CASE
        WHEN l.side = true THEN 'ask'::order_direction
        ELSE 'bid'::order_direction
    END,
    price = l.price,
    custodian_id = l.custodian_id,
    self_match_behavior = l.self_matching_behavior,
    restriction = l.restriction,
    min_base = NULL,
    max_base = NULL,
    min_quote = NULL,
    max_quote = NULL
FROM aggregator.user_history_limit AS l
WHERE l.market_id = u.market_id AND l.order_id = u.order_id;

UPDATE aggregator.user_history AS u
SET
    "user" = m."user",
    direction = CASE
        WHEN m.direction = true THEN 'buy'::order_direction
        ELSE 'sell'::order_direction
    END,
    price = NULL,
    custodian_id = m.custodian_id,
    self_match_behavior = m.self_matching_behavior,
    restriction = NULL,
    min_base = NULL,
    max_base = NULL,
    min_quote = NULL,
    max_quote = NULL
FROM aggregator.user_history_market AS m
WHERE m.market_id = u.market_id AND m.order_id = u.order_id;

UPDATE aggregator.user_history AS u
SET
    "user" = s.signing_account,
    direction = CASE
        WHEN s.direction = true THEN 'buy'::order_direction
        ELSE 'sell'::order_direction
    END,
    price = s.limit_price,
    custodian_id = NULL,
    self_match_behavior = NULL,
    restriction = NULL,
    min_base = s.min_base,
    max_base = s.max_base,
    min_quote = s.min_quote,
    max_quote = s.max_quote
FROM aggregator.user_history_swap AS s
WHERE s.market_id = u.market_id AND s.order_id = u.order_id;

WITH deduped_fills AS (
    SELECT
        *
    FROM
        fill_events
    WHERE
        emit_address = maker_address
),
fills AS (
    SELECT
        size,
        price,
        market_id,
        maker_order_id AS order_id
    FROM
        deduped_fills
    UNION ALL
    SELECT
        size,
        price,
        market_id,
        taker_order_id AS order_id
    FROM
        deduped_fills
),
avg_price AS (
    SELECT
        SUM(size * price) / SUM(size) AS avg_price,
        market_id,
        order_id
    FROM
        fills
    GROUP BY
        market_id,
        order_id
)
UPDATE aggregator.user_history AS u
SET
    average_execution_price = avg_price
FROM avg_price AS f
WHERE f.market_id = u.market_id AND f.order_id = u.order_id;

DROP VIEW api.limit_orders;
DROP VIEW api.market_orders;
DROP VIEW api.swap_orders;

DROP VIEW api.price_levels;

DROP FUNCTION api.average_execution_price;

DROP VIEW api.orders;

DROP TABLE aggregator.user_history_limit;
DROP TABLE aggregator.user_history_market;
DROP TABLE aggregator.user_history_swap;


DROP TRIGGER updated_order_trigger ON aggregator.user_history;
DROP FUNCTION notify_updated_order;

CREATE FUNCTION notify_updated_order () RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('econiaws', json_build_object('channel', 'updated_limit_order', 'payload', NEW)::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updated_order_trigger
AFTER UPDATE ON aggregator.user_history FOR EACH ROW
EXECUTE PROCEDURE notify_updated_order ();


CREATE or replace VIEW api.orders AS
    SELECT
        *
    FROM
        aggregator.user_history;


GRANT SELECT ON api.orders TO web_anon;


CREATE INDEX fill_events_time ON fill_events ("time");
CREATE INDEX fill_events_price ON fill_events (price);
CREATE INDEX fill_events_maker_address ON fill_events (maker_address, maker_custodian_id);
CREATE INDEX fill_events_maker_order_id ON fill_events (maker_order_id);
CREATE INDEX fill_events_taker_address ON fill_events (taker_address, taker_custodian_id);
CREATE INDEX fill_events_taker_order_id ON fill_events (taker_order_id);


CREATE INDEX balance_updates_by_handle_handle_custodian_id_market_id_txn_version ON balance_updates_by_handle (handle, custodian_id, market_id, txn_version DESC);
CREATE INDEX balance_updates_by_handle_handle ON balance_updates_by_handle (handle);


CREATE INDEX market_account_handles_handle ON market_account_handles (handle);


CREATE INDEX market_registration_event ON market_registration_events (market_id);
CREATE INDEX market_registration_base ON market_registration_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic
);
CREATE INDEX market_registration_quote ON market_registration_events (
    quote_account_address,
    quote_module_name,
    quote_struct_name
);
CREATE INDEX market_registration_base_quote ON market_registration_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name
);


CREATE INDEX recognized_market_events_all ON recognized_market_events (
    base_account_address,
    base_module_name,
    base_struct_name,
    base_name_generic,
    quote_account_address,
    quote_module_name,
    quote_struct_name,
    txn_version DESC,
    event_idx DESC
);


CREATE INDEX user_history_created_at ON aggregator.user_history (created_at);
CREATE INDEX user_history_order_status ON aggregator.user_history (order_status);
CREATE INDEX user_history_order_type ON aggregator.user_history (order_type);
CREATE INDEX user_history_order_status_order_type ON aggregator.user_history (order_status, order_type);
CREATE INDEX user_history_user_custodian_id_market_id ON aggregator.user_history ("user", custodian_id, market_id);
CREATE INDEX user_history_user_price ON aggregator.user_history (price);
CREATE INDEX user_history_user_market_id_direction ON aggregator.user_history (market_id, direction);


CREATE INDEX competition_leaderboard_users_points_volume_n_trades ON aggregator.competition_leaderboard_users (points DESC, volume DESC, n_trades DESC);
