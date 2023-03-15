create type side as enum ('buy', 'sell');

create table orders (
    id numeric (39) not null primary key,
    side side not null,
    size numeric (20) not null,
    price numeric (20) not null,
    user_address varchar (70) not null,
    custodian_id numeric (20),
    order_access_key numeric (20) not null
);

create type maker_event_type as enum ('cancel', 'change', 'evict', 'place');

create table maker_events (
    market_id numeric (20) not null,
    side side not null,
    market_order_id numeric (39) not null,
    user_address varchar (70) not null,
    custodian_id numeric (30),
    event_type maker_event_type not null,
    size numeric (20) not null,
    price numeric (20) not null,
    time timestamptz not null,
    primary key (market_order_id, time)
);

create table taker_events (
    market_id numeric (20) not null,
    side side not null,
    market_order_id numeric (39) not null,
    maker varchar (70) not null,
    custodian_id numeric (30),
    size numeric (20) not null,
    price numeric (20) not null,
    time timestamptz not null,
    primary key (market_order_id, time)
);
