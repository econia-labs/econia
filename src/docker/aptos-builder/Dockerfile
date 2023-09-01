# Aptos core git metadata.
ARG GIT_REPO=https://github.com/aptos-labs/aptos-core.git
ARG GIT_TAG=aptos-node-v1.6.3

# Binary compilation directory.
ARG BIN_DIR=/aptos-core/target/release

# Download Aptos Core, get build dependencies, and compile.
FROM rust:slim-bookworm AS compile
ARG GIT_REPO
ARG GIT_TAG
RUN apt update && apt-get install -y \
        binutils \
        build-essential \
        clang \
        cmake \
        curl \
        git \
        pkg-config \
        libclang-dev \
        libpq-dev \
        libssl-dev \
        libudev-dev \
        lld \
    && rm -rf /var/lib/apt/lists/*
RUN git clone $GIT_REPO --branch $GIT_TAG --depth 1
WORKDIR /aptos-core
RUN cargo build \
    --package aptos-db-bootstrapper \
    --package aptos-db-tool \
    --package aptos-node \
    --package aptos-faucet-service \
    --package aptos-indexer-grpc-cache-worker \
    --package aptos-indexer-grpc-data-service \
    --package aptos-indexer-grpc-file-store \
    --package aptos-indexer-grpc-post-processor \
    --release

# Store binaries in lightweight image.
FROM scratch AS store
ARG BIN_DIR
COPY --from=compile $BIN_DIR/aptos-db-bootstrapper .
COPY --from=compile $BIN_DIR/aptos-db-tool .
COPY --from=compile $BIN_DIR/aptos-node .
COPY --from=compile $BIN_DIR/aptos-faucet-service .
COPY --from=compile $BIN_DIR/aptos-indexer-grpc-cache-worker .
COPY --from=compile $BIN_DIR/aptos-indexer-grpc-data-service .
COPY --from=compile $BIN_DIR/aptos-indexer-grpc-file-store .
COPY --from=compile $BIN_DIR/aptos-indexer-grpc-post-processor .