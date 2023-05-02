# Econia Rust crates

## Running the API

To run the API, make sure the following dependencies are installed.

- Rust
- PostgreSQL
- Redis

### Building the API

[Cargo](https://doc.rust-lang.org/stable/cargo/), the Rust package manager, should be included as part of your Rust installation. Once you have it installed, simply run

```sh
cargo build
```

to install dependencies and build the project.

### Database setup

Install the Diesel CLI with the following command.

```sh
cargo install diesel_cli
```

You may also need to install [`libpq`](https://www.postgresql.org/docs/current/libpq.html), the PostgreSQL client library, for the next few steps to work.

Next, set an environment variable called `DATABASE_URL`, or add it to a .env file. Your file should look something like this.

```dosini
DATABASE_URL=postgres://postgres:password@localhost:5432/econia_db
```

Then, to set up Postgres with the database schema defined in the db crate, migrate to the db directory and run the following Diesel CLI commands. This will create the database and apply the migrations defined in the SQL files in `db/migrations`.

```sh
cd db
diesel setup
diesel migration run
```

If there is a change to the database schema, it may be necessary to reset the database and run the migrations again. In this case, run

```sh
diesel database reset
```

Additional resources are available on the Diesel website at <https://diesel.rs/guides>.

### Seed data

This API is meant to be used with an [indexer](https://aptos.dev/integration/indexing) running on the Aptos network. However, for development purposes, it may be useful to run the API with some mock data. To populate the database with mock data, run

```sh
cargo run --example seed_db
```

Now, all of the REST API endpoints should return data.

### Running the API

The API requires a connection to a PostgreSQL database and a Redis instance. In the same directory as this readme, create a `.env` file with the following variables. Replace the URLs here with the ones used in your local environment.

```dosini
DATABASE_URL=postgres://postgres:password@localhost:5432/econia_db
REDIS_URL=redis://localhost:6379
PORT=8000
```

Then, start the API by running

```sh
cargo run --bin api
```
