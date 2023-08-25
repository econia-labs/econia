# End-to-end compose

This Docker compose file specifies an end-to-end testing environment based on a local testnet compiled from source, with Econia and the Econia faucet published under single-signer vanity address accounts generated from plaintext (compromised) private keys.

Note that before you can use this file you will have to update the indexer submodule:

```sh
# From Econia repo root
git submodule init
git submodule update src/rust/dependencies/aptos-core
```

## Start up

> This command may take a while the first time you run it, since it will have to compile the Aptos CLI and an indexer node from source before running several commands against a local testnet.
> Subsequent calls should be much faster, however, due to Docker's caching mechanism.

```sh
# From Econia repo root
docker compose --file src/docker/compose.e2e.yml up --detach
```

While the local testnet is running, you can look up on-chain Move resources using the published node REST API port (note that the Aptos faucet API may take longer to start up than the node REST API):

```sh
# From Econia repo root
ECONIA_ADDRESS=$(cat src/docker/chain/accounts/econia.address)
FAUCET_ADDRESS=$(cat src/docker/chain/accounts/faucet.address)
aptos account list --account $FAUCET_ADDRESS --url http://localhost:8080
```

## Shut down

```sh
# From Econia repo root
docker compose --file src/docker/compose.e2e.yml down
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
  docker system prune -af --volumes
  ```
