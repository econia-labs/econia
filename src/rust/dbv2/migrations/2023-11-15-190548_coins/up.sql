-- Your SQL goes here
CREATE TABLE aggregator.coins (
    name text NOT NULL,
    symbol text NOT NULL,
    decimals smallint NOT NULL,
    address text NOT NULL,
    module text NOT NULL,
    struct text NOT NULL,
    PRIMARY KEY (address, module, struct)
);
