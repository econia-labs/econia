# Registry

## Module `0xc0deb00c::Registry`

### Dynamic scaling

#### Coins

This implementation provides market data structures for trading [`Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin) types ("coins") against one another. Each coin has a corresponding `CoinType` ("coin type"), and each instantiation of a coin has an associated `u64` amount ([`Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin)`<CoinType>.value`).

Coins can be traded against one another in a "trading pair", which contains a "base coin" that is denominated in terms of a "quote coin" (terminology inherited from Forex markets). At present the most common cryptocurrency trading pair is `BTC/USD`, which corresponds to Bitcoin (base coin) denominated in United States Dollars (quote "coin"): $29,759.51 per Bitcoin at the time of this writing.

Notably, for the above example, neither `BTC` nor `USD` actually correspond to [`Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin) types on the Aptos blockchain, but in all likelihood these two assets will come to be represented on-chain as a wrapped Bitcoin variant (coin type `wBTC` or similar) and a USD-backed stablecoin, respectively, with the latter issued by a centralized minting authority under the purview of the United States government, for example `USDC`.

Despite the risk of arbitrary seizure by centralized stablecoin issuers, centralized stablecoins like `USDC` have nevertheless become the standard mode of denomination for on-chain trading, so for illustrative purposes, USDC will be taken as the default quote coin for future examples.

#### Decimal price

While [`Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin) types have a `u64` value, the user-facing representation of this amount often takes the form of a decimal, for example, `100.75 USDC`, corresponding to 100 dollars and 75 cents. More precision is still possible, though, with `USDC` commonly offering up to 6 decimal places on other blockchains, so that a user can hold an amount like `500.123456 USDC`. On Aptos, this would correspond to a [`Coin`](move/econia/build/AptosFramework/docs/Coin.md#0x1\_Coin)`<USDC>.value` of `500123456` and a `CoinInfo<USDC>.decimals` of `6`. Similarly, base coins may have an arbitrary number of decimals, even though their underlying value is still stored as a `u64`.

For a given trading pair, the conversion between quote coin and base coin is achieved by simple multiplication and division:

* $coins\_{quote} = coins\_{base} \* price$
* $coins\_{base} = coins\_{quote} / price$

For example, 2 `wBTC` at a price of `29,759.51 USDC` per `wBTC` per corresponds to $2 \* 29,759.51 =$ `59,519.02 USDC`, while `59,519.02 USDC` corresponds to $59,519.02 / 29,759.51 =$ `2 wBTC`

#### Scaled integer price

Again, however, coin values are ultimately represented as `u64` amounts, and similarly, the present implementation's matching engine relies on `u64` prices. Hence a price "scale factor" is sometimes required, for instance when trading digital assets having a relatively low valuation:

Consider recently issued protocol coin `PRO`, which has 3 decimal places, a circulating supply of 1 billion, and a `USDC`-denominated market cap of $100,000. A single user-facing representation of a coin, `1.000 PRO`, thus corresponds to `1000` indivisible subunits and has a market price of $100,000 / 10^9 =$ `0.0001 USDC`, which means that one indivisible subunit of `PRO` has a market value of $0.0001 / 1000 =$ `0.0000001 USDC`. Except `USDC` only has 6 decimal places, meaning that an indivisible subunit of `PRO` costs less than one indivisible subunit of `USDC` (`0.000001 USDC`). Hence, an order for `2.567 PRO` would be invalid, since it would correspond to `0.0000002567 USDC`, an unrepresentable amount.

The proposed solution is a scaled integer price, defined as the number of quote subunits per `SF` base subunits (`SF` denoting scale factor):

* $price\_{scaled} = \frac{subunits\_{quote\}}{subunits\_{base} / SF} =$ $SF(\frac{subunits\_{quote\}}{subunits\_{base\}})$
* $subunits\_{base} = SF (subunits\_{quote} / price\_{scaled})$
* $subunits\_{quote} = price\_{scaled} (subunits\_{base} / SF)$

For instance, a scale factor of 1,000 for the current example yields prices denoting the number of `USDC` subunits (`0.000001 USDC`) per 1,000 `PRO` subunits (`1.000 PRO`). At a nominal price of `0.0001 USDC` per `1.000 PRO`, the scaled integer price would thus be `100`, a valid `u64`. Likewise, if the price were to fall to `0.000001 USDC` per `1.000 PRO`, the scaled integer price would then be `1`, still a valid `u64`. Here, the base coin can only be transacted in amounts that are integer multiples of the scale factor, because otherwise the corresponding number of quote coin subunits could assume a non-integer value: a user may place an order to trade `1.000 PRO` or `2.000 PRO`, but not `1.500 PRO`, because at a scaled integer price of `1`, it would require 1.5 indivisible `USDC` subunits to settle the trade, an amount that cannot be represented in a `u64`.

#### Market effects

If, eventually, the `USDC`-denominated market capitalization of `PRO` were to increase to $100B, then each `1.000 PRO` would assume a nominal value of `$100`, and a scale factor of `1000` would not provide adequate trading granularity: a user could place an order for `1.000 PRO` (`100 USDC`) or `2.000 PRO` (`200 USDC`), but due to the integer-multiple lot size requirement described above, enforced at the algorithm level, it would be impossible to place an order for `.5 PRO` (`50 USDC`). This limitation would almost certainly restrict retail trading activity, thus reducing price discovery efficiency, and so the scale factor of `1000` would no longer be appropriate.

But what is the most appropriate new scale factor for this mature trading pair? `100`? `10`? `1`? What happens if the price later plummets? And if the scale factor should be updated, then who executes the code change, and when do they do it? Shall the centralized authority who mints USDC (and who also has the power to arbitrarily seize anyone's assets) additionally be granted the authority to change the scale factor at any time? What if said entity, of for that matter, any centralized entity that can either act maliciously or be coerced, intentionally chooses an inappropriate scale factor in the interest of halting activity on an arbitrary trading pair?

With regard to choosing an appropriate scale factor, or more broadly for facilitating trading pairs in general, the present implementation's solution is to simply "let the market decide", via a permissionless market registration system that allows anyone to register any trading pair, with any scale factor of the form $10^E, E\in {0, 1, 2, \ldots, 19}$, as long as the trading pair has not already been initialized. Hence, when a new coin becomes available, several trading pairs are likely to be established across different scale factors, and the correspondingly fractured liquidity will tend to gravitate towards a preferred scale factor. As prices go up or down, liquidity will naturally migrate to the most efficient scale factor, without any input from a centralized entity.

### Data structures

#### Market info

A trading pair, or market, is fully specified by a unique [`MI`](registry.md#0xc0deb00c\_Registry\_MI) (Market info) struct, which has fields for a base coin type, a quote coin type, and a so-called "scale exponent" (`E` as above, corresponding to a power of 10). These types are represented in other functions and structs as `<B, Q, E>`.

Since markets are permissionless, anyone can register a market, assuming that the correspondingly unique [`MI`](registry.md#0xc0deb00c\_Registry\_MI) specifier has not already been registered under the market registry, [`MR`](registry.md#0xc0deb00c\_Registry\_MR), stored at the Econia address. The account that registers a market is known as a "host", because during registration they agree to host under their account an `Econia::Book::OB` that will facilitate trading.

#### Scale exponents and factors

The scale exponent types [`E0`](registry.md#0xc0deb00c\_Registry\_E0), [`E1`](registry.md#0xc0deb00c\_Registry\_E1), ..., [`E19`](registry.md#0xc0deb00c\_Registry\_E19), correspond to the scale factors [`F0`](registry.md#0xc0deb00c\_Registry\_F0), [`F1`](registry.md#0xc0deb00c\_Registry\_F1), ... [`F19`](registry.md#0xc0deb00c\_Registry\_F19), with lookup functionality provided by [`scale_factor`](registry.md#0xc0deb00c\_Registry\_scale\_factor)`<E>()`. Notably, scale exponents are types, while scale factors are `u64`, with the former enabling lookup in global storage, and the latter enabling integer arithmetic at the matching engine level. From a purely computer science perspective, it would actually be more straightforward for scale exponents and factors to correspond to powers of two, but since the present implementation is financially-motivated, powers of 10 are instead used. Hence the largest scale factor is [`F19`](registry.md#0xc0deb00c\_Registry\_F19) $= 10^{19} =$ `10000000000000000000`, the largest power of ten that can be represented in a `u64`

#### Book module

The core order book data structure, `Econia::Book::OB`, is implemented purely in Move, to facilitate coverage testing per the **`move`** CLI, which would not be possible (at least as of the time of this writing) if it were implemented in a module with Aptos native functions. See `Econia::Caps` for further discussion.

***

* [Dynamic scaling](registry.md#@Dynamic\_scaling\_0)
  * [Coins](registry.md#@Coins\_1)
  * [Decimal price](registry.md#@Decimal\_price\_2)
  * [Scaled integer price](registry.md#@Scaled\_integer\_price\_3)
  * [Market effects](registry.md#@Market\_effects\_4)
* [Data structures](registry.md#@Data\_structures\_5)
  * [Market info](registry.md#@Market\_info\_6)
  * [Scale exponents and factors](registry.md#@Scale\_exponents\_and\_factors\_7)
  * [Book module](registry.md#@Book\_module\_8)
* [Struct `E0`](registry.md#0xc0deb00c\_Registry\_E0)
* [Struct `E1`](registry.md#0xc0deb00c\_Registry\_E1)
* [Struct `E2`](registry.md#0xc0deb00c\_Registry\_E2)
* [Struct `E3`](registry.md#0xc0deb00c\_Registry\_E3)
* [Struct `E4`](registry.md#0xc0deb00c\_Registry\_E4)
* [Struct `E5`](registry.md#0xc0deb00c\_Registry\_E5)
* [Struct `E6`](registry.md#0xc0deb00c\_Registry\_E6)
* [Struct `E7`](registry.md#0xc0deb00c\_Registry\_E7)
* [Struct `E8`](registry.md#0xc0deb00c\_Registry\_E8)
* [Struct `E9`](registry.md#0xc0deb00c\_Registry\_E9)
* [Struct `E10`](registry.md#0xc0deb00c\_Registry\_E10)
* [Struct `E11`](registry.md#0xc0deb00c\_Registry\_E11)
* [Struct `E12`](registry.md#0xc0deb00c\_Registry\_E12)
* [Struct `E13`](registry.md#0xc0deb00c\_Registry\_E13)
* [Struct `E14`](registry.md#0xc0deb00c\_Registry\_E14)
* [Struct `E15`](registry.md#0xc0deb00c\_Registry\_E15)
* [Struct `E16`](registry.md#0xc0deb00c\_Registry\_E16)
* [Struct `E17`](registry.md#0xc0deb00c\_Registry\_E17)
* [Struct `E18`](registry.md#0xc0deb00c\_Registry\_E18)
* [Struct `E19`](registry.md#0xc0deb00c\_Registry\_E19)
* [Struct `MI`](registry.md#0xc0deb00c\_Registry\_MI)
* [Resource `MR`](registry.md#0xc0deb00c\_Registry\_MR)
* [Constants](registry.md#@Constants\_9)
* [Function `init_registry`](registry.md#0xc0deb00c\_Registry\_init\_registry)
* [Function `is_registered`](registry.md#0xc0deb00c\_Registry\_is\_registered)
* [Function `scale_factor`](registry.md#0xc0deb00c\_Registry\_scale\_factor)
* [Function `register_market`](registry.md#0xc0deb00c\_Registry\_register\_market)
* [Function `verify_address`](registry.md#0xc0deb00c\_Registry\_verify\_address)
* [Function `verify_bytestring`](registry.md#0xc0deb00c\_Registry\_verify\_bytestring)
* [Function `verify_market_types`](registry.md#0xc0deb00c\_Registry\_verify\_market\_types)
* [Function `verify_t_i`](registry.md#0xc0deb00c\_Registry\_verify\_t\_i)

```
use 0x1::Coin;
use 0x1::Signer;
use 0x1::Table;
use 0x1::TypeInfo;
use 0xc0deb00c::Book;
use 0xc0deb00c::Caps;
```

### Struct `E0`

```
struct E0
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E1`

```
struct E1
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E2`

```
struct E2
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E3`

```
struct E3
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E4`

```
struct E4
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E5`

```
struct E5
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E6`

```
struct E6
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E7`

```
struct E7
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E8`

```
struct E8
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E9`

```
struct E9
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E10`

```
struct E10
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E11`

```
struct E11
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E12`

```
struct E12
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E13`

```
struct E13
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E14`

```
struct E14
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E15`

```
struct E15
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E16`

```
struct E16
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E17`

```
struct E17
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E18`

```
struct E18
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `E19`

```
struct E19
```

<details>

<summary>Fields</summary>

`dummy_field: bool`

</details>

### Struct `MI`

Market info

```
struct MI has copy, drop
```

<details>

<summary>Fields</summary>

`b:` [`TypeInfo::TypeInfo`](move/econia/build/AptosFramework/docs/TypeInfo.md#0x1\_TypeInfo\_TypeInfo)Base CoinType TypeInfo`q:` [`TypeInfo::TypeInfo`](move/econia/build/AptosFramework/docs/TypeInfo.md#0x1\_TypeInfo\_TypeInfo)Quote CoinType TypeInfo`e:` [`TypeInfo::TypeInfo`](move/econia/build/AptosFramework/docs/TypeInfo.md#0x1\_TypeInfo\_TypeInfo)Scale exponent TypeInfo

</details>

### Resource `MR`

Market registry

```
struct MR has key
```

<details>

<summary>Fields</summary>

`t:` [`Table::Table`](move/econia/build/AptosFramework/docs/Table.md#0x1\_Table\_Table)`<`[`Registry::MI`](registry.md#0xc0deb00c\_Registry\_MI)`,`` `**`address`**`>`Table from [`MI`](registry.md#0xc0deb00c\_Registry\_MI) to address hosting the corresponding `MC`

</details>

### Constants

When account/address is not Econia

```
const E_NOT_ECONIA: u64 = 0;
```

When a type does not correspond to a coin

```
const E_NOT_COIN: u64 = 5;
```

When market registry not initialized

```
const E_NO_REGISTRY: u64 = 3;
```

When a given market is already registered

```
const E_REGISTERED: u64 = 4;
```

When registry already exists

```
const E_REGISTRY_EXISTS: u64 = 6;
```

When wrong type for exponent flag

```
const E_WRONG_EXPONENT_T: u64 = 2;
```

When wrong module

```
const E_WRONG_MODULE: u64 = 1;
```

```
const F0: u64 = 1;
```

```
const F1: u64 = 10;
```

```
const F10: u64 = 10000000000;
```

```
const F11: u64 = 100000000000;
```

```
const F12: u64 = 1000000000000;
```

```
const F13: u64 = 10000000000000;
```

```
const F14: u64 = 100000000000000;
```

```
const F15: u64 = 1000000000000000;
```

```
const F16: u64 = 10000000000000000;
```

```
const F17: u64 = 100000000000000000;
```

```
const F18: u64 = 1000000000000000000;
```

```
const F19: u64 = 10000000000000000000;
```

```
const F2: u64 = 100;
```

```
const F3: u64 = 1000;
```

```
const F4: u64 = 10000;
```

```
const F5: u64 = 100000;
```

```
const F6: u64 = 1000000;
```

```
const F7: u64 = 10000000;
```

```
const F8: u64 = 100000000;
```

```
const F9: u64 = 1000000000;
```

This module's name

```
const M_NAME: vector<u8> = [82, 101, 103, 105, 115, 116, 114, 121];
```

### Function `init_registry`

Publish [`MR`](registry.md#0xc0deb00c\_Registry\_MR) to Econia acount, aborting for all other accounts or if [`MR`](registry.md#0xc0deb00c\_Registry\_MR) already exists

```
public(friend) fun init_registry(account: &signer)
```

<details>

<summary>Implementation</summary>

```
public(friend) fun init_registry(
    account: &signer
) {
    let addr = s_a_o(account); // Get signer address
    assert!(addr == @Econia, E_NOT_ECONIA); // Assert Econia signer
    // Assert registry does not already exist
    assert!(!exists<MR>(addr), E_REGISTRY_EXISTS);
    // Move empty market registry to account
    move_to<MR>(account, MR{t: t_n<MI, address>()});
}
```

</details>

### Function `is_registered`

Return **`true`** if given market is registered

```
public(friend) fun is_registered<B, Q, E>(): bool
```

<details>

<summary>Implementation</summary>

```
public(friend) fun is_registered<B, Q, E>(
): bool
acquires MR {
    // Return false if no market registry at Econia account
    if (!exists<MR>(@Econia)) return false;
     // Get market info for given type arguments
    let m_i = MI{b: ti_t_o<B>(), q: ti_t_o<Q>(), e: ti_t_o<E>()};
    // Return if registry table contains market information
    t_c(&borrow_global<MR>(@Econia).t, m_i)
}
```

</details>

### Function `scale_factor`

Return scale factor corresponding to scale exponent type `E`

```
public(friend) fun scale_factor<E>(): u64
```

<details>

<summary>Implementation</summary>

```
public(friend) fun scale_factor<E>():
u64 {
    let t_i = ti_t_o<E>(); // Get type info of exponent type flag
    // Verify exponent type flag is from Econia address
    verify_address(ti_a_a(&t_i), @Econia, E_NOT_ECONIA);
    // Verify exponent type flag is from this module
    verify_bytestring(ti_m_n(&t_i), M_NAME, E_WRONG_MODULE);
    let s_n = ti_s_n(&t_i); // Get type struct name
    // Return corresponding scale factor
    if (s_n == ti_s_n(&ti_t_o<E0>() )) return F0;
    if (s_n == ti_s_n(&ti_t_o<E1>() )) return F1;
    if (s_n == ti_s_n(&ti_t_o<E2>() )) return F2;
    if (s_n == ti_s_n(&ti_t_o<E3>() )) return F3;
    if (s_n == ti_s_n(&ti_t_o<E4>() )) return F4;
    if (s_n == ti_s_n(&ti_t_o<E5>() )) return F5;
    if (s_n == ti_s_n(&ti_t_o<E6>() )) return F6;
    if (s_n == ti_s_n(&ti_t_o<E7>() )) return F7;
    if (s_n == ti_s_n(&ti_t_o<E8>() )) return F8;
    if (s_n == ti_s_n(&ti_t_o<E9>() )) return F9;
    if (s_n == ti_s_n(&ti_t_o<E10>())) return F10;
    if (s_n == ti_s_n(&ti_t_o<E11>())) return F11;
    if (s_n == ti_s_n(&ti_t_o<E12>())) return F12;
    if (s_n == ti_s_n(&ti_t_o<E13>())) return F13;
    if (s_n == ti_s_n(&ti_t_o<E14>())) return F14;
    if (s_n == ti_s_n(&ti_t_o<E15>())) return F15;
    if (s_n == ti_s_n(&ti_t_o<E16>())) return F16;
    if (s_n == ti_s_n(&ti_t_o<E17>())) return F17;
    if (s_n == ti_s_n(&ti_t_o<E18>())) return F18;
    if (s_n == ti_s_n(&ti_t_o<E19>())) return F19;
    abort E_WRONG_EXPONENT_T // Else abort
}
```

</details>

### Function `register_market`

Register a market for the given base coin type `B`, quote coin type `Q`, and scale exponent `E` , aborting if registry not initialized or if market already registered

```
public(script) fun register_market<B, Q, E>(host: &signer)
```

<details>

<summary>Implementation</summary>

```
public(script) fun register_market<B, Q, E>(
    host: &signer
) acquires MR {
    verify_market_types<B, Q, E>(); // Verify valid type arguments
    // Assert market registry is initialized at Econia account
    assert!(exists<MR>(@Econia), E_NO_REGISTRY);
    // Get market info for given type arguments
    let m_i = MI{b: ti_t_o<B>(), q: ti_t_o<Q>(), e: ti_t_o<E>()};
    // Borrow mutable reference to market registry table
    let r_t = &mut borrow_global_mut<MR>(@Econia).t;
    // Assert requested market not already registered
    assert!(!t_c(r_t, m_i), E_REGISTERED);
    // Initialize empty order book under host account
    b_i_b<B, Q, E>(host, scale_factor<E>(), &c_b_f_c());
    t_a(r_t, m_i, s_a_o(host)); // Register market-host relationship
}
```

</details>

### Function `verify_address`

Assert `a1` equals `a2`, aborting with code `e` if not

```
fun verify_address(a1: address, a2: address, e: u64)
```

<details>

<summary>Implementation</summary>

```
fun verify_address(
    a1: address,
    a2: address,
    e: u64
) {
    assert!(a1 == a2, e); // Assert equality
}
```

</details>

### Function `verify_bytestring`

Assert `s1` equals `s2`, aborting with code `e` if not

```
fun verify_bytestring(bs1: vector<u8>, bs2: vector<u8>, e: u64)
```

<details>

<summary>Implementation</summary>

```
fun verify_bytestring(
    bs1: vector<u8>,
    bs2: vector<u8>,
    e: u64
) {
    assert!(bs1 == bs2, e); // Assert equality
}
```

</details>

### Function `verify_market_types`

Assert `B` and `Q` are coins, and that `E` is scale exponent

```
fun verify_market_types<B, Q, E>()
```

<details>

<summary>Implementation</summary>

```
fun verify_market_types<B, Q, E>() {
    assert!(c_i_c_i<B>(), E_NOT_COIN); // Assert base quote type
    assert!(c_i_c_i<Q>(), E_NOT_COIN); // Assert quote coin type
    // Assert scale exponent type has corresponding scale factor
    scale_factor<E>();
}
```

</details>

### Function `verify_t_i`

Assert `t1` equals `t2`, aborting with code `e` if not

```
fun verify_t_i(t1: &TypeInfo::TypeInfo, t2: &TypeInfo::TypeInfo, e: u64)
```

<details>

<summary>Implementation</summary>

```
fun verify_t_i(
    t1: &TI,
    t2: &TI,
    e: u64
) {
    verify_address(ti_a_a(t1), ti_a_a(t2), e); // Verify address
    verify_bytestring(ti_m_n(t1), ti_m_n(t2), e); // Verify module
    verify_bytestring(ti_s_n(t1), ti_s_n(t2), e); // Verify struct
}
```

</details>
