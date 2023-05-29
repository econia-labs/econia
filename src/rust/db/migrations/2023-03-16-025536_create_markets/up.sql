-- Corresponds to aptos_std::type_info::TypeInfo and
-- aptos_framework::coin::CoinInfo. GenericAsset will also be included.
create table coins (
    account_address varchar (70) not null,
    module_name text not null,
    struct_name text not null,
    symbol varchar (10) not null,
    name text not null,
    decimals smallint not null,
    primary key (account_address, module_name, struct_name)
);

-- Corresponds to econia::registry::MarketInfo.
-- Only recognized markets should be stored in the api database.
create table markets (
    market_id numeric (20) not null primary key,
    name text not null,
    base_account_address varchar (70),
    base_module_name text,
    base_struct_name text,
    base_name_generic text,
    quote_account_address varchar (70) not null,
    quote_module_name text not null,
    quote_struct_name text not null,
    lot_size numeric (20) not null,
    tick_size numeric (20) not null,
    min_size numeric (20) not null,
    underwriter_id numeric (20) not null,
    created_at timestamptz not null,
    foreign key (
        base_account_address, base_module_name, base_struct_name
    ) references coins (account_address, module_name, struct_name),
    foreign key (
        quote_account_address, quote_module_name, quote_struct_name
    ) references coins (account_address, module_name, struct_name)
);

-- Corresponds to econia::registry::MarketRegistrationEvent
create table market_registration_events (
    market_id numeric (20) not null primary key,
    time timestamptz not null,
    base_account_address varchar (70),
    base_module_name text,
    base_struct_name text,
    base_name_generic text,
    quote_account_address varchar (70) not null,
    quote_module_name text not null,
    quote_struct_name text not null,
    lot_size numeric (20) not null,
    tick_size numeric (20) not null,
    min_size numeric (20) not null,
    underwriter_id numeric (20) not null,
    foreign key (market_id) references markets (market_id)
);

create function register_market() returns trigger as $register_market$
declare
    base_symbol varchar (8);
    quote_symbol varchar (8);
begin
if new.base_name_generic is null then
	select symbol from coins where account_address = NEW.base_account_address
		and module_name = NEW.base_module_name and struct_name = NEW.base_struct_name
		into base_symbol;

	select symbol from coins where account_address = NEW.quote_account_address
		and module_name = NEW.quote_module_name and struct_name = NEW.quote_struct_name
		into quote_symbol;

	insert into markets
	values (
        NEW.market_id,
        base_symbol || '-' || quote_symbol,
        NEW.base_account_address,
        NEW.base_module_name,
        NEW.base_struct_name,
        NEW.base_name_generic,
        NEW.quote_account_address,
        NEW.quote_module_name,
        NEW.quote_struct_name,
        NEW.lot_size,
        NEW.tick_size,
        NEW.min_size,
        NEW.underwriter_id,
        NEW.time
    );

else
    insert into markets
	values (
        NEW.market_id,
        NEW.base_name_generic,
        NEW.base_account_address,
        NEW.base_module_name,
        NEW.base_struct_name,
        NEW.base_name_generic,
        NEW.quote_account_address,
        NEW.quote_module_name,
        NEW.quote_struct_name,
        NEW.lot_size,
        NEW.tick_size,
        NEW.min_size,
        NEW.underwriter_id,
        NEW.time
    );
end if;
return NEW;

end;

$register_market$ language plpgsql;

create trigger register_market_trigger
before
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
    time timestamptz not null,
    event_type market_event_type not null,
    lot_size numeric (20),
    tick_size numeric (20),
    min_size numeric (20)
);
