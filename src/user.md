# User

## Module `0xc0deb00c::User`

User-facing trading functionality

* [Resource `OC`](user.md#0xc0deb00c\_User\_OC)
* [Resource `SC`](user.md#0xc0deb00c\_User\_SC)
* [Constants](user.md#@Constants\_0)
* [Function `deposit`](user.md#0xc0deb00c\_User\_deposit)
* [Function `init_containers`](user.md#0xc0deb00c\_User\_init\_containers)
* [Function `init_user`](user.md#0xc0deb00c\_User\_init\_user)
* [Function `withdraw`](user.md#0xc0deb00c\_User\_withdraw)
* [Function `init_o_c`](user.md#0xc0deb00c\_User\_init\_o\_c)
* [Function `submit_limit_order`](user.md#0xc0deb00c\_User\_submit\_limit\_order)
  * [Parameters](user.md#@Parameters\_1)
* [Function `update_s_c`](user.md#0xc0deb00c\_User\_update\_s\_c)

```
use 0x1::Account;
use 0x1::Coin;
use 0x1::Signer;
use 0xc0deb00c::Book;
use 0xc0deb00c::Caps;
use 0xc0deb00c::ID;
use 0xc0deb00c::Orders;
use 0xc0deb00c::Registry;
use 0xc0deb00c::Version;
```

### Resource `OC`

Order collateral for a given market

```
struct OC<B, Q, E> has key
```

<details>

<summary>Fields</summary>

`b_a: u64`Indivisible subunits of base coins available to withdraw`b_c:` [`Coin::Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin\_Coin)`<B>`Base coins held as collateral`q_a: u64`Indivisible subunits of quote coins available to withdraw`q_c:` [`Coin::Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin\_Coin)`<Q>`Quote coins held as collateral

</details>

### Resource `SC`

Counter for sequence number of last monitored Econia transaction

```
struct SC has key
```

<details>

<summary>Fields</summary>

`i: u64`

</details>

### Constants

Ask flag

```
const ASK: bool = true;
```

Bid flag

```
const BID: bool = false;
```

When invalid sequence number for current transaction

```
const E_INVALID_S_N: u64 = 5;
```

When not enough collateral for an operation

```
const E_NOT_ENOUGH_COLLATERAL: u64 = 9;
```

When no corresponding market

```
const E_NO_MARKET: u64 = 1;
```

When no order collateral container

```
const E_NO_O_C: u64 = 6;
```

When sequence number counter does not exist for user

```
const E_NO_S_C: u64 = 4;
```

When no transfer of funds indicated

```
const E_NO_TRANSFER: u64 = 7;
```

When order collateral container already exists

```
const E_O_C_EXISTS: u64 = 0;
```

When open orders container already exists

```
const E_O_O_EXISTS: u64 = 2;
```

When sequence number counter already exists for user

```
const E_S_C_EXISTS: u64 = 3;
```

When attempting to withdraw more than is available

```
const E_WITHDRAW_TOO_MUCH: u64 = 8;
```

### Function `deposit`

Deposit `b_val` base coin and `q_val` quote coin into `user`'s [`OC`](user.md#0xc0deb00c\_User\_OC), from their `AptosFramework::Coin::CoinStore`

```
public(script) fun deposit<B, Q, E>(user: &signer, b_val: u64, q_val: u64)
```

<details>

<summary>Implementation</summary>

```
public(script) fun deposit<B, Q, E>(
    user: &signer,
    b_val: u64,
    q_val: u64
) acquires OC, SC {
    let addr = s_a_o(user); // Get user address
    // Assert user has order collateral container
    assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
    // Assert user actually attempting to deposit
    assert!(b_val > 0 || q_val > 0, E_NO_TRANSFER);
    // Borrow mutable reference to user collateral container
    let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
    if (b_val > 0) { // If base coin to be deposited
        c_m<B>(&mut o_c.b_c, c_w<B>(user, b_val)); // Deposit it
        o_c.b_a = o_c.b_a + b_val; // Increment available base coin
    };
    if (q_val > 0) { // If quote coin to be deposited
        c_m<Q>(&mut o_c.q_c, c_w<Q>(user, q_val)); // Deposit it
        o_c.q_a = o_c.q_a + q_val; // Increment available quote coin
    };
    update_s_c(user); // Update user sequence counter
}
```

</details>

### Function `init_containers`

Initialize a user with `Econia::Orders::OO` and [`OC`](user.md#0xc0deb00c\_User\_OC) for market with base coin type `B`, quote coin type `Q`, and scale exponent `E`, aborting if no such market or if containers already initialized for market

```
public(script) fun init_containers<B, Q, E>(user: &signer)
```

<details>

<summary>Implementation</summary>

```
public(script) fun init_containers<B, Q, E>(
    user: &signer
) {
    assert!(r_i_r<B, Q, E>(), E_NO_MARKET); // Assert market exists
    let user_addr = s_a_o(user); // Get user address
    // Assert user does not already have collateral container
    assert!(!exists<OC<B, Q, E>>(user_addr), E_O_C_EXISTS);
    // Assert user does not already have open orders container
    assert!(!o_e_o<B, Q, E>(user_addr), E_O_O_EXISTS);
    // Pack empty collateral container
    let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
    move_to<OC<B, Q, E>>(user, o_c); // Move to user account
    // Initialize empty open orders container under user account
    o_i_o<B, Q, E>(user, r_s_f<E>(), &c_o_f_c());
}
```

</details>

### Function `init_user`

Initialize an [`SC`](user.md#0xc0deb00c\_User\_SC) with the sequence number of the initializing transaction, aborting if one already exists

```
public(script) fun init_user(user: &signer)
```

<details>

<summary>Implementation</summary>

```
public(script) fun init_user(
    user: &signer
) {
    let user_addr = s_a_o(user); // Get user address
    // Assert user has not already initialized a sequence counter
    assert!(!exists<SC>(user_addr), E_S_C_EXISTS);
    // Initialize sequence counter with user's sequence number
    move_to<SC>(user, SC{i: a_g_s_n(user_addr)});
}
```

</details>

### Function `withdraw`

Withdraw `b_val` base coin and `q_val` quote coin from `user`'s [`OC`](user.md#0xc0deb00c\_User\_OC), into their `AptosFramework::Coin::CoinStore`

```
public(script) fun withdraw<B, Q, E>(user: &signer, b_val: u64, q_val: u64)
```

<details>

<summary>Implementation</summary>

```
public(script) fun withdraw<B, Q, E>(
    user: &signer,
    b_val: u64,
    q_val: u64
) acquires OC, SC {
    let addr = s_a_o(user); // Get user address
    // Assert user has order collateral container
    assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
    // Assert user actually attempting to withdraw
    assert!(b_val > 0 || q_val > 0, E_NO_TRANSFER);
    // Borrow mutable reference to user collateral container
    let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
    if (b_val > 0) { // If base coin to be withdrawn
        // Assert not trying to withdraw more than available
        assert!(!(b_val > o_c.b_a), E_WITHDRAW_TOO_MUCH);
        // Withdraw from order collateral, deposit to coin store
        c_d<B>(addr, c_e<B>(&mut o_c.b_c, b_val));
        o_c.b_a = o_c.b_a - b_val; // Update available amount
    };
    if (q_val > 0) { // If quote coin to be withdrawn
        // Assert not trying to withdraw more than available
        assert!(!(q_val > o_c.q_a), E_WITHDRAW_TOO_MUCH);
        // Withdraw from order collateral, deposit to coin store
        c_d<Q>(addr, c_e<Q>(&mut o_c.q_c, q_val));
        o_c.q_a = o_c.q_a - q_val; // Update available amount
    };
    update_s_c(user); // Update user sequence counter
}
```

</details>

### Function `init_o_c`

Initialize order collateral container for given user, aborting if already initialized

```
fun init_o_c<B, Q, E>(user: &signer)
```

<details>

<summary>Implementation</summary>

```
fun init_o_c<B, Q, E>(
    user: &signer,
) {
    // Assert user does not already have order collateral for market
    assert!(!exists<OC<B, Q, E>>(s_a_o(user)), E_O_C_EXISTS);
    // Assert given market has actually been registered
    assert!(r_i_r<B, Q, E>(), E_NO_MARKET);
    // Pack empty order collateral container
    let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
    move_to<OC<B, Q, E>>(user, o_c); // Move to user account
}
```

</details>

### Function `submit_limit_order`

Submit limit order for market `<B, Q, E>`

#### Parameters

* `user`: User submitting a limit order
* `host`: The market host (See `Econia::Registry`)
* `side`: [`ASK`](user.md#0xc0deb00c\_User\_ASK) or [`BID`](user.md#0xc0deb00c\_User\_BID)
* `price`: Scaled integer price (see `Econia::ID`)
* `size`: Unscaled order size (see `Econia::Orders`), in base coin subunits

```
fun submit_limit_order<B, Q, E>(user: &signer, host: address, side: bool, price: u64, size: u64)
```

<details>

<summary>Implementation</summary>

```
fun submit_limit_order<B, Q, E>(
    user: &signer,
    host: address,
    side: bool,
    price: u64,
    size: u64
) acquires OC, SC {
    update_s_c(user); // Update user sequence counter
    // Assert market exists at given host address
    assert!(b_e_b<B, Q, E>(host), E_NO_MARKET);
    let addr = s_a_o(user); // Get user address
    // Assert user has order collateral container
    assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
    // Borrow mutable reference to user's order collateral container
    let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
    let v_n = v_g_v_n(); // Get transaction version number
    if (side == ASK) { // If limit order is an ask
        let id = id_a(price, v_n); // Get corresponding order id
        // Verify and add to user's open orders, storing scaled size
        let (scaled_size, _) =
            o_a_a<B, Q, E>(addr, id, price, size, &c_o_f_c());
        // Assert user has enough base coins held as collateral
        assert!(!(size > o_c.b_a), E_NOT_ENOUGH_COLLATERAL);
        // Decrement amount of base coins available for withdraw
        o_c.b_a = o_c.b_a - size;
        // Add ask to order book
        b_a_a<B, Q, E>(host, addr, id, price, scaled_size, &c_b_f_c());
    } else { // If limit order is a bid
        let id = id_b(price, v_n); // Get corresponding order id
        // Verify and add to user's open orders, storing scaled size
        // and amount of quote coins needed to fill the order
        let (scaled_size, fill_amount) =
            o_a_b<B, Q, E>(addr, id, price, size, &c_o_f_c());
        // Assert user has enough quote coins held as collateral
        assert!(!(fill_amount > o_c.q_a), E_NOT_ENOUGH_COLLATERAL);
        // Decrement amount of base coins available for withdraw
        o_c.q_a = o_c.q_a - fill_amount;
        // Add bid to order book
        b_a_b<B, Q, E>(host, addr, id, price, scaled_size, &c_b_f_c());
    };
}
```

</details>

### Function `update_s_c`

Update sequence counter for user `u` with the sequence number of the current transaction, aborting if user does not have an initialized sequence counter or if sequence number is not greater than the number indicated by the user's [`SC`](user.md#0xc0deb00c\_User\_SC)

```
fun update_s_c(u: &signer)
```

<details>

<summary>Implementation</summary>

```
fun update_s_c(
    u: &signer,
) acquires SC {
    let user_addr = s_a_o(u); // Get user address
    // Assert user has already initialized a sequence counter
    assert!(exists<SC>(user_addr), E_NO_S_C);
    // Borrow mutable reference to user's sequence counter
    let s_c = borrow_global_mut<SC>(user_addr);
    let s_n = a_g_s_n(user_addr); // Get current sequence number
    // Assert new sequence number greater than that of counter
    assert!(s_n > s_c.i, E_INVALID_S_N);
    s_c.i = s_n; // Update counter with current sequence number
}
```

</details>
