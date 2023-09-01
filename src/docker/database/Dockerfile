# This docker file is used to run the database migrations.
FROM rust:slim-bookworm

# Relative to Econia repo root.
ARG DATABASE_ROOT=src/rust/dbv2

ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
COPY --link $DATABASE_ROOT /db/

WORKDIR /db/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get --no-install-recommends install -y \
        libpq-dev \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*
RUN cargo install diesel_cli \
    --features postgres \
    --no-default-features

ENTRYPOINT ["diesel", "migration", "run"]
