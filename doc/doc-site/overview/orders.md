# Orders

- [Orders](#orders)
  - [Order ID](#order-id)
    - [Example ask](#example-ask)
    - [Example bid](#example-bid)
  - [Order book](#order-book)
  - [Crit-bit trees](#crit-bit-trees)

## Order ID

As defined in [`order_id.move`](../../../src/move/econia/build/Econia/docs/order_id.md), each maker order in Econia is assigned a `u128` order ID, with the most-significant ("first") 64 bits indicating the order price (in ticks per lot), and the least-significant ("last") 64 bits derived from a market-specific [`OrderBook.counter`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook).

In the case of an ask, the final 64 bits are simply the counter, while in the case of a bid, the final 64 bits are the bitwise complement (each bit flipped) of the counter.

### Example ask
* Price (ticks per lot) of `255` (`0b11111111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000011111111`
* Counter `170` (`0b10101010`)
    * Last 64 bits: `0000000000000000000000000000000000000000000000000000000010101010`
* Resultant order ID, base-10: `4703919738795935662250`

### Example bid
* Price (ticks per lot) of `15` (`0b1111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000000001111`
* Counter `63` (`0b111111`)
    * Last 64 bits: `1111111111111111111111111111111111111111111111111111111111000000`
* Resultant order ID, base-10: `295147905179352825792`

## Order book

An Econia [`OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook) contains a [`CritBitTree`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_CritBitTree) for asks, and a [`CritBitTree`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_CritBitTree) for bids, with each tree mapping from an order ID to a corresponding [`Order`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_Order) on the [`OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook).
Here, the order ID enables efficient traversal from [`Order`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_Order) to [`Order`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_Order) when filling taker buys or sells according to price-time priority, as described in [`order_id.move`](../../../src/move/econia/build/Econia/docs/order_id.md)

## Crit-bit trees

As described in [`critbit.move`](../../../src/move/econia/build/Econia/docs/critbit.md), crit-bit trees do not require complex rebalancing algorithms like AVL or red-black binary search trees, and they support rapid predecessor/successor iteration because elements are automatically sorted upon insertion.
Key-value pairs are stored in [`OuterNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_OuterNode) instances, and [`InnerNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_InnerNode) instances indicate the most-significant critical bit (crit-bit) of divergence between the node's two subtrees.
In practice, this means that the key for each [`OuterNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_OuterNode) to the left of a given [`InnerNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_InnerNode) is unset at its critical bit, and the key for each [`OuterNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_OuterNode) to the right of a given [`InnerNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_InnerNode) is set at its critical bit:

```
       2nd
      /   \
    001   1st
         /   \
       101   0th
            /   \
          110   111
```

Here, the key `001` is to the left of the [`InnerNode`](../../../src/move/econia/build/Econia/docs/critbit.md#0xc0deb00c_critbit_InnerNode) marked `2nd`, meaning that the key `001` is unset (has a `0`) at the bit 2 position, while all the other keys are to the right and are thus set (have a `1`) at the bit 2 position.

```
001
^ Unset
```

```
101      110      111
^ Set    ^ Set    ^ Set
```

Again, crit-bit tree keys in Econia are order IDs, which allows for iterated traversal from [`Order`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_Order) to [`Order`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_Order) when filling taker buys and sells against an [`OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook), as described in [`order_id.move`](../../../src/move/econia/build/Econia/docs/order_id.md).