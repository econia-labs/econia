create table coins (
    symbol varchar(8) not null primary key,
    name text not null,
    decimals smallint not null,
    address text not null
);

create table orderbooks (
    id numeric not null primary key,
    base varchar(8) not null references coins(symbol),
    quote varchar(8) not null references coins(symbol),
    lot_size numeric not null,
    tick_size numeric not null,
    min_size numeric not null,
    underwriter_id numeric not null
);
