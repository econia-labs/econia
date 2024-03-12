ARG DATABASE_URL

ARG APP_DIR=/app
ARG RUST_ROOT=src/rust
ARG BIN_PATH=$APP_DIR/target/release/mqtt-publisher

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
RUN cargo build --release -p mqtt-publisher

FROM debian:bookworm-slim AS runtime
ARG APP_DIR
ARG BIN_PATH
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libudev-dev \
    build-essential \
    libclang-dev \
    libpq-dev \
    libssl-dev \
    lld \
    pkg-config \
    mosquitto \
    bash \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder $BIN_PATH $APP_DIR/

COPY src/docker/mqtt/mosquitto.conf /mosquitto/config/mosquitto.conf

COPY src/docker/mqtt/acl_file /acl_file

RUN chown mosquitto:mosquitto /acl_file

RUN chmod 600 /acl_file

COPY src/docker/mqtt/start.sh /start.sh

ENV MQTT_URL=mqtt://127.0.0.1:21883

# This helps the aggregator stop faster
STOPSIGNAL SIGKILL

CMD bash /start.sh
