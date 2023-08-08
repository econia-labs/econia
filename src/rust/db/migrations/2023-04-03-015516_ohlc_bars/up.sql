create table bars_1m (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, start_time),
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
    primary key (market_id, start_time),
    foreign key (market_id) references markets (market_id)
);

create table bars_15m (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, start_time),
    foreign key (market_id) references markets (market_id)
);

create table bars_30m (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, start_time),
    foreign key (market_id) references markets (market_id)
);

create table bars_1h (
    market_id numeric (20) not null,
    start_time timestamptz not null,
    open numeric (20) not null,
    high numeric (20) not null,
    low numeric (20) not null,
    close numeric (20) not null,
    volume numeric (20) not null,
    primary key (market_id, start_time),
    foreign key (market_id) references markets (market_id)
);

create function handle_1m_interval_end()
returns trigger
as $handle_1m_interval_end$
declare
    interval_rows bars_1m%rowtype;
begin
    if date_part('minute', new.start_time)::int % 5 = 4 then
        with bars as (
            select
                *
            from
                bars_1m
            where
                start_time > new.start_time - '4 minutes'::interval - '1 second'::interval
                and start_time <= new.start_time
                and market_id = new.market_id
),
first as (
    select
        start_time,
        first_value(open) over (order by start_time) as open
from
    bars
),
last as (
    select
        start_time,
        first_value(close) over (order by start_time desc) as close
from
    bars
)
select
    bars.market_id,
    min(first.start_time),
    min(first.open) as open,
    max(high) as high,
    min(low) as low,
    min(last.close) as close,
    sum(volume) as volume
from
    bars
    inner join first on bars.start_time = first.start_time
    inner join last on bars.start_time = last.start_time
group by
    bars.market_id into interval_rows;
insert into bars_5m
    values (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
end if;
    return new;
end;
$handle_1m_interval_end$
language plpgsql;

create trigger handle_1m_interval_end_trigger
after insert on bars_1m
for each row
execute procedure handle_1m_interval_end();

create function handle_5m_interval_end()
returns trigger
as $handle_5m_interval_end$
declare
    interval_rows bars_5m%rowtype;
begin
    if date_part('minute', new.start_time)::int % 15 = 10 then
        with bars as (
            select
                *
            from
                bars_5m
            where
                start_time > new.start_time - '10 minutes'::interval - '1 second'::interval
                and start_time <= new.start_time
                and market_id = new.market_id
),
first as (
    select
        start_time,
        first_value(open) over (order by start_time) as open
from
    bars
),
last as (
    select
        start_time,
        first_value(close) over (order by start_time desc) as close
from
    bars
)
select
    bars.market_id,
    min(first.start_time),
    min(first.open) as open,
    max(high) as high,
    min(low) as low,
    min(last.close) as close,
    sum(volume) as volume
from
    bars
    inner join first on bars.start_time = first.start_time
    inner join last on bars.start_time = last.start_time
group by
    bars.market_id into interval_rows;
insert into bars_15m
    values (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
end if;
    return new;
end;
$handle_5m_interval_end$
language plpgsql;

create trigger handle_5m_interval_end_trigger
after insert on bars_5m
for each row
execute procedure handle_5m_interval_end();

create function handle_15m_interval_end()
returns trigger
as $handle_15m_interval_end$
declare
    interval_rows bars_15m%rowtype;
begin
    if date_part('minute', new.start_time)::int % 30 = 15 then
        with bars as (
            select
                *
            from
                bars_15m
            where
                start_time > new.start_time - '15 minutes'::interval - '1 second'::interval
                and start_time <= new.start_time
                and market_id = new.market_id
),
first as (
    select
        start_time,
        first_value(open) over (order by start_time) as open
from
    bars
),
last as (
    select
        start_time,
        first_value(close) over (order by start_time desc) as close
from
    bars
)
select
    bars.market_id,
    min(first.start_time),
    min(first.open) as open,
    max(high) as high,
    min(low) as low,
    min(last.close) as close,
    sum(volume) as volume
from
    bars
    inner join first on bars.start_time = first.start_time
    inner join last on bars.start_time = last.start_time
group by
    bars.market_id into interval_rows;
insert into bars_30m
    values (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
end if;
    return new;
end;
$handle_15m_interval_end$
language plpgsql;

create trigger handle_15m_interval_end_trigger
after insert on bars_15m
for each row
execute procedure handle_15m_interval_end();

create function handle_30m_interval_end()
returns trigger
as $handle_30m_interval_end$
declare
    interval_rows bars_30m%rowtype;
begin
    if date_part('minute', new.start_time)::int = 30 then
        with bars as (
            select
                *
            from
                bars_30m
            where
                start_time > new.start_time - '30 minutes'::interval - '1 second'::interval
                and start_time <= new.start_time
                and market_id = new.market_id
),
first as (
    select
        start_time,
        first_value(open) over (order by start_time) as open
from
    bars
),
last as (
    select
        start_time,
        first_value(close) over (order by start_time desc) as close
from
    bars
)
select
    bars.market_id,
    min(first.start_time),
    min(first.open) as open,
    max(high) as high,
    min(low) as low,
    min(last.close) as close,
    sum(volume) as volume
from
    bars
    inner join first on bars.start_time = first.start_time
    inner join last on bars.start_time = last.start_time
group by
    bars.market_id into interval_rows;
insert into bars_1h
    values (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
end if;
    return new;
end;
$handle_30m_interval_end$
language plpgsql;

create trigger handle_30m_interval_end_trigger
after insert on bars_30m
for each row
execute procedure handle_30m_interval_end();
