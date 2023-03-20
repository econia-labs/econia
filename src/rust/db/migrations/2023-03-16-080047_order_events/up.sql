create type side as enum ('bid', 'ask');

create type order_state as enum ('open', 'filled', 'cancelled', 'evicted');

create table orders (
    market_order_id numeric (39) not null,
    market_id numeric (20) not null,
    side side not null,
    size numeric (20) not null,
    price numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    order_state order_state not null,
    remaining_size numeric (20) not null,
    created_at timestamptz not null,
    primary key (market_order_id, market_id),
    foreign key (market_id) references markets (market_id)
);

create type maker_event_type as enum ('cancel', 'change', 'evict', 'place');

create table maker_events (
    market_id numeric (20) not null,
    side side not null,
    market_order_id numeric (39) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    event_type maker_event_type not null,
    size numeric (20) not null,
    price numeric (20) not null,
    time timestamptz not null,
    primary key (market_order_id, time),
    foreign key (market_id) references markets (market_id),
    foreign key (
        market_order_id, market_id
    ) references orders (market_order_id, market_id)
);

create function handle_maker_event() returns trigger
as $handle_maker_event$ begin

-- Inserts a new row into the orders table if the event type is 'place'.
if new.event_type = 'place' then
    insert into orders values (
        new.market_order_id,
        new.market_id,
        new.side,
        new.size,
        new.price,
        new.user_address,
        new.custodian_id,
        'open',
        new.size,
        new.time
    );

-- Updates the row of the order if the event type is 'change'.
-- This also updates the remaining_size column based on the updated order size,
-- and if the order size is decreased to the point that there is no amount left
-- to fill, remaining_size will be set to zero, and the order state will be set
-- to 'filled'.
elsif new.event_type = 'change' then
    update orders set
        size = new.size,
        price = new.price,
        remaining_size = greatest(new.size - size + remaining_size, 0),
        order_state = (case when new.size - size + remaining_size <= 0
                       then 'filled' else order_state end)
    where market_order_id = new.market_order_id and market_id = new.market_id;

-- Order state is set to 'cancelled' if the event type is 'cancel'.
elsif new.event_type = 'cancel' then
    update orders set
        order_state = 'cancelled'
    where market_order_id = new.market_order_id and market_id = new.market_id;

-- Order state is set to 'evicted' if the event type is 'evict'.
elsif new.event_type = 'evict' then
    update orders set
        order_state = 'evicted'
    where market_order_id = new.market_order_id and market_id = new.market_id;
end if;
return new;
end;
$handle_maker_event$ language plpgsql;

-- The trigger is configured so that it fires upon every row insertion to the
-- maker_events table. The orders table must be updated before the maker_events
-- table in order to satisfy the foreign key constraint on maker_events when
-- a new order is placed.
create trigger handle_maker_event_trigger
before
insert on maker_events for each row
execute procedure handle_maker_event();

create table taker_events (
    market_id numeric (20) not null,
    side side not null,
    market_order_id numeric (39) not null,
    maker varchar (70) not null,
    custodian_id numeric (30),
    size numeric (20) not null,
    price numeric (20) not null,
    time timestamptz not null,
    primary key (market_order_id, time),
    foreign key (market_id) references markets (market_id),
    foreign key (
        market_order_id, market_id
    ) references orders (market_order_id, market_id)
);

create table fills (
    market_id numeric (20) not null,
    maker_order_id numeric (39) not null,
    maker varchar (70) not null,
    maker_side side not null,
    maker_custodian_id numeric (30),
    taker_order_id numeric (39),
    taker varchar (70),
    taker_custodian_id numeric (30),
    fill_size numeric (20) not null,
    price numeric (20) not null,
    time timestamptz not null,
    primary key (market_id, maker_order_id, time),
    foreign key (market_id) references markets (market_id),
    foreign key (
        maker_order_id, market_id
    ) references orders (market_order_id, market_id)
);

-- Decreases the remaining_size on the order by the fill size.
create function handle_taker_event() returns trigger
as $handle_taker_event$ begin
    -- This updates the maker order corresponding to the taker event.
    -- new.size refers to fill size
    update orders set
        remaining_size = remaining_size - new.size,
        order_state = (case when remaining_size - new.size <= 0
                       then 'filled' else order_state end)
    where market_order_id = new.market_order_id and market_id = new.market_id;

    insert into fills values (
        new.market_id,
        new.market_order_id,
        new.maker,
        new.side,
        new.custodian_id,
        null,
        null,
        null,
        new.size,
        new.price,
        new.time
    );
return new;
end;
$handle_taker_event$ language plpgsql;

create trigger handle_taker_event_trigger
before
insert on taker_events for each row
execute procedure handle_taker_event();
