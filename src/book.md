# Book

## Module `0xc0deb00c::Book`

### Test oriented implementation

The present module is implemented purely in Move, to enable coverage testing as described in `Econia::Caps`. Hence the use of [`FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap) in public functions.  test

### Order structure

For a market specified by `<B, Q, E>` (see `Econia::Registry`), an order book is stored in an [`OB`](book.md#0xc0deb00c\_Book\_OB), which has a `Econia::CritBit::CB` for both asks and bids. In each tree, key-value pairs have a key formatted per `Econia::ID`, and a value [`P`](book.md#0xc0deb00c\_Book\_P), which indicates the user holding the corresponding position in the order book, as well as the scaled size (see `Econia::Orders`) of the position remaining to be filled.

#### Order placement

***

* [Test oriented implementation](book.md#@Test\_oriented\_implementation\_0)
* [Order structure](book.md#@Order\_structure\_1)
  * [Order placement](book.md#@Order\_placement\_2)
* [Struct `FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap)
* [Resource `OB`](book.md#0xc0deb00c\_Book\_OB)
* [Struct `P`](book.md#0xc0deb00c\_Book\_P)
* [Constants](book.md#@Constants\_3)
* [Function `add_ask`](book.md#0xc0deb00c\_Book\_add\_ask)
* [Function `add_bid`](book.md#0xc0deb00c\_Book\_add\_bid)
* [Function `exists_book`](book.md#0xc0deb00c\_Book\_exists\_book)
* [Function `get_friend_cap`](book.md#0xc0deb00c\_Book\_get\_friend\_cap)
* [Function `init_book`](book.md#0xc0deb00c\_Book\_init\_book)
* [Function `scale_factor`](book.md#0xc0deb00c\_Book\_scale\_factor)
* [Function `add_position`](book.md#0xc0deb00c\_Book\_add\_position)
  * [Parameters](book.md#@Parameters\_4)
  * [Assumes](book.md#@Assumes\_5)
* [Function `manage_crossed_spread`](book.md#0xc0deb00c\_Book\_manage\_crossed\_spread)

```
use 0x1::Signer;
use 0xc0deb00c::CritBit;
use 0xc0deb00c::ID;
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

### Resource `OB`

Order book with base coin type `B`, quote coin type `Q`, and scale exponent type `E`

```
struct OB<B, Q, E> has key
```

<details>

<summary>Fields</summary>

`f: u64`Scale factor`a:` [`CritBit::CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`<`[`Book::P`](book.md#0xc0deb00c\_Book\_P)`>`Asks`b:` [`CritBit::CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`<`[`Book::P`](book.md#0xc0deb00c\_Book\_P)`>`Bids`m_a: u128`Order ID (see `Econia::ID`) of minimum ask`m_b: u128`Order ID (see `Econia::ID`) of maximum bid

</details>

### Struct `P`

Position in an order book

```
struct P has store
```

<details>

<summary>Fields</summary>

`s: u64`Scaled size (see `Econia::Orders`) of position to be filled`a:`` `**`address`**Address holding position

</details>

### Constants

`u128` bitmask with all bits set

```
const HI_128: u128 = 340282366920938463463374607431768211455;
```

Ask flag

```
const ASK: bool = true;
```

Bid flag

```
const BID: bool = false;
```

When order book already exists at given address

```
const E_BOOK_EXISTS: u64 = 0;
```

When account/address is not Econia

```
const E_NOT_ECONIA: u64 = 2;
```

When order book does not exist at given address

```
const E_NO_BOOK: u64 = 1;
```

### Function `add_ask`

Wrapped [`add_position`](book.md#0xc0deb00c\_Book\_add\_position)`()` call for [`ASK`](book.md#0xc0deb00c\_Book\_ASK), requiring [`FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap)

```
public fun add_ask<B, Q, E>(host: address, user: address, id: u128, price: u64, size: u64, _c: &Book::FriendCap)
```

<details>

<summary>Implementation</summary>

```
public fun add_ask<B, Q, E>(
    host: address,
    user: address,
    id: u128,
    price: u64,
    size: u64,
    _c: &FriendCap
) acquires OB {
    add_position<B, Q, E>(host, user, ASK, id, price, size)
}
```

</details>

### Function `add_bid`

Wrapped [`add_position`](book.md#0xc0deb00c\_Book\_add\_position)`()` call for [`BID`](book.md#0xc0deb00c\_Book\_BID), requiring [`FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap)

```
public fun add_bid<B, Q, E>(host: address, user: address, id: u128, price: u64, size: u64, _c: &Book::FriendCap)
```

<details>

<summary>Implementation</summary>

```
public fun add_bid<B, Q, E>(
    host: address,
    user: address,
    id: u128,
    price: u64,
    size: u64,
    _c: &FriendCap
) acquires OB {
    add_position<B, Q, E>(host, user, BID, id, price, size)
}
```

</details>

### Function `exists_book`

Return **`true`** if specified order book type exists at address

```
public fun exists_book<B, Q, E>(a: address): bool
```

<details>

<summary>Implementation</summary>

```
public fun exists_book<B, Q, E>(a: address): bool {exists<OB<B, Q, E>>(a)}
```

</details>

### Function `get_friend_cap`

Return a [`FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap), aborting if not called by Econia account

```
public fun get_friend_cap(account: &signer): Book::FriendCap
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

### Function `init_book`

Initialize order book under host account, provided [`FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap), with market types `B`, `Q`, `E`, and scale factor `f`

```
public fun init_book<B, Q, E>(host: &signer, f: u64, _c: &Book::FriendCap)
```

<details>

<summary>Implementation</summary>

```
public fun init_book<B, Q, E>(
    host: &signer,
    f: u64,
    _c: &FriendCap
) {
    // Assert book does not already exist under host account
    assert!(!exists_book<B, Q, E>(s_a_o(host)), E_BOOK_EXISTS);
    let o_b = // Pack empty order book
        OB<B, Q, E>{f, a: cb_e<P>(), b: cb_e<P>(), m_a: HI_128, m_b: 0};
    move_to<OB<B, Q, E>>(host, o_b); // Move to host
}
```

</details>

### Function `scale_factor`

Return scale factor of specified order book at given address

```
public fun scale_factor<B, Q, E>(addr: address): u64
```

<details>

<summary>Implementation</summary>

```
public fun scale_factor<B, Q, E>(
    addr: address
): u64
acquires OB {
    // Assert book exists at given address
    assert!(exists_book<B, Q, E>(addr), E_NO_BOOK);
    borrow_global<OB<B, Q, E>>(addr).f // Return book's scale factor
}
```

</details>

### Function `add_position`

Add new position to book for market `<B, Q, E>`, eliminating redundant error checks covered by calling functions

#### Parameters

* `host`: Address of market host
* `user`: Address of user submitting position
* `side`: [`ASK`](book.md#0xc0deb00c\_Book\_ASK) or [`BID`](book.md#0xc0deb00c\_Book\_BID)
* `id`: Order ID (see `Econia::ID`)
* `price`: Scaled integer price (see `Econia::ID`)
* `size`: Scaled order size (see `Econia::Orders`)

#### Assumes

* Correspondent order has already passed validation checks per `Econia::Orders::add_order()`
* [`OB`](book.md#0xc0deb00c\_Book\_OB) for given market exists at host address

```
fun add_position<B, Q, E>(host: address, user: address, side: bool, id: u128, price: u64, size: u64)
```

<details>

<summary>Implementation</summary>

```
fun add_position<B, Q, E>(
    host: address,
    user: address,
    side: bool,
    id: u128,
    price: u64,
    size: u64
) acquires OB {
    // Borrow mutable reference to order book at host address
    let o_b = borrow_global_mut<OB<B, Q, E>>(host);
    // Get minimum ask price and maximum bid price on book
    let (m_a_p, m_b_p) = (id_p(o_b.m_a), id_p(o_b.m_b));
    if (side == ASK) { // If order is an ask
        if (price > m_b_p) { // If order does not cross spread
            // Add corresponding position to ask tree
            cb_i(&mut o_b.a, id, P{s: size, a: user});
            // If order is within spread, update min ask id
            if (price < m_a_p) o_b.m_a = id;
        // Otherwise manage order that crosses spread
        } else manage_crossed_spread();
    } else { // If order is a bid
        if (price < m_a_p) { // If order does not cross spread
            // Add corresponding position to bid tree
            cb_i(&mut o_b.b, id, P{s: size, a: user});
            // If order is within spread, update max bid id
            if (price > m_b_p) o_b.m_b = id;
        // Otherwise manage order that crosses spread
        } else manage_crossed_spread();
    }
}
```

</details>

### Function `manage_crossed_spread`

Stub function for managing crossed spread, aborts every time

```
fun manage_crossed_spread()
```

<details>

<summary>Implementation</summary>

```
fun manage_crossed_spread() {abort 0xff}
```

</details>
