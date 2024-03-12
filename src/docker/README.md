# Data service stack local Docker compose

The `compose.dss-local.yaml` Docker compose file specifies the Econia data service stack in its most basic form, which can be run locally.

You can read more about the DSS by taking a look at the [official documentation](https://econia.dev/off-chain/dss/data-service-stack).

## Configuration

Note that before you can use this file you will have to update the indexer submodule:

```sh
# From Econia repo root
git submodule update --init --recursive
```

## End-to-end docker compose

This Docker compose is designed to work with an end-to-end testing environment, with Econia and the Econia faucet published under single-signer vanity address accounts generated from plaintext (compromised) private keys.

There are a few steps to start up the local end-to-end testing environment:

**1. Set environment variables.**

See the file `example.env` for an example configuration.
Copy and rename this file to `.env`, which is ignored by git, so that the Docker Compose will pick it up.
Then modify the options to use a local end-to-end testing chain.
The new, copied and renamed file goes into the same folder as the template.

**2. Run the docker compose.**

```sh
# From Econia repo root
docker compose \
    --file src/docker/compose.dss-core.yaml \
    --file src/docker/compose.dss-local.yaml up
```

Expect this to take a little over 10 minutes to compile (on an M1 OSX machine).

**3. Verify contract deployment** (optional, recommended).

While the local testnet is running, you can look up on-chain Move resources using the published node REST API port.
Note that the Aptos faucet API may take longer to start up than the node REST API:

```sh
ECONIA_ADDRESS=0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40
FAUCET_ADDRESS=0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878
aptos account list --account $FAUCET_ADDRESS --url http://0.0.0.0:8080
aptos account list --account $ECONIA_ADDRESS --url http://0.0.0.0:8080
```

Both of the last two commands should report resources deployed to the expected addresses.

**4. Verify working connectivity** (optional, recommended).

There is a script available that performs most (but not all) of the eventful and/or interesting operations on the exchange.
By running it against the local end-to-end deployment, it's possible to verify things like processor operation, database connectivity and data accessibility.
To run the script you'll need to install [Poetry](https://python-poetry.org/docs/).

Next run the following:

```sh
# From Econia repo root
cd src/python/sdk
poetry install
poetry run trade
```

Enter nothing for all of the prompts to use the default local configuration.

Next, the script will step through various operations such as order creation, cancellation and fulfillment; press `ENTER` to advance each step.
The script should execute to completion (it says `THE END!`) if everything is working.
Verify that the database is accessible by navigating to `http://0.0.0.0:3000`, and that necessary tables are visible/contain data by navigating to:

- `http://0.0.0.0:3000/market_registration_events`
- `http://0.0.0.0:3000/cancel_order_events`
- `http://0.0.0.0:3000/fill_events`
- `http://0.0.0.0:3000/place_limit_order_events`
- `http://0.0.0.0:3000/change_order_size_events`
- `http://0.0.0.0:3000/place_market_order_events`
- `http://0.0.0.0:3000/place_swap_order_events`
- `http://0.0.0.0:3000/recognized_market_events`

If each of these tables is visible and containing data then that means the processor, database and PostgREST are all working together!

**5. Stop the local DSS**

```sh
# From Econia repo root
docker compose --file src/docker/compose.dss-local.yaml stop
```

This will stop all docker containers, but keep their state on disk.
You can later start it up by using:

```sh
# From Econia repo root
docker compose --file src/docker/compose.dss-local.yaml start
```

**6. Shut down the local DSS**

```sh
# From Econia repo root
docker compose --file src/docker/compose.dss-local.yaml down
```

This will delete the containers, and you will lose state with this command.
It is recommended to use this only if you want to restart re-indexing from scratch.

Note that this will not delete all DSS related state, like the database volume.

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
