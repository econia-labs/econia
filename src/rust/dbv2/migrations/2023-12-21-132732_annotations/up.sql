-- Your SQL goes here
CREATE TABLE annotations (
    "time" timestamptz NOT NULL,
    "timeEnd" timestamptz,
    "title" text NOT NULL,
    "text" text,
    "tag" text NOT NULL,
);

INSERT INTO annotations ("time", "title", "tag") VALUES (
    '2023-11-28 14:03:00+00'::timestamptz,
    'Econia mainnet launch',
    'Econia'
);

INSERT INTO annotations ("time", "title", "tag") VALUES (
    '2023-11-30 22:03:00+00'::timestamptz,
    'APT-LZUSDC promo tweet',
    'Econia'
);

INSERT INTO annotations ("time", "title", "tag") VALUES (
    '2023-12-11 15:33:00+00'::timestamptz,
    'Aries Spotlight article',
    'Econia'
);

INSERT INTO annotations ("time", "title", "tag") VALUES (
    '2023-12-18 13:53:00+00'::timestamptz,
    'LZeth launch',
    'Econia'
);
