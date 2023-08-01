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

## `econia_sdk.utils.decimals`

This package contains a few helpers for calculating market creation parameters (lot size, tick size, and min size).
The intent is to allow one to express their desired sizes in decimal notation, and have that converted to integer notation.
Nota bene that these expect reasonable inputs.
For example: converting 0.000001 unit size for 3 decimals returns 1 subunit size, which is 0.001 unit size, instead of an error.
Price conversion utilities are left out for this reason: truncation, even a small percent's worth, would make them too dangerous.

Let's walk through an example of configuring a market using these utilities.
If you'd like to follow along, install the Econia SDK, run the Python interpreter and import the SDK using...
```bash
pip3 install econia-sdk
python3
>>> from econia_sdk.utils.decimals import *
```

Market configuration (beyond base type and quote type) consists of 3 integer values: lot size, tick size, and min size.

| value | units | description |
| -- | -- | -- |
| lot size | subunits of base type | the granularity of base sizes |
| tick size | subunits of quote type | the granularity of quote sizes |
| min size | number of lots | the minimum limit order size |

In order to proceed, we must decide the granularity of base and quote sizes as well as the minimum limit order size for our market.
One must consider that "price" in the exchange is an integer expressed in terms of "ticks per lot" so the granularity (size) of ticks and lots relates to the prices that can be expressed.
That is, tick size and lot size beget a constant price granularity.
In general the desire is to have one _tick_ be "small" relative to one **_lot_** in terms of value, since the minimum expressible price is 1 tick per lot, then 2 ticks and so forth.
Let's use `eAPT` and `eUSDC` used in the faucet below as example base and quote types respectively for a market.
We know that eAPT (the base type) has 8 decimals and eUSDC (the quote type) has 6 decimals:
```
>>> base_decimals = 8
>>> quote_decimals = 6
```

We'd like to be able to express small prices with high granularity.
Let's try using 0.001 eAPT for the granularity base coin sizes, and 0.01 eUSDC (one penny) for the granularity of quote coin sizes.
Does this work?
Let's find out!
```
>>> get_min_quote_per_base(0.001, 0.01)
10.0
```
There are 1000 lots in 1 `eAPT` (=1/0.001) and the minimum expressible price is 1 tick per lot.
We know that 1 tick is worth 1 cent.
Thus, the granularity of price in human terms is \$10 per eAPT--thus the minimum price is \$10/eAPT, followed by \$20/eAPT and so forth.
Given that (real) APT is right now \$7, we can assess that this configuration would not be workable or appropriate!

The problem is fixable by using a more granular tick size, say 0.00001 instead of 0.01.
Checking our price granularity now shows better results:
```
>>> get_min_quote_per_base(0.001, 0.00001)
0.01
```

That's a price granularity of 1 cent, since the result here is in quote units and 1 eUSDC is \$1.
Now that we have the minimum base and quote size decimals we'd like to use, we're ready to configure the market.
Let's get the lot size and tick size:
```
>>> lot_size = get_lot_size(0.001, base_decimals)
>>> lot_size
100000
>>> tick_size = get_tick_size(0.00001, quote_decimals)
>>> tick_size
10
```

We also need a minimum size. Let's say orders must have a minimum of 1 whole APT in order to post, given the lot size of 100000 from above:
```
>>> get_min_size(1.0, base_decimals, lot_size)
1000
```

That means we use use a minimum size of 1000 lots to configure our market, so the configuring triple would be:
- Lot size: 100000 (subunits of base)
- Tick size: 10 (subunits of quote)
- Min size: 1000 (lots of base)

This gives us a market with a price granularity of 1 cent and minimum order size of 1 eAPT! Can you see how one would get a price granularity of 0.1 cents instead?
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
# deploy the exchange (all one command)
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
  * Base Type (unit of lots): 0x...::example_apt::ExampleAPT
  * Quote Type (unit of ticks): 0x...::example_usdc::ExampleUSDC
Market ID: 4
TRANSACTIONS EXECUTED (first-to-last):
  * Create a new market: 0xc349ace5607dc230bce9299c87ce3ce5e5d4df28338ed09026cb83d0fe5aa4f9
There are no open orders on this market right now.
```

In this case, the market did not exist for the pair of faucet currencies (`ExampleAPT` and `ExampleUSDC`) that we deployed.
Only one market can exist per unique configuration so once it's created here, it won't be created again in future runs.
Instead it'll be detected as existing via a view function, and then re-used from thereafter.
There don't appear to be any open orders on this brand-new market which makes a lot of sense!

The long hex string is a transaction hash, which can be looked up on an explorer if using a public chain such as devnet.
[Explorers](https://explorer.aptoslabs.com/?network=devnet) can provide more information about a transaction at a glance.

#### Step #2: Set-up the Account "A"

```
Press enter to set-up an Account A with funds.
New market account after deposit:
  * eAPT: 0 -> 10.0
  * eUSDC: 0 -> 10000.0
Account A was set-up: 0xfb456eeadbb32a392263e56ff682f080be9cae2a97c7113813e3e6bfaa5b0c6b
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 eAPT (yet to be deposited): 0x3e2d3431ec77b51a47efc64ea4565ef365e68623d7cf22689bf025eee27e3f67
  * Mint 10000.0 eUSDC (yet to be deposited): 0x6ae9b23119347499f685c768ba73a593f0182157de0daecde54861f700287d37
  * Register a new account in market 4: 0x84054125ea208beb322333404db4b2776706c7c8516db7bf3456ddcca4e0bf5e
  * Deposit 10.0 eAPT to market account: 0xdbe0636240082324b50c9e077b06606c6f4ba6bb9391cb2b79bbbeacbcd73726
  * Deposit 10000.0 eUSDC to market account: 0x081330a8e094e99d7f55324a53fd103d1e0107202138dddd146888fe100efe01
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
  * User address: 0xfb456eeadbb32a392263e56ff682f080be9cae2a97c7113813e3e6bfaa5b0c6b
  * Order ID: 18446884819787842536
  * Side: BID (Buying)
  * Price: 1000 eUSDC ticks per eAPT lot
  * Size: 1000 available eAPT lots / 1000
EVENT SUMMARY: PlaceLimitOrderEvent
  * User address: 0xfb456eeadbb32a392263e56ff682f080be9cae2a97c7113813e3e6bfaa5b0c6b
  * Order ID: 36893628897792362448
  * Side: ASK (Selling)
  * Price: 2000 eUSDC ticks per eAPT lot
  * Size: 1000 available eAPT lots / 1000
Account A has finished placing limit orders.
  * There were no limit orders filled by any orders placed.
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (1000 lots) (1000 ticks/lot): 0x38c8fe61694e8d8d03f655813b428e20f76f5e9306a64c912e3349f542fdb76d
  * Place limit ASK/SELL order (1000 lots) (2000 ticks/lot): 0x1e0883bc4947dde35f9eb3599f0a02976a20d6f75efc5ddcae47c7b0e40bbbea
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
  * eAPT: 0 -> 10.0
  * eUSDC: 0 -> 10000.0
Account B was set-up: 0xcaebb3c924ff16721bb4df186592e2e1282a64bf468090d2168659aa730a70cb
TRANSACTIONS EXECUTED (first-to-last):
  * Mint 10.0 eAPT (yet to be deposited): 0x512781d089ab0baedfeb8e6d2ef11058589a5d8912b9c921efcd3ec2dc6d2e91
  * Mint 10000.0 eUSDC (yet to be deposited): 0x731244203e1eb3b76f8834cbd65b8aedc17340e60f6eaaa0186f0a536fdae13b
  * Register a new account in market 4: 0x402bfb900154cd9988ba532cb684a33ab7c39312509f9922b78ff53829bd8561
  * Deposit 10.0 eAPT to market account: 0xfe2b0b76689a4e813fc1ac4fc6f769f62ff5b43ee2073271cd2fdb70b1be514c
  * Deposit 10000.0 eUSDC to market account: 0x7b8796ccb21206bf082cfeb3a14e00dfb0b614a702ca7d39a1b4c4d680d4215c
```

Same as step #2, but for a new account.

#### Step 5: Place Market Orders (as Account B)

```
Press enter to place market orders (buy and sell) with Account B.
Account B has finished placing 2 market orders.
  * This resulted in 2 limit orders getting filled.
TRANSACTIONS EXECUTED (first-to-last):
  * Place market BID/BUY order (500 lots): 0x3f3d9ea7749914bbf3f34b8e2741ae101053736b7cd042a31823a75f026d8a99
  * Place market ASK/SELL order (500 lots): 0x3f5deb4578e48153721c835fbacbe6bd1b3e44f6abd9c5156776f366d42838fe
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
  * Cancel all ASKS for Account A: 0x8282a02796e53b9154b8ece8864deb9cb56cf65f14b59d8533d90202c014766b
  * Cancel all BIDS for Account A:: 0x9574bc34a613e7a36a306b61bc59dc9dda6994a2224a11ed63e017d6af7dd0d9
CURRENT BEST PRICE LEVELS:
There is no eAPT being bought or sold right now!
```

This one is straightforward, but it's worth nothing that there are no longer orders on the book unlike in the step above.
That's because in this case, all of the liquidity in the order book has been cancelled by our cancelling all of Account A's orders (since Account A's orders were all the orders on the book).

#### Step 7: Place Multiple Competitive Limit Orders (as Account A)

```
Press enter to place competitive limit orders (top-of-book) with Account A.
Account A has created multiple competitive limit orders!
TRANSACTIONS EXECUTED (first-to-last):
  * Place limit BID/BUY order (100 lots) (1000 ticks/lot): 0x82869ddaad27e0a3f1d71986197780ac3041056c9cca4c6b236cba5661e5cb3c
  * Place limit ASK/SELL order (100 lots) (2000 ticks/lot): 0xb6d9dbe0dd18240731ba566f4e551f40f033dc114913d6f57c4daa15fb19969c
  * Place limit BID/BUY order (200 lots) (1001 ticks/lot): 0xf59b35d778c590499f43a73588a7abd20db3ad397495783101c4e00c75bd3087
  * Place limit ASK/SELL order (200 lots) (1999 ticks/lot): 0x21708b891a921cf89c97a3581cc3a7d2eef30266ceea64284a4b6415c0d7fceb
  * Place limit BID/BUY order (300 lots) (1002 ticks/lot): 0xd9cffeec8e90a5ad58740da35a85191d73e084fd32e5ef0955ad8cac063244b3
  * Place limit ASK/SELL order (300 lots) (1998 ticks/lot): 0x7dd286ee3f3e5e14d4ed478c95dae3523554132e2a09716fc2f107b000a8a953
  * Place limit BID/BUY order (400 lots) (1003 ticks/lot): 0xda3d13b0dd646b5d55acda1c4e3013e38bd1f6e76e000c8b820d02904aefc75f
  * Place limit ASK/SELL order (400 lots) (1997 ticks/lot): 0x381589f7f89c42a161beb38ac4967dc5ca2cd81d69e3cd82a9f522a3db788071
  * Place limit BID/BUY order (500 lots) (1004 ticks/lot): 0x841cac8504c8e3a9cc153203f4fe1e1fbe6a8c36a25af5ea2a3d5f49f59c3f78
  * Place limit ASK/SELL order (500 lots) (1996 ticks/lot): 0x81a2832772a82573db4a7ef9374edb31d1e0f989ee9de14cfb4ebd9c6f75fca3
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
