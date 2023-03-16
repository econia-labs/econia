create type side as enum ('buy', 'sell');

create type order_state as enum ('open', 'filled', 'cancelled');

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
    return new;
elsif new.event_type = 'change' then
    update orders set
        size = new.size,
        price = new.price,
        remaining_size = greatest(new.size - (size - orders.remaining_size), 0),
        order_state = (case when new.size - (size - orders.remaining_size) <= 0
                       then 'filled' else order_state end)
    where market_order_id = new.market_order_id and market_id = new.market_id;
    return new;
elsif new.event_type = 'cancel' then
    update orders set
        order_state = 'cancelled'
    where market_order_id = new.market_order_id and market_id = new.market_id;
    return new;
end if;
end;
$handle_maker_event$ language plpgsql;

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
