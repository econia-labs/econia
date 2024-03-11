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

## MQTT protocol overview

Each MQTT message has a topic and a payload.

You can subscribe to topics.

When specifying the topic you want to subscribe to, you can put a + instead of a value to subscribe to all events matching the rest of the topic.

### Example:

We use the topic `fill/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`.
Fill events by the user `0xc0deface` with custodian ID 1 on market 3 will have `fill/3/0xc0deface/1` as a topic.
But you could subscribe to `fill/+/0xc0deface/+` to get all fill events from the user `0xc0deface`.

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

Note that if you subscribe to fill events for two different user/custodian ID combinations on the same market and they fill against eachother, you will recieve the same fill event notification twice, once on each channel.

## Example

You can find a Python example on how to use the MQTT protocol in `src/python/sdk/examples/event.py`.

First, run `poetry install` to install all the necessary dependencies.
Then, run `poetry run event` to start the example script.

