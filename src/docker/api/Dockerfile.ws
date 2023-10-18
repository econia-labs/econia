FROM debian:stable-slim

ARG POSTGRES_WEBSOCKETS_VERSION

RUN apt-get update \
    && apt-get install -y libpq-dev wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/diogob/postgres-websockets/releases/download/$POSTGRES_WEBSOCKETS_VERSION/postgres-websockets

RUN chmod u+x ./postgres-websockets

ENTRYPOINT ["./postgres-websockets"]
