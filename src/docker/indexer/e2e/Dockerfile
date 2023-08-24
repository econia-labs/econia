# Relative to Econia repository root.
ARG RUST_ROOT=src/rust

# Relative to image root.
ARG APP_ROOT=/app
ARG INDEXER_ROOT=$APP_ROOT/dependencies/aptos-core
ARG CRATE_ROOT=$INDEXER_ROOT/aptos-node
ARG NODE_BIN=$INDEXER_ROOT/target/release/aptos-node
ARG NODE_YAML=$INDEXER_ROOT/aptos-node/indexer-node.yaml

# Relative to chain image root.
ARG WAYPOINT_TXT=/app/data/waypoint.txt
ARG GENESIS_BLOB=/app/data/0/genesis.blob

FROM cargo-chef as chef
ARG APP_ROOT
WORKDIR $APP_ROOT

# Prepare build dependency recipe.
FROM chef as planner
ARG RUST_ROOT
COPY $RUST_ROOT .
RUN cargo chef prepare --recipe-path recipe.json

# Get/compile build dependencies, then indexer.
FROM chef as builder
ARG APP_ROOT
ARG CRATE_ROOT
ARG NODE_BIN
ARG RUST_ROOT
RUN apt-get update && apt-get install -y \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    && rm -rf /var/lib/apt/lists/*
COPY $RUST_ROOT .
COPY --from=planner $APP_ROOT/recipe.json $APP_ROOT/recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
WORKDIR $CRATE_ROOT
RUN cargo build \
    --bin aptos-node \
    --release \
    --features indexer
RUN strip -s $NODE_BIN

# Establish intermediate layer with local testnet chain files.
FROM chain as chain-files

# Copy over compiled indexer files, chain data, and install runtime dependency.
FROM debian:bookworm-slim AS runtime
ARG APP_ROOT
ARG GENESIS_BLOB
ARG NODE_BIN
ARG NODE_YAML
ARG WAYPOINT_TXT
WORKDIR $APP_ROOT
COPY --from=builder $NODE_BIN .
COPY --from=builder $NODE_YAML .
COPY --from=chain-files $WAYPOINT_TXT .
COPY --from=chain-files $GENESIS_BLOB .
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*