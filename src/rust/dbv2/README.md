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

To generate schemas:

```sh
diesel database reset
diesel print-schema -s aggregator > src/schema/aggregator.rs
```

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

## Binaries

### Trading competition management

#### Create a competition

Compile the `init-competition` binary:

```sh
cargo build --release --bin init-competition
```

It requires a file in the `/src/rust/dbv2` directory called `competition-metadata.json`.
There is a template file in that location by the name `competition-metadata-template.json`.
Rename the template file to `competition-metadata.json` and update its contents accordingly.
After that, run the `init-competition` binary from `/src/rust/dbv2`:

```sh
./../target/release/init-competition
```

If successful, it will print out the added competition like so:

```
New competition: CompetitionMetadata {
    id: 1,
    start: 2023-10-01T11:00:00Z,
    end: 2023-10-16T19:00:00Z,
    prize: 123456789,
    market_id: BigDecimal("3"),
    integrators_required: [
        Some(
            "0xace",
        ),
    ],
}
```

#### View all competitions

Compile and run the `get-competitions` binary from the `/src/rust/dbv2` directory:

```sh
cargo build --release --bin get-competitions
```

```sh
./../target/release/get-competitions
```

If successful it will print out all competitions, for example:

```
Existing competitions:
CompetitionMetadata {
    id: 1,
    start: 2023-10-01T11:00:00Z,
    end: 2023-10-16T19:00:00Z,
    prize: 123456789,
    market_id: BigDecimal("3"),
    integrators_required: [
        Some(
            "0xace",
        ),
    ],
}
```

#### Add/remove/view competition exclusions

> Any of these operations will fail if they reference a competition ID that does not yet exist.

Users can be excluded from a competition's leaderboards by their address.
Compile all of the utilities like so:

```sh
cargo build --release --bin get-exclusions
cargo build --release --bin add-exclusions
cargo build --release --bin add-inclusions
```

**Add exclusions**

This binary requires a file in `/src/rust/dbv2` named `competition-additional-exclusions.json` for which there is a template in the same location.
Run the binary from the `/src/rust/dbv2` directory like so:

```sh
./../target/release/add-exclusions
```

If successful, it will print out the exclusions added like so:

```
New exclusions: [
    CompetitionExclusion {
        user: "0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40",
        reason: Some(
            "Internal testing",
        ),
        competition_id: 1,
    },
    CompetitionExclusion {
        user: "0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878",
        reason: Some(
            "Integrating partner",
        ),
        competition_id: 1,
    },
]
```

**Get exclusions**

This binary accepts 0 to 2 arguments: up to one competition id and up to one user address, in any order.
Run it from the `/src/rust/dbv2` directory like so:

```sh
./../target/release/get-exclusions # Optionally pass a competition id, user address
```

If there are exclusions matching those parameters, they will be printed like so:

```
EXCLUSIONS:
(COMPETITION_ID) ADDRESS: "REASON"
```

```
EXCLUSIONS:
(1) 0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40: "Internal testing"
(1) 0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878: "Integrating partner"
```

If none match, the following will be printed instead:

```
No exclusions match those parameters.
```

Passing no arguments will print the whole exclusion table (or its lack of contents).

It will throw an exception if you try to insert a user to a competition they're already excluded from.
To remove someone from exclusion, use inverse of this binary, (`add-inclusions`), described below.

**Add inclusions**

This binary requires a file in `/src/rust/dbv2` named `competition-additional-inclusions.json` for which there is a template in the same location.
Run the binary from the `/src/rust/dbv2` directory like so:

```sh
./../target/release/add-inclusions
```

If successful, it will print out the exclusions added like so:

```
Now included: 0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
Now included: 0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
```

If the user(s) are already included for the given competition id(s) then the output will look like:

```
Already included: 0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
Already included: 0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
```
