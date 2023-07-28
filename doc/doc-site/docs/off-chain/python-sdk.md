# Python SDK

The code for the Python SDK lives in [`/econia/src/python/sdk/econia_sdk`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk).
There are 2 primary packages ([`econia_sdk.entry`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk/entry) and [`econia_sdk.view`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk/view)) complemented by two secondary imports.
This code provides programmatic access to Econia exchanges, in addition to offering an example of how to put it all together shown later in this document.

# Primary Packages

## `econia_sdk.entry`

This package contains helpers for accessing Econia's `public entry` functions.
Each method's name corresponds to the name of a public entry function in one of the following Econia Move modules:

| package                       | move                                                                                            | python                                                                                                |
| ----------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `econia_sdk.entry.incentives` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/incentives.py) |
| `econia_sdk.entry.market`     | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move)     | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/market.py)     |
| `econia_sdk.entry.registry`   | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move)   | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/registry.py)   |
| `econia_sdk.entry.user`       | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move)       | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/user.py)       |

The corresponding Move code is well-commented and up-to-date, so it's helpful to have handy when working with the Python SDK.
If the function you desire happens to not be supported by the Python SDK (or sadly isn't working), it's possible to use `econia_sdk.lib.EconiaClient` to execute the appropriate `public entry` Move function yourself.
See the Python code linked above for examples of how an `EntryFunction` instance is created.

## `econia_sdk.view`

This package contains helpers for accessing Econia's `#[view]` functions.
Each method's name corresponds to the name of a view function in one of the following Econia Move modules:

| package                            | move                                                                                                  | python                                                                                                     |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `econia_sdk.view.incentives`       | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move)       | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/incentives.py)       |
| `econia_sdk.view.market`           | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move)           | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/market.py)           |
| `econia_sdk.view.registry`         | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move)         | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/registry.py)         |
| `econia_sdk.view.user`             | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move)             | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/user.py)             |
| `econia_sdk.view.resource_account` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/resource_account.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/resource_account.py) |

The corresponding Move code is well-commented and up-to-date, so it's helpful to have handy when working with the Python SDK.
If the function you desire happens to not be supported by the Python SDK (or sadly isn't working), it's possible to use `econia_sdk.lib.EconiaViewer` to execute the appropriate `#[view]` Move function yourself.
See the Python code linked above for examples of how an `EconiaViewer` instance is used.
Note the return value of the `EconiaViewer` functions "[quacks](https://en.wikipedia.org/wiki/Duck_typing) like JSON" but every field-value is stringified.

# Secondary Packages

## `econia_sdk.lib`

This package contains `EconiaClient`, which takes care of executing transactions pointed at `public entry` function targets, and `EconiaViewer` which takes care of access to off-chain callable `#[view]` function targets.
These are not meant to be used without help from this Python SDK.
Both are sufficiently capable to handle all possible functions to which they may apply, as long as those functions exist in the deployed Move contract code.

## `econia_sdk.types`

This package contains various enum types useful for parsing and referring to important values.
Note that Move doesn't have enum types so unlike most of the above, these do not map directly to Move.
However, each value in each enum is associated with a constant that exists in the Move code.

# Other Contents

## `examples.trade`

This is a script that makes use of both view functions and entry functions to perform a few scenarios in the exchange for the user.
After set-up, it should be automatic (except for hitting enter to proceed the script).
On display are things like registering a market, creating a market account and funding it, placing limit/market orders under various conditions as well as cancelling them.
It's useful as a way to gain an understanding of what different fields/parameters mean and in general how to use the Python SDK.
**Running/reading this example script and understanding what it does is recommended before anyone trades real money with the SDK.**

### Running the Example Script ("Trading From Scratch")

You're recommended to run a local Aptos node and faucet first; this prevents any rate-limiting issues from preventing your progress.
Install the Aptos CLI & run your local node/faucet:

```bash
brew install aptos # only if necessary
mkdir aptos && cd aptos
aptos node run-local-testnet --with-faucet
```

In another terminal, run the following:

```bash
export APTOS_NODE_URL=http://0.0.0.0:8080/v1
export APTOS_FAUCET_URL=http://0.0.0.0:8081
```

You'll also have the option of entering these as prompts of the script, but the environment variable is preferred because it's easier to run multiple times.
It's time to deploy our own Econia Faucet to the local chain:

```bash
git clone https://github.com/econia-labs/econia.git # only if necessary
cd ./econia/src/move/faucet
aptos init --profile econia_faucet_deploy # enter "local" for the chain
export FAUCET_ADDR=<ACCOUNT-FROM-ABOVE>
# deploy the faucet (all one command)
aptos move publish \
        --named-addresses econia_faucet=$FAUCET_ADDR \
        --profile econia_faucet_deploy \
        --assume-yes
```

You also need to deploy Econia:

```bash
cd ./econia/src/move/econia
aptos init --profile econia_exchange_deploy # enter "local" for the chain
export ECONIA_ADDR=<ACCOUNT-FROM-ABOVE>
# deploy the faucet (all one command)
aptos move publish \
        --override-size-check \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDR \
        --profile econia_exchange_deploy \
        --assume-yes
```

It's time to run the script!
Setting our environment variables will have cleared the initial setup prompts for us.
In order to run, install Poetry then install dependencies and run the script:

```bash
brew install poetry # only if necessary
cd ./econia/src/python/sdk && poetry install # only if necessary
poetry run trade # we're off to the races!
```

### Understanding the Example Script

#### Step #1: Set-up the Market

```
Press enter to initialize (or obtain) the market.
Market does not exist yet, creating one...
EVENT SUMMARY: MarketRegistrationEvent
  * Base Type (unit of lots): 0x...::test_apt::TestAPT
  * Quote Type (unit of ticks): 0x...::test_usdc::TestUSDC
Market ID: 3
TRANSACTIONS EXECUTED (first-to-last):
  * Create a new market: 0xfb71a2742a9ac08e2757d0f0cca54f9b859b49423679c57075852591cda8dabf
There are no open orders on this market right now.
```

In this case, the market did not exist for the pair of faucet currencies (`TestEth` and `TestUSDC`) that we deployed.
Only one market can exist per unique configuration so once it's created here, it won't be created again in future runs.
Instead it'll be detected as existing via a view function, and then re-used from thereafter.
There don't appear to be any open orders on this brand-new market which makes a lot of sense!

The long hex string is a transaction hash, which can be looked up on an explorer if using a public chain such as devnet.
[Explorers](https://explorer.aptoslabs.com/?network=devnet) can provide more information about a transaction at a glance.

#### Step #2: Set-up the Account "A"

```
Press enter to set-up an Account A with funds.
New market account after deposit:
  * tAPT: 0 -> 10.0
  * tUSDC: 0 -> 10000.0
Account A was set-up: 0x73db82a6cee1bd2443d3305454d83e36ca81ee5f3c17c5d06ecd8fe68838c9a4
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 tAPT (yet to be deposited): 0x44dd030c6b689544b20c5bddf5d9cafdd17a8550e3696f7f4dbad17dcc231716
  * Mint 10000.0 tUSDC (yet to be deposited): 0xe92cdb4235e32840bae7961dd3d0b5ed47374bb9c6791986283bd148acf9ebca
  * Register a new account in market 3: 0x30e8d0dddbf44e6ab639b15f127cdae6d0fda4c4aab82e20d34deddda423dd03
  * Deposit 10.0 tAPT to market account: 0x0baddfd53f7a105e45de96e7682ca7b90d2dcc449314e3c18bfdb869e9a49f92
  * Deposit 10000.0 tUSDC to market account: 0xef94c0d495377afeb2bde1180d3e2c4b620c01b925d623186a8c18adac5f768d
```

Interacting with the exchange as an address requires a market account for each trading pair.
Market accounts possess the funds available to trade on a trading pair as an account.
In the above, we perform two steps for two coins, in addition to registering a new market account:

1. Create a new market account (only if necessary).
1. Obtain the funds to be deposited (in this case, we mint them).
1. Deposit the funds into the account.

This gives us the 5 total transactions we expect and see above. Minting and depositing happens twice while creating a new account happens only once. This will happen again when we create an Account "B" below.

#### Step #3: Place Limit Orders (as Account A)

```
Press enter to place limit orders with Account A.
EVENT SUMMARY: PlaceLimitOrderEvent
  * User address: 0x73db82a6cee1bd2443d3305454d83e36ca81ee5f3c17c5d06ecd8fe68838c9a4
  * Order ID: 18446884819787842536
  * Side: BID (Buying)
  * Price: 1000 tUSDC ticks per tAPT lot
  * Size: 1000 available tAPT lots / 1000
EVENT SUMMARY: PlaceLimitOrderEvent
  * User address: 0x73db82a6cee1bd2443d3305454d83e36ca81ee5f3c17c5d06ecd8fe68838c9a4
  * Order ID: 36893628897792362448
  * Side: ASK (Selling)
  * Price: 2000 tUSDC ticks per tAPT lot
  * Size: 1000 available tAPT lots / 1000
Account A has finished placing limit orders.
  * There were no limit orders filled by any orders placed.
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (1000 lots) (1000 ticks/lot): 0xb5cc09e7f1caa23b27f0037c1de5e0052b52bccf22f50842b1942ed4629b2db5
  * Place limit ASK/SELL order (1000 lots) (2000 ticks/lot): 0x9ed8e3afe84a533ec485ee58188d4134d86b2b7271f24041d8f872c5dc26ba7f
CURRENT BEST PRICE LEVELS:
  * Highest BID/BUY @ 1000 ticks/lot, 1000 lots
  * Lowest ASK/SELL @ 2000 ticks/lot, 1000 lots
```

Limit orders behave as expected: some of the user's market account funds are "locked up" in what's called a limit order, as opposed to a market order.
Limit orders make an asset available for purchase at a given price.
When a market order comes along and pays the price of a limit order, this is called a "fill" event.
We're about to witness such a fill event in the coming steps.

#### Step #4: Set-up the Account "B"

```
Press enter to set-up an Account B with funds.
New market account after deposit:
  * tAPT: 0 -> 10.0
  * tUSDC: 0 -> 10000.0
Account B was set-up: 0x6c1bf6edc2dd770096b1251f218b3fb23aa242e3ef6a62fa55f1c01345ba2692
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 tAPT (yet to be deposited): 0xf1690dd28662a9ff19712a56a5e30f0b65dce452b8a40f8a0dc7494d4657b290
  * Mint 10000.0 tUSDC (yet to be deposited): 0x848ac4b0a11dd6f11117721ccdcfd0bdcbde9fbfb6b5f36f8388b235c548a13d
  * Register a new account in market 3: 0xf7089757ee42aced4deb3f59f8f2c79770f06e24751aaa46ab4de1fbcbcf04a1
  * Deposit 10.0 tAPT to market account: 0x633d4dbf96368c2da4e4370402a402362134bd33d6065917b7f76d3a4fb5d449
  * Deposit 10000.0 tUSDC to market account: 0xb237d27d1cfccbf7aa2bb3d7dea8a7bf52f2ac3f94ff142d82ee67a740db672b
```

Same as step #2, but for a new account.

#### Step 5: Place Market Orders (as Account B)

```
Press enter to place market orders (buy and sell) with Account B.
Account B has finished placing 2 market orders.
  * This resulted in 2 limit orders getting filled.
TRANSACTIONS EXECUTED (first-to-last):
  * Place market BID/BUY order (500 lots): 0xa52c0f6fa1d7f9ce01e89a0044198bb8e4495d7964b5ae8f7a9660f8b635e0a8
  * Place market ASK/SELL order (500 lots): 0x719a60b1f2edff7bf6d5a0d175b27aebddb81c1abdb75146b93b96e5483897af
CURRENT BEST PRICE LEVELS:
  * Highest BID/BUY @ 1000 ticks/lot, 500 lots
  * Lowest ASK/SELL @ 2000 ticks/lot, 500 lots
```

Here after Account B has placed their market orders in both directions, the best price level in both directions has gone down in total size.
This is expected, because some of the liquidity available has been taken at the agreed-upon prices in both the "buy base asset" (bid) and "sell base asset" (ask) cases.

#### Step 6: Cancel All Limit Orders (as Account A)

```
Press enter to cancel all of Account A's outstanding orders
Account A has cancelled all 2 of their orders.
TRANSACTIONS EXECUTED (first-to-last):
  * Cancel all ASKS for Account A: 0x46cb07d3eb9b622d4645559adae8a5e9cdc28670173760bee4154f43b8f8f4e0
  * Cancel all BIDS for Account A:: 0x50da928e8621167a8e9b6297dd9966f4f871b81b918a046b7840305002299075
CURRENT BEST PRICE LEVELS:
There is no tAPT being bought or sold right now!
```

This one is straightforward, but it's worth nothing that there are no longer orders on the book unlike in the step above.
That's because in this case, all of the liquidity in the order book has been cancelled by our cancelling all of Account A's orders (since Account A's orders were all the orders on the book).

#### Step 7: Place Multiple Competitive Limit Orders (as Account A)

```
Press enter to place competitive limit orders (top-of-book) with Account A.
Account A has created multiple competitive limit orders!
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (100 lots) (1000 ticks/lot): 0xbae8ef0b65838fa914d00da061cf2ab34f5cf6882f0d6a8d6f65b07db184101d
  * Place limit ASK/SELL order (100 lots) (2000 ticks/lot): 0x988a1c25d4d4bf987e4fa4f75c98bfea2c77637605575296d5179d1589bdb266
  * Place limit BID/BUY order (200 lots) (1001 ticks/lot): 0x149f2519dc522cccd1fdd242309cfe2504565b172eb1f394e6106a3173d97978
  * Place limit ASK/SELL order (200 lots) (1999 ticks/lot): 0x60f1632bf52d3a5c00b8b6a08596d961e07ef83ce6421dad95b090cb6ac1d44a
  * Place limit BID/BUY order (300 lots) (1002 ticks/lot): 0x8efda089c834b7962771cb30a04faeead52aa2d21d6b829541b6c2a4ef7aed64
  * Place limit ASK/SELL order (300 lots) (1998 ticks/lot): 0x614d18accc9f50e4aa33e477c1d0bd835b416b7e7d4bc16226ceb6c497e8a364
  * Place limit BID/BUY order (400 lots) (1003 ticks/lot): 0x27bf83490f24d16677ce2478d62b4d15984bbee3b7a4b8c78a98e68dd25abb8d
  * Place limit ASK/SELL order (400 lots) (1997 ticks/lot): 0xca00b5f77d31a2746496da7d24ce15596ee1e96fb6ddce4208265228b46ea8e5
  * Place limit BID/BUY order (500 lots) (1004 ticks/lot): 0x8f736a19aa57e724b5ecb5e3dc812c2c21189bc631d9a8810b82be1e79fbe167
  * Place limit ASK/SELL order (500 lots) (1996 ticks/lot): 0xc9ad3b9f29cab5e0dd6c234c359bf1e569b326e4f1303cf7c7de77843f9b8455
CURRENT BEST PRICE LEVELS:
  * Highest BID/BUY @ 1004 ticks/lot, 500 lots
  * Lowest ASK/SELL @ 1996 ticks/lot, 500 lots
```

Here you can see that Account A is placing multiple limit orders in each direction.
Every order "beats" the last, for example the bid at 1001 ticks per lot across 200 lots "beats" the bid at 1000 ticks per lot across 100 lots.
The highest price the base asset (tETH) is being bought for right now is 1004 ticks/lot with 500 lots at that price.
Likewise the lowest price the base asset (tETH) is being sold for right now is 1996 ticks/lot with 500 lots at that price.

We'll see the sequence of these limit orders clearer in the next step, where Account B places spread-crossing limit orders.

#### Step #8: Place Spread-Crossing Limit Orders (as Account B)

```
Press enter to place spread-crossing limit order with Account B (no remainder).
LAST ORDER EXECUTION BREAKDOWN: FillEvent(s)
  * There were 5 BID orders filled by the ASK order placement.
  * Execution prices (ticks/lot): 1004 -> 1003 -> 1002 -> 1001 -> 1000
  * Execution sizes (lots): 500 +> 400 +> 300 +> 200 +> 100
  * Execution fees (quote subunits): 251000 +> 200600 +> 150300 +> 100100 +> 50000
  * The order WAS fully satisfied by initial execution


Press enter to place spread-crossing limit order with Account B (w/ remainder).
LAST ORDER EXECUTION BREAKDOWN: FillEvent(s)
  * There were 5 ASK orders filled by the BID order placement.
  * Execution prices (ticks/lot): 1996 -> 1997 -> 1998 -> 1999 -> 2000
  * Execution sizes (lots): 500 +> 400 +> 300 +> 200 +> 100
  * Execution fees (quote subunits): 499000 +> 399400 +> 299700 +> 199900 +> 100000
  * The order WAS NOT fully satisfied by initial execution


THE END!
```

There were two limit orders placed by B here; both "crossed the spread" and one had some remaining after filling all orders up to its price.
Here, "crossing the spread" means placing a bid with a price higher than the lowest ask, or an ask with a price lower than the highest bid.
Since the market bid (buy) in this case had remaining size, there will be an order left on the book (worth 1500 lots) on the bid side.
**Try running the script again and see if the order is there!**
