# Orders

## Module `0xc0deb00c::Orders`

### Test oriented implementation

The present module is implemented purely in Move, to enable coverage testing as described in `Econia::Caps`. Hence the use of [`FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap) in public functions.

### Order structure

For a market specified by `<B, Q, E>` (see `Econia::Registry`), a user's open orders are stored in an [`OO`](orders.md#0xc0deb00c\_Orders\_OO), which has a `Econia::CritBit::CB` for both asks and bids. In each tree, key-value pairs have a key formatted per `Econia::ID`, and a value indicating the order's "scaled size" remaining to be filled, where scaled size is defined as the "unscaled size" of an order divided by the market scale factor (See `Econia::Registry`):

$size\_{scaled} = size\_{unscaled} / SF$

#### Order placement

For example, if a user wants to place a bid for `1400` indivisible subunits of protocol coin `PRO` in a `USDC`-denominated market with with a scale factor of `100`, and is willing to pay `28014` indivisble subunits of `USDC`, then their bid has an unscaled size of `1400`, a scaled size of `14`, and a scaled price of `2001`. Thus when this bid is added to the user's open orders per [`add_bid`](orders.md#0xc0deb00c\_Orders\_add\_bid)`()`, into the `b` field of their [`OO`](orders.md#0xc0deb00c\_Orders\_OO)`<PRO, USDC, E2>` will be inserted a key-value pair of the form ${id, 14}$, where $id$ denotes an order ID (per `Econia::ID`) indicating a scaled price of `2001`.

***

* [Test oriented implementation](orders.md#@Test\_oriented\_implementation\_0)
* [Order structure](orders.md#@Order\_structure\_1)
  * [Order placement](orders.md#@Order\_placement\_2)
* [Struct `FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap)
* [Resource `OO`](orders.md#0xc0deb00c\_Orders\_OO)
* [Constants](orders.md#@Constants\_3)
* [Function `add_ask`](orders.md#0xc0deb00c\_Orders\_add\_ask)
* [Function `add_bid`](orders.md#0xc0deb00c\_Orders\_add\_bid)
* [Function `exists_orders`](orders.md#0xc0deb00c\_Orders\_exists\_orders)
* [Function `get_friend_cap`](orders.md#0xc0deb00c\_Orders\_get\_friend\_cap)
* [Function `init_orders`](orders.md#0xc0deb00c\_Orders\_init\_orders)
* [Function `scale_factor`](orders.md#0xc0deb00c\_Orders\_scale\_factor)
* [Function `add_order`](orders.md#0xc0deb00c\_Orders\_add\_order)
  * [Parameters](orders.md#@Parameters\_4)
  * [Returns](orders.md#@Returns\_5)
  * [Abort sceniarios](orders.md#@Abort\_sceniarios\_6)
  * [Assumes](orders.md#@Assumes\_7)

```
use 0x1::Signer;
use 0xc0deb00c::CritBit;
```

### Struct `FriendCap`

Friend-like capability, administered instead of declaring as a friend a module containing Aptos native functions, which would inhibit coverage testing via the Move CLI. See `Econia::Caps`

```
struct FriendCap has copy, drop, store
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Resource `OO`

Open orders, for the given market, on a user's account

```
struct OO<B, Q, E> has key
```

<details>

<summary>Fields</summary>

`f: u64`Scale factor`a:` [`CritBit::CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`<u64>`Asks`b:` [`CritBit::CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`<u64>`Bids

</details>

### Constants

`u64` bitmask with all bits set

```
const HI_64: u64 = 18446744073709551615;
```

Ask flag

```
const ASK: bool = true;
```

Bid flag

```
const BID: bool = false;
```

When account/address is not Econia

```
const E_NOT_ECONIA: u64 = 2;
```

When amount is not an integer multiple of scale factor

```
const E_AMOUNT_NOT_MULTIPLE: u64 = 4;
```

When amount of quote coins to fill order overflows u64

```
const E_FILL_OVERFLOW: u64 = 5;
```

When order book does not exist at given address

```
const E_NO_ORDERS: u64 = 1;
```

When open orders already exists at given address

```
const E_ORDERS_EXISTS: u64 = 0;
```

When indicated price indicated 0

```
const E_PRICE_0: u64 = 3;
```

When order size is 0

```
const E_SIZE_0: u64 = 6;
```

### Function `add_ask`

Wrapped [`add_order`](orders.md#0xc0deb00c\_Orders\_add\_order)`()` call for [`ASK`](orders.md#0xc0deb00c\_Orders\_ASK), requiring [`FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap)

```
public fun add_ask<B, Q, E>(addr: address, id: u128, price: u64, size: u64, _c: &Orders::FriendCap): (u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun add_ask<B, Q, E>(
    addr: address,
    id: u128,
    price: u64,
    size: u64,
    _c: &FriendCap
): (
    u64,
    u64
)
acquires OO {
    add_order<B, Q, E>(addr, ASK, id, price, size)
}
```

</details>

### Function `add_bid`

Wrapped [`add_order`](orders.md#0xc0deb00c\_Orders\_add\_order)`()` call for [`BID`](orders.md#0xc0deb00c\_Orders\_BID), requiring [`FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap)

```
public fun add_bid<B, Q, E>(addr: address, id: u128, price: u64, size: u64, _c: &Orders::FriendCap): (u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun add_bid<B, Q, E>(
    addr: address,
    id: u128,
    price: u64,
    size: u64,
    _c: &FriendCap
): (
    u64,
    u64
)
acquires OO {
    add_order<B, Q, E>(addr, BID, id, price, size)
}
```

</details>

### Function `exists_orders`

Return **`true`** if specified open orders type exists at address

```
public fun exists_orders<B, Q, E>(a: address): bool
```

<details>

<summary>Implementation</summary>

```
public fun exists_orders<B, Q, E>(
    a: address
): bool {
    exists<OO<B, Q, E>>(a)
}
```

</details>

### Function `get_friend_cap`

Return a [`FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap), aborting if not called by Econia

```
public fun get_friend_cap(account: &signer): Orders::FriendCap
```

<details>

<summary>Implementation</summary>

```
public fun get_friend_cap(
    account: &signer
): FriendCap {
    // Assert called by Econia
    assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
    FriendCap{} // Return requested capability
}
```

</details>

### Function `init_orders`

Initialize open orders under host account, provided [`FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap), with market types `B`, `Q`, `E`, and scale factor `f`

```
public fun init_orders<B, Q, E>(user: &signer, f: u64, _c: &Orders::FriendCap)
```

<details>

<summary>Implementation</summary>

```
public fun init_orders<B, Q, E>(
    user: &signer,
    f: u64,
    _c: &FriendCap
) {
    // Assert open orders does not already exist under user account
    assert!(!exists_orders<B, Q, E>(s_a_o(user)), E_ORDERS_EXISTS);
    // Pack empty open orders container
    let o_o = OO<B, Q, E>{f, a: cb_e<u64>(), b: cb_e<u64>()};
    move_to<OO<B, Q, E>>(user, o_o); // Move to user
}
```

</details>

### Function `scale_factor`

Return scale factor of specified open orders at given address

```
public fun scale_factor<B, Q, E>(addr: address): u64
```

<details>

<summary>Implementation</summary>

```
public fun scale_factor<B, Q, E>(
    addr: address
): u64
acquires OO {
    // Assert open orders container exists at given address
    assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
    // Return open order container's scale factor
    borrow_global<OO<B, Q, E>>(addr).f
}
```

</details>

### Function `add_order`

Add new order to users's open orders container for market `<B, Q, E>`, returning scaled size of order

#### Parameters

* `addr`: User's address
* `side`: [`ASK`](orders.md#0xc0deb00c\_Orders\_ASK) or [`BID`](orders.md#0xc0deb00c\_Orders\_BID)
* `id`: Order ID (see `Econia::ID`)
* `price`: Scaled integer price (see `Econia::ID`)
* `size`: Unscaled order size, in base coin subunits

#### Returns

* `u64`: Scaled order size
* `u64`: Number of quote coin subunits needed to fill order

#### Abort sceniarios

* If `price` is 0
* If `size` is 0
* If [`OO`](orders.md#0xc0deb00c\_Orders\_OO)`<B, Q, E>` not initialized at `addr`
* If `size` is not an integer multiple of price scale factor for given market (see `Econia::Registry`)
* If amount of quote coin subunits needed to fill order does not fit in a `u64`

#### Assumes

* Caller has constructed `id` to indicate `price` as specified in `Econia::ID`, since `id` is not directly operated on or verified (`id` is only used as a tree insertion key)

```
fun add_order<B, Q, E>(addr: address, side: bool, id: u128, price: u64, size: u64): (u64, u64)
```

<details>

<summary>Implementation</summary>

```
fun add_order<B, Q, E>(
    addr: address,
    side: bool,
    id: u128,
    price: u64,
    size: u64,
): (
u64,
u64
) acquires OO {
    assert!(price > 0, E_PRICE_0); // Assert order has actual price
    assert!(size > 0, E_SIZE_0); // Assert order has actual size
    // Assert open orders container exists at given address
    assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
    // Borrow mutable reference to open orders at given address
    let o_o = borrow_global_mut<OO<B, Q, E>>(addr);
    let s_f = o_o.f; // Get price scale factor
    // Assert order size is integer multiple of price scale factor
    assert!(size % s_f == 0, E_AMOUNT_NOT_MULTIPLE);
    let scaled_size = size / s_f; // Get scaled order size
    // Determine amount of quote coins needed to fill order, as u128
    let fill_amount = (scaled_size as u128) * (price as u128);
    // Assert that fill amount can fit in a u64
    assert!(!(fill_amount > (HI_64 as u128)), E_FILL_OVERFLOW);
    // Add order to corresponding tree
    if (side == ASK) cb_i<u64>(&mut o_o.a, id, scaled_size)
        else cb_i<u64>(&mut o_o.b, id, scaled_size);
    (scaled_size, (fill_amount as u64))
}
```

</details>
