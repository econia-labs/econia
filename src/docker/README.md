# Dockerfiles

This directory contains Dockerfiles arranged into subdirectories of the form `purpose/Dockerfile` (instead of having many `<purpose>.Dockerfile`s in one directory), such that purpose-specific `.dockerignore` files can be added later without introducing conflict.

All commands should be run from the Econia repository root, to ensure that any required source files are exposed during the build context.

# Aptos CLI

This Dockerfile builds an image with the most up-to-date `aptos` CLI, along with `git`.

The `--platform` flag is pinned here to ensure that the solver can find the corresponding local image, rather than trying to pull it from Docker Hub, when using this image as a parent image for other local builds.

## Build

```bash
# From Econia repo root
docker build . \
    --file src/docker/aptos-cli/Dockerfile \
    --tag aptos-cli \
    --platform=linux/amd64
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
    --tag local-testnet \
    --platform=linux/amd64
```

This command uses plaintext (compromised) private keys to publish Econia and the faucet under the following single-signer vanity address accounts:

```bash
ECONIA_ADDRESS=0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
FAUCET_ADDRESS=0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
```

## Serve

Once the image is built, you can serve a local testnet containing the Econia and faucet packages as a background process (via detached container mode).
This command publishes the local testnet node REST API on port 8080 and the faucet API on port 8081:

```bash
CONTAINER_ID=$(docker run \
    --detach \
    --publish 8080:8080 \
    --publish 8081:8081 \
    local-testnet)
```

While the local testnet is running, you can look up the faucet account using the published node REST API port (note that the faucet API may take longer to start up than the node REST API):

```bash
aptos account list --account $FAUCET_ADDRESS --url http://localhost:8080
```

## Shut down

To shut down the container:

```bash
docker stop $CONTAINER_ID
```
