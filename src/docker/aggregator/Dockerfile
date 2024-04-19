ARG APTOS_NETWORK
ARG DATABASE_URL

ARG APP_DIR=/app
ARG RUST_ROOT=src/rust
ARG BIN_PATH=$APP_DIR/target/release/aggregator

FROM rust:slim-bookworm AS builder
ARG APP_DIR
ARG RUST_ROOT
COPY $RUST_ROOT $APP_DIR
WORKDIR $APP_DIR
RUN apt-get update && apt-get install -y \
    libudev-dev \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*
RUN RUSTFLAGS="--cfg tokio_unstable" cargo build --release -p aggregator

FROM debian:bookworm-slim AS runtime
ARG APP_DIR
ARG APTOS_NETWORK
ARG BIN_PATH
ARG DATABASE_URL
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libudev-dev \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder $BIN_PATH $APP_DIR/

ENV APTOS_NETWORK=$APTOS_NETWORK
ENV DATABASE_URL=$DATABASE_URL

# This helps the aggregator stop faster
STOPSIGNAL SIGKILL

ENTRYPOINT /app/aggregator
