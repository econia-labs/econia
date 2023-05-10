---
title: API Reference

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
    "market_id": 0,
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
    "market_id": 1,
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
curl "https://dev.api.econia.exchange/market/0"
```

```python
import requests

market_id = 0
res = requests.get(f"https://dev.api.econia.exchange/market/{market_id}")
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 0;
  const res = await fetch(`https://dev.api.econia.exchange/market/${marketId}`);
  const data = await res.json();
  console.log(data);
}
main();
```

> The above request returns JSON structured like this:

```json
{
    "market_id": 0,
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

`GET /market/:market_id`

### Path Parameters

Parameter | Type | Description
--------- | ---- | -----------
market_id | u64  | The ID of the market to retrieve

### Errors

Error Code | Description
---------- | -------
400        | Bad Request: the provided market ID was not a valid u64
404        | Not Found: no market with the specified ID was found

## Get orderbook

Get the current orderbook for a particular market. The response will include
prices for each level on the orderbook, and the total size of the orders
available at that price.

```shell
curl "https://dev.api.econia.exchange/market/0/orderbook?depth=1"
```

```python
import requests

market_id = 0
params = {"depth": 1}

res = requests.get(
    f"https://dev.api.econia.exchange/market/{market_id}/orderbook", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 0;
  const params = new URLSearchParams({ depth: 1 });
  const res = await fetch(
    `https://dev.api.econia.exchange/market/${marketId}/orderbook?${params}`
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

`GET /market/:market_id/orderbook`

### Path Parameters

Parameter | Type | Description
--------- | ---- | -----------
market_id | u64  |  The ID of the market to retrieve

### Query Parameters

Parameter | Type | Description
--------- | ---- | -----------
depth     | u32  | The number of orderbook levels to retrieve

### Errors

Error Code | Description
---------- | -------
400        | Bad Request: invalid parameters
404        | Not Found: no market with the specified ID was found

The depth parameter must be a number greater than or equal to 1.

## Get market history

Get the market history for a particular market. The response will include the
open, high, low, and close prices for each interval, as well as the total volume
for that interval.

```shell
curl -G "https://dev.api.econia.exchange/market/0/history" \
  -d resolution=1m \
  -d from=1683018300 \
  -d to=1683024240
```

```python
import requests

market_id = 0
params = {
    "resolution": "1m",
    "from": 1683018300,
    "to": 1683024240,
}

res = requests.get(
    f"https://dev.api.econia.exchange/market/{market_id}/history", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 0;
  const params = new URLSearchParams({
    resolution: "1m",
    from: 1683018300,
    to: 1683024240,
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/market/${marketId}/history?${params}`
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

`GET /market/:market_id/orderbook`

### Path Parameters

Parameter | Type | Description
--------- | ---- | -----------
market_id | u64  |  The ID of the market to retrieve

### Query Parameters

Parameter  | Type | Description
---------  | ---- | -----------
resolution | enum | The resolution of the requested historical data. Accepted values are 1m, 5m, 15m, 30m, and 1h.
from       | i64  | Unix timestamp (in seconds) for the start of the requested time range
to         | i64  | Unix timestamp (in seconds) for the end of the requested time range

### Errors

Error Code | Description
---------- | -------
400        | Bad Request: invalid parameters
404        | Not Found: no market with the specified ID was found

The resolution parameter must be one of the options listed above. Additionally,
the `to` and `from` timestamps must be valid Unix timestamps denoted in seconds,
and the `from` timestamp must come before the `to` timestamp.

## Get market fills

Get the fills for a particular market.

```shell
curl -G "https://dev.api.econia.exchange/market/0/fills" \
  -d from=1682944490 \
  -d to=1682944500
```

```python
import requests

market_id = 0
params = {
    "from": 1682944490,
    "to": 1682944500,
}

res = requests.get(
    f"https://dev.api.econia.exchange/market/{market_id}/fills", params=params)
data = res.json()

print(data)
```

```javascript
async function main() {
  const marketId = 0;
  const params = new URLSearchParams({
    from: 1682944490,
    to: 1682944500,
  });
  const res = await fetch(
    `https://dev.api.econia.exchange/market/${marketId}/fills?${params}`
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
    "market_id": 0,
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

`GET /market/:market_id/fills`

### Path Parameters

Parameter | Type | Description
--------- | ---- | -----------
market_id | u64  |  The ID of the market to retrieve

### Query Parameters

Parameter  | Type | Description
---------  | ---- | -----------
from       | i64  | Unix timestamp (in seconds) for the start of the requested time range
to         | i64  | Unix timestamp (in seconds) for the end of the requested time range

### Errors

Error Code | Description
---------- | -------
400        | Bad Request: invalid parameters
404        | Not Found: no market with the specified ID was found

The `to` and `from` timestamps must be valid Unix timestamps denoted in seconds,
and the `from` timestamp must come before the `to` timestamp.

## Get open orders

Get open orders for a particular account.

```shell
curl "https://dev.api.econia.exchange/account/0x1/open-orders"
```

```python
import requests

account_id = "0x1"

res = requests.get(
    f"https://dev.api.econia.exchange/account/{account_id}/open-orders")
data = res.json()

print(data)
```

```javascript
async function main() {
  const accountId = "0x1";
  const res = await fetch(
    `https://dev.api.econia.exchange/account/${accountId}/open-orders`
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
        "market_order_id": 0,
        "market_id": 0,
        "side": "bid",
        "size": 1000,
        "price": 1000,
        "user_address": "0x1",
        "custodian_id": null,
        "order_state": "open",
        "created_at": "2023-05-01T12:34:56.789012Z"
    },
    {
        "market_order_id": 1,
        "market_id": 0,
        "side": "ask",
        "size": 1000,
        "price": 2000,
        "user_address": "0x1",
        "custodian_id": null,
        "order_state": "open",
        "created_at": "2023-05-01T12:34:56.789012Z"
    },
```

### HTTP Request

`GET /account/:account_id/open-orders`

### Path Parameters

Parameter  | Type   | Description
---------  | ----   | -----------
account_id | String | The ID of the account to retrieve open orders for

### Errors

Error Code | Description
---------- | -------
404        | Not Found: no account with the specified ID was found

## Get order history

Get the order history for a particular account.

```shell
curl "https://dev.api.econia.exchange/account/0x1/order-history"
```

```python
import requests

account_id = "0x1"

res = requests.get(
    f"https://dev.api.econia.exchange/account/{account_id}/order-history")
data = res.json()

print(data)
```

```javascript
async function main() {
  const accountId = "0x1";
  const res = await fetch(
    `https://dev.api.econia.exchange/account/${accountId}/order-history`
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
        "market_order_id": 0,
        "market_id": 0,
        "side": "bid",
        "size": 1000,
        "price": 1000,
        "user_address": "0x1",
        "custodian_id": null,
        "order_state": "filled",
        "created_at": "2023-04-30T12:34:56.789012Z"
    },
    {
        "market_order_id": 1,
        "market_id": 0,
        "side": "ask",
        "size": 1000,
        "price": 2000,
        "user_address": "0x1",
        "custodian_id": null,
        "order_state": "open",
        "created_at": "2023-05-01T12:34:56.789012Z"
    },
```

### HTTP Request

`GET /account/:account_id/order-history`

### Path Parameters

Parameter  | Type   | Description
---------  | ----   | -----------
account_id | String | The ID of the account to retrieve order history for

### Errors

Error Code | Description
---------- | -------
404        | Not Found: no account with the specified ID was found

# WebSocket API

## Overview

The dev version of the API is available at `wss://dev.api.econia.exchange/ws`.
