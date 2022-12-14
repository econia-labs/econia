# Orders

For each market, Econia tracks bids and asks in two places:

1. A global [`OrderBook`] resource for the market.
1. A user-specific [`MarketAccount`] for each user trading on the market.

## Order book structure

Econia uses a custom data structure, the [AVL queue], for storing orders.
In short, the [AVL queue] combines an AVL tree with a doubly linked list at every tree node, where tree nodes are price levels and list nodes are orders.
For example, consider the following "ascending" [AVL queue]:

>                                        1001 [35 -> 38]
>                                       /    \
>                   [50 -> 60 -> 55] 1000    1003 [20]
>     AVL queue head ^                      /    \
>                              [15 -> 5] 1002    1004 [4 -> 10]
>                                                           ^ AVL queue tail

Here, orders are sorted by:

1. Increasing price, then
1. Increasing order of insertion within a price level.

Conversely, consider the following "descending" [AVL queue]:


>                             992 [25 -> 28]
>                            /   \
>        [30 -> 40 -> 45] 991    994 [18]
>      AVL queue tail ^         /   \
>                   [14 -> 4] 993   995 [11 -> 2]
>                                        ^ AVL queue head

Here, orders are sorted by:

1. *Decreasing* price, then
2. Increasing order of insertion within a price level.

Each [`OrderBook`] has an ascending [AVL queue] for asks, and a descending [AVL queue] for bids, such that the two structures above produce the following price-time priority order book:


<table>

<tr><td>

| Price | Size | Side                                       |
|-------|------|--------------------------------------------|
| 1004  | 10   | <span style={{color: 'red'}}>Ask</span>    |
| 1004  | 4    | <span style={{color: 'red'}}>Ask</span>    |
| 1003  | 20   | <span style={{color: 'red'}}>Ask</span>    |
| 1002  | 5    | <span style={{color: 'red'}}>Ask</span>    |
| 1002  | 15   | <span style={{color: 'red'}}>Ask</span>    |
| 1001  | 38   | <span style={{color: 'red'}}>Ask</span>    |
| 1001  | 35   | <span style={{color: 'red'}}>Ask</span>    |
| 1000  | 55   | <span style={{color: 'red'}}>Ask</span>    |
| 1000  | 60   | <span style={{color: 'red'}}>Ask</span>    |
| 1000  | 50   | <span style={{color: 'red'}}>Ask</span>    |

</td><td>

| Price | Size | Side                                       |
|-------|------|--------------------------------------------|
| 995   | 11   | <span style={{color: 'green'}}>Bid</span>  |
| 995   | 2    | <span style={{color: 'green'}}>Bid</span>  |
| 994   | 18   | <span style={{color: 'green'}}>Bid</span>  |
| 993   | 14   | <span style={{color: 'green'}}>Bid</span>  |
| 993   | 4    | <span style={{color: 'green'}}>Bid</span>  |
| 992   | 25   | <span style={{color: 'green'}}>Bid</span>  |
| 992   | 28   | <span style={{color: 'green'}}>Bid</span>  |
| 991   | 30   | <span style={{color: 'green'}}>Bid</span>  |
| 991   | 40   | <span style={{color: 'green'}}>Bid</span>  |
| 991   | 45   | <span style={{color: 'green'}}>Bid</span>  |

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

## Insertions

When a new order is placed, it is inserted at the tail of the corresponding doubly linked list for the given price level, if such a price level is already in the tree.
For instance, continuing the above example, placing an ask order for size 18 at price 1003 would lead to the following asks AVL queue:

>                          1001 [35 -> 38]
>                         /    \
>     [50 -> 60 -> 55] 1000    1003 [20 -> 18]
>                             /    \       ^ new list node
>                [15 -> 5] 1002    1004 [4 -> 10]

Attempting to place another ask at a price of 1005, however, would require inserting a new tree node, yielding an unbalanced AVL tree:

>         1001
>        /    \
>     1000    1003
>            /    \
>         1002    1004
>                     \
>                     1005

And this would require a rotation:

>             1003
>            /    \
>         1001    1004
>        /    \       \
>     1000    1002    1005

This self-balancing behavior reduces lookup cost reductions, since the upper limit on AVL tree height is approximately $1.44 \log_2 n$, where $n$ is the number of tree nodes.

:::tip

See the [AVL queue height spec] for more mathematical properties and derivations.

:::

Without an upper bound on the number of price levels, however, the tree can still grow to prohibitive sizes, since Aptos' storage gas schedule charges per-item costs.
In particular, each tree node is a table entry, meaning that lookup gas costs increase linearly with tree height.

## Eviction

To prevent tree height from growing too tall, the AVL queue supports eviction functionality, whereby the AVL queue tail is popped upon insertion of a different order, if one of two conditions are met:

1. The tree exceeds a specified critical height, or
1. The AVL tree cannot fit any more orders.

Presently, the AVL tree supports up to [`N_NODES_MAX`] = 16383 orders at a time, meaning that for a critical height of 18, for example, up to 16383 orders, each at a different price level, are supported.
At a critical height of 10 however, eviction may happen for as few as 376 price levels, and is guaranteed to happen for 2048 or more price levels, due to the upper and lower bounds on price level count for a given height:

:::tip

Again, see [AVL queue height spec] for supporting calculations.

:::

| Tree height  | Min price levels | Max price levels |
|--------------|------------------|------------------|
| 0            | 1                | 1                |
| 1            | 2                | 3                |
| 2            | 4                | 7                |
| ...          | ...              | ...              |
| 10           | 232              | 2047             |
| 11           | 376              | 4095             |
| ...          | ...              | ...              |
| 18           | 10945            | 524287           |
| 19           | 17710            | 1048575          |


For example, consider the following price level tree:

>         1001
>        /    \
>     1000    1003

Here, the tree has a height of one, and if a critical height of 1 were chosen, the following order structure would be valid:


>                    1001 [12 -> 45 -> 67]
>                   /    \
>     [45 -> 78] 1000    1003 [19]

Up to 16377 orders could be placed at a price of 1000 without meeting the eviction criteria, but if an order were placed at price 1002, the tree would exceed the critical height and the next insertion would result in an eviction.

The first insertion at price 1002 results in a tree that exceeds the critical height for this example:

>                    1001 [12 -> 45 -> 67]
>                   /    \
>     [45 -> 78] 1000    1003 [19]
>                       /
>                   1002 [43]

The next insertion at price 1002 results in an eviction, since the critical height has been exceeded prior to the insertion:

>                    1001 [12 -> 45 -> 67]
>                   /    \
>     [45 -> 78] 1000    1002 [43 -> 78]

Here, the single order at price 1003 has been evicted.

:::note

Econia does not use a critical height of 1. The actual critical height is defined at [`econia::market::CRITICAL_HEIGHT`].

:::

## Lots, ticks, size, and price

Consider a hypothetical trading pair `APT/USDC`, `APT` denominated in `USDC`.
Here, `APT` is considered the "base" asset and has 8 decimals, meaning that the smallest indivisible subunit of `APT` corresponds to $1^{-8} = 0.00000001$ `APT`.
`USDC` is considered the "quote" asset and has 6 decimals, meaning that the smallest indivisible subunit of `USDC` corresponds to $1^{-6} = 0.000001$ `USDC`.

Econia's matching engine is limited to transacting indivisible subunits (e.g. $1^{-8} = 0.00000001$ `APT` or $1^{-6} = 0.000001$ `USDC`) at a time and operates purely on integers, grouping base asset subunits into "lots" and quote asset subunits into "ticks".
The "lot size" is the number of indivisible subunits in a lot, and the "tick size" is the number of indivisible subunits in a tick.
Order size is defined as the number of lots in an order, and price is defined as the number of ticks per lot.

:::tip

Lot size and tick size are configured during market registration.

:::

For example, consider (in decimal units) an order for 7.8 `APT` at a price of 5.23 `USDC` per `APT`, corresponding to 40.794 `USDC` total, or $40.794 / 1^{-6} = 40794000$ `USDC` subunits.

Assuming that 0.1 `APT` (decimal) order size granularity is sufficient for the market, the corresponding lot size is then $0.1 / 1^{-8} = 10000000$ indivisible subunits.
This means that the original price of 5.23 `USDC` per `APT` corresponds to 0.523 `USDC` per 0.1 `APT` (per lot).
Assuming that 0.001 `USDC` price granularity per lot (0.01 `USDC` per `APT`) is sufficient for the market, the corresponding tick size is then $0.001 / 1^{-6} = 1000$ indivisible subunits:

| Field                                | Value    |
|--------------------------------------|----------|
| Order size granularity (`APT`)       | 0.1      |
| Lot size                             | 10000000 |
| Price granularity (`USDC` per `APT`) | 0.01     |
| Price granularity (`USDC` per lot)   | 0.001    |
| Tick size                            | 1000     |
| Order size (`APT`)                   | 7.8      |
| Order size (lots)                    | 78       |
| Price (`USDC` per `APT`)             | 5.23     |
| Price (`USDC` per lot)               | .523     |
| Price (ticks per lot)                | 523      |
| Total `USDC` (decimal)               | 40.794   |
| Total `USDC` (subunits)              | 40794000 |

Note that Econia can only support precision down to a single indivisible subunit for either base or quote.
This means, for example, that a market may not have a decimal order size granularity of $1^{-9} = 0.000000001$ `APT`, as each increment in size would correspond to a number of base asset subunits that could not be represented as an integer (0.1 indivisible subunits of `APT`).

Similarly, if a market has a decimal order size granularity of 0.0001 `APT` (lot size 10000), than it can only support decimal price granularity down to 0.01 `USDC` per `APT`:
at the lowest possible integer price of 1 tick per lot, the decimal change in total quote amount for each additional lot traded would be $0.0001 * 0.01 = 0.000001$ `USDC`, or one indivisible subunit of `USDC`, corresponding to a tick size of 1.
A decimal price granularity of 0.001 `USDC` per `APT` would not be supported, however, because at the lowest possible integer price of 1 tick per lot, the decimal change in total quote amount for each additional lot traded would be $0.0001 * 0.001 = 0.0000001$ `USDC`, a quote asset amount that could not be represented as an integer multiple of subunits (0.1 indivisible subunits of `USDC`).

Hence to check that a lot size/tick size combination is even possible for a market:

1. Pick a decimal order size granularity: 0.1 `APT`.
2. Pick a decimal price granularity : 0.01 `USDC` per `APT`.
3. Calculate the product, verifying that the result can be represented as an integer multiple of quote asset subunits: $0.1 * 0.01 = 0.001 > 0.000001 = 1^{-6}$.
4. Convert the product to quote asset subunits, yielding tick size: $0.001 / 1^{-6} = 1000$.
5. Convert decimal order size granularity to base asset subunits, yielding lot size: $0.1 / 1^{-8} = 10000000$.

<!---Alphabetized reference links-->

[AVL queue]:                         https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/avl_queue.md
[AVL queue height spec]:             https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/avl_queue.md#height
[`econia::market::CRITICAL_HEIGHT`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_CRITICAL_HEIGHT
[`MarketAccount`]:                   https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
[`N_NODES_MAX`]:                     https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX
[`OrderBook`]:                       https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook