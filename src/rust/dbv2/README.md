# Database

This repository provides migrations to create the Econia event database, and Rust types to work with the event database.

The aggregator furthermore adds tables to this database under the `aggregator` schema. Those are disucssed in the `src/rust/aggregator` crate.

# Contributing

When creating a new migration, before commiting, please make sure to use [sql-formatter](https://github.com/sql-formatter-org/sql-formatter) with the provided configuration.

Also make sure to add the corresponding documentation to `models.md`.

# Documentation

## diesel

We use [`diesel`](https://crates.io/crates/diesel) to create and run migrations and models.

This crates provides the models for every table in the database.

We also use `diesel` to run migrations. In our docker compose configuration, we have a dedicated docker container that runs `diesel migration run`.

## Notifications

We use [Postgres notifications](https://www.postgresql.org/docs/15/sql-notify.html) to create a real time notification feed for Econia's events.

Each event table has a [trigger](https://www.postgresql.org/docs/15/sql-createtrigger.html) that emits a notification with the name of the event as the channel,
and the raw event data converted to JSON as its payload.
