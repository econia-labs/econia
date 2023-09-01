# Relative to Econia repository root.
ARG APTOS_CORE_ROOT=src/rust/dependencies/aptos-core

# Get cargo chef, set working directory.
FROM rust:slim-bookworm as chef
RUN cargo install cargo-chef
WORKDIR /aptos-core

# Plan dependency recipe.
FROM chef AS planner
ARG APTOS_CORE_ROOT
COPY $APTOS_CORE_ROOT .
RUN cargo chef prepare --recipe-path recipe.json

# Get build dependencies then compile recipe.
FROM chef AS builder
ARG APTOS_CORE_ROOT
RUN apt update && apt-get --no-install-recommends install -y \
        binutils \
        build-essential \
        clang \
        cmake \
        curl \
        pkg-config \
        libclang-dev \
        libpq-dev \
        libssl-dev \
        libudev-dev \
        lld \
    && rm -rf /var/lib/apt/lists/*
COPY $APTOS_CORE_ROOT .
COPY --from=planner /aptos-core/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Build release binaries.
RUN cargo build \
    --bin aptos-indexer-grpc-cache-worker \
    --package aptos-indexer-grpc-cache-worker \
    --bin aptos-indexer-grpc-data-service \
    --package aptos-indexer-grpc-data-service \
    --bin aptos-indexer-grpc-file-store \
    --package aptos-indexer-grpc-file-store \
    --bin aptos-indexer-grpc-post-processor \
    --package aptos-indexer-grpc-post-processor \
    --release

# Build CLI binary with requisite profile.
RUN RUSTFLAGS="--cfg tokio_unstable" cargo build \
    --bin aptos \
    --package aptos \
    --profile cli
