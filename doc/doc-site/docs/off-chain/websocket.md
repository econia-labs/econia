# WebSocket

The documentation of the WebSocket server from Econia's DSS.

## Format

There is a general format for all WebSocket messages which is the following:

```json
{
  "channel": "",
  "payload": {

  }
}
```

`channel` indicates from which channel the message comes, and `payload` contains the message's data.

## Channels

There is a channel per event type.

Here is the list of all channels:

- `market_registration_event`
- `place_limit_order_event`
- `place_market_order_event`
- `place_swap_order_event`
- `fill_event`
- `change_order_size_event`
- `cancel_order_event`

For each channel, the payload will be the same as you would get by querying this event from the REST API.
For example, the payload of an event coming from the `fill_event` channel will be the exact same as the data you get by querying `localhost:3001/fill_events` (note that channel names have no `s` at the end where as REST API endpoints do), except that you get them one by one (not in an array).

Just to illustrate what has been said above, here is what you would get from the `fill_event` channel:

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

And here is what you would get from the `/fill_events` endpoint (if there was only this fill event in the database):

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

Note the `[` and the `]`.
