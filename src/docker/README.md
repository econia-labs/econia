# Dockerfiles

This directory arranges Dockerfiles into subdirectories of the form `purpose/Dockerfile` (instead of having many `<purpose>.Dockerfile`s in one directory), such that purpose-specific `.dockerignore` files can be added later without introducing conflict.

# End-to-end compose

This Docker compose file specifies an end-to-end testing environment based on a local testnet compiled from source, with Econia and the Econia faucet published under single-signer vanity address accounts generated from plaintext (compromised) private keys.

## Start up

> This command may take up to 10 minutes or so the first time you run it, since it will have to compile the Aptos CLI from source then run several commands against a local testnet.
> Subsequent calls should be much faster, however, due to Docker's caching mechanism.

```bash
# From Econia repo root
docker compose --file src/docker/compose.e2e.yml up --detach
```

While the local testnet is running, you can look up published Move resources using the published node REST API port (note that the Aptos faucet API may take longer to start up than the node REST API):

```bash
# From Econia repo root
ECONIA_ADDRESS=$(cat src/docker/chain/accounts/econia.address)
FAUCET_ADDRESS=$(cat src/docker/chain/accounts/faucet.address)
aptos account list --account $FAUCET_ADDRESS --url http://localhost:8080
```

## Shut down

```bash
# From Econia repo root
docker compose --file src/docker/compose.e2e.yml down
```

# Local testnet

If you run the end-to-end compose environment, the local testnet image will be automatically handled for you.
However, you can still use it manually.

## Build

Since this Dockerfile relies on Move source files elsewhere in the Econia repository, build it from the Econia repository root to expose the Move files during the build context:

```bash
# From Econia repo root
docker build . \
    --file src/docker/chain/Dockerfile \
    --tag chain
```

## Serve

Once the image is built, you can serve a local testnet containing the Econia and Econia faucet packages as a background process (via detached container mode).
This command publishes the local testnet node REST API on port 8080 and the Aptos faucet API on port 8081:

```bash
CONTAINER_ID=$(docker run \
    --detach \
    --publish 8080:8080 \
    --publish 8081:8081 \
    chain)
```

## Shut down

To shut down the container:

```bash
docker stop $CONTAINER_ID
```

# Helpful Docker commands

- List all images:

  ```
  docker images -a
  ```

- List all containers:

  ```
  docker ps -a
  ```

- Stop and remove all containers:

  ```
  docker ps -aq | xargs docker stop | xargs docker rm
  ```

- Prune all containers, images, and volumes:

  ```
  docker system prune -a --volumes
  ```
