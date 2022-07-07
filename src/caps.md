# Caps

## Module `0xc0deb00c::Caps`

### Test-oriented architecture

Some modules, like `Econia::Registry`, rely heavily on Move native functions defined in the `AptosFramework`, for which the **`move`** CLI's coverage testing tool does not offer general support (at least as of the time of this writing). Thus, since the `aptos` CLI does not offer any coverage testing support whatsoever (again, at least as of the time of this writing), such modules cannot be coverage tested per straightforward methods. Other modules, however, do not depend as strongly on `AptosFramework` functions, and as such, whenever possible, they are implemented purely in Move to enable coverage testing, for example, like `Econia::CritBit`.

The pairing of pure-Move and non-pure-Move modules occasionally requires workarounds, for instance, like the pseudo-friend capability `Econia::Book::FriendCap`, a cumbersome alternative to the use of a **`public`**`(`**`friend`**`)` function: a more straightforward approach would involve only exposing `Econia::Book::init_book`, for example, to friend modules, but this would involve the declaration of `Econia::Registry` module as a friend, and since `Econia::Registry` relies on `AptosFramework` native functions, the **`move`** CLI test compiler would thus break when attempting to link the corresponding files, even when only attempting to run coverage tests on `Econia::Book`. Hence, the use of `Econia::Book:FriendCap`, a friend-like capability, which allows `Econia::Book` to be implemented purely in Move and to be coverage tested using the **`move`** CLI, while also restricting access to friend-like modules.

### Capability aggregation

Rather than having friend-like capabilities managed by individual modules, they are aggregated here for ease of use, and are initialized all at once per [`init_caps`](caps.md#0xc0deb00c\_Caps\_init\_caps)`()`. As a **`public`**`(`**`friend`**`)` function, this is only intended to be called by `Econia::Init::init_econia()`, which essentially configures the Econia account to facilitate trading.

Similarly, capability access functions like [`book_f_c`](caps.md#0xc0deb00c\_Caps\_book\_f\_c)`()` are also provided as **`public`**`(`**`friend`**`)` functions, to be accessed only by select modules, namely those which contain Aptos native functions and which depend on pure-Move modules offering friend-like capabilities: `Econia::Registry`, for instance, is listed as a friend, since it requires access to `Econia::Book::FriendCap`.

***

* [Test-oriented architecture](caps.md#@Test-oriented\_architecture\_0)
* [Capability aggregation](caps.md#@Capability\_aggregation\_1)
* [Resource `FC`](caps.md#0xc0deb00c\_Caps\_FC)
* [Constants](caps.md#@Constants\_2)
* [Function `book_f_c`](caps.md#0xc0deb00c\_Caps\_book\_f\_c)
* [Function `has_f_c`](caps.md#0xc0deb00c\_Caps\_has\_f\_c)
* [Function `init_caps`](caps.md#0xc0deb00c\_Caps\_init\_caps)
* [Function `orders_f_c`](caps.md#0xc0deb00c\_Caps\_orders\_f\_c)

```
use 0x1::Signer;
use 0xc0deb00c::Book;
use 0xc0deb00c::Orders;
```

### Resource `FC`

Container for friend-like capabilities

```
struct FC has key
```

<details>

<summary>Fields</summary>

`b:` [`Book::FriendCap`](book.md#0xc0deb00c\_Book\_FriendCap)`Econia::Book` capability`o:` [`Orders::FriendCap`](orders.md#0xc0deb00c\_Orders\_FriendCap)`Econia::Orders` capability

</details>

### Constants

When account/address is not Econia

```
const E_NOT_ECONIA: u64 = 0;
```

When friend-like capabilities container already exists

```
const E_FC_EXISTS: u64 = 1;
```

When no friend-like capabilities container

```
const E_NO_FC: u64 = 2;
```

### Function `book_f_c`

Return `Econia::Book` friend-like capability

```
public(friend) fun book_f_c(): Book::FriendCap
```

<details>

<summary>Implementation</summary>

```
public(friend) fun book_f_c():
BFC
acquires FC {
    assert!(has_f_c(), E_NO_FC); // Assert capabilities initialized
    borrow_global<FC>(@Econia).b // Return requested capability
}
```

</details>

### Function `has_f_c`

Return true if friend capability container initialized

```
public(friend) fun has_f_c(): bool
```

<details>

<summary>Implementation</summary>

```
public(friend) fun has_f_c(): bool {exists<FC>(@Econia)}
```

</details>

### Function `init_caps`

Initialize friend-like capabilities, storing under Econia account, aborting if called by another account or if capability container already exists

```
public(friend) fun init_caps(account: &signer)
```

<details>

<summary>Implementation</summary>

```
public(friend) fun init_caps(
    account: &signer
) {
    let addr = s_a_o(account); // Get signer address
    assert!(addr == @Econia, E_NOT_ECONIA); // Assert Econia signer
    // Assert friend-like capabilities container does not yet exist
    assert!(!exists<FC>(addr), E_FC_EXISTS);
    // Move friend-like capabilities container to Econia account
    move_to<FC>(account, FC{b: b_g_f_c(account), o: o_g_f_c(account)});
}
```

</details>

### Function `orders_f_c`

Return `Econia::Orders` friend-like capability

```
public(friend) fun orders_f_c(): Orders::FriendCap
```

<details>

<summary>Implementation</summary>

```
public(friend) fun orders_f_c():
OFC
acquires FC {
    assert!(has_f_c(), E_NO_FC); // Assert capabilities initialized
    borrow_global<FC>(@Econia).o // Return requested capability
}
```

</details>
