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

### Price levels

`levels/MARKET_ID/DIRECTION/LEVEL`

Here, `DIRECTION` is either `ask` or `bid`, and `LEVEL` is the level of the price level (level 1 is the best ask/bid, level 2 is the second best, etc.).

Levels go up to 10.

Tip: You can subscribe to `levels/MARKET_ID/#` or `levels/MARKET_ID/+/+` to subscribe to all price levels events for a market.

A payload for this event looks like this:

```json
{
  "price": 12345,
  "size": 12345
}
```

### PlaceLimitOrderEvents

`place_limit_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID/INTEGRATOR`

The JSON format for this message is the same as the REST API [`/place_limit_order_events` endpoint](./rest-api#tag/place_limit_order_events).

### PlaceMarketOrderEvents

`place_market_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID/INTEGRATOR`

The JSON format for this message is the same as the REST API [`/place_market_order_events` endpoint](./rest-api#tag/place_market_order_events).

### PlaceSwapOrderEvents

`place_swap_order/MARKET_ID/INTEGRATOR/SIGNING_ACCOUNT`

The JSON format for this message is the same as the REST API [`/place_swap_order_events` endpoint](./rest-api#tag/place_swap_order_events).

### ChangeOrderSizeEvents

`change_order_size/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API [`/change_order_size_events` endpoint](./rest-api#tag/change_order_size_events).

### CancelOrderEvents

`cancel_order/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API [`/cancel_order_events` endpoint](./rest-api#tag/cancel_order_events).

### FillEvents

`fill/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID`

The JSON format for this message is the same as the REST API [`/fill_events` endpoint](./rest-api#tag/fill_events).

Note that if you subscribe to fill events for two different user/custodian ID combinations on the same market and they fill against each other, you will receive the same fill event notification twice, once on each channel.

## Example

The Econia repository contains a Docker compose environment for running a DSS against a local testnet.
This compose environment is designed for end-to-end testing, and can be used for monitoring MQTT notifications via the event.py example script.
In order to run the example script, you'll need to install Poetry.

If you'd like to run the example script against the end-to-end Docker compose environment, first initialize the environment according to the steps [here](https://github.com/econia-labs/econia/blob/main/src/docker/README.md).
Then once the compose environment is running, open up a new terminal and run the following:

```bash
# From Econia repo root
cd src/python/sdk
poetry install
poetry run event
```

Enter nothing for all of the prompts to use the default local configuration.

Now you can perform actions on the locally-deployed exchange to trigger events, or run the trade.py script:

```bash
# From Econia repo root, new terminal
cd src/python/sdk
poetry run trade
```

Enter nothing for all of the prompts to use the default local configuration.

As you run through the assorted sections in the trading script, you should see fill events coming in over the MQTT channel.
