FROM debian:stable-slim

ARG POSTGREST_VERSION

RUN apt-get update \
    && apt-get install -y libpq-dev tar wget xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/PostgREST/postgrest/releases/download/$POSTGREST_VERSION/postgrest-$POSTGREST_VERSION-linux-static-x64.tar.xz

RUN tar xf postgrest-$POSTGREST_VERSION-linux-static-x64.tar.xz

RUN rm postgrest-$POSTGREST_VERSION-linux-static-x64.tar.xz

ENTRYPOINT ["./postgrest"]
