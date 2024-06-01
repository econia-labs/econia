# Data service stack

The Econia data service stack (DSS) is a collection of services that provide assorted data endpoints for integration purposes.
It exposes a REST API and an MQTT server, which are powered internally by an aggregator, a database, and an indexer.
To ensure composability, portability, and ease of use, each component is represented as a Docker service inside of a Docker compose environment.
For more on Docker, see [the official docs](https://docs.docker.com/).

This page will show you how to run the DSS locally.

## How it works

The DSS exposes a REST API and an MQTT server.

The MQTT server mainly provides notifications of any events emitted by the Econia Move package.
It can be addressed at `mqtt://0.0.0.0:21883` in the default local configuration of docker compose.

The REST API also provides all the events emitted by the Econia Move package., as well as aggregated data like order history and order book state.
It can be addressed at `http://0.0.0.0:3000` in the default local configuration of docker compose.

In order to access the MQTT server, connect to the following URL: `mqtt://your-host:21883`.
To get a list of the different topics, please see the [MQTT documentation](./mqtt.md).

The REST API is actually a PostgREST instance.
You can find the REST API documentation [here](./rest-api.md).
You can learn more about how to query a PostgREST instance on their [official documentation](https://postgrest.org/en/stable/).

## Walkthrough

There are two ways of running the DSS:

1. Against a public chain like Aptos devnet, testnet, or mainnet.
1. Against a local chain, as described [here](https://github.com/econia-labs/econia/tree/main/src/docker).

This walkthrough will use the official Aptos mainnet.
The process is the same as running against testnet, just with a slightly different config process.

### Getting the API key

Unless you are an infrastructure provider or want to run a fullnode yourself, the simplest way to get indexed transaction data is from the Aptos Labs gRPC endpoint (indexer v2 API).
To connect to this service, you'll need to get an API key [here](https://developers.aptoslabs.com/).

### Generating a config

Once you have the API key, you'll need to create an environment configuration file.
A template can be found at `src/docker/example.env`.
In the same folder as the template, create a copy of the file named `.env`.

The file is pre-configured to index the Econia mainnet package.
The only field you'll have to set is you Aptos gRPC API key.

If you wish to run against another chain (for example `testnet`), follow the instructions in the file, where you can find the necessary values to put for each supported chain.

### Checking out the right branch

The Econia DSS is developed on a [Rust-like train schedule](https://doc.rust-lang.org/book/appendix-07-nightly-rust.html):

- Experimental DSS features are merged directly to `main`.
- The latest stable DSS features are merged from `main` into the `dss-stable` branch.

Before you start working with the DSS, make sure you are on the right branch and have cloned submodules:

```bash
# From Econia repo root
git checkout dss-stable
git pull
git submodule update --init --recursive
```

### Running the DSS

:::tip

If you've run the DSS before and want a clean build, clear your Docker containers, image cache, and volumes:

```sh
docker ps -aq | xargs docker stop | xargs docker rm
docker system prune -af
docker volume prune -af
```

If you want to redeploy all the same images with a fresh database, just run `docker volume prune -af` to prune all Docker volumes.

:::

From the Econia repo root, run the following command:

```bash
docker compose --file src/docker/compose.dss-core.yaml up
```

This might take a while to start (expect anywhere from a couple minutes, to more, depending on the machine you have).

Then, to shut it down simply press `Ctrl+C`.

Alternatively, to run in detached mode (as a background process), simply add the `--detach` flag, then to temporarily stop it:

```bash
docker compose --file src/docker/compose.dss-core.yaml stop
```

To start it again, use:

```bash
docker compose --file src/docker/compose.dss-core.yaml start
```

Finally, to fully shut it down:

```bash
docker compose --file src/docker/compose.dss-core.yaml down
```

### Conducting a hot upgrade

If you'd like to upgrade your DSS to the latest version without having to backfill the entire database, you can conduct a "hot upgrade".
This process leverage's Docker compose' underlying capability to preserve database volumes across environment builds, so that you can recompile binaries without having to sync to chain tip for each new release.

:::note
The Econia Labs team strives to enable a hot upgrade for every DSS release (relative to the most recent release).
Occasionally, however, upstream changes (like breaking changes to the Aptos indexing framework) may require backfilling from Move package genesis.
See the [changelog](./changelog.md) to verify that the latest release supports a hot upgrade.
:::

1. Shut down the DSS

   ```bash
   docker compose --file src/docker/compose.dss-core.yaml down
   ```

1. Clean your Docker containers and image cache:

   ```bash
   docker system prune -af
   ```

   :::tip
   This is similar to starting a DSS from scratch, but it preserves the `db` volume.
   :::

1. Check out the latest stable DSS source code:

   ```bash
   git checkout dss-stable
   git pull
   git submodule update --init --recursive
   ```

1. Restart the DSS:

   ```bash
   docker compose --file src/docker/compose.dss-core.yaml build --no-cache
   docker compose --file src/docker/compose.dss-core.yaml up --force-recreate
   ```

### Verifying the DSS

Verify that the database is accessible by navigating your browser to `http://0.0.0.0:3000`.

Once the processor has parsed all transactions up until the chain tip, then check that individual tables are visible/contain data by navigating to:

- `http://0.0.0.0:3000/market_registration_events`
- `http://0.0.0.0:3000/cancel_order_events`
- `http://0.0.0.0:3000/fill_events`
- `http://0.0.0.0:3000/place_limit_order_events`
- `http://0.0.0.0:3000/balance_updates`

:::tip

It may take up to ten minutes before the `market_registration_events_table` has data in it on testnet, and several hours to fully sync to chain tip on both testnet and mainnet.

:::

To see what transaction the DSS processor has synced through, check the logs:

```sh
docker logs docker-processor-1 --tail 5
```

To verify the aggregator is running:

```sh
docker logs docker-aggregator-1 --tail 5
```

To connect directly to the database:

```sh
psql postgres://econia:econia@localhost:5432/econia
```

### Result

Great job!
You have successfully deployed Econia's DSS.
You can now query port 3000 to access the REST API and port 21883 to access the MQTT server.
