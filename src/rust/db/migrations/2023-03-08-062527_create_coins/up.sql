create table coins (
    symbol varchar(8) not null primary key,
    name text not null,
    decimals smallint not null,
    address text not null
);

create table orderbooks (
    id int not null primary key,
    base varchar(8) not null references coins(symbol),
    quote varchar(8) not null references coins(symbol),
    lot_size int not null,
    tick_size int not null,
    min_size int not null,
    underwriter_id int not null
);
