-- Your SQL goes here
CREATE TABLE
  aggregator.coins (
    NAME TEXT NOT NULL,
    symbol TEXT NOT NULL,
    decimals SMALLINT NOT NULL,
    address TEXT NOT NULL,
    module TEXT NOT NULL,
    struct TEXT NOT NULL,
    PRIMARY KEY (address, module, struct)
  );