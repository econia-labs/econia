# syntax=docker/dockerfile:1-labs

# Aptos CLI git metadata.
ARG GIT_REPO=https://github.com/aptos-labs/aptos-core.git
ARG GIT_TAG=aptos-cli-v2.1.1

# Relative to Econia repository root.
ARG MOVE_ROOT=src/move
ARG ECONIA_ROOT=$MOVE_ROOT/econia
ARG FAUCET_ROOT=$MOVE_ROOT/faucet
ARG ACCOUNT_FILES=src/docker/tss/accounts/

# Relative to image root.
ARG NODE_BIN=/aptos-core/target/cli/aptos

# Get Aptos repo and build dependencies, then compile.
FROM rust:1-bookworm AS compile-cli
ARG GIT_REPO
ARG GIT_TAG
ARG NODE_BIN
RUN git clone \
    $GIT_REPO \
    --branch $GIT_TAG \
    --depth 1
RUN apt-get update && apt-get install -y \
    libudev-dev \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    && rm -rf /var/lib/apt/lists/*
RUN RUSTFLAGS="--cfg tokio_unstable" cargo build \
    --bin aptos \
    --manifest-path aptos-core/Cargo.toml \
    --package aptos \
    --profile cli
RUN strip -s $NODE_BIN

FROM ubuntu
# Copy over combiled CLI binary only and get runtime dependency.
ARG NODE_BIN
COPY --from=compile-cli $NODE_BIN /usr/local/bin
RUN apt-get update && apt-get install -y \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy in Move and account files.
ARG MOVE_ROOT
ARG ECONIA_ROOT
ARG FAUCET_ROOT
ARG ACCOUNT_FILES
WORKDIR /app/
COPY $ECONIA_ROOT/Move.toml econia/
COPY $ECONIA_ROOT/sources/* econia/sources/
COPY $FAUCET_ROOT/Move.toml faucet/
COPY $FAUCET_ROOT/sources/* faucet/sources/
COPY $ACCOUNT_FILES accounts/

COPY src/docker/tss/install_deps.sh .
COPY src/docker/tss/start.sh .

RUN chmod u+x /app/install_deps.sh
RUN chmod u+x /app/start.sh

RUN /app/install_deps.sh

ENV PATH=/root/.local/bin:$PATH

# This helps the container stop faster
STOPSIGNAL SIGKILL

CMD /app/start.sh

HEALTHCHECK --start-period=1m30s --start-interval=5s --interval=5s --timeout=3s \
    CMD curl -f localhost:8090 || exit 1
