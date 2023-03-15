create type side as enum ('buy', 'sell');

create table orders (
    market_order_id numeric (39) not null primary key,
    market_id numeric (20) not null,
    side side not null,
    size numeric (20) not null,
    price numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    created_at timestamptz not null,
    order_access_key numeric (20) not null,
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
    foreign key (market_id) references markets (market_id)
);

create function place_order() returns trigger as $place_order$ begin
if new.event_type = 'place' then
    insert into orders values (
        new.market_order_id,
        new.market_id,
        new.side,
        new.size,
        new.price,
        new.user_address,
        new.custodian_id,
        new.time,
        0 -- TODO order access key
    );
    return new;
end if;
end;
$place_order$ language plpgsql;

create trigger place_order_trigger
after
insert on maker_events for each row
execute procedure place_order();

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
    foreign key (market_id) references markets (market_id)
);
