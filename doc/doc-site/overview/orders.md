# Orders

## Order ID

As described in the [`Econia::ID` module documentation](../../../src/move/econia/build/Econia/docs/ID.md), each limit order in Econia is assigned an `u128` order ID, with the most-significant ("first") 64 bits indicating the order price, and the least-significant ("last") 64 bits derived from the [Aptos database version number](https://aptos.dev/concepts/basics-txns-states/#versioned-database) at which the order was placed. In the case of an ask, the final 64 bits are simply the database version number itself, while in the case of a bid, the final 64 bits are the bitwise complement (each bit flipped) of the database version number.

### Example ask
* Scaled integer price `255` (`0b11111111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000011111111`
* Aptos database version number `170` (`0b10101010`)
    * Last 64 bits: `0000000000000000000000000000000000000000000000000000000010101010`
* Resultant order ID, base-10: `4703919738795935662250`

### Example ask
* Scaled integer price `15` (`0b1111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000000001111`
* Aptos database version number `63` (`0b111111`)
    * Last 64 bits: `1111111111111111111111111111111111111111111111111111111111000000`
* Resultant order ID, base-10: `295147905179352825792`

## Order book

As described in the [`Econia::Book` module documentation](../../../src/move/econia/build/Econia/docs/Book.md), an order book is represented by two crit-bit trees, one for asks and one for bids.
Each tree maps from order ID to a corresponding position ([`P`](../../../src/move/econia/build/Econia/docs/Book.md#Struct-`P`)) on the book, with each position specifying a scaled size (number of base coin parcels to be filled) and the address of the user holding the position.
Here, the order ID enables efficient traversal from position to position when filling market sells against the book (described in more detail in the module documentation), due to the underlying properties of crit-bit trees.

As described in the [`Econia::Critbit` module documentation](../../../src/move/econia/build/Econia/docs/CritBit.md), crit-bit trees do not require complex rebalancing algorithms like AVL or red-black binary search trees, and they support rapid predecessor/successor iteration because elements are automatically sorted upon insertion.
Key-value pairs are stored in outer nodes along the tree, with inner nodes indicating the most-significant critical bit (crit-bit) of divergence between the node's two subtrees.
In practice, this means that all outer nodes to the left of a given inner node are unset at its critical bit, and all outer nodes to the right of a given inner node are set at its critical bit:

```
       2nd
      /   \
    001   1st
         /   \
       101   0th
            /   \
          110   111
```

Here, the key `001` is to the left of the inner node marked `2nd`, meaning that it is unset (has a `0`) at the bit 2 position, while all the other nodes are to the right, and are set (have a `1`) at the bit 2 position for their corresponding keys.

```
001
^ Unset
```

```
101      110      111
^ Set    ^ Set    ^ Set
```

Again, crit-bit trees keys in Econia are order IDs, and as described in the [`Econia::ID` module documentation](../../../src/move/econia/build/Econia/docs/ID.md), this allows for iterated traversal from position to position on when filling market buys and sells.

## Open orders

As described in the [`Econia::Orders` module documentation](../../../src/move/econia/build/Econia/docs/Orders.md), each user also has an open orders container ([`OO`](../../../src/move/econia/build/Econia/docs/Orders.md#Struct-`OO`) which stores the order ID and unfilled size of their outstanding asks and bids.
This is updated, along with a user's order collateral container ([`OC`](../../../src/move/econia/build/Econia/docs/User.md#Struct-`OC`), each time a user places or cancels a limit order, places a market order, or has an open order filled by someone else.

## Matching engine

When a user submits a market buy or sell, Econia's matching engine ([Match.move](../../src/move/econia/sources/Match.move)) loops over positions on the order book, routes funds accordingly between users, and updates the available collateral values for the submitting user.
If there is not enough depth on the book or, in the case of a market buy, if the user runs out of quote coins before their requested order size is filled, the matching engine simply stops attempting to fill the market order.