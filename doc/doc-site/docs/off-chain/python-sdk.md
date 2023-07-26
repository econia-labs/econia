# Python SDK

The code for the Python SDK lives in [`/econia/src/python/sdk/econia_sdk`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk).
There are 2 primary packages ([`econia_sdk.entry`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk/entry) and [`econia_sdk.view`](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk/view)) complemented by two secondary imports.
This code provides programmatic access to Econia exchanges, in addition to offering an example of how to put it all together shown later in this document.

# Primary Packages
## `econia_sdk.entry`

This package contains helpers for accessing Econia's `public entry` functions.
Each method's name corresponds to the name of a public entry function in one of the following Econia Move modules:

| package | move | python |
| -- | --- | --- |
| `econia_sdk.entry.incentives` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/incentives.py) |
| `econia_sdk.entry.market` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/market.py) |
| `econia_sdk.entry.registry` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/registry.py) |
| `econia_sdk.entry.user` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/user.py) |

The corresponding Move code is well-commented and up-to-date, so it's helpful to have handy when working with the Python SDK.
If the function you desire happens to not be supported by the Python SDK (or sadly isn't working), it's possible to use `econia_sdk.lib.EconiaClient` to execute the appropriate `public entry` Move function yourself.
See the Python code linked above for examples of how an `EntryFunction` instance is created.

## `econia_sdk.view`

This package contains helpers for accessing Econia's `#[view]` functions.
Each method's name corresponds to the name of a view function in one of the following Econia Move modules:

| package | move | python |
| -- | --- | --- |
| `econia_sdk.view.incentives` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/incentives.py) |
| `econia_sdk.view.market` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/market.py) |
| `econia_sdk.view.registry` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/registry.py) |
| `econia_sdk.view.user` | [link](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move) | [link](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/user.py) |
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
export FAUCET_ADDR=<ADDR-FROM-ABOVE>
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
export ECONIA_ADDR=<ADDR-FROM-ABOVE>
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
  * Base Type (unit of lots): 0x...::test_eth::TestETH
  * Quote Type (unit of ticks): 0x...::test_usdc::TestUSDC
Market ID: 1
TRANSACTIONS EXECUTED (first-to-last):
  * Create a new market: 0x544c1535d9634bb4d4f5ee5b74ae798e45e5b1a0e54bfea060026e5ce0163dd9
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
  * tETH: 0 -> 10.0
  * tUSDC: 0 -> 10000.0
Account A was set-up: 0xb5a2e0363ecfd9fbc9cd9e77f5db5d7d6e85a1c8b931675f71e99a1836adfe41
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 tETH (yet to be deposited): 0xbecafd3453798384eacdc25733d53e30d8d86524c27cf2f8da533a3ad785838a
  * Mint 10000.0 tUSDC (yet to be deposited): 0xfdddda8daf3881908c413ec5d8cf12fb3a2d164d57a43908b06236171cfd1103
  * Register a new account in market 1: 0x89a403548b2b986555751fa0e4d2d29e6a099ca38dd2d5640297b587fb27510c
  * Deposit 10.0 tETH to market account: 0x8233bc577deafd9f3ace59c9d7843807c1a41bf9604e980eddff47990d677bdc
  * Deposit 10000.0 tETH to market account: 0xd6b6eeb06160c13c174ea4c868fef9457686f45c7839463640cb7a5b051f95a3
```

Interacting with the exchange as an address requires a market account for each trading pair.
Market accounts possess the funds available to trade on a trading pair as an account.
In the above, we perform two steps for two coins, in addition to registering a new market account:

1. Create a new market account (only if necessary).
2. Obtain the funds to be deposited (in this case, we mint them).
3. Deposit the funds into the account.

This gives us the 5 total transactions we expect and see above. Minting and depositing happens twice while creating a new account happens only once. This will happen again when we create an Account "B" below.

#### Step #3: Place Limit Orders (as Account A)
```
Press enter to place limit orders with Account A.
EVENT SUMMARY: PlaceLimitOrderEvent
  * User address: 0xb5a2e0363ecfd9fbc9cd9e77f5db5d7d6e85a1c8b931675f71e99a1836adfe41
  * Order ID: 18446884819787842536
  * Side: BID (Buying)
  * Price: 1000 tUSDC ticks per tETH lot
  * Size: 1000 available tETH lots / 1000
EVENT SUMMARY: PlaceLimitOrderEvent
  * User address: 0xb5a2e0363ecfd9fbc9cd9e77f5db5d7d6e85a1c8b931675f71e99a1836adfe41
  * Order ID: 36893628897792362448
  * Side: ASK (Selling)
  * Price: 2000 tUSDC ticks per tETH lot
  * Size: 1000 available tETH lots / 1000
Account A has finished placing limit orders.
  * There were no limit orders filled by any orders placed.
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (1000 lots) (1000 ticks/lot): 0x7f8a086a31a7298f68eb474179de845ca31f0c124a31bdf3ecbdad23d571d880
  * Place limit ASK/SELL order (1000 lots) (2000 ticks/lot): 0xc994c5aca37a83aca9514b002d54788650943cba80d008c48ffa2870898fbf12
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
  * tETH: 0 -> 10.0
  * tUSDC: 0 -> 10000.0
Account B was set-up: 0x9f8bdcf624604f69b6c70c8d121b6d9bacddf48c8424dcccb5adf0ebd2c2e700
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 tETH (yet to be deposited): 0x95bd0b4e5f5758e90c6a8a74074710cc8f44379e178125c141792ba1c7df744a
  * Mint 10000.0 tUSDC (yet to be deposited): 0x840f1fdedefaec8d48b6483052d804cf1af82d1197f3619623272a151a2bfa0d
  * Register a new account in market 1: 0xb2f0ffdfac1edf6fe1de2c489dbaac353e03e8a12f97b6c48ae51e9651cfcd99
  * Deposit 10.0 tETH to market account: 0xda3d0c4c29d8c3b6ac8baeddd66b7308e8b053ec1ede3d39b01ae0fa49adc83b
  * Deposit 10000.0 tETH to market account: 0x4c97cda5c829da9aa318e129c5b5ceb65f34ea69f4e7df15797781215c306a30
```

Same as step #2, but for a new account.


#### Step 5: Place Market Orders (as Account B)

```
Press enter to place market orders (buy and sell) with Account B.
Account B has finished placing 2 market orders.
  * This resulted in 2 limit orders getting filled.
TRANSACTIONS EXECUTED (first-to-last):
  * Place market BID/BUY order (500 lots): 0x1b20523bd946e81d921243bc2acb0666aff5049d7aeb0f184004a606a66f1623
  * Place market ASK/SELL order (500 lots): 0xb82e88ddae98aadd195c743fc8dfde582fb03a41ff959af231157ffbddcce8db
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
  * Cancel all ASKS for Account A: 0xbd77261240ede717d95af21d1887b7292271a8675fe8ced54aa100d998e2edc5
  * Cancel all BIDS for Account A:: 0x207b2cdeea95fa60549301d77e72baa38fe99346893d771ed59ffe9df8c0167c
CURRENT BEST PRICE LEVELS:
There is no tETH being bought or sold right now!
```

This one is straightforward, but it's worth nothing that there are no longer orders on the book unlike in the step above.
That's because in this case, all of the liquidity in the order book has been cancelled by our cancelling all of Account A's orders (since Account A's orders were all the orders on the book).

#### Step 7: Place Multiple Competitive Limit Orders (as Account A)

```
Press enter to place competitive limit orders (top-of-book) with Account A.
Account A has created multiple competitive limit orders!
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (100 lots) (1000 ticks/lot): 0xaa5eaf815072342645a85dbd7e40e84d999d44fae484440832474ccc7927cc18
  * Place limit ASK/SELL order (100 lots) (2000 ticks/lot): 0x7ec72c68aef04221eba37e83041440c2ef0e9bfe68bfc70b9e73580508177237
  * Place limit BID/BUY order (200 lots) (1001 ticks/lot): 0x463316baead724ff08021e2e8d59fbeefcffffb19e6ea026d167005e69168268
  * Place limit ASK/SELL order (200 lots) (1999 ticks/lot): 0xd19cacbe7b6a2496e91fd17fd359e228f1b5bd9d6ac9c4f0db706e8ad24a9939
  * Place limit BID/BUY order (300 lots) (1002 ticks/lot): 0xbb9b637d01b6209c13d760e7a1b9dbd4fcdd05a724b5ed0e4c50463be1566d3d
  * Place limit ASK/SELL order (300 lots) (1998 ticks/lot): 0x7ad8c60956edaee5c3d4a8d355c015a5c5776f79ec19310f8d91b7a1ba3e159a
  * Place limit BID/BUY order (400 lots) (1003 ticks/lot): 0x64a1e2bc60a50ad2a44fdadb9aaa4f75a03a1061af5ebe926a79619ba4acdab8
  * Place limit ASK/SELL order (400 lots) (1997 ticks/lot): 0x2acba7786094cbaa5f3551f9489847e33f9d114734ff9f35bdc815488cb0c8ea
  * Place limit BID/BUY order (500 lots) (1004 ticks/lot): 0x2038221c4fa6488f3645fe6722ef1269f19ecd61d7e4352a8767cb12106ba3d8
  * Place limit ASK/SELL order (500 lots) (1996 ticks/lot): 0xe4754a6069c76275a0d8ea3933825160abb9bddf78a3cee7f27d798e479df337
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
```

There were two limit orders placed by B here; both "crossed the spread" and one had some remaining after filling all orders up to its price.
Here, "crossing the spread" means placing a bid with a price higher than the lowest ask, or an ask with a price lower than the highest bid.
Since the market bid (buy) in this case had remaining size, there will be an order left on the book (worth 1500 lots) on the bid side.
**Try running the script again and see if the order is there!**