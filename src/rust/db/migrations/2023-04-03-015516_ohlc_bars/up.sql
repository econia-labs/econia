create table bars_1m (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, time),
    foreign key (market_id) references markets (market_id)
);

create table bars_5m (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, time),
    foreign key (market_id) references markets (market_id)
);
