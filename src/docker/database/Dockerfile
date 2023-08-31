# This docker file is used to run the database migrations
FROM rust:slim-bookworm

ARG DATABASE_ROOT=src/rust/dbv2
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
COPY $DATABASE_ROOT /db/

WORKDIR /db/

RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*
RUN cargo install diesel_cli \
    --features postgres \
    --no-default-features

ENTRYPOINT ["diesel", "migration", "run"]
