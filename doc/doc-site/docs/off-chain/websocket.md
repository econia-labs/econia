# WebSocket

Econia's DSS provides a WebSocket server for real-time notifications.

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

For each channel, the payload format is identical to the corresponding event format returned by the [DSS REST API](./rest-api.md).
For example, the payload of an event from the `fill_event` channel is identical to the event format returned by a REST API query for `localhost:3001/fill_events` (note that channel names have no `s` at the end but REST API endpoints do), except that WebSocket events are received one by one instead of in an array.

Hence, a return from the `fill_event` channel is of format:

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

In contrast, the format of a REST API query return for the `/fill_events` endpoint (if there was only one fill event in the database):

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
