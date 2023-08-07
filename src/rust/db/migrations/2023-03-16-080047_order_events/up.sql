create type side as enum (
    'bid',
    'ask'
);

create type order_state as enum (
    'open',
    'filled',
    'cancelled',
    'evicted'
);

create type restriction as enum (
    'no_restriction',
    'fill_or_abort',
    'immediate_or_cancel',
    'post_or_abort'
);

create type self_match_behavior as enum (
    'abort',
    'cancel_both',
    'cancel_maker',
    'cancel_taker'
);

create type cancel_reason as enum (
    'size_change_internal',
    'eviction',
    'immediate_or_cancel',
    'manual_cancel',
    'max_quote_traded',
    'not_enough_liquidity',
    'self_match_maker',
    'self_match_taker'
);

create table orders (
    order_id numeric (39) not null,
    market_id numeric (20) not null,
    side side not null,
    size numeric (20) not null,
    remaining_size numeric (20) not null,
    price numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    order_state order_state not null,
    created_at timestamptz not null,
    primary key (order_id, market_id),
    foreign key (market_id) references markets (market_id)
);

create table cancel_order_events (
    market_id numeric (20) not null,
    order_id numeric (39) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    reason cancel_reason not null,
    time timestamptz not null,
    primary key (market_id, order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (order_id, market_id) references orders (order_id, market_id)
);

create function handle_cancel_order_event()
returns trigger
as $handle_cancel_order_event$
begin
    update
        orders
    set
        order_state = 'cancelled'
    where
        market_id = new.market_id
        and order_id = new.order_id;
    return new;
end;
$handle_cancel_order_event$
language plpgsql;

create trigger handle_cancel_order_event_trigger
before insert on cancel_order_events
for each row
execute procedure handle_cancel_order_event();

create table change_order_size_events (
    market_id numeric (20) not null,
    order_id numeric (39) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    side side not null,
    new_size numeric (20) not null,
    time timestamptz not null,
    primary key (market_id, order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (order_id, market_id) references orders (order_id, market_id)
);

create function handle_change_order_size_event()
returns trigger
as $handle_change_order_size_event$
begin
    update
        orders
    set
        size = new.size
    where
        market_id = new.market_id
        and order_id = new.order_id;
    return new;
end;
$handle_change_order_size_event$
language plpgsql;

create trigger handle_change_order_size_event_trigger
before insert on change_order_size_events
for each row
execute procedure handle_change_order_size_event();

create table fill_events (
    market_id numeric (20) not null,
    size numeric (20) not null,
    price numeric (20) not null,
    maker_side side not null,
    maker varchar (70) not null,
    maker_custodian_id numeric (20),
    maker_order_id numeric (39) not null,
    taker varchar (70) not null,
    taker_custodian_id numeric (20),
    taker_order_id numeric (39) not null,
    taker_quote_fees_paid numeric (20) not null,
    sequence_number_for_trade numeric (20) not null,
    time timestamptz not null,
    primary key (market_id, maker_order_id, taker_order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (maker_order_id, market_id) references orders (
        order_id, market_id
    ),
    foreign key (taker_order_id, market_id) references orders (
        order_id, market_id
    )
);

create function handle_fill_event()
returns trigger
as $handle_fill_event$
begin
    update
        orders
    set
        remaining_size = remaining_size - new.size,
        order_state = (
            case when remaining_size <= 0 then
                'filled'
            else
                order_state
            end)
    where
        market_id = new.market_id
        and order_id = new.order_id;
    return new;
end;
$handle_fill_event$
language plpgsql;

create trigger handle_fill_event_trigger
before insert on fill_events
for each row
execute procedure handle_fill_event();

create table place_limit_order_events (
    market_id numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    integrator varchar (70),
    side side not null,
    size numeric (20) not null,
    price numeric (20) not null,
    restriction restriction not null,
    self_match_behavior self_match_behavior not null,
    remaining_size numeric (20) not null,
    order_id numeric (39) not null,
    time timestamptz not null,
    primary key (market_id, order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (order_id, market_id) references orders (order_id, market_id)
);

create function handle_place_limit_order_event()
returns trigger
as $handle_place_limit_order_event$
begin
    insert into orders
        values (new.order_id, new.market_id, new.side, new.size, new.remaining_size, new.price, new.user_address, new.custodian_id, 'open', new.time);
    return new;
end;
$handle_place_limit_order_event$
language plpgsql;

create trigger handle_place_limit_order_event_trigger
before insert on place_limit_order_events
for each row
execute procedure handle_place_limit_order_event();

create table place_market_order_events (
    market_id numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    integrator varchar (70),
    direction side not null,
    size numeric (20) not null,
    self_match_behavior self_match_behavior not null,
    order_id numeric (39) not null,
    time timestamptz not null,
    primary key (market_id, order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (order_id, market_id) references orders (order_id, market_id)
);

create function handle_place_market_order_event()
returns trigger
as $handle_place_market_order_event$
begin
    insert into orders
        values (new.order_id, new.market_id, new.direction, new.size, new.size, new.remaining_size, new.user_address, new.custodian_id, 'open', new.time);
    return new;
end;
$handle_place_market_order_event$
language plpgsql;

create trigger handle_place_market_order_event_trigger
before insert on place_market_order_events
for each row
execute procedure handle_place_market_order_event();

create table place_swap_order_events (
    market_id numeric (20) not null,
    signing_account varchar (70) not null,
    integrator varchar (70),
    direction side not null,
    min_base numeric (20) not null,
    max_base numeric (20) not null,
    min_quote numeric (20) not null,
    max_quote numeric (20) not null,
    limit_price numeric (20) not null,
    order_id numeric (39) not null,
    time timestamptz not null,
    primary key (market_id, order_id),
    foreign key (market_id) references markets (market_id),
    foreign key (order_id, market_id) references orders (order_id, market_id)
);
