FROM rust:1-bookworm AS compile

ARG GIT_TAG=aptos-cli-v2.0.3
ARG GIT_REPO=https://github.com/aptos-labs/aptos-core.git

# Get Aptos repo and build dependencies, then compile.
RUN git clone \
        $GIT_REPO \
        --branch $GIT_TAG \
        --depth 1 \
        && \
    apt-get update && \
    apt-get install \
        build-essential \
        libclang-dev \
        libpq-dev \
        libssl-dev \
        lld \
        -y \
        && \
    rm -rf /var/lib/apt/lists/* && \
    RUSTFLAGS="--cfg tokio_unstable" cargo build \
        --manifest-path aptos-core/Cargo.toml \
        --package aptos \
        --profile cli

# Copy over combiled binary only and get runtime dependency.
FROM debian:bookworm AS runtime
COPY --from=compile /aptos-core/target/cli/aptos /usr/local/bin
RUN apt-get update && \
    apt-get install \
        libssl-dev \
        -y \
        && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["usr/local/bin/aptos", "--version"]
