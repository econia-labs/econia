FROM aptos-cli as publish

# Declare source paths relative to Econia repository root.
ARG MOVE_ROOT=src/move
ARG ECONIA_ROOT=$MOVE_ROOT/econia
ARG FAUCET_ROOT=$MOVE_ROOT/faucet
ARG ACCOUNTS_ROOT=src/docker/local-testnet/accounts

# Copy in files.
COPY $ECONIA_ROOT/Move.toml /app/econia/
COPY $ECONIA_ROOT/sources/* /app/econia/sources/
COPY $FAUCET_ROOT/Move.toml /app/faucet/
COPY $FAUCET_ROOT/sources/* /app/faucet/sources/
COPY $ACCOUNTS_ROOT /app/accounts/

# Start a local testnet, initialize profiles, publish Econia and faucet packages.
RUN aptos node run-local-testnet \
        --test-dir /app/data \
        --with-faucet \
        & \
    sleep 30 && \
    aptos init \
        --network local \
        --private-key-file /app/accounts/econia.key \
        --profile econia \
        && \
    aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia=$(cat /app/accounts/econia.address) \
        --override-size-check \
        --package-dir /app/econia \
        --profile econia \
        && \
    aptos init \
        --network local \
        --private-key-file /app/accounts/faucet.key \
        --profile faucet \
        && \
    aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia_faucet=$(cat /app/accounts/faucet.address) \
        --override-size-check \
        --package-dir /app/faucet \
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