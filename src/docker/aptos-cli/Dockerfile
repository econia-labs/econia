FROM rust:1-bookworm AS compile

ARG GIT_TAG=aptos-cli-v2.0.3

RUN git clone --depth 1 --branch $GIT_TAG https://github.com/aptos-labs/aptos-core.git
WORKDIR /aptos-core/
RUN apt-get update \
    && apt-get install \
        build-essential \
        libclang-dev \
        libpq-dev \
        libssl-dev \
        lld \
        -y
RUN cargo build --package aptos --release

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
    && apt-get install \
        git \
        libssl-dev \
        -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=compile /aptos-core/target/release/aptos /usr/local/bin

CMD aptos --version
