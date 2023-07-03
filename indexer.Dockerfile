FROM rust:latest as chef
RUN cargo install cargo-chef --locked
WORKDIR /src

FROM chef as planner
COPY ./src/rust/ .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /src/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY ./src/rust .
RUN apt-get update && apt-get install build-essential libclang-dev lld -y 
WORKDIR /src/dependencies/aptos-core/aptos-node
RUN cargo build --release --features indexer
RUN strip -s /src/dependencies/aptos-core/target/release/aptos-node

FROM debian:bullseye-slim as runner
COPY --from=builder /src/dependencies/aptos-core/target/release/aptos-node /node/
COPY --from=builder /src/dependencies/aptos-core/aptos-node/indexer-node.yaml /node/
WORKDIR /node
RUN apt-get update && apt-get install libpq-dev curl -y && rm -rf /var/lib/apt/lists/*
ENV APTOS_NETWORK=devnet
ENV DATABASE_URL=postgres://postgres:mysecretpassword@localhost:5432/postgres
ENTRYPOINT [ \ 
    "/bin/bash", \ 
    "-c", \ 
    " \
    curl -O https://raw.githubusercontent.com/aptos-labs/aptos-networks/main/${APTOS_NETWORK}/genesis.blob; \ 
    curl -O https://raw.githubusercontent.com/aptos-labs/aptos-networks/main/${APTOS_NETWORK}/waypoint.txt; \
    sed -i -e \"s|postgres_uri:.*|postgres_uri: \"${DATABASE_URL}\"|g\" indexer-node.yaml; \
    ./aptos-node --config indexer-node.yaml \
    " \
]

