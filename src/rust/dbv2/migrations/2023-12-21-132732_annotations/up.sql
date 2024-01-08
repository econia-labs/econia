-- Your SQL goes here
CREATE TABLE annotations (
    "time" timestamptz NOT NULL,
    "timeEnd" timestamptz,
    "title" text NOT NULL,
    "text" text,
    "tag" text NOT NULL,
    PRIMARY KEY ("title", "tag")
);
