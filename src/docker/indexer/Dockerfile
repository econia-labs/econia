ARG APP_ROOT=/app
ARG INDEXER_ROOT=$APP_ROOT/dependencies/aptos-core
ARG NODE_BIN=$INDEXER_ROOT/target/releases/aptos-node
ARG NODE_YAML=$INDEXER_ROOT/aptos-node/indexer-node.yaml

FROM rust:1-bookworm AS chef
RUN cargo install cargo-chef
WORKDIR $APP_ROOT

FROM chef as planner
COPY src/rust/ .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder

ARG INDEXER_ROOT
ARG NODE_BIN

COPY --from=planner $APP_ROOT/recipe.json recipe.json
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
RUN cargo chef cook --release --recipe-path recipe.json
COPY src/rust .
WORKDIR $INDEXER_ROOT/aptos-node
RUN cargo build --release --features indexer
RUN strip -s $NODE_BIN

FROM debian:bookworm-slim AS run

ARG NODE_BIN
ARG NODE_YAML

COPY --from=builder $NODE_BIN $APP_ROOT
COPY --from=builder $NODE_YAML $APP_ROOT

RUN apt-get update && \
    apt-get install \
        libpq-dev \
        -y \
        && \
    rm -rf /var/lib/apt/lists/*
