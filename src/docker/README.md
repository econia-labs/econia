# Data service stack local Docker compose

The `dss-local.yaml` Docker compose file specifies the Econia data service stack in its most basic form, which can be run locally.

## Configuration

1. Note that before you can use this file you will have to update the indexer submodule:

   ```sh
   # From Econia repo root
   git submodule init
   git submodule update src/rust/dependencies/aptos-indexer-processors
   ```

1. You'll also need to provide a `processor/config.yaml` based on `processor/config-template.yaml`.

## Start up

> This command may take a while the first time you run it, since it will have to compile several binaries.
> Subsequent calls should be much faster, however, due to Docker's caching mechanism.

```sh
# From Econia repo root
docker compose --file src/docker/data-service-stack.yaml up detach
```

## Shut down

```sh
# From Econia repo root
docker compose --file src/docker/data-service-stack.yaml down
```

# End-to-end docker compose

This Docker compose is designed to work with an end-to-end testing environment, with Econia and the Econia faucet published under single-signer vanity address accounts generated from plaintext (compromised) private keys.

While the local testnet is running, you can look up on-chain Move resources using the published node REST API port (note that the Aptos faucet API may take longer to start up than the node REST API):

```sh
# From Econia repo root
ECONIA_ADDRESS=$(cat src/docker/chain/accounts/econia.address)
FAUCET_ADDRESS=$(cat src/docker/chain/accounts/faucet.address)
aptos account list --account $FAUCET_ADDRESS --url http://localhost:8080
```

# Helpful Docker commands

The [Docker docs](https://docs.docker.com/) offer an extensive collection of helpful tutorials, examples, and references.
For convenience, here is a consolidated list of some of the most helpful commands for working with Econia.

- List all images:

  ```
  docker images -a
  ```

- Run a shell inside an image:

  ```
  docker run -it --entrypoint sh <IMAGE_NAME>
  ```

- List all containers:

  ```
  docker ps -a
  ```

- Stop and remove all containers:

  ```
  docker ps -aq | xargs docker stop | xargs docker rm
  ```

- Show disk usage:

  ```
  docker system df
  ```

- Prune all containers, images, and volumes:

  ```
  docker system prune -af
  docker volume prune -af
  ```
