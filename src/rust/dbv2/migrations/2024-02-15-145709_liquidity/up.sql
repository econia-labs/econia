-- Your SQL goes here
CREATE TABLE aggregator.liquidity_groups (
    group_id SERIAL NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    market_id NUMERIC(20,0) NOT NULL
);

CREATE TABLE aggregator.liquidity_group_members (
    group_id INT REFERENCES aggregator.liquidity_groups ("group_id"),
    "address" TEXT,
    PRIMARY KEY (group_id, "address")
);

CREATE TABLE aggregator.liquidity (
    group_id INT NOT NULL REFERENCES aggregator.liquidity_groups ("group_id"),
    "time" TIMESTAMPTZ,
    bps_times_ten SMALLINT,
    amount_ask_lots NUMERIC(20,0),
    amount_bid_lots NUMERIC(20,0),
    PRIMARY KEY (group_id, "time", bps_times_ten)
);

GRANT SELECT ON aggregator.liquidity TO grafana;
GRANT SELECT ON aggregator.liquidity_groups TO grafana;
GRANT SELECT ON aggregator.liquidity_group_members TO grafana;

CREATE FUNCTION aggregator.add_member_to_liquidity_group(NUMERIC(20,0), TEXT) RETURNS VOID AS $$
BEGIN
    DELETE FROM aggregator.liquidity;
    INSERT INTO aggregator.liquidity_group_members VALUES ($1, $2);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION aggregator.remove_member_from_liquidity_group(NUMERIC(20,0), TEXT) RETURNS VOID AS $$
BEGIN
    DELETE FROM aggregator.liquidity;
    DELETE FROM aggregator.liquidity_group_members WHERE group_id = $1 AND "address" = $2;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION aggregator.create_liquidity_group(TEXT, NUMERIC(20,0)) RETURNS VOID AS $$
BEGIN
    DELETE FROM aggregator.liquidity;
    INSERT INTO aggregator.liquidity_groups VALUES ($1, $2);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION aggregator.remove_liquidity_group(INT) RETURNS VOID AS $$
BEGIN
    DELETE FROM aggregator.liquidity WHERE group_id = $1;
    DELETE FROM aggregator.liquidity_groups WHERE group_id = $1;
    DELETE FROM aggregator.liquidity_group_members WHERE group_id = $1;
END;
$$ LANGUAGE plpgsql;

DROP VIEW aggregator.spreads_latest_event_timestamp;
DROP TABLE aggregator.spreads_last_indexed_timestamp;

DELETE FROM aggregator.order_history_last_indexed_timestamp;
DROP TABLE aggregator.order_history;
