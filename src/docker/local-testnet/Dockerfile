FROM aptos-cli as publish

# Declare source paths relative to Econia repository root.
ARG MOVE_ROOT=src/move
ARG ECONIA_ROOT=$MOVE_ROOT/econia
ARG FAUCET_ROOT=$MOVE_ROOT/faucet
ARG ACCOUNTS_ROOT=src/docker/local-testnet/accounts

# Copy in files.
WORKDIR /app/
COPY $ECONIA_ROOT/Move.toml econia/
COPY $ECONIA_ROOT/sources/* econia/sources/
COPY $FAUCET_ROOT/Move.toml faucet/
COPY $FAUCET_ROOT/sources/* faucet/sources/
COPY $ACCOUNTS_ROOT accounts/

# Get git, start a local testnet, initialize profiles, publish packages.
RUN apt-get update && \
    apt-get install git -y && \
    rm -rf /var/lib/apt/lists/* && \
    aptos node run-local-testnet \
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

# Copy over chain data only.
FROM aptos-cli as runtime
COPY --from=publish /app/data /app/data

# Serve local testnet.
ENTRYPOINT [ \
    "usr/local/bin/aptos", "node", "run-local-testnet", \
    "--test-dir", "/app/data", \
    "--with-faucet" \
]
