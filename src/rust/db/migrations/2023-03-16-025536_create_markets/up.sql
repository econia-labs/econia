-- Corresponds to aptos_std::type_info::TypeInfo and
-- aptos_framework::coin::CoinInfo. GenericAsset will also be included.
CREATE TABLE coins (
    account_address varchar(70) NOT NULL,
    module_name text NOT NULL,
    struct_name text NOT NULL,
    symbol varchar(10) NOT NULL,
    name text NOT NULL,
    decimals smallint NOT NULL,
    PRIMARY KEY (account_address, module_name, struct_name)
);

-- Corresponds to econia::registry::MarketInfo.
-- Only recognized markets should be stored in the api database.
CREATE TABLE markets (
    market_id numeric(20) NOT NULL PRIMARY KEY,
    name text NOT NULL,
    base_account_address varchar(70),
    base_module_name text,
    base_struct_name text,
    base_name_generic text,
    quote_account_address varchar(70) NOT NULL,
    quote_module_name text NOT NULL,
    quote_struct_name text NOT NULL,
    lot_size numeric(20) NOT NULL,
    tick_size numeric(20) NOT NULL,
    min_size numeric(20) NOT NULL,
    underwriter_id numeric(20) NOT NULL,
    created_at timestamptz NOT NULL,
    FOREIGN KEY (base_account_address, base_module_name, base_struct_name) REFERENCES coins (account_address, module_name, struct_name),
    FOREIGN KEY (quote_account_address, quote_module_name, quote_struct_name) REFERENCES coins (account_address, module_name, struct_name)
);

-- Corresponds to econia::registry::MarketRegistrationEvent
CREATE TABLE market_registration_events (
    market_id numeric(20) NOT NULL PRIMARY KEY,
    time timestamptz NOT NULL,
    base_account_address varchar(70),
    base_module_name text,
    base_struct_name text,
    base_name_generic text,
    quote_account_address varchar(70) NOT NULL,
    quote_module_name text NOT NULL,
    quote_struct_name text NOT NULL,
    lot_size numeric(20) NOT NULL,
    tick_size numeric(20) NOT NULL,
    min_size numeric(20) NOT NULL,
    underwriter_id numeric(20) NOT NULL,
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE FUNCTION register_market ()
    RETURNS TRIGGER
    AS $register_market$
DECLARE
    base_symbol varchar(8);
    quote_symbol varchar(8);
BEGIN
    IF NEW.base_name_generic IS NULL THEN
        SELECT
            symbol
        FROM
            coins
        WHERE
            account_address = NEW.base_account_address
            AND module_name = NEW.base_module_name
            AND struct_name = NEW.base_struct_name INTO base_symbol;
        SELECT
            symbol
        FROM
            coins
        WHERE
            account_address = NEW.quote_account_address
            AND module_name = NEW.quote_module_name
            AND struct_name = NEW.quote_struct_name INTO quote_symbol;
        INSERT INTO markets
            VALUES (NEW.market_id, base_symbol || '-' || quote_symbol, NEW.base_account_address, NEW.base_module_name, NEW.base_struct_name, NEW.base_name_generic, NEW.quote_account_address, NEW.quote_module_name, NEW.quote_struct_name, NEW.lot_size, NEW.tick_size, NEW.min_size, NEW.underwriter_id, NEW.time);
    ELSE
        INSERT INTO markets
            VALUES (NEW.market_id, NEW.base_name_generic, NEW.base_account_address, NEW.base_module_name, NEW.base_struct_name, NEW.base_name_generic, NEW.quote_account_address, NEW.quote_module_name, NEW.quote_struct_name, NEW.lot_size, NEW.tick_size, NEW.min_size, NEW.underwriter_id, NEW.time);
    END IF;
    RETURN NEW;
END;
$register_market$
LANGUAGE plpgsql;

CREATE TRIGGER register_market_trigger
    BEFORE INSERT ON market_registration_events
    FOR EACH ROW
    EXECUTE PROCEDURE register_market ();

-- Corresponds to econia::registry::RecognizedMarketInfo
-- This id does not need to exist, but diesel only supports tables
-- with primary keys
CREATE TABLE recognized_markets (
    id serial NOT NULL PRIMARY KEY,
    market_id numeric(20) NOT NULL,
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

-- Type of events that can be emitted for a recognized market.
CREATE TYPE market_event_type AS enum (
    'add',
    'remove',
    'update'
);

-- Corresponds to econia::registry::RecognizedMarketEvent.
CREATE TABLE recognized_market_events (
    market_id numeric(20) NOT NULL PRIMARY KEY,
    time timestamptz NOT NULL,
    event_type market_event_type NOT NULL,
    lot_size numeric(20),
    tick_size numeric(20),
    min_size numeric(20)
);
