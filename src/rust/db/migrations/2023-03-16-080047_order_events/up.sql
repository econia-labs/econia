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

CREATE TABLE orders (
    order_id numeric(39) NOT NULL,
    market_id numeric(20) NOT NULL,
    side side NOT NULL,
    size numeric(20) NOT NULL,
    price numeric(20) NOT NULL,
    user_address varchar(70) NOT NULL,
    custodian_id numeric(20),
    order_state order_state NOT NULL,
    created_at timestamptz NOT NULL,
    PRIMARY KEY (order_id, market_id),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
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

CREATE TABLE cancel_order_events (
    market_id numeric(20) NOT NULL,
    order_id numeric(39) NOT NULL,
    user varchar(70) NOT NULL,
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
    user varchar(70) NOT NULL,
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

CREATE TYPE restriction AS enum (
    'no_restriction',
    'fill_or_abort',
    'immediate_or_cancel',
    'post_or_abort',
);

CREATE TYPE self_match_behavior AS enum (
    'abort',
    'cancel_both',
    'cancel_maker',
    'cancel_taker'
);

CREATE TABLE place_limit_order_events (
    market_id numeric(20) NOT NULL,
    user varchar(70) NOT NULL,
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

CREATE TABLE place_market_order_events (
    market_id numeric(20) NOT NULL,
    user varchar(70) NOT NULL,
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

-- create type maker_event_type as enum ('cancel', 'change', 'evict', 'place');
--
-- create table maker_events (
--     market_id numeric (20) not null,
--     side side not null,
--     market_order_id numeric (39) not null,
--     user_address varchar (70) not null,
--     custodian_id numeric (20),
--     event_type maker_event_type not null,
--     size numeric (20) not null,
--     price numeric (20) not null,
--     time timestamptz not null,
--     primary key (market_order_id, time),
--     foreign key (market_id) references markets (market_id),
--     foreign key (
--         market_order_id, market_id
--     ) references orders (market_order_id, market_id)
-- );
--
-- create function handle_maker_event() returns trigger
-- as $handle_maker_event$ begin
--
-- -- Inserts a new row into the orders table if the event type is 'place'.
-- if new.event_type = 'place' then
--     insert into orders values (
--         new.market_order_id,
--         new.market_id,
--         new.side,
--         new.size,
--         new.price,
--         new.user_address,
--         new.custodian_id,
--         'open',
--         new.time
--     );
--
-- -- Updates the row of the order if the event type is 'change'.
-- -- This also updates the remaining_size column based on the updated order size,
-- -- and if the order size is decreased to the point that there is no amount left
-- -- to fill, remaining_size will be set to zero, and the order state will be set
-- -- to 'filled'.
-- elsif new.event_type = 'change' then
--     update orders set
--         size = new.size,
--         price = new.price
--     where market_order_id = new.market_order_id and market_id = new.market_id;
--
-- -- Order state is set to 'cancelled' if the event type is 'cancel'.
-- elsif new.event_type = 'cancel' then
--     update orders set
--         order_state = 'cancelled'
--     where market_order_id = new.market_order_id and market_id = new.market_id;
--
-- -- Order state is set to 'evicted' if the event type is 'evict'.
-- elsif new.event_type = 'evict' then
--     update orders set
--         order_state = 'evicted'
--     where market_order_id = new.market_order_id and market_id = new.market_id;
-- end if;
-- return new;
-- end;
-- $handle_maker_event$ language plpgsql;
--
-- -- The trigger is configured so that it fires upon every row insertion to the
-- -- maker_events table. The orders table must be updated before the maker_events
-- -- table in order to satisfy the foreign key constraint on maker_events when
-- -- a new order is placed.
-- create trigger handle_maker_event_trigger
-- before
-- insert on maker_events for each row
-- execute procedure handle_maker_event();
--
-- create table taker_events (
--     market_id numeric (20) not null,
--     side side not null,
--     market_order_id numeric (39) not null,
--     maker varchar (70) not null,
--     custodian_id numeric (30),
--     size numeric (20) not null,
--     price numeric (20) not null,
--     time timestamptz not null,
--     primary key (market_order_id, time),
--     foreign key (market_id) references markets (market_id),
--     foreign key (
--         market_order_id, market_id
--     ) references orders (market_order_id, market_id)
-- );
--
-- create table fills (
--     market_id numeric (20) not null,
--     maker_order_id numeric (39) not null,
--     maker varchar (70) not null,
--     maker_side side not null,
--     custodian_id numeric (30),
--     size numeric (20) not null,
--     price numeric (20) not null,
--     time timestamptz not null,
--     primary key (market_id, maker_order_id, time),
--     foreign key (market_id) references markets (market_id),
--     foreign key (
--         maker_order_id, market_id
--     ) references orders (market_order_id, market_id)
-- );
--
-- -- Decreases the remaining_size on the order by the fill size.
-- create function handle_taker_event() returns trigger
-- as $handle_taker_event$ begin
--     -- This updates the maker order corresponding to the taker event.
--     -- new.size refers to fill size
--     update orders set
--         size = size - new.size,
--         order_state = (case when size - new.size <= 0
--                        then 'filled' else order_state end)
--     where market_order_id = new.market_order_id and market_id = new.market_id;
--
--     insert into fills values (
--         new.market_id,
--         new.market_order_id,
--         new.maker,
--         new.side,
--         new.custodian_id,
--         new.size,
--         new.price,
--         new.time
--     );
-- return new;
-- end;
-- $handle_taker_event$ language plpgsql;
--
-- create trigger handle_taker_event_trigger
-- before
-- insert on taker_events for each row
-- execute procedure handle_taker_event();
