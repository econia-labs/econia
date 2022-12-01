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

| Price | Size | Side |
|-------|------|------|
| 1004  | 10   | Ask  |
| 1004  | 4    | Ask  |
| 1003  | 20   | Ask  |
| 1002  | 5    | Ask  |
| 1002  | 15   | Ask  |
| 1001  | 38   | Ask  |
| 1001  | 35   | Ask  |
| 1000  | 55   | Ask  |
| 1000  | 60   | Ask  |
| 1000  | 50   | Ask  |
| 995   | 11   | Bid  |
| 995   | 2    | Bid  |
| 994   | 18   | Bid  |
| 993   | 14   | Bid  |
| 993   | 4    | Bid  |
| 992   | 25   | Bid  |
| 992   | 28   | Bid  |
| 991   | 30   | Bid  |
| 991   | 40   | Bid  |
| 991   | 45   | Bid  |

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

<!---Alphabetized reference links-->

[AVL queue]:        ../../../src/move/econia/doc/avl_queue.md
[`MarketAccount`]:  ../../../src/move/econia/doc/user.md#0xc0deb00c_user_MarketAccount
[`OrderBook`]:      ../../../src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook