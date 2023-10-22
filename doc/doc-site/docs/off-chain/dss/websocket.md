# WebSockets

Econia's [DSS](./data-service-stack.md) provides a WebSocket server for real-time notifications.

## Format

The WebSocket server uses a general format for all WebSocket messages:

```json
{
  "channel": "",
  "payload": {

  }
}
```

- `channel` indicates which channel the message comes from.
- `payload` contains the message's data.

## Channels

Each event type has a its own channel.

Channels include:

- `market_registration_event`
- `place_limit_order_event`
- `place_market_order_event`
- `place_swap_order_event`
- `fill_event`
- `change_order_size_event`
- `cancel_order_event`
- `recognized_market_event`
- `new_limit_order`
- `updated_limit_order`
- `new_market_order`
- `new_swap_order`

For each channel, the payload format is identical to the corresponding event format returned by the [DSS REST API](./rest-api.md).
For example, the payload of an event from the `fill_event` channel is identical to the event format returned by a REST API query for `localhost:3000/fill_events` (note that channel names have no `s` at the end but REST API endpoints do), except that WebSocket events are received one by one instead of in an array.

Note that `new_{limit,market,swap}_order` and `updated_limit_order` correspond to `{limit,market,swap}_orders`.
`new_*` channels will send a message each time an order is placed.
The `updated_limit_order` channel will send a message each time an order is updated (size changed, filled, etc).

Hence the format of an event payload from the `fill_event` channel:

```json
{
  "txn_version": 0,
  "event_idx": 0,
  "emit_address": "0x1",
  "time": "1970-01-01T00:00:00.000000+00:00",
  "maker_address": "0x1",
  "maker_custodian_id": 0,
  "maker_order_id": 0,
  "maker_side": true,
  "market_id": 0,
  "price": 0,
  "sequence_number_for_trade": 0,
  "size": 0,
  "taker_address": "0x1",
  "taker_custodian_id": 0,
  "taker_order_id": 0,
  "taker_quote_fees_paid": 0
}
```

In contrast, the response of a REST API query for the `/fill_events` endpoint (assuming only one fill event in the database):

```json
[{
  "txn_version": 0,
  "event_idx": 0,
  "emit_address": "0x1",
  "time": "1970-01-01T00:00:00.000000+00:00",
  "maker_address": "0x1",
  "maker_custodian_id": 0,
  "maker_order_id": 0,
  "maker_side": true,
  "market_id": 0,
  "price": 0,
  "sequence_number_for_trade": 0,
  "size": 0,
  "taker_address": "0x1",
  "taker_custodian_id": 0,
  "taker_order_id": 0,
  "taker_quote_fees_paid": 0
}]
```

Note the `[` and the `]`, constituting an array.

## Example

The Econia repository contains a Docker compose environment for running a DSS against a local testnet.
This compose environment is designed for end-to-end testing, and can be used for monitoring WebSockets notifications via the [`event.py`](https://github.com/econia-labs/econia/blob/main/src/python/sdk/examples/event.py) example script.
In order to run the example script, you'll need to install [Poetry](https://python-poetry.org/docs/).

If you'd like to run the example script against the end-to-end Docker compose environment, first initialize the environment according to the steps [here](https://github.com/econia-labs/econia/blob/main/src/docker/README.md).
Then once the compose environment is running, open up a new terminal and run the following:

```sh
# From Econia repo root
cd src/python/sdk
poetry install
poetry run event
```

:::note
In preparation for the testnet trading competition during 2023-10-25T00:00/2023-11-01T00:00Z, JWT support has been removed from the REST API because the required extension is unavailable on Google Cloud Platform, such that database migrations had to be refactored in a way that prevented JWT generation through the `PostgREST` service.
You can still manually generate a JWT yourself, though, noting the following plaintext environment variable for the `postgrest-websockets` service:

```yaml
- PGWS_JWT_SECRET=econia_0000000000000000000000000
```

Stand by for a resolution, including explicit instructions on JWT generation.
:::

Enter nothing for all of the prompts to use the default local configuration.

Now you can perform actions on the locally-deployed exchange to trigger events, or run the `trade.py` script:

```sh
# From Econia repo root, new terminal
cd src/python/sdk
poetry run trade
```

Enter nothing for all of the prompts to use the default local configuration.

As you run through the assorted sections in the trading script, you should see fill events coming in over the WebSockets channel.
