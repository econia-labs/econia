# Data service stack

The Econia data service stack (DSS) is a collection of services that provide assorted data endpoints for integration purposes.
It exposes a REST API and a WebSocket server, which are powered internally by an aggregator, a database, and an indexer.
To ensure composability, portability, and ease of use, each component is represented as a Docker service inside of a Docker compose environment.
For more on Docker, see [the official docs](https://docs.docker.com/).

This page will show you how to run the DSS locally.

## How it works

The DSS exposes a REST API and a WebSocket server.

The WebSocket server mainly provides notifications of any events emitted by the Econia Move package.

The REST API also provides all the events emitted by the Econia Move package., as well as aggregated data like order history and order book state.

In order to access the WebSocket server, connect to the following URL: `ws://your-host/[JWT]` where `[JWT]` is a JSON Web Token (JWT).
To get a JWT, query the REST API at `http://your-host/rpc/jwt` with the HTTP method `POST` and `{"channels": […]}` as a payload, where `[…]` is a list of the names of the channels you want to receive notifications for.
Alternatively, you can generate the JWT by yourself (you can find the secret in the Docker compose file under `src/docker`).
To get a list of the different channels, please see the [WebSocket server documentation](./websocket.md).

The REST API is actually a PostgREST instance.
You can find the REST API documentation [here](./rest-api.md).
You can learn more about how to query a PostgREST instance on their [official documentation](https://postgrest.org/en/stable/).

## Testnet walkthrough

There are two ways of running the DSS:

1. Against a local chain.
1. Against a public chain like Aptos devnet, testnet, or mainnet.

For continuous integration (CI) or development, running the DSS against a local chain is recommended.

This walkthrough will use the official Aptos testnet.
The process is the same as running against mainnet, just with a slightly different config process.

### Getting the API key

Unless you are an infrastructure provider or want to run a fullnode yourself, the simplest way to get indexed transaction data is from the Aptos Labs gRPC endpoint (indexer v2 API).
To connect to this service, you'll need to get an API key [here](https://aptos-api-gateway-prod.firebaseapp.com/).

Once you have the API key, you'll need to create the processor configuration file.
A template can be found at `src/docker/processor/config-template-global.yaml`.
In the same folder as the template, create a copy of the file named `config.yaml`, then fill it as follows:

- health_check_port: `8085`
- server_config:
  - processor_config:
    - type: `econia_transaction_processor`.
    - econia_address: the testnet Econia address (`0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff`).
  - postgres_connection_string: `postgres://econia:econia@postgres:5432/econia` if you are using the database which comes with the Docker compose file.
  - indexer_grpc_data_service_address: `https://grpc.testnet.aptoslabs.com:443` for testnet.
    See [the Aptos official documentation](https://aptos.dev/indexer/txn-stream/labs-hosted) for other networks.
  - indexer_grpc_http2_ping_interval_in_secs: `60`.
  - indexer_grpc_http2_ping_timeout_in_secs: `10`.
  - auth_token: the key you got earlier.
  - starting_version: where to start indexing.
    For this walkthrough, use the first transaction of the [Econia testnet account](../../welcome.md#account-addresses) (`649555969`), which is a prudent starting point that slightly precedes the publication of the Econia Move package on testnet.

:::warning

A `starting_version` that is too late will lead to missed events and corrupted data.

:::

### Updating the git submodules

Before starting the DSS, make sure to have the git submodules cloned.
If not, run the following command:

```bash
# From Econia repo root
git submodule init
git submodule update src/rust/dependencies/aptos-indexer-processors
```

### Starting the DSS

Once you're done with the previous step, you can start the DSS:

```bash
# From Econia repo root
docker compose --file src/docker/compose.dss-global.yaml up
```

This might take a while to start (expect anywhere from a couple minutes, to more, depending on the machine you have).

Then, to shut it down simply press `Ctrl+C`.

Alternatively, to run in detached mode (as a background process):

```bash
# From Econia repo root
docker compose --file src/docker/compose.dss-global.yaml up --detach
```

Then, to shut it down:

```bash
# From Econia repo root
docker compose --file src/docker/compose.dss-global.yaml down
```

:::tip
When switching chains, don't forget to prune the Docker database volume (`docker volume prune -af` to prune all Docker volumes).
:::

### Verifying the DSS

Verify that the database is accessible by navigating your browser to `http://0.0.0.0:3001`.

Once the processor has parsed all transactions up until the chain tip, then check that individual tables are visible/contain data by navigating to:

- `http://0.0.0.0:3001/market_registration_events`
- `http://0.0.0.0:3001/cancel_order_events`
- `http://0.0.0.0:3001/fill_events`
- `http://0.0.0.0:3001/place_limit_order_events`
- `http://0.0.0.0:3001/market_account_handles`

:::tip

It may take up to ten minutes before the `market_registration_events_table` has data in it.

To see what transaction the DSS processor has synced through, do not run in detached mode.

:::

### Result

Great job!
You have successfully deployed Econia's DSS.
You can now query port 3001 to access the REST API and port 3000 to access the WebSocket server.
