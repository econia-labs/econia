FROM aptos-cli

# Publication addresses and private keys.
ARG ECONIA_ADDRESS=0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
ARG FAUCET_ADDRESS=0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
ARG ECONIA_PRIVATE_KEY=0x8eeb9bd1808d99ef54758060f5067b5707be379058cfd83cd983fe7e47063a09
ARG FAUCET_PRIVATE_KEY=0x3a85635d893dd29f0764d5269b39531085e3f2642608baa05ba8f5f6a6f9ff6e

# Move package folders.
ARG MOVE_ROOT=src/move
ARG ECONIA_ROOT=$MOVE_ROOT/econia
ARG FAUCET_ROOT=$MOVE_ROOT/faucet

# Copy Move packages into image.
COPY $ECONIA_ROOT/Move.toml /chain/econia/
COPY $ECONIA_ROOT/sources/* /chain/econia/sources/
COPY $FAUCET_ROOT/Move.toml /chain/faucet/
COPY $FAUCET_ROOT/sources/* /chain/faucet/sources/

# Start a local testnet, initialize profiles, publish Econia and faucet packages.
WORKDIR /chain/
RUN aptos node run-local-testnet \
        --test-dir data \
        --with-faucet \
        & sleep 30 \
    && aptos init \
        --network local \
        --private-key $ECONIA_PRIVATE_KEY \
        --profile econia \
    && aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDRESS \
        --override-size-check \
        --package-dir econia \
        --profile econia \
    && aptos init \
        --network local \
        --private-key $FAUCET_PRIVATE_KEY \
        --profile faucet \
    && aptos move publish \
        --assume-yes \
        --included-artifacts none \
        --named-addresses econia_faucet=$FAUCET_ADDRESS \
        --override-size-check \
        --package-dir faucet \
        --profile faucet

# Serve local testnet.
CMD aptos node run-local-testnet \
        --test-dir data \
        --with-faucet
