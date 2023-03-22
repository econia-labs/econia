FROM rust:1.68-bookworm as builder
RUN apt-get update
RUN apt-get install mold -y
WORKDIR /app
COPY . .
ARG RUSTFLAGS="-C link-arg=-fuse-ld=mold"
RUN cargo build --release --bin api

FROM debian:bookworm-slim AS runtime
RUN apt-get update
RUN apt-get install ca-certificates libpq-dev -y
COPY --from=builder /app/target/release/api /usr/local/bin
ENTRYPOINT ["/usr/local/bin/api"]
