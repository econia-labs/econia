-- Corresponds to aptos_std::type_info::TypeInfo and 
-- aptos_framework::coin::CoinInfo.
create table coins (
    id serial not null primary key,
    account_address varchar (70) not null,
    module_name text not null,
    struct_name text not null,
    symbol varchar (8),
    name text,
    decimals smallint
);

-- Corresponds to econia::registry::MarketInfo.
-- Only recognized markets should be stored in the api database.
create table markets (
    market_id numeric (20) not null primary key,
    base_id serial not null,
    base_name_generic text,
    quote_id serial not null,
    lot_size numeric (20) not null,
    tick_size numeric (20) not null,
    min_size numeric (20) not null,
    underwriter_id numeric (20) not null,
    created_at timestamptz not null,
    foreign key (base_id) references coins (id),
    foreign key (quote_id) references coins (id)
);

-- Corresponds to econia::registry::MarketRegistrationEvent
create table market_registration_events (
    market_id numeric (20) not null primary key,
    time timestamptz not null,
    base_id serial not null,
    base_name_generic text,
    quote_id serial not null,
    lot_size numeric (20) not null,
    tick_size numeric (20) not null,
    min_size numeric (20) not null,
    underwriter_id numeric (20) not null
);

create function register_market() returns trigger as $register_market$ begin
insert into markets
values (
        NEW.market_id,
        NEW.base_id,
        NEW.base_name_generic,
        NEW.quote_id,
        NEW.lot_size,
        NEW.tick_size,
        NEW.min_size,
        NEW.underwriter_id,
        NEW.time
    );

return NEW;

end;

$register_market$ language plpgsql;

create trigger register_market_trigger
after
insert on market_registration_events for each row
execute procedure register_market();

-- Corresponds to econia::registry::RecognizedMarketInfo
-- This id does not need to exist, but diesel only supports tables 
-- with primary keys
create table recognized_markets (
    id serial not null primary key,
    market_id numeric (20) not null,
    foreign key (market_id) references markets (market_id)
);

-- Type of events that can be emitted for a recognized market.
create type market_event_type as enum ('add', 'remove', 'update');

-- Corresponds to econia::registry::RecognizedMarketEvent. 
create table recognized_market_events (
    market_id numeric (20) not null primary key,
    event_type market_event_type not null,
    lot_size numeric (20),
    tick_size numeric (20),
    min_size numeric (20)
);
