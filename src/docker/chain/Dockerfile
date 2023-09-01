# Relative to Econia repository root.
ARG MOVE_ROOT=src/move
ARG ECONIA_ROOT=$MOVE_ROOT/econia
ARG FAUCET_ROOT=$MOVE_ROOT/faucet
ARG ACCOUNT_FILES=src/docker/chain/accounts/

# Relative to Aptos builder image root.
ARG NODE_BIN=/aptos-core/target/cli/aptos

# Copy over combiled CLI binary and get runtime dependency.
FROM debian:bookworm-slim AS config-cli
ARG NODE_BIN
COPY --from=aptos-builder $NODE_BIN /usr/local/bin
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt-get --no-install-recommends install -y \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Publish Econia and Econia faucet to local testnet.
FROM config-cli AS publish-packages

# Copy in Move and account files.
ARG MOVE_ROOT
ARG ECONIA_ROOT
ARG FAUCET_ROOT
ARG ACCOUNT_FILES
WORKDIR /app/
COPY --link $ECONIA_ROOT/Move.toml econia/
COPY --link $ECONIA_ROOT/sources/* econia/sources/
COPY --link $FAUCET_ROOT/Move.toml faucet/
COPY --link $FAUCET_ROOT/sources/* faucet/sources/
COPY --link $ACCOUNT_FILES accounts/

# Get git, start a local testnet, initialize profiles, publish packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get --no-install-recommends install -y \
        git \
    && rm -rf /var/lib/apt/lists/*
RUN aptos node run-local-testnet \
        --test-dir data \
        --with-faucet \
        & \
    sleep 30 && \
    aptos init \
        --network local \
        --private-key-file accounts/econia.key \
        --profile econia \
        && \
    aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia=$(cat accounts/econia.address) \
        --override-size-check \
        --package-dir econia \
        --profile econia \
        && \
    aptos init \
        --network local \
        --private-key-file accounts/faucet.key \
        --profile faucet \
        && \
    aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia_faucet=$(cat accounts/faucet.address) \
        --override-size-check \
        --package-dir faucet \
        --profile faucet

# Copy over chain data to fresh CLI, expose REST API and Aptos Faucet API.
FROM config-cli AS run
COPY --from=publish-packages --link /app/data /app/data
EXPOSE 8080
EXPOSE 8081

# Serve local testnet.
ENTRYPOINT [ \
    "usr/local/bin/aptos", "node", "run-local-testnet", \
    "--test-dir", "/app/data", \
    "--with-faucet" \
]
