CREATE TYPE side AS enum (
    'bid',
    'ask'
);

CREATE TYPE order_state AS enum (
    'open',
    'filled',
    'cancelled',
    'evicted'
);

CREATE TYPE restriction AS enum (
    'no_restriction',
    'fill_or_abort',
    'immediate_or_cancel',
    'post_or_abort'
);

CREATE TYPE self_match_behavior AS enum (
    'abort',
    'cancel_both',
    'cancel_maker',
    'cancel_taker'
);

CREATE TYPE cancel_reason AS enum (
    'size_change_internal',
    'eviction',
    'immediate_or_cancel',
    'manual_cancel',
    'max_quote_traded',
    'not_enough_liquidity',
    'self_match_maker',
    'self_match_taker'
);

CREATE TABLE orders (
    order_id numeric(39) NOT NULL,
    market_id numeric(20) NOT NULL,
    side side NOT NULL,
    size numeric(20) NOT NULL,
    remaining_size numeric(20) NOT NULL,
    price numeric(20) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    order_state order_state NOT NULL,
    created_at timestamptz NOT NULL,
    PRIMARY KEY (order_id, market_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE TABLE cancel_order_events (
    market_id numeric(20) NOT NULL,
    order_id numeric(39) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    reason cancel_reason NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (order_id, market_id) REFERENCES orders (order_id, market_id)
);

CREATE FUNCTION handle_cancel_order_event ()
    RETURNS TRIGGER
    AS $handle_cancel_order_event$
BEGIN
    UPDATE
        orders
    SET
        order_state = 'cancelled'
    WHERE
        market_id = NEW.market_id
        AND order_id = NEW.order_id;
    RETURN new;
END;
$handle_cancel_order_event$
LANGUAGE plpgsql;

CREATE TRIGGER handle_cancel_order_event_trigger
    BEFORE INSERT ON cancel_order_events
    FOR EACH ROW
    EXECUTE PROCEDURE handle_cancel_order_event ();

CREATE TABLE change_order_size_events (
    market_id numeric(20) NOT NULL,
    order_id numeric(39) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    side side NOT NULL,
    new_size numeric(20) NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (order_id, market_id) REFERENCES orders (order_id, market_id)
);

CREATE FUNCTION handle_change_order_size_event ()
    RETURNS TRIGGER
    AS $handle_change_order_size_event$
BEGIN
    UPDATE
        orders
    SET
        size = NEW.size
    WHERE
        market_id = NEW.market_id
        AND order_id = NEW.order_id;
    RETURN new;
END;
$handle_change_order_size_event$
LANGUAGE plpgsql;

CREATE TRIGGER handle_change_order_size_event_trigger
    BEFORE INSERT ON change_order_size_events
    FOR EACH ROW
    EXECUTE PROCEDURE handle_change_order_size_event ();

CREATE TABLE fill_events (
    market_id numeric(20) NOT NULL,
    size numeric(20) NOT NULL,
    price numeric(20) NOT NULL,
    maker_side side NOT NULL,
    maker varchar(70) NOT NULL,
    maker_custodian_id numeric(20),
    maker_order_id numeric(39) NOT NULL,
    taker varchar(70) NOT NULL,
    taker_custodian_id numeric(20),
    taker_order_id numeric(39) NOT NULL,
    taker_quote_fees_paid numeric(20) NOT NULL,
    sequence_number_for_trade numeric(20) NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, maker_order_id, taker_order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (maker_order_id, market_id) REFERENCES orders (order_id, market_id),
    FOREIGN KEY (taker_order_id, market_id) REFERENCES orders (order_id, market_id)
);

CREATE FUNCTION handle_fill_event ()
    RETURNS TRIGGER
    AS $handle_fill_event$
BEGIN
    UPDATE
        orders
    SET
        remaining_size = remaining_size - NEW.size,
        order_state = (
            CASE WHEN remaining_size <= 0 THEN
                'filled'
            ELSE
                order_state
            END)
    WHERE
        market_id = NEW.market_id
        AND order_id = NEW.order_id;
    RETURN new;
END;
$handle_fill_event$
LANGUAGE plpgsql;

CREATE TRIGGER handle_fill_event_trigger
    BEFORE INSERT ON fill_events
    FOR EACH ROW
    EXECUTE PROCEDURE handle_fill_event ();

CREATE TABLE place_limit_order_events (
    market_id numeric(20) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    integrator varchar(70),
    side side NOT NULL,
    size numeric(20) NOT NULL,
    price numeric(20) NOT NULL,
    restriction restriction NOT NULL,
    self_match_behavior self_match_behavior NOT NULL,
    remaining_size numeric(20) NOT NULL,
    order_id numeric(39) NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (order_id, market_id) REFERENCES orders (order_id, market_id)
);

CREATE FUNCTION handle_place_limit_order_event ()
    RETURNS TRIGGER
    AS $handle_place_limit_order_event$
BEGIN
    INSERT INTO orders
        VALUES (NEW.order_id, NEW.market_id, NEW.side, NEW.size, NEW.remaining_size, NEW.price, NEW.user_address, NEW.custodian_id, 'open', NEW.time);
    RETURN new;
END;
$handle_place_limit_order_event$
LANGUAGE plpgsql;

CREATE TRIGGER handle_place_limit_order_event_trigger
    BEFORE INSERT ON place_limit_order_events
    FOR EACH ROW
    EXECUTE PROCEDURE handle_place_limit_order_event ();

CREATE TABLE place_market_order_events (
    market_id numeric(20) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    integrator varchar(70),
    direction side NOT NULL,
    size numeric(20) NOT NULL,
    self_match_behavior self_match_behavior NOT NULL,
    order_id numeric(39) NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (order_id, market_id) REFERENCES orders (order_id, market_id)
);

CREATE FUNCTION handle_place_market_order_event ()
    RETURNS TRIGGER
    AS $handle_place_market_order_event$
BEGIN
    INSERT INTO orders
        VALUES (NEW.order_id, NEW.market_id, NEW.direction, NEW.size, NEW.size, NEW.remaining_size, NEW.user_address, NEW.custodian_id, 'open', NEW.time);
    RETURN new;
END;
$handle_place_market_order_event$
LANGUAGE plpgsql;

CREATE TRIGGER handle_place_market_order_event_trigger
    BEFORE INSERT ON place_market_order_events
    FOR EACH ROW
    EXECUTE PROCEDURE handle_place_market_order_event ();

CREATE TABLE place_swap_order_events (
    market_id numeric(20) NOT NULL,
    signing_account varchar(70) NOT NULL,
    integrator varchar(70),
    direction side NOT NULL,
    min_base numeric(20) NOT NULL,
    max_base numeric(20) NOT NULL,
    min_quote numeric(20) NOT NULL,
    max_quote numeric(20) NOT NULL,
    limit_price numeric(20) NOT NULL,
    order_id numeric(39) NOT NULL,
    time timestamptz NOT NULL,
    PRIMARY KEY (market_id, order_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id),
    FOREIGN KEY (order_id, market_id) REFERENCES orders (order_id, market_id)
);
