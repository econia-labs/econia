# Orders

- [Orders](#orders)
  - [Order ID](#order-id)
    - [Example ask](#example-ask)
    - [Example ask](#example-ask-1)
  - [Order book](#order-book)
  - [Market accounts](#market-accounts)
  - [Custodians](#custodians)
  - [Matching engine](#matching-engine)

## Order ID

As described in the [`econia::order_id` module documentation](../../../src/move/econia/build/Econia/docs/order_id.md), each limit order in Econia is assigned a `u128` order ID, with the most-significant ("first") 64 bits indicating the order price, and the least-significant ("last") 64 bits derived from a market-specific counter or serial ID.
In the case of an ask, the final 64 bits are simply the serial ID itself, while in the case of a bid, the final 64 bits are the bitwise complement (each bit flipped) of the serial ID.

### Example ask
* Scaled integer price `255` (`0b11111111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000011111111`
* Serial ID `170` (`0b10101010`)
    * Last 64 bits: `0000000000000000000000000000000000000000000000000000000010101010`
* Resultant order ID, base-10: `4703919738795935662250`

### Example ask
* Scaled integer price `15` (`0b1111`)
    * First 64 bits: `0000000000000000000000000000000000000000000000000000000000001111`
* Serial ID `63` (`0b111111`)
    * Last 64 bits: `1111111111111111111111111111111111111111111111111111111111000000`
* Resultant order ID, base-10: `295147905179352825792`

## Order book

As described in the [`econia::market` module documentation](../../../src/move/econia/build/Econia/docs/market.md), an order book is represented by two crit-bit trees, one for asks and one for bids.
Each tree maps from order ID to a corresponding order on the book.
Here, the order ID enables efficient traversal from order to order when filling market sells against the book (described in more detail in the module documentation), due to the underlying properties of crit-bit trees.

As described in the [`econia::critBit` module documentation](../../../src/move/econia/build/Econia/docs/critbit.md), crit-bit trees do not require complex rebalancing algorithms like AVL or red-black binary search trees, and they support rapid predecessor/successor iteration because elements are automatically sorted upon insertion.
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

Here, the key `001` is to the left of the inner node marked `2nd`, meaning that the key `001` is unset (has a `0`) at the bit 2 position, while all the other nodes are to the right, and have keys that are set (have a `1`) at the bit 2 position.

```
001
^ Unset
```

```
101      110      111
^ Set    ^ Set    ^ Set
```

Again, crit-bit trees keys in Econia are order IDs, and as described in the [`econia::order_id` module documentation](../../../src/move/econia/build/Econia/docs/order_id.md), this design allows for iterated traversal from position to position when filling market buys and sells.

## Market accounts

As described in the [`econia::user` module documentation](../../../src/move/econia/build/Econia/docs/user.md), each user also has market accounts map ([`econia::user::MarketAccounts`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_MarketAccounts)), which stores information about a user's open orders and collateral statistics for a given market/custodian.
This is updated, along with a user's order collateral ([`econia::user::Collateral`](../../../src/move/econia/build/Econia/docs/user.md#0xc0deb00c_user_Collateral)), each time a user places or cancels a limit order, places a market order, or has an open order filled by someone else.

## Custodians

Econia allows third parties to register as custodians, thus receiving a custodian capability ([`econia::registry::CustodianCapability`](../../../src/move/econia/build/Econia/docs/registry.md#0xc0deb00c_registry_CustodianCapability).
Once a user opens a market account with a designated custodian, that custodian is then authorized to place/cancel orders and withdraw collateral on the user's behalf without their signature.

## Matching engine

When a user submits a market buy or sell, Econia's matching engine ([`market.move`](../../../src/move/econia/sources/market.move)) loops over positions on the order book, routes funds accordingly between users, and updates the available collateral values for the submitting user.
If there is not enough depth on the book or, in the case of a market buy, if the user runs out of quote coins before their requested order size is filled, then the matching engine simply stops attempting to fill the market order.