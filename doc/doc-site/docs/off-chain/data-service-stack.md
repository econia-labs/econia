# Data service stack

The data service stack (DSS), is a group of programs that power the Econia off-chain products.
It exposes a REST API and a WebSocket server, and is composed of multiple services (database, API server, WebSocket server, indexer, …).
To make it easy to run, we have dockerized each service, and have created a Docker compose file to run everything easily.
On this page, we're going to see how to set everything up.

# How it works

We have a REST API and a WebSocket server.

The WebSocket server mainly notifies you of any events emitted by the contract.

The REST API also contains all the events emitted by the contract, as well as some processed data, like order history, order book state, …

In order to access the WebSocket server, you have to connect to the following URL: `ws://your-host/[JWT]` where `[JWT]` is a JWT.
To obtain said JWT, you need to query the REST API (or you can manually generate it, you can find the secret in the Docker compose file).
Querying the REST API at `http://your-host/rpc/jwt`) with the HTTP method POST and `{"channels": […]}` as a payload, where `[…]` is a list of the names of the channels you want to receive notifications from.
To get a list of the different channels, please see the [WebSocket server documentation](./websocket.md).

The REST API is actually a PostgREST instance.
You can find the REST API documentation [here](./rest-api.md).
You can learn more about how to query a PostgREST instance on their [official documentation](https://postgrest.org/en/stable/).

# Running

There are two ways of running the DSS: using a local chain or using testnet/mainnet/devnet.

For CI or development, we recommend running the DSS against a local chain.
This is in the process of being integrated into the Docker compose file, but is not yet available.

We are going to use the official Aptos testnet.
The process is the same if you were to run it against mainnet.

## Getting the API key

In order to index events, you used to need to run a full node.
This can be quite hard considering the processing and storage needs this represents.
Thankfully, Aptos has recently exposed an API which can be queried for events and avoids you having to run a full node.
To use the latter, you'll need to get an API key [here](https://aptos-api-gateway-prod.firebaseapp.com/).

Once you have the API key, you'll need to create the processor configuration file. A template can be found at `src/docker/processor/config-template.yaml`. Copy this (in the same folder) as `config.yaml`. Here is how to fill it:

- health_check_port: `8085`
- server_config:
  - processor_name: `econia_processor`.
  - postgres_connection_string: `postgres://econia:econia@postgres/econia` if you are using the database which comes with the Docker compose file.
  - indexer_grpc_data_service_address: `grpc.testnet.aptoslabs.com:443` for testnet.
    See [the Aptos official documentation](https://aptos.dev/indexer/txn-stream/labs-hosted) for other networks.
  - indexer_grpc_http2_ping_interval_in_secs: `60`.
  - indexer_grpc_http2_ping_timeout_in_secs: `10`.
  - auth_token: the key you got earlier.
  - econia_address: the testnet Econia address (`0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff`).
  - starting_version: where to start indexing.
    We recommend this to be the transaction Econia was deployed on, so that you don't miss any events which could lead to corrupted data.

## Starting the DSS

Once you're done with the previous step, you can start the DSS.
In order to do so, you can run the following commands:

```bash
cd src/docker
docker compose -f compose.dss-local.yaml up -d
```

This might take a while to start (expect anywhere from a couple minutes, to more, depending on the machine you have).

## Result

Great job !
You have successfully deployed Econia's DSS.
You can now query port 3001 to access the REST API and port 3000 to access the WebSocket server.
