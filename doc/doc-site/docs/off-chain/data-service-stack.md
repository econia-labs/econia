# Data service stack

The Econia data service stack (DSS) is a collection of services that provide assorted data endpoints for integration purposes.
It exposes a REST API and a WebSocket server, and is composed of multiple services (database, API server, WebSocket server, indexer, …).
To make it easy to run, we have dockerized each service, and have created a Docker compose file to run everything easily.
On this page, we're going to see how to set everything up.

# How it works

We have a REST API and a WebSocket server.

The WebSocket server mainly notifies you of any events emitted by the contract.

The REST API also contains all the events emitted by the contract, as well as some processed data like order history and order book state.

In order to access the WebSocket server, you have to connect to the following URL: `ws://your-host/[JWT]` where `[JWT]` is a JWT.
To obtain said JWT, you can query the REST API at `http://your-host/rpc/jwt` with the HTTP method POST and `{"channels": […]}` as a payload, where `[…]` is a list of the names of the channels you want to receive notifications from.
Alternatively, you can generate the JWT by yourself (you can find the secret in the Docker compose file).
To get a list of the different channels, please see the [WebSocket server documentation](./websocket.md).

The REST API is actually a PostgREST instance.
You can find the REST API documentation [here](./rest-api.md).
You can learn more about how to query a PostgREST instance on their [official documentation](https://postgrest.org/en/stable/).

# Running

There are two ways of running the DSS: using a local chain or using a public chain like Aptos devnet, testnet, or mainnet.

For CI or development, we recommend running the DSS against a local chain.

For this walkthrough, we are going to use the official Aptos testnet.
The process the same as if you were going to run against mainnet, just with a slightly different config process.

## Getting the API key

Unless you are an infrastructure provider or want to run a fullnode yourself, the simplest way to get indexed transaction data is from the Aptos Labs gRPC endpoint (indexer V2 API).
To connect to this service, you'll need to get an API key [here](https://aptos-api-gateway-prod.firebaseapp.com/).

Once you have the API key, you'll need to create the processor configuration file.
A template can be found at `src/docker/processor/config-template-global.yaml`.
In the same folder as the template, create a copy of the file named `config.yaml`, then fill it as follows:

- health_check_port: `8085`
- server_config:
  - processor_config:
    - type: `econia_transaction_processor`.
    - econia_address: the testnet Econia address (`0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff`).
  - postgres_connection_string: `postgres://econia:econia@postgres/econia` if you are using the database which comes with the Docker compose file.
  - indexer_grpc_data_service_address: `https://grpc.testnet.aptoslabs.com:443` for testnet.
    See [the Aptos official documentation](https://aptos.dev/indexer/txn-stream/labs-hosted) for other networks.
  - indexer_grpc_http2_ping_interval_in_secs: `60`.
  - indexer_grpc_http2_ping_timeout_in_secs: `10`.
  - auth_token: the key you got earlier.
  - starting_version: where to start indexing.
    We recommend this to be the transaction Econia was deployed on, so that you don't miss any events which could lead to corrupted data (`649555969`).

## Updating the git submodules

Before starting the DSS, make sure to have the git submodules cloned.
If not, run the following command:

```bash
git submodule update --init --recursive
```

## Starting the DSS

Once you're done with the previous step, you can start the DSS.
In order to do so, you can run the following commands:

```bash
docker compose -f src/docker/compose.dss-global.yaml up -d # From inside econia repo root
```

This might take a while to start (expect anywhere from a couple minutes, to more, depending on the machine you have).

## Result

Great job!
You have successfully deployed Econia's DSS.
You can now query port 3001 to access the REST API and port 3000 to access the WebSocket server.
