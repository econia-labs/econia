# Base image
FROM rust:latest as builder

# Install dependencies?
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get update
RUN apt install -y clang
RUN rustup toolchain install 1.66.1-aarch64-unknown-linux-gnu
RUN rustup component add rustfmt --toolchain 1.66.1-aarch64-unknown-linux-gnu
COPY ./src/rust .
WORKDIR /indexer
RUN cargo build --release
WORKDIR /dependencies/aptos-core/aptos-node
RUN cargo build --release --features indexer

FROM rust:latest
WORKDIR /root/

WORKDIR /root/indexer
COPY --from=builder /indexer .
COPY --from=builder /target/release/indexer .
COPY --from=builder /dependencies/aptos-core/target/release/aptos-node .
ENTRYPOINT ["./indexer"]