# This docker file is used to run the database migrations
FROM rust:slim-bookworm

ARG RUST_ROOT=src/rust
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
WORKDIR $RUST_ROOT/dbv2

COPY . .

RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*
RUN cargo install diesel_cli \
    --features postgres \
    --no-default-features

ENTRYPOINT ["diesel", "migration", "run"]
