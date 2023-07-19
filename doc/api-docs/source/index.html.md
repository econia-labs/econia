---
title: Econia API Reference

language_tabs:
  - shell
  - python
  - javascript

search: true

code_clipboard: true

meta:
  - name: description
    content: Econia REST API documentation
---

# Introduction

This is the documentation for Econia's REST API.

For details on Econia's smart contract, please check out the developer documentation
site available <a href="https://econia.dev/" target="_blank" rel="noreferrer">here</a>.

# REST API

## Overview

The dev version of the REST API is available at `https://dev.api.econia.exchange`.

No authentication is required to access any of the endpoints on the REST API,
since all data accessible through this API is also publicly available on the
Aptos blockchain.

APIs to interact with our smart contract deployments on testnet and mainnet will be available soon.

<aside class="notice">
The API is still under active development, and we may introduce breaking changes.
Note that currently, the API returns mock data and is not connected to any
smart contract deployment.
</aside>

## Get markets

Get information about all markets registered on Econia.

```shell
curl "https://dev.api.econia.exchange/markets"
```

```python
import requests

res = requests.get(f"https://dev.api.econia.exchange/markets")
data = res.json()

print(data)
```

```javascript
async function main() {
  const res = await fetch("https://dev.api.econia.exchange/markets");
  const data = await res.json();
  console.log(data);
}
main();
```

> The above command returns JSON structured like this:

```json
[
  {
    "market_id": 1,
    "name": "APT-tUSDC",
    "base": {
      "account_address": "0x1",
      "module_name": "aptos_coin",
      "struct_name": "AptosCoin",
      "symbol": "APT",
      "name": "Aptos Coin",
      "decimals": 8
    },
    "base_name_generic": null,
    "quote": {
      "account_address": "0x0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf9422",
      "module_name": "test_usdc",
      "struct_name": "TestUSDCoin",
      "symbol": "tUSDC",
      "name": "Test USDC",
      "decimals": 6
    },
    "lot_size": 1000,
    "tick_size": 1000,
    "min_size": 1000,
    "underwriter_id": 0,
    "created_at": "2023-05-01T12:34:56.789012Z"
  },
  {
    "market_id": 2,
    "name": "APT-PERP",
    "base": null,
    "base_name_generic": "APT-PERP",
    "quote": {
      "account_address": "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
      "module_name": "test_usdc",
      "struct_name": "TestUSDCoin",
      "symbol": "tUSDC",
      "name": "Test USDC",
      "decimals": 6
    },
    "lot_size": 1000,
    "tick_size": 1000,
    "min_size": 1000,
    "underwriter_id": 0,
    "created_at": "2023-05-01T12:34:56.789012Z"
  }
]

```

### HTTP Request

`GET /markets`

### Parameters

None

### Notes

A market either have a base asset, or be a generic market. If the market has a
base asset, the `base` field fill be populated, and the `base_name_generic` field
will be `null`. If the market is a generic market, the `base` field will be `null`,
and the `base_name_generic` field will be a string.

For more information on base asset markets and generic markets, refer to the
documentation <a href="https://econia.dev/overview/registry/" target="_blank" rel="noreferrer">here</a>.

## Get markets by ID

Get information about a specific market.

```shell
curl "https://dev.api.econia.exchange/markets/1"
```

```python
import requests

market_id = 1
res = requests.get(f"https://dev.api.econia.exchange/markets/{market_id}")
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const res = await fetch(`https://dev.api.econia.exchange/markets/${marketId}`);
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
{
  "market_id": 1,
  "name": "APT-tUSDC",
  "base": {
    "account_address": "0x1",
    "module_name": "aptos_coin",
    "struct_name": "AptosCoin",
    "symbol": "APT",
    "name": "Aptos Coin",
    "decimals": 8
  },
  "base_name_generic": null,
  "quote": {
    "account_address": "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
    "module_name": "test_usdc",
    "struct_name": "TestUSDCoin",
    "symbol": "tUSDC",
    "name": "Test USDC",
    "decimals": 6
  },
  "lot_size": 1000,
  "tick_size": 1000,
  "min_size": 1000,
  "underwriter_id": 0,
  "created_at": "2023-05-01T12:34:56.789012Z"
}
```

### HTTP Request

`GET /markets/:market_id`

### Path Parameters

| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| market_id | u64  | The ID of the market to retrieve |

### Errors

| Error Code | Description                                             |
| ---------- | ------------------------------------------------------- |
| 400        | Bad Request: the provided market ID was not a valid u64 |
| 404        | Not Found: no market with the specified ID was found    |

## Get orderbook

Get the current orderbook for a particular market. The response will include
prices for each level on the orderbook, and the total size of the orders
available at that price.

```shell
curl "https://dev.api.econia.exchange/markets/1/orderbook?depth=1"
```

```python
import requests

market_id = 1
params = {"depth": 1}

res = requests.get(
    f"https://dev.api.econia.exchange/markets/{market_id}/orderbook", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const params = new URLSearchParams({ depth: 1 });
  const res = await fetch(
    `https://dev.api.econia.exchange/markets/${marketId}/orderbook?${params}`
  );
  const data = await res.json();
  console.log(data);
}
main();

```

> The above request returns JSON structured like this:

```json
{
  "bids": [
    {
      "price": 1000,
      "size": 1000
    }
  ],
  "asks": [
    {
      "price": 2000,
      "size": 1000
    }
  ]
}
```

### HTTP Request

`GET /markets/:market_id/orderbook`

### Path Parameters

| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| market_id | u64  | The ID of the market to retrieve |

### Query Parameters

| Parameter | Type | Description                                |
| --------- | ---- | ------------------------------------------ |
| depth     | u32  | The number of orderbook levels to retrieve |

### Errors

| Error Code | Description                                          |
| ---------- | ---------------------------------------------------- |
| 400        | Bad Request: invalid parameters                      |
| 404        | Not Found: no market with the specified ID was found |

The depth parameter must be a number greater than or equal to 1.

## Get market history

Get the market history for a particular market. The response will include the
open, high, low, and close prices for each interval, as well as the total volume
for that interval.

```shell
curl -G "https://dev.api.econia.exchange/markets/1/history" \
  -d resolution=1m \
  -d from=1683018300 \
  -d to=1683024240
```

```python
import requests

market_id = 1
params = {
    "resolution": "1m",
    "from": 1683018300,
    "to": 1683024240,
}

res = requests.get(
    f"https://dev.api.econia.exchange/markets/{market_id}/history", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const params = new URLSearchParams({
    resolution: "1m",
    from: 1683018300,
    to: 1683024240,
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/markets/${marketId}/history?${params}`
  );
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
[
  {
    "start_time": "2023-05-02T09:05:00Z",
    "open": 2000,
    "high": 4000,
    "low": 1000,
    "close": 3000,
    "volume": 1000
  },
  {
    "start_time": "2023-05-02T09:06:00Z",
    "open": 3000,
    "high": 5000,
    "low": 2000,
    "close": 4000,
    "volume": 1000
  }
]
```

### HTTP Request

`GET /markets/:market_id/orderbook`

### Path Parameters

| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| market_id | u64  | The ID of the market to retrieve |

### Query Parameters

| Parameter  | Type | Description                                                                                    |
| ---------- | ---- | ---------------------------------------------------------------------------------------------- |
| resolution | enum | The resolution of the requested historical data. Accepted values are 1m, 5m, 15m, 30m, and 1h. |
| from       | i64  | Unix timestamp (in seconds) for the start of the requested time range                          |
| to         | i64  | Unix timestamp (in seconds) for the end of the requested time range                            |

### Errors

| Error Code | Description                                          |
| ---------- | ---------------------------------------------------- |
| 400        | Bad Request: invalid parameters                      |
| 404        | Not Found: no market with the specified ID was found |

The resolution parameter must be one of the options listed above. Additionally,
the `to` and `from` timestamps must be valid Unix timestamps denoted in seconds,
and the `from` timestamp must come before the `to` timestamp.

## Get market fills

Get the fills for a particular market.

```shell
curl -G "https://dev.api.econia.exchange/markets/1/fills" \
  -d from=1682944490 \
  -d to=1682944500
```

```python
import requests

market_id = 1
params = {
    "from": 1682944490,
    "to": 1682944500,
}

res = requests.get(
    f"https://dev.api.econia.exchange/markets/{market_id}/fills", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const params = new URLSearchParams({
    from: 1682944490,
    to: 1682944500,
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/markets/${marketId}/fills?${params}`
  );
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
[
  {
    "market_id": 1,
    "maker_order_id": 0,
    "maker": "0x3",
    "maker_side": "buy",
    "custodian_id": null,
    "size": 1000,
    "price": 1000,
    "time": "2023-05-01T12:34:56.789012Z"
  }
]
```

### HTTP Request

`GET /markets/:market_id/fills`

### Path Parameters

| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| market_id | u64  | The ID of the market to retrieve |

### Query Parameters

| Parameter | Type | Description                                                           |
| --------- | ---- | --------------------------------------------------------------------- |
| from      | i64  | Unix timestamp (in seconds) for the start of the requested time range |
| to        | i64  | Unix timestamp (in seconds) for the end of the requested time range   |

### Errors

| Error Code | Description                                          |
| ---------- | ---------------------------------------------------- |
| 400        | Bad Request: invalid parameters                      |
| 404        | Not Found: no market with the specified ID was found |

The `to` and `from` timestamps must be valid Unix timestamps denoted in seconds,
and the `from` timestamp must come before the `to` timestamp.

## Get order status

Get the status for an individual order.

```shell
curl -G "https://dev.api.econia.exchange/markets/1/order/100"
```

```python
import requests

market_id = 1
market_order_id = 100

res = requests.get(
    f"https://dev.api.econia.exchange/markets/{market_id}/order/{market_order_id}")
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const marketOrderId = 100;

  const res = await fetch(
    `https://dev.api.econia.exchange/markets/${marketId}/order/${marketOrderId}`
  );
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
{
  "market_order_id": 100,
  "market_id": 1,
  "side": "ask",
  "size": 1000,
  "price": 2000,
  "user_address": "0x1",
  "custodian_id": null,
  "order_state": "open",
  "created_at": "2023-05-01T12:34:56.789012Z"
}
```

### HTTP Request

`GET /markets/:market_id/order/:market_order_id`

### Path Parameters

| Parameter       | Type | Description                      |
| --------------- | ---- | -------------------------------- |
| market_id       | u64  | The ID of the market to retrieve |
| market_order_id | u64  | The ID of the order to retrieve  |

### Errors

| Error Code | Description                                          |
| ---------- | ---------------------------------------------------- |
| 400        | Bad Request: invalid parameters                      |
| 404        | Not Found: no order with the specified ID was found |

## Get stats

Get stats for all available markets. The stats returned are the open, high, low,
and close prices and volume for the time range specified, and the price change
percentage between the start of the time range and the current time.

```shell
curl "https://dev.api.econia.exchange/stats?resolution=1d"
```

```python
import requests

params = {
    "resolution": "1d",
}

res = requests.get(
    "https://dev.api.econia.exchange/stats", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const params = new URLSearchParams({
    resolution: "1d",
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/stats?${params}`
  );
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
[
  {
    "market_id": 1,
    "open": 30891,
    "high": 39427,
    "low": 30380,
    "close": 34009,
    "change": 0.10093555,
    "volume": 116906256
  },
  {
    "market_id": 2,
    "open": 30891,
    "high": 36681,
    "low": 28596,
    "close": 34009,
    "change": 0.10093555,
    "volume": 112806240
  }
]
```

### HTTP Request

`GET /stats`

### Query Parameters

| Parameter  | Type | Description                                                                          |
| ---------- | ---- | ------------------------------------------------------------------------------------ |
| resolution | enum | The resolution of the requested stats. Accepted values are 1m, 5m, 15m, 30m, and 1h. |

### Errors

| Error Code | Description                     |
| ---------- | ------------------------------- |
| 400        | Bad Request: invalid parameters |

### Notes

The time range used by this endpoint will differ from the ones used by the market
history endpoint. The market history endpoint bars will always be mapped to
predetermined start and end timestamps, but this endpoint will return data up to
the current time, and the start time is calculated using the provided resolution.

For example, if the resolution given is `1h`, all intervals given by the market
history endpoint will start on the hour, but the stats parameter will simply
use the current time as the end time.

The volume is given in amounts of the base currency for the market, and corresponds
to the total volume given by the size field in the fill events of the smart contract.

The change field is given in decimals, so a value of `1.2345` would indicate a
123.45% price increase.

## Get stats by id

Get stats for a specific market.

```shell
curl "https://dev.api.econia.exchange/markets/1/stats?resolution=1d"
```

```python
import requests

market_id = 1
params = {
    "resolution": "1d",
}

res = requests.get(
    f"https://dev.api.econia.exchange/markets/{market_id}/stats", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 1;
  const params = new URLSearchParams({
    resolution: "1d",
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/markets/${marketId}/stats?${params}`
  );
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
{
  "market_id": 1,
  "open": 30891,
  "high": 39427,
  "low": 30380,
  "close": 34009,
  "change": 0.10093555,
  "volume": 116906256
}
```

### HTTP Request

`GET /markets/:market_id/stats`

### Path Parameters

| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| market_id | u64  | The ID of the market to retrieve |

### Query Parameters

| Parameter  | Type | Description                                                                          |
| ---------- | ---- | ------------------------------------------------------------------------------------ |
| resolution | enum | The resolution of the requested stats. Accepted values are 1m, 5m, 15m, 30m, and 1h. |

### Errors

| Error Code | Description                                          |
| ---------- | ---------------------------------------------------- |
| 400        | Bad Request: invalid parameters                      |
| 404        | Not Found: no market with the specified ID was found |

## Get open orders

Get open orders for a particular account.

```shell
curl "https://dev.api.econia.exchange/account/0x1/open-orders"
```

```python
import requests

account_address = "0x1"

res = requests.get(
    f"https://dev.api.econia.exchange/account/{account_address}/open-orders")
data = res.json()

print(data)
```

```javascript
async function main() {
  const accountAddress = "0x1";
  const res = await fetch(
    `https://dev.api.econia.exchange/account/${accountAddress}/open-orders`
  );
  const data = await res.json();
  console.log(data);
}
main();

```

> The above request returns JSON structured like this:

```json
[
  {
    "market_order_id": 100,
    "market_id": 1,
    "side": "bid",
    "size": 1000,
    "price": 1000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "open",
    "created_at": "2023-05-01T12:34:56.789012Z"
  },
  {
    "market_order_id": 101,
    "market_id": 1,
    "side": "ask",
    "size": 1000,
    "price": 2000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "open",
    "created_at": "2023-05-01T12:34:56.789012Z"
  }
]
```

### HTTP Request

`GET /account/:account_address/open-orders`

### Path Parameters

| Parameter       | Type   | Description                                       |
| --------------- | ------ | ------------------------------------------------- |
| account_address | String | The ID of the account to retrieve open orders for |

### Query Parameters

| Parameter       | Type           | Description                                  |
| --------------- | -------------- | -------------------------------------------- |
| limit           | u32 (optional) | The number of orders to retrieve             |
| offset          | u32 (optional) | The position to start retrieving record from |

### Errors

| Error Code | Description                                           |
| ---------- | ----------------------------------------------------- |
| 400        | Bad Request: invalid parameters                       |
| 404        | Not Found: no account with the specified ID was found |

### Notes

- Open orders are sorted by the `created_at` timestamp, starting from the most
  recent order.
- Offset is zero-based, so in order to retrieve orders starting at the second
  most recent order, send a request with `offset` set to `1`.
- Both `limit` and `offset` are optional parameters, and it is possible to set
  one without the other.
- When a request is sent without a `limit` query parameter, the endpoint returns all open orders under the
  specified account. When `offset` is not set, the results start at the most recent order.

## Get order history

Get the order history for a particular account.

```shell
curl "https://dev.api.econia.exchange/account/0x1/order-history"
```

```python
import requests

account_address = "0x1"

res = requests.get(
    f"https://dev.api.econia.exchange/account/{account_address}/order-history")
data = res.json()

print(data)
```

```javascript
async function main() {
  const accountAddress = "0x1";
  const res = await fetch(
    `https://dev.api.econia.exchange/account/${accountAddress}/order-history`
  );
  const data = await res.json();
  console.log(data);
}
main();

```

> The above request returns JSON structured like this:

```json
[
  {
    "market_order_id": 100,
    "market_id": 1,
    "side": "bid",
    "size": 1000,
    "price": 1000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "filled",
    "created_at": "2023-04-30T12:34:56.789012Z"
  },
  {
    "market_order_id": 101,
    "market_id": 1,
    "side": "ask",
    "size": 1000,
    "price": 2000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "open",
    "created_at": "2023-05-01T12:34:56.789012Z"
  }
]
```

### HTTP Request

`GET /account/:account_address/order-history`

### Path Parameters

| Parameter       | Type   | Description                                         |
| --------------- | ------ | --------------------------------------------------- |
| account_address | String | The ID of the account to retrieve order history for |

### Query Parameters

| Parameter       | Type           | Description                                  |
| --------------- | -------------- | -------------------------------------------- |
| limit           | u32 (optional) | The number of orders to retrieve             |
| offset          | u32 (optional) | The position to start retrieving record from |

### Errors

| Error Code | Description                                           |
| ---------- | ----------------------------------------------------- |
| 400        | Bad Request: invalid parameters                       |
| 404        | Not Found: no account with the specified ID was found |

### Notes

- Orders are sorted by the `created_at` timestamp, starting from the most
  recent order.
- Offset is zero-based, so in order to retrieve orders starting at the second
  most recent order, send a request with `offset` set to `1`.
- Both `limit` and `offset` are optional parameters, and it is possible to set
  one without the other.
- When a request is sent without a `limit` query parameter, the endpoint returns
  the complete order history under the specified account. When `offset` is not set,
  the results start at the most recent order.

## Get fills by account and market

Get fills for a particular account and market.

```shell
curl "https://dev.api.econia.exchange/account/0x1/markets/1/fills"
```

```python
import requests

account_address = "0x1"
market_id = 1

res = requests.get(
    f"https://dev.api.econia.exchange/account/{account_address}/markets/{market_id}/fills")
data = res.json()

print(data)
```

```javascript
async function main() {
  const accountAddress = "0x1";
  const marketId = 1;
  const res = await fetch(
    `https://dev.api.econia.exchange/account/${accountAddress}/markets/${marketId}/fills`
  );
  const data = await res.json();
  console.log(data);
}
main();

```

> The above request returns JSON structured like this:

```json
[
  {
    "market_id": 1,
    "maker_order_id": 100,
    "maker": "0x3",
    "maker_side": "buy",
    "custodian_id": null,
    "size": 1000,
    "price": 1000,
    "time": "2023-05-01T12:34:56.789012Z"
  }
]
```

### HTTP Request

`GET /account/:account_address/markets/:market_id/fills`

### Path Parameters

| Parameter       | Type   | Description                                         |
| --------------- | ------ | --------------------------------------------------- |
| account_address | String | The ID of the account to retrieve order history for |
| market_id       | u64    | The ID of the market to retrieve                    |

### Errors

| Error Code | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| 400        | Bad Request: invalid parameters                                 |
| 404        | Not Found: no account or market with the specified ID was found |

# WebSocket API

## Overview

The dev version of the API is available at `wss://dev.api.econia.exchange/ws`.

## Ping

```json
{
  "method": "ping"
}
```

> The above request returns JSON structured like this:

```json
{
  "event": "pong"
}
```

When the client sends a ping message, the server will respond with a pong message.

The client must send a ping message to the WebSocket API server at least once an
hour. When more than an hour elapses without a ping message, the server will close
the connection.

## Orders

```json
{
  "method": "subscribe",
  "channel": "orders",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

> The above request returns JSON structured like this:

```json
{
  "event": "confirm",
  "channel": "orders",
  "method": "subscribe",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

> After a subscription is successfully initiated, the server returns JSON
> structured like this for every update.

```json
{
  "event": "update",
  "channel": "orders",
  "data": {
    "market_order_id": 1,
    "market_id": 1,
    "side": "bid",
    "size": 1000,
    "price": 1000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "open",
    "created_at": "2023-05-01T12:34:56.789012Z"
  }
}
```

> If the parameters provided are invalid, the request returns JSON structured
> like this:

```json
{
  "event": "error",
  "message": "market with id `100` not found"
}
```

> To unsubscribe, the user may send JSON structured like this:

```json
{
  "method": "unsubscribe",
  "channel": "orders",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

The client can subscribe to the orders channel to receive updates on orders for
a specific market and user address. Once a subscription has been confirmed, the
client will receive updates when orders are placed, closed, cancelled, or evicted.

Note that this channel will not provide updates for every fill made to an order.
To receive those updates, the client must subscribe to the fills channel.

The client may subscribe to any number of market ID / user address combinations.
If the client attempts to subscribe to a market ID / user address combination they
are already subscribed to, the WebSocket API will send an error message notifying
them that this is the case.

## Fills

```json
{
  "method": "subscribe",
  "channel": "fills",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

> The above request returns JSON structured like this:

```json
{
  "event": "confirm",
  "channel": "fills",
  "method": "subscribe",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

> After a subscription is successfully initiated, the server returns JSON
> structured like this for every update.

```json
{
  "event": "update",
  "channel": "fills",
  "data": {
    "market_order_id": 1,
    "market_id": 1,
    "side": "bid",
    "size": 500,
    "price": 1000,
    "user_address": "0x1",
    "custodian_id": null,
    "order_state": "open",
    "created_at": "2023-05-01T12:34:56.789012Z"
  }
}
```

> To unsubscribe, the user may send JSON structured like this:

```json
{
  "method": "unsubscribe",
  "channel": "fills",
  "params": {
    "market_id": 1,
    "user_address": "0x1"
  }
}
```

The client can subscribe to the fills channel to receive updates on orders for
a specific market and user address. Once a subscription has been successfully
initiated, the client will receive updates whenever a fill occurs for an order
on the specified market placed by the specified account.

The client may subscribe to any number of market ID / user address combinations.
If the client attempts to subscribe to a market ID / user address combination they
are already subscribed to, the WebSocket API will send an error message notifying
them that this is the case.

## Price Levels

```json
{
  "method": "subscribe",
  "channel": "price_levels",
  "params": {
    "market_id": 1,
  }
}
```

> The above request returns JSON structured like this:

```json
{
  "event": "confirm",
  "channel": "price_levels",
  "method": "subscribe",
  "params": {
    "market_id": 1,
  }
}
```

> After a subscription is successfully initiated, the server returns JSON
> structured like this for every update.

```json
{
  "event": "update",
  "channel": "price_levels",
  "data": {
    "market_id": 1,
    "side": "bid",
    "size": 1000,
    "price": 1000,
    "timestamp": "2023-05-01T12:34:56.789012Z"
  }
}
```

> To unsubscribe, the user may send JSON structured like this:

```json
{
  "method": "unsubscribe",
  "channel": "price_levels",
  "params": {
    "market_id": 1
  }
}
```

The client can subscribe to the price levels channel to receive updates on
price levels on the orderbook for a specific market. Once a subscription has been
successfully initiated, the client will receive updates whenever the amount
available to fill at a price changes, or orders become available at a new price.

The client can use the updates available from this channel along with the results
of the GET orderbook endpoint to keep track of the current state of the orderbook.

The price level update message contains the side of the orderbook, and a timestamp
so that users can be sure whether or not an update should be applied to the
locally tracking state to reach the correct current orderbook state.
