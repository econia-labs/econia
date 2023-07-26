CREATE TABLE bars_1m (
    market_id numeric(20) NOT NULL,
    start_time timestamptz NOT NULL,
    open numeric(20) NOT NULL,
    high numeric(20) NOT NULL,
    low numeric(20) NOT NULL,
    close numeric(20) NOT NULL,
    volume numeric(20) NOT NULL,
    PRIMARY KEY (market_id, start_time),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE TABLE bars_5m (
    market_id numeric(20) NOT NULL,
    start_time timestamptz NOT NULL,
    open numeric(20) NOT NULL,
    high numeric(20) NOT NULL,
    low numeric(20) NOT NULL,
    close numeric(20) NOT NULL,
    volume numeric(20) NOT NULL,
    PRIMARY KEY (market_id, start_time),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE TABLE bars_15m (
    market_id numeric(20) NOT NULL,
    start_time timestamptz NOT NULL,
    open numeric(20) NOT NULL,
    high numeric(20) NOT NULL,
    low numeric(20) NOT NULL,
    close numeric(20) NOT NULL,
    volume numeric(20) NOT NULL,
    PRIMARY KEY (market_id, start_time),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE TABLE bars_30m (
    market_id numeric(20) NOT NULL,
    start_time timestamptz NOT NULL,
    open numeric(20) NOT NULL,
    high numeric(20) NOT NULL,
    low numeric(20) NOT NULL,
    close numeric(20) NOT NULL,
    volume numeric(20) NOT NULL,
    PRIMARY KEY (market_id, start_time),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE TABLE bars_1h (
    market_id numeric(20) NOT NULL,
    start_time timestamptz NOT NULL,
    open numeric(20) NOT NULL,
    high numeric(20) NOT NULL,
    low numeric(20) NOT NULL,
    close numeric(20) NOT NULL,
    volume numeric(20) NOT NULL,
    PRIMARY KEY (market_id, start_time),
    FOREIGN KEY (market_id) REFERENCES markets (market_id)
);

CREATE FUNCTION handle_1m_interval_end ()
    RETURNS TRIGGER
    AS $handle_1m_interval_end$
DECLARE
    interval_rows bars_1m%rowtype;
BEGIN
    IF date_part('minute', NEW.start_time)::int % 5 = 4 THEN
        WITH bars AS (
            SELECT
                *
            FROM
                bars_1m
            WHERE
                start_time > NEW.start_time - '4 minutes'::interval - '1 second'::interval
                AND start_time <= NEW.start_time
                AND market_id = NEW.market_id
),
FIRST AS (
    SELECT
        start_time,
        first_value(OPEN) OVER (ORDER BY start_time) AS open
FROM
    bars
),
LAST AS (
    SELECT
        start_time,
        first_value(CLOSE) OVER (ORDER BY start_time DESC) AS close
FROM
    bars
)
SELECT
    bars.market_id,
    min(first.start_time),
    min(first.open) AS open,
    max(high) AS high,
    min(low) AS low,
    min(last.close) AS close,
    sum(volume) AS volume
FROM
    bars
    INNER JOIN FIRST ON bars.start_time = first.start_time
    INNER JOIN LAST ON bars.start_time = last.start_time
GROUP BY
    bars.market_id INTO interval_rows;
INSERT INTO bars_5m
    VALUES (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
END IF;
    RETURN new;
END;
$handle_1m_interval_end$
LANGUAGE plpgsql;

CREATE TRIGGER handle_1m_interval_end_trigger
    AFTER INSERT ON bars_1m FOR EACH ROW
    EXECUTE PROCEDURE handle_1m_interval_end ();

CREATE FUNCTION handle_5m_interval_end ()
    RETURNS TRIGGER
    AS $handle_5m_interval_end$
DECLARE
    interval_rows bars_5m%rowtype;
BEGIN
    IF date_part('minute', NEW.start_time)::int % 15 = 10 THEN
        WITH bars AS (
            SELECT
                *
            FROM
                bars_5m
            WHERE
                start_time > NEW.start_time - '10 minutes'::interval - '1 second'::interval
                AND start_time <= NEW.start_time
                AND market_id = NEW.market_id
),
FIRST AS (
    SELECT
        start_time,
        first_value(OPEN) OVER (ORDER BY start_time) AS open
FROM
    bars
),
LAST AS (
    SELECT
        start_time,
        first_value(CLOSE) OVER (ORDER BY start_time DESC) AS close
FROM
    bars
)
SELECT
    bars.market_id,
    min(first.start_time),
    min(first.open) AS open,
    max(high) AS high,
    min(low) AS low,
    min(last.close) AS close,
    sum(volume) AS volume
FROM
    bars
    INNER JOIN FIRST ON bars.start_time = first.start_time
    INNER JOIN LAST ON bars.start_time = last.start_time
GROUP BY
    bars.market_id INTO interval_rows;
INSERT INTO bars_15m
    VALUES (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
END IF;
    RETURN new;
END;
$handle_5m_interval_end$
LANGUAGE plpgsql;

CREATE TRIGGER handle_5m_interval_end_trigger
    AFTER INSERT ON bars_5m FOR EACH ROW
    EXECUTE PROCEDURE handle_5m_interval_end ();

CREATE FUNCTION handle_15m_interval_end ()
    RETURNS TRIGGER
    AS $handle_15m_interval_end$
DECLARE
    interval_rows bars_15m%rowtype;
BEGIN
    IF date_part('minute', NEW.start_time)::int % 30 = 15 THEN
        WITH bars AS (
            SELECT
                *
            FROM
                bars_15m
            WHERE
                start_time > NEW.start_time - '15 minutes'::interval - '1 second'::interval
                AND start_time <= NEW.start_time
                AND market_id = NEW.market_id
),
FIRST AS (
    SELECT
        start_time,
        first_value(OPEN) OVER (ORDER BY start_time) AS open
FROM
    bars
),
LAST AS (
    SELECT
        start_time,
        first_value(CLOSE) OVER (ORDER BY start_time DESC) AS close
FROM
    bars
)
SELECT
    bars.market_id,
    min(first.start_time),
    min(first.open) AS open,
    max(high) AS high,
    min(low) AS low,
    min(last.close) AS close,
    sum(volume) AS volume
FROM
    bars
    INNER JOIN FIRST ON bars.start_time = first.start_time
    INNER JOIN LAST ON bars.start_time = last.start_time
GROUP BY
    bars.market_id INTO interval_rows;
INSERT INTO bars_30m
    VALUES (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
END IF;
    RETURN new;
END;
$handle_15m_interval_end$
LANGUAGE plpgsql;

CREATE TRIGGER handle_15m_interval_end_trigger
    AFTER INSERT ON bars_15m FOR EACH ROW
    EXECUTE PROCEDURE handle_15m_interval_end ();

CREATE FUNCTION handle_30m_interval_end ()
    RETURNS TRIGGER
    AS $handle_30m_interval_end$
DECLARE
    interval_rows bars_30m%rowtype;
BEGIN
    IF date_part('minute', NEW.start_time)::int = 30 THEN
        WITH bars AS (
            SELECT
                *
            FROM
                bars_30m
            WHERE
                start_time > NEW.start_time - '30 minutes'::interval - '1 second'::interval
                AND start_time <= NEW.start_time
                AND market_id = NEW.market_id
),
FIRST AS (
    SELECT
        start_time,
        first_value(OPEN) OVER (ORDER BY start_time) AS open
FROM
    bars
),
LAST AS (
    SELECT
        start_time,
        first_value(CLOSE) OVER (ORDER BY start_time DESC) AS close
FROM
    bars
)
SELECT
    bars.market_id,
    min(first.start_time),
    min(first.open) AS open,
    max(high) AS high,
    min(low) AS low,
    min(last.close) AS close,
    sum(volume) AS volume
FROM
    bars
    INNER JOIN FIRST ON bars.start_time = first.start_time
    INNER JOIN LAST ON bars.start_time = last.start_time
GROUP BY
    bars.market_id INTO interval_rows;
INSERT INTO bars_1h
    VALUES (interval_rows.market_id, interval_rows.start_time, interval_rows.open, interval_rows.high, interval_rows.low, interval_rows.close, interval_rows.volume);
END IF;
    RETURN new;
END;
$handle_30m_interval_end$
LANGUAGE plpgsql;

CREATE TRIGGER handle_30m_interval_end_trigger
    AFTER INSERT ON bars_30m FOR EACH ROW
    EXECUTE PROCEDURE handle_30m_interval_end ();
