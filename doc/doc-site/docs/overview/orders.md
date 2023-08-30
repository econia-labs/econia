# Orders

For each market, Econia tracks bids and asks in two places:

1. A global [`OrderBook`] resource for the market.
1. A user-specific [`MarketAccount`] for each user trading on the market.

## Order book structure

Econia uses a custom data structure, the [AVL queue], for storing orders.
In short, the [AVL queue] combines an AVL tree with a doubly linked list at every tree node, where tree nodes are price levels and list nodes are orders.
For example, consider the following "ascending" [AVL queue]:

> ```
>                                    1001 [35 -> 38]
>                                   /    \
>               [50 -> 60 -> 55] 1000    1003 [20]
> AVL queue head ^                      /    \
>                          [15 -> 5] 1002    1004 [4 -> 10]
>                                                       ^ AVL queue tail
> ```

Here, orders are sorted by:

1. Increasing price, then
1. Increasing order of insertion within a price level.

Conversely, consider the following "descending" [AVL queue]:

> ```
>                         992 [25 -> 28]
>                        /   \
>    [30 -> 40 -> 45] 991    994 [18]
>  AVL queue tail ^         /   \
>               [14 -> 4] 993   995 [11 -> 2]
>                                    ^ AVL queue head
> ```

Here, orders are sorted by:

1. *Decreasing* price, then
1. Increasing order of insertion within a price level.

Each [`OrderBook`] has an ascending [AVL queue] for asks, and a descending [AVL queue] for bids, such that the two structures above produce the following price-time priority order book:

<table>

import ColoredText from '@site/src/components/ColoredText';

<tr><td>

| Price | Size | Side                                           |
| ----- | ---- | ---------------------------------------------- |
| 1004  | 10   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1004  | 4    | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1003  | 20   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1002  | 5    | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1002  | 15   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1001  | 38   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1001  | 35   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1000  | 55   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1000  | 60   | <ColoredText color="#ff0000">Ask</ColoredText> |
| 1000  | 50   | <ColoredText color="#ff0000">Ask</ColoredText> |

</td><td>

| Price | Size | Side                                           |
| ----- | ---- | ---------------------------------------------- |
| 995   | 11   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 995   | 2    | <ColoredText color="#00ff00">Bid</ColoredText> |
| 994   | 18   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 993   | 14   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 993   | 4    | <ColoredText color="#00ff00">Bid</ColoredText> |
| 992   | 25   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 992   | 28   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 991   | 30   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 991   | 40   | <ColoredText color="#00ff00">Bid</ColoredText> |
| 991   | 45   | <ColoredText color="#00ff00">Bid</ColoredText> |

</td></tr></table>

Here, a large taker buy will fill against asks in the following sequence:

1. Price 1000, size 50
1. Price 1000, size 60
1. Price 1000, size 55
1. Price 1001, size 35
1. ...

Similarly, a large taker sell will fill against bids in the following sequence:

1. Price 995, size 11
1. Price 995, size 2
1. Price 994, size 18
1. Price 993, size 14
1. ...

### Insertion

When a new order is placed, it is inserted at the tail of the corresponding doubly linked list for the given price level, if such a price level is already in the tree.
For instance, continuing the above example, placing an ask order for size 18 at price 1003 would lead to the following asks AVL queue:

> ```
>                      1001 [35 -> 38]
>                     /    \
> [50 -> 60 -> 55] 1000    1003 [20 -> 18]
>                         /    \       ^ new list node
>            [15 -> 5] 1002    1004 [4 -> 10]
> ```

Attempting to place another ask at a price of 1005, however, would require inserting a new tree node, yielding an unbalanced AVL tree:

> ```
>     1001
>    /    \
> 1000    1003
>        /    \
>     1002    1004
>                 \
>                 1005
> ```

And this would require a rotation:

> ```
>         1003
>        /    \
>     1001    1004
>    /    \       \
> 1000    1002    1005
> ```

This self-balancing behavior reduces lookup cost reductions, since the upper limit on AVL tree height is approximately $1.44 \log_2 n$, where $n$ is the number of tree nodes.

:::tip

See the [AVL queue height spec] for more mathematical properties and derivations.

:::

Without an upper bound on the number of price levels, however, the tree can still grow to prohibitive sizes, since Aptos' storage gas schedule charges per-item costs.
In particular, each tree node is a table entry, meaning that lookup gas costs increase linearly with tree height.

### Eviction

To prevent tree height from growing too tall, the AVL queue supports eviction functionality, whereby the AVL queue tail is popped upon insertion of a different order, if one of two conditions are met:

1. The tree exceeds a specified critical height, or
1. The AVL tree cannot fit any more orders.

Presently, the AVL tree supports up to [`N_NODES_MAX`] = 16383 orders at a time, meaning that for a critical height of 18, for example, up to 16383 orders, each at a different price level, are supported.
At a critical height of 10 however, eviction may happen for as few as 376 price levels, and is guaranteed to happen for 2048 or more price levels, due to the upper and lower bounds on price level count for a given height:

:::note

Again, see [AVL queue height spec] for supporting calculations.

:::

| Tree height | Min price levels | Max price levels |
| ----------- | ---------------- | ---------------- |
| 0           | 1                | 1                |
| 1           | 2                | 3                |
| 2           | 4                | 7                |
| ...         | ...              | ...              |
| 10          | 232              | 2047             |
| 11          | 376              | 4095             |
| ...         | ...              | ...              |
| 18          | 10945            | 524287           |
| 19          | 17710            | 1048575          |

For example, consider the following price level tree:

> ```
>     1001
>    /    \
> 1000    1003
> ```

Here, the tree has a height of one, and if a critical height of 1 were chosen, the following order structure would be valid:

> ```
>                1001 [12 -> 45 -> 67]
>               /    \
> [45 -> 78] 1000    1003 [19]
> ```

Up to 16377 orders could be placed at a price of 1000 without meeting the eviction criteria, but if an order were placed at price 1002, the tree would exceed the critical height and the next insertion would result in an eviction.

The first insertion at price 1002 results in a tree that exceeds the critical height for this example:

> ```
>                1001 [12 -> 45 -> 67]
>               /    \
> [45 -> 78] 1000    1003 [19]
>                   /
>               1002 [43]
> ```

The next insertion at price 1002 results in an eviction, since the critical height has been exceeded prior to the insertion:

> ```
>                1001 [12 -> 45 -> 67]
>               /    \
> [45 -> 78] 1000    1002 [43 -> 78]
> ```

Here, the single order at price 1003 has been evicted.

:::note

Econia does not use a critical height of 1. The actual critical height is defined at [`CRITICAL_HEIGHT`].

:::

## Units and market parameters

There are a few important properties one cares about when creating and configuring a market, in rough order of priority:

#### Price granularity

Market participants should be able to express prices that are close enough together to be effectively continuous while being far enough apart to reflect meaningful movement with a single increment.

- **Too granular:** Almost every order occupies its own price level, and user interfaces struggle to display a useful segment of the order book before running out of visual real-estate.
  Maximum price may be too low (not common).
- **Too coarse:** A single increment (or decrement) in price reflects a dramatic shift in value whose magnitude exceeds those of smaller movements that are still meaningful to market participants.
  Minimum price may be too high (common).
- **Just right:** Prices are effectively continuous in that any meaningful movement is always expressible as some increment or decrement in price.
  Orders coalesce into useful price levels, and the minimum/maximum prices are not relevant concerns to market action.

#### Minimum order size

Market participants should be able to create a limit order as long as it's for a meaningful amount of asset.
Each individual limit order affected by a market order adds to the network fee cost of the market order's execution.
Thus, it's in every participant's interest that every limit order has a meaningful enough size to include in the execution of a market order.

- **Too low:** The limit order books become polluted with small orders and it becomes difficult or impossible to execute a market order without paying a significant network fee.
  Malicious actors may conduct a denial-of-service attack by sending in lots of orders with negligible size.
- **Too high:** Some or many meaningful market participants are cut out of trading action and thus must take their liquidity somewhere else.
- **Just right:** Anyone who wants to provide liquidity can, even at smaller amounts, but malicious actors are denied an attack vector.

#### Order size granularity

Market participants should be able to express any amount as an order size that is close to or equal to the amount it reflects.
One increment or decrement in order size should be a meaningful but not overwhelming difference in value.

- **Too granular:** Size granularity is too coarse due to lack of ability to express the price of one size increment (or decrement) in terms smaller than a single subunit of asset.
- **Too coarse:** A single increment (or decrement) in size reflects a dramatic shift in value whose magnitude exceeds those of smaller changes that are still meaningful to market participants. Minimum order size may be too high (not common).
- **Just right:** Every amount of asset is expressible as a size with an equivalent asset amount that's close enough to the original amount so as to not change its value by a meaningful amount.

Let's create a market with these key properties in mind, and find a configuration that makes sense in light of these concerns.

### Creating hypothetical markets

Consider a hypothetical trading pair `APT/USDC`, `APT` denominated in `USDC`.
Here, `APT` is considered the "base" asset and `USDC` is considered the "quote asset", meaning that orders sized in `APT` are quoted in `USDC` per `APT`:

| Term        | Specifies   | Symbol | Unit Decimals | Unit Price |
| ----------- | ----------- | ------ | ------------- | ---------- |
| Base asset  | Order size  | `APT`  | 8             | \$7.32     |
| Quote asset | Order price | `USDC` | 6             | \$1.00     |

We'd like to find a market configuration that makes sense given the above economic state.
Configuring a market requires three _integer_ values beyond the base and quote type, since the Econia Move package uses only integer arithmetic:

| Parameter          | Meaning                  | Units                      |
| ------------------ | ------------------------ | -------------------------- |
| Lot size           | Order size granularity   | Subunits of base (`APT`)   |
| Tick size          | Lot value granularity    | Subunits of quote (`USDC`) |
| Minimum order size | Minimum limit order lots | Number of lots             |

This section utilizes helpers from the Econia Python SDK.
If you'd like to follow along, run in the nearest terminal:

```bash
pip3 install econia-sdk
python3
>>> from econia_sdk.utils.decimals import *
```

Take a look at the code [here] to see what's available in that package.

We'd like the value of one increment in order size to be worth about a penny, say \$0.00732.
That means our lot size (in unit terms) should be 0.001 `APT`, which is worth said amount.
We'd also like the market to have a price granularity of one-tenth of a penny (0.001 `USDC`).
Last, we'd like the market to have a minimum order size of 0.5 `APT` (worth \$3.66).
We're given the base (`APT`) and quote (`USDC`) decimals: 8 and 6 respectively.

The above configuration can be plugged into `get_market_parameters_integer` from the SDK to obtain the market configuration:

```python
>>> base_decimals = 8
>>> quote_decimals = 6
>>> size_precision_nominal = "0.001"
>>> price_precision_nominal = "0.001"
>>> min_size_nominal = "0.5"
>>> (lot_size, tick_size, min_size) = get_market_parameters_integer(
... size_precision_nominal,
... price_precision_nominal,
... min_size_nominal,
... base_decimals,
... quote_decimals,
... )
>>> (lot_size, tick_size, min_size)
(100000, 1, 500)
```

It's easy to tell if this is reasonable by checking the maximum price given our price precision.

```python
>>> get_max_price_nominal(price_precision_nominal)
Decimal('4294967.295')
```

This means the maximum price for 1 `APT` in our market is \$4,294,967.295 which is plenty high.
We are done configuring the market now, these are our results:

| Parameter    | Units                | Value  | Meaning                  |
| ------------ | -------------------- | ------ | ------------------------ |
| Lot size     | Subunits (of `APT`)  | 100000 | Order size granularity   |
| Tick size    | Subunits (of `USDC`) | 1      | Lot value granularity    |
| Minimum size | Lots (of `APT`)      | 500    | Minimum limit order lots |

Always remember to check the maximum price of your configuration to ensure adequate price granularity and room for movement both upwards and downwards!
Note that price granularity is equivalent to the minimum price (in nominal terms) for a market.

______________________________________________________________________

Next, consider a liquid staking derivative `sAPT` trading against `APT`, `sAPT/APT`, both having 8 decimals.
Since the two assets have almost the same nominal price, price granularity will need to be much higher here.

| Variable                | Value          |
| ----------------------- | -------------- |
| Nominal size precision  | 0.001 `sAPT`   |
| Nominal price precision | 0.000001 `APT` |
| Nominal minimum size    | 0.5 `sAPT`     |
| Base decimals           | 8              |
| Quote decimals          | 8              |

Let's check the market parameters using the SDK:

```python
>>> base_decimals = 8
>>> quote_decimals = 8
>>> size_precision_nominal = "0.001"
>>> price_precision_nominal = "0.000001"
>>> min_size_nominal = "0.5"
>>> (lot_size, tick_size, min_size) = get_market_parameters_integer(
... size_precision_nominal,
... price_precision_nominal,
... min_size_nominal,
... base_decimals,
... quote_decimals,
... )
...
ValueError: The price is too granular given the size granularity.
```

It's possible for a price precision to be too granular because the minimum tick size is 1 subunit of quote.
We have to choose between less price precision, or less size precision (the latter is illustrated below):

```python
>>> size_precision_nominal = "0.01" # more coarse by an order of magnitude
>>> (lot_size, tick_size, min_size) = get_market_parameters_integer(
... size_precision_nominal,
... price_precision_nominal,
... min_size_nominal,
... base_decimals,
... quote_decimals
... )
>>> (lot_size, tick_size, min_size)
(1000000, 1, 50)
```

This gives us a price precision of 1/10000th of a penny, with no room to go more precise should we desire.
However we recall that the most granular possible price isn't necessarily desirable due to almost every order then occupying its own price level, cluttering user interfaces.
Some coarseness is desirable for that reason, therefore the market creator might instead use less price granularity and choose to preserve size precision.
Although it is possible for user interfaces to summarize orders into price levels that don't actually exist, this approach would represent to the user information that is not accurate, and is not recommended.

Let's check the maximum price of this market, keeping in mind that it should hover around 1 since the assets have almost the same value:

```python
>>> get_max_price_nominal(price_precision_nominal)
Decimal('4294.967295')
```

Always remember to check the maximum price for a given price precision before using it to register a market.

:::tip

Prices in Econia are represented as 32-bit integers, such that the maximum possible integer price is $2^{32}-1 = 4294967295$ ticks per lot.

:::

That would be a maximum price of 4294.967295 `sAPT` per `APT`, which is plenty high.
Thus our final market parameters are:

| Parameter    | Units                | Value   | Meaning                  |
| ------------ | -------------------- | ------- | ------------------------ |
| Lot size     | Subunits (of `sAPT`) | 1000000 | Order size granularity   |
| Tick size    | Subunits (of `APT`)  | 1       | Lot value granularity    |
| Minimum size | Lots (of `sAPT`)     | 50      | Minimum limit order lots |

## Adversarial considerations

Econia operates within the bounds of the Aptos virtual machine, a resource-scarce computing environment that imposes a unique set of operational constraints.
In particular, Aptos' gas schedule charges for each "per-item" storage operation, which means that the cost of a transaction increases each time a `key`-able resource or a table entry is accessed.

Since Econia's AVL queue is based on table entries, this means that Econia could become prohibitively expensive if it did not place an upper bound on the number of possible price levels.
For instance, if Econia were to allow an unbounded number of price levels and 256-bit prices, then an attacker could place orders at integer prices of $1, 2, 3, 4, \ldots$ and so on, potentially leading to a tree of height $h \approx 1.44 * 256 \approx 368$, such that insertion/removal operations would have to access as many as 368 table entries.
This would lead to prohibitively high gas costs, such that a malicious actor could effectively denial-of-service (DoS) an order book by placing orders across all possible integer prices below/above the spread (depending on the side).

In the interest of preventing such an attack, Econia's AVL queue implementation thus sets an upper bound on the number of price levels, as well as the number of total orders, allowed on a given side of the order book.
Yet simply imposing an upper bound is not enough:
with only an upper bound on the size of the order book, an attacker could simply place the maximum number of orders possible to completely occupy the entire order book, far enough away from the spread so that no one would ever accept the best price.
Here the order book would be practically locked until the attacker decided to cancel an order.

Hence Econia additionally imposes eviction logic, whereby the order with lowest price-time priority is evicted if the order book fills up.
Here, orders far away from the spread are subject to cancellation if a better price comes around, such that an attacker attempting to fill up the order book will either have their orders matched against or will get evicted.
If an attacker were to attempt placing and cancelling during the same transaction to circumvent these implications, they would still have to pay for:

1. [`N_NODES_MAX`] insertions to the AVL queue to place their malicious orders,
1. [`N_NODES_MAX`] removals from the AVL queue for the evictee cancellations, and
1. [`N_NODES_MAX`] removals from the AVL queue to cancel their own malicious orders.

Notably, each of these operations entails assorted function calls, global state mutation, etc., such that the requisite transaction would fail due to too high of a gas cost.
In theory an attacker could split up the operation across multiple transactions, but then of course they risk having their orders filled at a price worse than the best market price (since they would have to place an order closer to the spread than that of the best order, in order to evict the order with the highest price-time priority).

In the rare case that an attacker is also a block-producing node, then the multi-transaction requirement does not necessarily apply, but here there is a larger issue at play that affects more than just Econia:
block-producing nodes have the power to sequence transactions in ways that benefit themselves, even to the detriment of others.
A solution to this broader issue (miner extractable value, or MEV) lies outside the scope of the present discussion.

Note that the economic outcomes of any adversarial behaviors discussed above do not constitute a failure per se of the Econia protocol, but rather, present a set of critical implications for anyone who makes assumptions about Econia's operations:
if a substantial portion of an order book were to be evicted, then it would not be the case that Econia had been "hacked", as Econia would continue to accept new orders from trading bots, retail users, etc., and the order book could freely fill back up.
But if someone were to build a protocol on top of Econia that assumed there would *always* be orders within a certain price range, for example, then the violation of this assumption could lead to economic losses higher up in the protocol dependency stack.

Hence the above analysis is provided in the interest of educating protocol developers about potential adversarial dynamics, such that they may avoid making erroneous assumptions with unintended consequences.

## More on data structures

An Econia [`OrderBook`] tracks each order as [`market::Order`], which is complemented by a [`user::Order`] under the corresponding user's [`MarketAccount`]:
when a user places a bid, for example, the global [`OrderBook`] for the market is updated along with the user's corresponding [`MarketAccount`].

While [`market::Order`] instances are stored in an [AVL queue] inside an [`OrderBook`] for the corresponding side, [`user::Order`] instances are stored in a different custom data structure, the [`Tablist`].
A [`Tablist`] is a hybrid between a doubly linked list and a table, such that iteration is possible both during runtime and off-chain.
Here, a user's asks and bids are each stored in a [`Tablist`], having key-value pairs where the value is a [`user::Order`].
The key in the pair is known as an "access key", which essentially functions as a pointer into [`Tablist`] memory:

Rather than allocate a new node for each order and de-allocate it when the order fills, unused nodes are pushed onto a stack of inactive nodes, then popped off when a new order needs to be tabulated.
Each node is referred to by its index in the underlying table, and this index is the access key used for $O(1)$ node lookup.

Each [`market::Order`] stores the access key for the corresponding [`user::Order`], and similarly, each [`user::Order`] stores a "market order ID" used for lookup within the [AVL queue].
As explained in the [market module documentation], a market order ID encodes the price of the order as well as a counter for the number of orders that have been placed on the corresponding order book.

Notably, each market order ID also contains an [AVL queue]-specific access key, which essentially functions as a pointer into [AVL queue] memory for a similar inactive node stack paradigm.
Whether in a [`MarketAccount`] or an [`OrderBook`], the inactive node stack approach decreases gas costs by minimizing the number of table item creations.

[avl queue]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/avl_queue.md
[avl queue height spec]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/avl_queue.md#height
[here]: https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/utils/decimals.py
[market module documentation]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md
[`critical_height`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_CRITICAL_HEIGHT
[`market::order`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_Order
[`marketaccount`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
[`n_nodes_max`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX
[`orderbook`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook
[`tablist`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/tablist.md#0xc0deb00c_tablist_Tablist
[`user::order`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_Order
