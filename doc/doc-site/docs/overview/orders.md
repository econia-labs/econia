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

Consider a hypothetical trading pair `APT/USDC`, `APT` denominated in `USDC`.
Here, `APT` is considered the "base" asset and `USDC` is considered the "quote asset", meaning that orders sized in `APT` are quoted in `USDC` per `APT`:

| Term        | Specifies   | Symbol |
| ----------- | ----------- | ------ |
| Base asset  | Order size  | `APT`  |
| Quote asset | Order price | `USDC` |

In addition to a base/quote trading pair, each market in Econia additionally contains the following parameters, which are selected by the market registrant during registration:

| Parameter          | Meaning                     | Example     |
| ------------------ | --------------------------- | ----------- |
| Lot size           | Order size granularity      | 0.1 `APT`   |
| Tick size          | Price granularity           | 0.01 `USDC` |
| Minimum order size | Smallest allowed order size | 0.5 `APT`   |

On this market, an order for 7.8 `APT` at a price of 5.23 `USDC` per `APT` would be valid, but the following would be invalid:

| Size | Price | Reason             |
| ---- | ----- | ------------------ |
| 7.85 | 5.23  | Size too granular  |
| 7.8  | 5.235 | Price too granular |
| 0.4  | 5.23  | Size too small     |

Econia's matching engine uses integers rather than decimals, such that conversion from decimal amounts to integer amounts requires the `aptos_framework::coin::CoinInfo.decimals` for a given `CoinType`:

| Term           | Symbol       | Coin   | Amount |
| -------------- | ------------ | ------ | ------ |
| Base decimals  | $\large d_b$ | `APT`  | 8      |
| Quote decimals | $\large d_q$ | `USDC` | 6      |

Here, a decimal amount of coins (e.g. 7.8 `APT`), can be converted to an integer amount of indivisible coin subunits (`aptos_framework::coin::Coin.value`):

```python
>>> from decimal import Decimal as dec
>>> decimals = 8
>>> coins = dec('123.456')
>>> subunits = int(coins * 10 ** decimals)
>>> subunits
12345600000
```

Similarly, other terms can be converted as follows:

| Variable                   | Decimal symbol | Integer symbol |
| -------------------------- | -------------- | -------------- |
| Lot size                   | $\large l_d$   | $\large l_i$   |
| Tick size                  | $\large t_d$   | $\large t_i$   |
| Minimum order size         | $\large m_d$   | $\large m_i$   |
| Size                       | $\large s_d$   | $\large s_i$   |
| Price                      | $\large p_d$   | $\large p_i$   |
| Total quote amount to fill | $\large a_d$   | $\large a_i$   |

1. $$\LARGE l_i = l_d 10 ^ {d_b}$$
   ```python
   >>> decimals_base = 8
   >>> lot_size_decimal = dec('0.1')
   >>> lot_size_integer = int(lot_size_decimal * 10 ** decimals_base)
   >>> lot_size_integer
   10000000
   ```
1. $$\LARGE l_d = l_i 10 ^ {-d_b}$$
   ```python
   >>> lot_size_decimal = dec(lot_size_integer) / 10 ** decimals_base
   >>> lot_size_decimal
   Decimal('0.1')
   ```
1. $$\LARGE t_i = l_d t_d 10 ^ {d_q}$$
   ```python
   >>> decimals_quote = 6
   >>> tick_size_decimal = dec('0.01')
   >>> tick_size_integer = int(lot_size_decimal * tick_size_decimal
   ...                         * 10 ** decimals_quote)
   >>> tick_size_integer
   1000
   ```
1. $$\LARGE t_d = \frac{t_i}{l_i} 10 ^ {d_b - d_q}$$
   ```python
   >>> tick_size_decimal = (dec(tick_size_integer) / dec(lot_size_integer)
   ...                      * 10 ** (decimals_base - decimals_quote)).normalize()
   >>> tick_size_decimal
   Decimal('0.01')
   ```
1. $$\LARGE m_i = m_d 10 ^ {d_b}$$
   ```python
   >>> min_size_decimal = dec('0.5')
   >>> min_size_integer = int(min_size_decimal * 10 ** decimals_base)
   >>> min_size_integer
   50000000
   ```
1. $$\LARGE m_d = m_i 10 ^ {-d_b}$$
   ```python
   >>> min_size_decimal = dec(min_size_integer) / 10 ** decimals_base
   >>> min_size_decimal
   Decimal('0.5')
   ```
1. $$\LARGE s_i = \frac{s_d}{l_d}$$
   ```python
   >>> size_decimal = dec('7.8')
   >>> size_integer = int(size_decimal / lot_size_decimal)
   >>> size_integer
   78
   ```
1. $$\LARGE s_d = s_i l_i 10 ^ {-d_b}$$
   ```python
   >>> size_decimal = dec(size_integer) * lot_size_integer / 10 ** decimals_base
   >>> size_decimal
   Decimal('7.8')
   ```
1. $$\LARGE p_i = \frac{p_d}{t_d}$$
   ```python
   >>> price_decimal = dec('5.23')
   >>> price_integer = int(price_decimal / tick_size_decimal)
   >>> price_integer
   523
   ```
1. $$\LARGE p_d = \frac{p_i t_i}{l_i} 10 ^ {d_b - d_q}$$
   ```python
   >>> price_decimal = (dec(price_integer) * dec(tick_size_integer)
   ...                  / dec(lot_size_integer)
   ...                  * 10 ** (decimals_base - decimals_quote)).normalize()
   >>> price_decimal
   Decimal('5.23')
   ```
1. $$\LARGE a_d = s_d p_d$$
   ```python
   >>> amount_decimal = size_decimal * price_decimal
   >>> amount_decimal
   Decimal('40.794')
   ```
1. $$\LARGE a_i = a_d 10 ^ {d_q}$$
   ```python
   >>> amount_integer = int(amount_decimal * 10 ** decimals_quote)
   >>> amount_integer
   40794000
   ```
1. $$\LARGE a_i = s_i p_i t_i$$
   ```python
   >>> amount_integer = size_integer * price_integer * tick_size_integer
   >>> amount_integer
   40794000
   ```
1. $$\LARGE a_d = a_i 10 ^ {-d_q}$$
   ```python
   >>> amount_decimal = dec(amount_integer) / 10 ** decimals_quote
   >>> amount_decimal
   Decimal('40.794')
   ```

Hence:

| Variable                   | Decimal amount | Integer amount |
| -------------------------- | -------------- | -------------- |
| Lot size                   | 0.1 `APT`      | 10000000       |
| Tick size                  | 0.01 `USDC`    | 1000           |
| Minimum order size         | 0.5  `APT`     | 50000000       |
| Size                       | 7.8 `APT`      | 78             |
| Price                      | 5.23 `USDC`    | 523            |
| Total quote amount to fill | 40.794 `USDC`  | 40794000       |

Note that Econia can only support precision down to a single indivisible subunit for either base or quote.
This means, for example, that a market may not have a decimal lot size of $10^{-9} = 0.000000001$ `APT`, as each increment in size would correspond to a number of base asset subunits that could not be represented as an integer (0.1 indivisible subunits of `APT`):

```python
>>> lot_size_decimal = dec('0.000000001')
>>> (lot_size_decimal * 10 ** decimals_base).normalize()
Decimal('0.1')
```

Similarly, if a market has a decimal lot size of 0.0001 `APT`, than it can only support a decimal tick size down to 0.01 `USDC` per `APT`, because the increment in total quote amount for each additional lot or tick corresponds to a single `USDC` subunit:

```python
>>> lot_size_decimal = dec('0.0001')
>>> tick_size_decimal = dec('0.01')
>>> quote_increment_decimal = lot_size_decimal * tick_size_decimal
>>> to_check = (quote_increment_decimal * 10 ** decimals_quote).normalize()
>>> to_check
Decimal('1')
```

Notably, this check amount is equivalent to the integer tick size:

```python
>>> tick_size_integer = int(lot_size_decimal * tick_size_decimal
...                         * 10 ** decimals_quote)
>>> tick_size_integer
1
```

A decimal tick size of 0.001 `USDC` per `APT` would not be supported, however, because at the lowest possible price of 1 tick, the increment in total quote amount for each additional lot could not be represented as an integer multiple of subunits:

```python
>>> tick_size_decimal = dec('0.001')
>>> quote_increment_decimal = lot_size_decimal * tick_size_decimal
>>> (quote_increment_decimal * 10 ** decimals_quote).normalize()
Decimal('0.1')
```

Hence to check that a lot size/tick size combination is even possible for a market:

1. Pick a decimal lot size.

   ```python
   >>> lot_size_decimal = dec('0.1')
   ```

1. Assert that integer lot size corresponds to an integer multiple of base subunits.

   ```python
   >>> to_check = lot_size_decimal * 10 ** decimals_base
   >>> lot_size_integer = int(to_check)
   >>> assert to_check >= 1 and to_check == lot_size_integer
   ```

1. Pick a decimal tick size.

   ```python
   >>> tick_size_decimal = dec('0.01')
   ```

1. Assert that the integer tick size corresponds to an integer multiple of quote subunits.

   ```python
   >>> to_check = (lot_size_decimal * tick_size_decimal
   ...             * 10 ** decimals_quote).normalize()
   >>> tick_size_integer = int(to_check)
   >>> assert to_check >= 1 and to_check == tick_size_integer
   ```

### Noteworthy examples

Consider the trading pair `wBTC/USDC`:
as of the time of this writing, one `BTC` costs approximately 17792.27 `USD`, so initial choices for lot size and tick size might entail:

1. 0.00001 `wBTC` decimal lot size (corresponding to 0.1779227 `USDC` nominal).
1. 0.01 `USDC` decimal tick size.

Notably, these choices yield a total quote amount increment that does not correspond to an integer multiple of `USDC` subunits:

```python
>>> lot_size_decimal = dec('0.00001')
>>> tick_size_decimal = dec('0.01')
>>> to_check = (lot_size_decimal * tick_size_decimal
...             * 10 ** decimals_quote).normalize()
>>> tick_size_integer = int(to_check)
>>> to_check
Decimal('0.1')
>>> assert to_check >= 1 and to_check == tick_size_integer
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AssertionError
```

Thus a different combination must be chosen, for example, by increasing decimal lot size by a factor of 10:

1. 0.0001 `wBTC` decimal lot size (corresponding to 1.779227 `USDC` nominal).
1. 0.01 `USDC` decimal tick size.

Here, the resultant quote amount increment corresponds to 1 `USDC` subunit, for a tick size of 1:

```python
>>> lot_size_decimal = dec('0.0001')
>>> to_check = (lot_size_decimal * tick_size_decimal
...             * 10 ** decimals_quote).normalize()
>>> tick_size_integer = int(to_check)
>>> assert to_check >= 1 and to_check == tick_size_integer
>>> tick_size_integer
1
```

However, the new decimal order size granularity corresponds to 1.779227 `USDC` nominal, which may not be considered granular enough.
Hence alternative parametric inputs might entail:

1. 0.00005 `wBTC` decimal order size granularity (corresponding to 0.8896135 `USDC` nominal).
1. 0.02 `USDC` decimal price granularity.

Here, the total quote amount increment again corresponds to an integer multiple of `USDC` subunits, for a tick size of 1:

```python
>>> lot_size_decimal = dec('0.00005')
>>> tick_size_decimal = dec('0.02')
>>> to_check = (lot_size_decimal * tick_size_decimal
...             * 10 ** decimals_quote).normalize()
>>> tick_size_integer = int(to_check)
>>> assert to_check >= 1 and to_check == tick_size_integer
>>> tick_size_integer
1
```

Note, however, that compared with the other viable parameter set, this set trades off size precision for price precision:
twice as much size granularity entails one half as much price granularity.

:::note

Size granularity restrictions only apply to limit orders.
Market orders and swaps allow users to specify precise trade amounts down to a single integer subunit.

:::

Hence the nominal price of 17792.27 `USD` per `BTC` must be truncated to either 17792.26 or 17792.28.
For the latter case, this entails an integer price of 889614:

```python
>>> price_decimal = dec('17792.28')
>>> price_integer = int(price_decimal / tick_size_decimal)
>>> price_integer
889614
```

Next, consider a liquid staking derivative `sAPT` trading against `APT`, `sAPT/APT`, both having 8 decimals.
Here, high price precision may be appropriate:

| Variable          | Value                     |
| ----------------- | ------------------------- |
| Decimal lot size  | 0.01 `sAPT`               |
| Decimal tick size | 0.000001 `APT` per `sAPT` |
| Base decimals     | 8                         |
| Quote decimals    | 8                         |
| Decimal price     | 1.000012 `APT` per `sAPT` |

```python
>>> decimals_base = 8
>>> decimals_quote = 8
>>> lot_size_decimal = dec('0.01')
>>> tick_size_decimal = dec('0.000001')
>>> price_decimal = dec('1.000012')
>>> lot_size_integer = int(lot_size_decimal * 10 ** decimals_base)
>>> lot_size_integer
1000000
>>> tick_size_integer = int(lot_size_decimal * tick_size_decimal
...                         * 10 ** decimals_quote)
>>> tick_size_integer
1
>>> price_integer = int(price_decimal / tick_size_decimal)
>>> price_integer
1000012
```

Next, consider `wBTC` trading against a hypothetical stable coin `USDX` with 10 decimals: `wBTC/USDX`.
Here, a market registrant may again opt for high price precision, but if they specify too much, they may not be able to encode the corresponding integer price in 32 bits:

:::tip

Prices in Econia are represented as 32-bit integers, such that the maximum possible integer price is $2^{32} = 4294967296$ ticks per lot.

:::

| Variable             | Value                          |
| -------------------- | ------------------------------ |
| Decimal lot size     | 0.0001 `wBTC`                  |
| Quote asset decimals | 10                             |
| Decimal tick size    | 0.000001 `USDX` per `wBTC`     |
| Decimal price        | 17792.280012 `USDX` per `wBTC` |

```python
>>> lot_size_decimal = dec('0.0001')
>>> decimals_quote = 10
>>> tick_size_decimal = dec('0.000001')
>>> price_decimal = dec('17792.280012')
>>> tick_size_integer = int(lot_size_decimal * tick_size_decimal
...                         * 10 ** decimals_quote)
>>> tick_size_integer
1
>>> price_integer = int(price_decimal / tick_size_decimal)
>>> price_integer
17792280012
>>> price_integer <= 2 ** 32
False
```

Hence decimal tick size must be reduced so that integer prices can fit into a 32-bit integer.

### Picking the right parameters

As shown above, picking the "correct" lot size, tick size, and minimum order size for a given market is ultimately a judgement call.
Still, however, there are several guidelines that can aid the process:

1. **Only specify as much granularity as needed**:
   overly-granular lot size and tick size combinations do not properly translate to integer tick sizes, and may make indexing more difficult.
   Three orders at price 12.34 is easier to interpret than one order each at 12.3401, 12.3404, and 12.3407.

1. **Specify a reasonable minimum order size that will help keep gas costs low**:
   when matching against the book, an AVL queue removal is required for each fill, which means that taker orders will require more global storage operations if they have to fill against more maker orders.
   For example, if the minimum order size for a market corresponds to \$ 0.1 USD nominal, and someone submits a market buy order for \$100 of the base asset, then they may have to pay the gas costs for up to $100 / 0.1 = 1000$ AVL queue operations.
   In contrast, for a more reasonable minimum order size of \$ 10 USD nominal, at most they will have to pay for 10 AVL queue operations.

1. **Plan for price increases**:
   as shown above, prices must be able to fit into 32-bit integers.
   If a market's parameters have been calibrated such that a 3x price increase will lead to a 32-bit integer overflow, then a different lot size/tick size combination should be chosen.
   Notably, if prices go up on the order of 100x, for instance, then a new market will likely be necessary anyways, due to changes in the appropriate level of granularity for a lot size/tick size combination.
   Hence initial market parameters should be chosen to support the maximum price swing possible before the registration of a new market becomes necessary due to granularity considerations alone.

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
[market module documentation]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md
[`critical_height`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_CRITICAL_HEIGHT
[`market::order`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_Order
[`marketaccount`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
[`n_nodes_max`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX
[`orderbook`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook
[`tablist`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/tablist.md#0xc0deb00c_tablist_Tablist
[`user::order`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/user.md#0xc0deb00c_user_Order
