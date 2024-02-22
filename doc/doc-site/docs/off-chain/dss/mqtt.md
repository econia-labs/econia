# MQTT

Econia's [DSS](./data-service-stack.md) provides an MQTT server for real-time notifications.
It uses Mosquitto as the MQTT server, and a custom Rust program to publish PostgreSQL events to MQTT.

By default, the MQTT server runs on port 21883.

All messages sent on all topics are in JSON format.

There are multiple available MQTT libraries across a wide variety of languages:

- [mqtt.js](https://github.com/mqttjs/MQTT.js) for JavaScript/TypeScript
- [rumqtt](https://github.com/bytebeamio/rumqtt) for Rust
- [paho.mqtt.python](https://github.com/eclipse/paho.mqtt.python) for Python
- many more [here](https://github.com/eclipse?q=paho.mqtt)

## Topics

### PlaceLimitOrderEvents

`place_limit_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID/INTEGRATOR`

The JSON format for this message is the same as the REST API `/place_limit_order_events` endpoint.

### PlaceMarketOrderEvents

`place_market_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID/INTEGRATOR`

The JSON format for this message is the same as the REST API `/place_market_order_events` endpoint.

### PlaceSwapOrderEvents

`place_swap_order/MARKET_ID/INTEGRATOR/SIGNING_ACCOUNT`

The JSON format for this message is the same as the REST API `/place_swap_order_events` endpoint.

### ChangeOrderSizeEvents

`change_order_size/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API `/change_order_size_events` endpoint.

### CancelOrderEvents

`cancel_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API `/cancel_order_events` endpoint.

### FillEvents

`fill/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API `/fill_events` endpoint.

Note that this event is emitted twice: once for the maker, and once for the taker.
This means that you will get this event no matter what if you're subscribed to the maker or taker, but you will receive it twice if you're subscribed to both.
You can detect if you got a duplicate by using the `txn_version` and the `event_idx` fields, which in conjuctions, are a unique identifier of the event.

