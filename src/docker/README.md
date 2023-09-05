# End-to-end compose

This Docker compose file specifies an end-to-end testing environment based on a local chain, compiled from source.

Since the relevant Aptos binaries all use similar dependencies, they are compiled in a batched `aptos-builder` Dockerfile based on the [`aptos-core` builder](https://github.com/aptos-labs/aptos-core/tree/main/docker/builder), then copied over to service-specific images.

Note that since [`aptos-core indexer-grpc`](https://github.com/aptos-labs/aptos-core/blob/main/docker/compose/indexer-grpc) relies on [`aptos-core validator-testnet`](https://github.com/aptos-labs/aptos-core/blob/main/docker/compose/indexer-grpc), the two Docker compose environments are here consolidated into one Docker compose environment, to reduce instantiation overhead.

## Start up

> This command may take a while the first time you run it, since it will have to compile several Aptos binaries.
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
