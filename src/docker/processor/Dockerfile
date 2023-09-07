# Based on aptos-labs/aptos-indexer-processors/Dockerfile.

# Relative to Econia repo root.
ARG RUST_ROOT=src/rust

# Relative to builder layer root.
ARG APP_DIR=/app
ARG PROCESSOR_DIR=$APP_DIR/dependencies/aptos-indexer-processors/rust
ARG BIN_PATH=$PROCESSOR_DIR/target/release/processor

# Install build dependencies, compile binary.
FROM rust:slim-bullseye AS builder
ARG APP_DIR
ARG PROCESSOR_DIR
ARG RUST_ROOT
COPY $RUST_ROOT $APP_DIR
WORKDIR $PROCESSOR_DIR
RUN apt-get update && apt-get install -y \
        clang \
        cmake \
        curl \
        git \
        libpq-dev \
        libssl-dev \
        lld \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
RUN cargo build --release -p processor

# Install dependencies, copy over compiled binary.
FROM debian:bullseye-slim AS runtime
ARG BIN_PATH
RUN apt-get update && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        iproute2 \
        libpq-dev \
        libssl1.1 \
        net-tools \
        netcat \
        tcpdump \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder $BIN_PATH /usr/local/bin

# Use JSON Rust logging.
ENV RUST_LOG_FORMAT=json

# Health check port.
EXPOSE 8084

# Run processor with config file.
ENTRYPOINT ["/usr/local/bin/processor", "-c", "/config.yaml"]
