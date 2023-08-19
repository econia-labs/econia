# Dockerfiles

This directory contains Dockerfiles arranged into subdirectories of the form `purpose/Dockerfile` (instead of having many `<purpose>.Dockerfile`s in one directory), such that purpose-specific `.dockerignore` files can be added later without introducing conflict.

All commands should be run from the Econia repository root, to ensure that any required source files are exposed during the build context.

# Aptos CLI

This Dockerfile builds an image containing the Aptos CLI compiled from source, to avoid potential platform issues that could ensue from other image generation methods.

## Build

```bash
# From Econia repo root
docker build . \
    --file src/docker/aptos-cli/Dockerfile \
    --tag aptos-cli
```

## Version check

```bash
docker run aptos-cli
```

# Local testnet

## Build

After building the Aptos CLI image locally:

```bash
# From Econia repo root
docker build . \
    --file src/docker/local-testnet/Dockerfile \
    --tag local-testnet
```

This command uses plaintext (compromised) private keys to publish Econia and the Econia faucet under the following single-signer vanity address accounts:

```bash
# From Econia repo root
ECONIA_ADDRESS=$(cat src/docker/local-testnet/accounts/econia.address)
FAUCET_ADDRESS=$(cat src/docker/local-testnet/accounts/faucet.address)
```

## Serve

Once the image is built, you can serve a local testnet containing the Econia and Econia faucet packages as a background process (via detached container mode).
This command publishes the local testnet node REST API on port 8080 and the Aptos faucet API on port 8081:

```bash
CONTAINER_ID=$(docker run \
    --detach \
    --publish 8080:8080 \
    --publish 8081:8081 \
    local-testnet)
```

docker run local-testnet

While the local testnet is running, you can look up the Econia faucet account using the published node REST API port (note that the Aptos faucet API may take longer to start up than the node REST API):

```bash
aptos account list --account $FAUCET_ADDRESS --url http://localhost:8080
```

## Shut down

To shut down the container:

```bash
docker stop $CONTAINER_ID
```
