-- Your SQL goes here
CREATE TABLE aggregator.prices (
    "market_id" NUMERIC(20,0),
    "start_time_1m_period" TIMESTAMPTZ,
    "price" NUMERIC(20,0) NOT NULL,
    "sum_fill_size_1m_period" NUMERIC(20,0) NOT NULL,
    PRIMARY KEY ("market_id", "start_time_1m_period")
);


CREATE TABLE aggregator.prices_last_indexed_txn (
    "txn_version" NUMERIC(20,0),
    PRIMARY KEY ("txn_version")
);


CREATE VIEW api.prices AS
SELECT * FROM aggregator.prices;


GRANT SELECT ON api.prices TO WEB_ANON;


GRANT SELECT ON aggregator.prices TO grafana;
GRANT SELECT ON aggregator.prices_last_indexed_txn TO grafana;
GRANT SELECT ON api.prices TO grafana;
