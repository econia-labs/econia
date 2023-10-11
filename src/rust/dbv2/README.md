# Database

This repository provides migrations to create the Econia event database, and Rust types to work with the event database.

The aggregator furthermore adds tables to this database under the `aggregator` schema.
Those are discussed in the `src/rust/aggregator` crate.

# Contributing

When creating a new migration, before committing, please make sure to use [sql-formatter](https://github.com/sql-formatter-org/sql-formatter) with the provided configuration.

# Documentation

## `diesel`

We use [`diesel`](https://crates.io/crates/diesel) to create and run migrations and models.

This crates provides the models for every table in the database.

We also use `diesel` to run migrations. In our docker compose configuration, we have a dedicated docker container that runs `diesel migration run`.

## Notifications

We use [Postgres notifications](https://www.postgresql.org/docs/14/sql-notify.html) to create a real time notification feed for Econia's events.

Each event table has a [trigger](https://www.postgresql.org/docs/14/sql-createtrigger.html) that emits a notification with the name of the event as the channel, and the raw event data converted to JSON as its payload.

## PostgREST

We use PostgREST as our REST API.

PostgREST will serve all tables that are found in the `api` PostgreSQL schema.

We chose to not create any table directly in the `api` schema, but to create them in another schema, and add a view representing them in the `api` schema.
This way, we have more control over what can and cannot be viewed, and we avoid having public tables by default.
So if you wish to add a table that is queriable via our REST API, you have to add it to the `api` schema as follows:

```sql
-- Create the actual table
CREATE TABLE example (…);

-- Expose the table in the api schema
CREATE VIEW api.example AS SELECT * FROM example;
```

## Managing testnet trading competitions

1. Store `DATABASE_URL` environment variable:

   ```sh
   export DATABASE_URL=postgres://econia:econia@localhost:5432/econia
   ```

1. Create `competition-metadata.json` based on `competition-metadata-template.json`.

1. Create a new competition:

   ```sh
   cargo run --bin init-competition
   ```

1. View all competitions:

   ```sh
   cargo run --bin get-competitions
   ```
