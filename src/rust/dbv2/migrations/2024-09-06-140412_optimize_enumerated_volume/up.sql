-- Your SQL goes here
CREATE TABLE aggregator.enumerated_volume_last_indexed_txn (
    txn_version NUMERIC(20,0) NOT NULL
);

INSERT INTO aggregator.enumerated_volume_last_indexed_txn
VALUES (0);

ALTER TABLE aggregator.enumerated_volume DROP COLUMN last_indexed_txn CASCADE;

DELETE FROM aggregator.enumerated_volume;

CREATE VIEW api.enumerated_volume AS
SELECT * FROM aggregator.enumerated_volume
NATURAL LEFT JOIN aggregator.coins;

GRANT
SELECT
  ON api.enumerated_volume TO web_anon;
