# This docker file is used to run the database migrations
FROM rust:slim-bookworm

ARG RUST_ROOT=src/rust
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
COPY $RUST_ROOT /app

RUN apt-get update && apt-get install -y \
    libudev-dev \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT ["cargo", "run", "-p", "aggregator"]
