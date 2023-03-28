# WebSocket API docs

Work in progress.

## Ping

The client sends ping messages in the following format.

```json
{
    "method": "ping"
}
```

The WebSocket API server will respond with

```json
{
    "event": "pong"
}
```

The client should send ping messages at least once an hour. If it has been more than one hour since the client last sent a ping message, the API will terminate the connection.

## Orders channel

### Subscribe

The client subscribes to an orders channel by sending the following message. User address and market ID must be specified as parameters.

```json
{
    "method": "subscribe",
    "channel": "orders",
    "params": {
        "market_id": 0,
        "user_address": "0x1"
    }
}
```

The WebSocket API server will respond with the following message.

```json
{
    "event": "confirm",
    "method": "subscribe",
    "channel": "orders",
    "params": {
        "market_id": 0,
        "user_address": "0x1"
    }
}

```

Then, when there are order updates on the specified market for this user, the WebSocket API will send messages such as this one.

```json
{
    "event": "update",
    "channel": "orders",
    "data": {
        "market_order_id": 1,
        "market_id": 0,
        "side": "ask",
        "size": 1000,
        "price": 1000,
        "user_address": "0x1",
        "custodian_id": null,
        "order_state": "open",
        "created_at": "2023-03-01T12:34:56.000000Z"
    }
}
```

If the client is already subscribed to the channel, an error message is returned.

```json
{
    "event": "error",
    "message": "already subscribed to channel `{\"channel\":\"orders\",\"params\":{\"market_id\":0,\"user_address\":\"0x1\"}}`"
}
```

The client can repeat this process to subscribe to any number of orderbook/user address combinations.

### Unsubscribe

To unsubscribe from an orders channel, the client sends the following message.

```json
{
    "method": "unsubscribe",
    "channel": "orders",
    "params": {
        "market_id": 0,
        "user_address": "0x1"
    }
}
```

Then, the API will return a confirmation message.

```json
{
    "event": "confirm",
    "method": "unsubscribe"
    "channel": "orders",
    "params": {
        "market_id": 0,
        "user_address": "0x1"
    },
    
}
```

If the user is not subscribed to the channel the WebSocket API received an unsubscribe message for, the following error message is returned.

```json
{
    "event": "error",
    "message": "not subscribed to channel `{\"channel\":\"orders\",\"params\":{\"market_id\":0,\"user_address\":\"0x1\"}}`"
}
```

## Fills channel

TODO

## Tickers channel

TODO
