FROM rust:1-bookworm AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef as planner
COPY src/rust/ .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN apt-get update && \
    apt-get install \
        build-essential \
        libclang-dev \
        libpq-dev \
        libssl-dev \
        lld \
        -y \
        && \
    rm -rf /var/lib/apt/lists/*
RUN cargo chef cook  --release --recipe-path recipe.json
COPY src/rust .
WORKDIR /app/dependencies/aptos-core/aptos-node
RUN cargo build --release --features indexer
RUN strip -s /app/dependencies/aptos-core/target/release/aptos-node