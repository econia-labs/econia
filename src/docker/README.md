# Data service stack local Docker compose

The `compose.dss-local.yaml` Docker compose file specifies the Econia data service stack in its most basic form, which can be run locally.

You can read more about the DSS by taking a look at the [official documentation](https://econia.dev/off-chain/data-service-stack).

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
docker compose --file src/docker/compose.dss-local.yaml up --detach
```

## Shut down

```sh
# From Econia repo root
docker compose --file src/docker/compose.dss-local.yaml down
```

# End-to-end docker compose

This Docker compose is designed to work with an end-to-end testing environment, with Econia and the Econia faucet published under single-signer vanity address accounts generated from plaintext (compromised) private keys.

There are a few steps to start up the local end-to-end testing environment:

**1. Configure the processor.**

See the file `config-template-local.yaml` in `/src/docker/processor` for an example configuration.
Copy and rename this file to `config.yaml`, which is ignored by git, so that the docker compose will pick it up.
The new, copied and renamed file goes into the same folder as the template.

**2. Run the docker compose.**

While inside `/src/docker` run:

```sh
docker compose -f ./compose.dss-local.yaml up
```

Expect this to take a little over 10 minutes (on an M1 OSX machine).

**3. Verify contract deployment** (optional, recommended).

While the local testnet is running, you can look up on-chain Move resources using the published node REST API port.
Note that the Aptos faucet API may take longer to start up than the node REST API:

```sh
# From Econia repo root
ECONIA_ADDRESS=0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
FAUCET_ADDRESS=0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
aptos account list --account $FAUCET_ADDRESS --url http://0.0.0.0:8080
aptos account list --account $ECONIA_ADDRESS --url http://0.0.0.0:8080
```

Both of the last two commands should spit out a bunch of resources deployed to the expected addresses.

**4. Verify working connectivity** (optional, recommended).

There is a script available that performs most (but not all) of the eventful and/or interesting operations on the exchange.
By running it against the local end-to-end deployment, it's possible to verify things like processor operation, database connectivity and data accessibility.
You'll need to install [Poetry](https://python-poetry.org/docs/):

```sh
brew install poetry
```

Alternatively, if your platform doesn't support `brew`:

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

Next, navigate your terminal to `/src/python/sdk` and run the following:

```sh
poetry install
poetry run trade
```

The script will have a few prompts, respond to each of them as follows:

| Prompt         | Value                                                              |
| -------------- | ------------------------------------------------------------------ |
| Econia address | 0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40 |
| Faucet address | 0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878 |
| Node URL       | http://0.0.0.0:8080/v1                                             |
| Faucet URL     | http://0.0.0.0:8081                                                |

Next, the script will step through various operations such as order creation, cancellation and fulfillment; press `ENTER` to advance each step.
The script should execute to completion (it says `THE END!`) if everything is working.
Verify that the database is accessible by navigating to `http://0.0.0.0:3001`, and that necessary tables are visible/contain data by navigating to:

- `http://0.0.0.0:3001/market_registration_events`
- `http://0.0.0.0:3001/cancel_order_events`
- `http://0.0.0.0:3001/fill_events`
- `http://0.0.0.0:3001/place_limit_order_events`

If each of these tables is visible and containing data then that means the processor, database and PostgREST are all working together!

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
