
<a name="0xc0deb00c_Registry"></a>

# Module `0xc0deb00c::Registry`


<a name="@Dynamic_scaling_0"></a>

## Dynamic scaling



<a name="@Coins_1"></a>

### Coins


This implementation provides market data structures for trading
<code><a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">Coin</a></code> types ("coins") against one another. Each coin has a
corresponding <code>CoinType</code> ("coin type"), and each instantiation of a
coin has an associated <code>u64</code> amount (<code><a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">Coin</a>&lt;CoinType&gt;.value</code>).

Coins can be traded against one another in a "trading pair", which
contains a "base coin" that is denominated in terms of a "quote
coin" (terminology inherited from Forex markets). At present the
most common cryptocurrency trading pair is <code>BTC/USD</code>, which
corresponds to Bitcoin (base coin) denominated in United States
Dollars (quote "coin"): $29,759.51 per Bitcoin at the time of this
writing.

Notably, for the above example, neither <code>BTC</code> nor <code>USD</code> actually
correspond to <code><a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">Coin</a></code> types on the Aptos blockchain, but in all
likelihood these two assets will come to be represented on-chain as
a wrapped Bitcoin variant (coin type <code>wBTC</code> or similar) and a
USD-backed stablecoin, respectively, with the latter issued by a
centralized minting authority under the purview of the United States
government, for example <code>USDC</code>.

Despite the risk of arbitrary seizure by centralized stablecoin
issuers, centralized stablecoins like <code>USDC</code> have nevertheless
become the standard mode of denomination for on-chain trading, so
for illustrative purposes, USDC will be taken as the default quote
coin for future examples.


<a name="@Decimal_price_2"></a>

### Decimal price


While <code><a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">Coin</a></code> types have a <code>u64</code> value, the user-facing
representation of this amount often takes the form of a decimal, for
example, <code>100.75 USDC</code>, corresponding to 100 dollars and 75 cents.
More precision is still possible, though, with <code>USDC</code> commonly
offering up to 6 decimal places on other blockchains, so that a user
can hold an amount like <code>500.123456 USDC</code>. On Aptos, this would
correspond to a <code><a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">Coin</a>&lt;USDC&gt;.value</code> of <code>500123456</code> and a
<code>CoinInfo&lt;USDC&gt;.decimals</code> of <code>6</code>. Similarly, base coins may have an
arbitrary number of decimals, even though their underlying value is
still stored as a <code>u64</code>.

For a given trading pair, the conversion between quote coin and base
coin is achieved by simple multiplication and division:
* $coins_{quote} = coins_{base} * price$
* $coins_{base} = coins_{quote} / price$

For example, 2 <code>wBTC</code> at a price of <code>29,759.51 USDC</code> per <code>wBTC</code> per
corresponds to $2 * 29,759.51 =$ <code>59,519.02 USDC</code>, while <code>59,519.02
USDC</code> corresponds to $59,519.02 / 29,759.51 =$ <code>2 wBTC</code>


<a name="@Scaled_integer_price_3"></a>

### Scaled integer price


Again, however, coin values are ultimately represented as <code>u64</code>
amounts, and similarly, the present implementation's matching engine
relies on <code>u64</code> prices. Hence a price "scale factor" is sometimes
required, for instance when trading digital assets having a
relatively low valuation:

Consider recently issued protocol coin <code>PRO</code>, which has 3 decimal
places, a circulating supply of 1 billion, and a <code>USDC</code>-denominated
market cap of $100,000. A single user-facing representation of a
coin, <code>1.000 PRO</code>, thus corresponds to <code>1000</code> indivisible subunits
and has a market price of $100,000 / 10^9 =$ <code>0.0001 USDC</code>, which
means that one indivisible subunit of <code>PRO</code> has a market value of
$0.0001 / 1000 =$ <code>0.0000001 USDC</code>. Except <code>USDC</code> only has 6 decimal
places, meaning that an indivisible subunit of <code>PRO</code> costs less than
one indivisible subunit of <code>USDC</code> (<code>0.000001 USDC</code>). Hence, an order
for <code>2.567 PRO</code> would be invalid, since it would correspond to
<code>0.0000002567 USDC</code>, an unrepresentable amount.

The proposed solution is a scaled integer price, defined as the
number of quote subunits per <code>SF</code> base subunits (<code>SF</code> denoting
scale factor):
* $price_{scaled} = \frac{subunits_{quote}}{subunits_{base} / SF} =$
$SF(\frac{subunits_{quote}}{subunits_{base}})$
* $subunits_{base} = SF (subunits_{quote} / price_{scaled})$
* $subunits_{quote} = price_{scaled} (subunits_{base} / SF)$

For instance, a scale factor of 1,000 for the current
example yields prices denoting the number of <code>USDC</code> subunits
(<code>0.000001 USDC</code>) per 1,000 <code>PRO</code> subunits (<code>1.000 PRO</code>). At a
nominal price of <code>0.0001 USDC</code> per <code>1.000 PRO</code>, the scaled integer
price would thus be <code>100</code>, a valid <code>u64</code>.  Likewise, if the price
were to fall to <code>0.000001 USDC</code> per <code>1.000 PRO</code>, the scaled integer
price would then be <code>1</code>, still a valid <code>u64</code>. Here, the base coin
can only be transacted in amounts that are integer multiples of the
scale factor, because otherwise the corresponding number of quote
coin subunits could assume a non-integer value: a user may place an
order to trade <code>1.000 PRO</code> or <code>2.000 PRO</code>, but not <code>1.500 PRO</code>,
because at a scaled integer price of <code>1</code>, it would require 1.5
indivisible <code>USDC</code> subunits to settle the trade, an amount that
cannot be represented in a <code>u64</code>.


<a name="@Market_effects_4"></a>

### Market effects


If, eventually, the <code>USDC</code>-denominated market capitalization of
<code>PRO</code> were to increase to $100B, then each <code>1.000 PRO</code> would assume
a nominal value of <code>$100</code>, and a scale factor of <code>1000</code> would not
provide adequate trading granularity: a user could place an order
for <code>1.000 PRO</code> (<code>100 USDC</code>) or <code>2.000 PRO</code> (<code>200 USDC</code>), but
due to the integer-multiple lot size requirement described above,
enforced at the algorithm level, it would be impossible to place an
order for <code>.5 PRO</code> (<code>50 USDC</code>). This limitation would almost
certainly restrict retail trading activity, thus reducing price
discovery efficiency, and so the scale factor of <code>1000</code> would no
longer be appropriate.

But what is the most appropriate new scale factor for this mature
trading pair? <code>100</code>? <code>10</code>? <code>1</code>? What happens if the price later
plummets? And if the scale factor should be updated, then who
executes the code change, and when do they do it? Shall the
centralized authority who mints USDC (and who also has the power to
arbitrarily seize anyone's assets) additionally be granted the
authority to change the scale factor at any time? What if said
entity, of for that matter, any centralized entity that can either
act maliciously or be coerced, intentionally chooses an
inappropriate scale factor in the interest of halting activity on an
arbitrary trading pair?

With regard to choosing an appropriate scale factor, or more broadly
for facilitating trading pairs in general, the present
implementation's solution is to simply "let the market decide", via
a permissionless market registration system that allows anyone to
register any trading pair, with any scale factor of the form
$10^E, E\in \{0, 1, 2, \ldots, 19\}$, as long as the trading pair
has not already been initialized. Hence, when a new coin becomes
available, several trading pairs are likely to be established across
different scale factors, and the correspondingly fractured liquidity
will tend to gravitate towards a preferred scale factor. As prices
go up or down, liquidity will naturally migrate to the most
efficient scale factor, without any input from a centralized entity.


<a name="@Data_structures_5"></a>

## Data structures



<a name="@Market_info_6"></a>

### Market info


A trading pair, or market, is fully specified by a unique <code><a href="Registry.md#0xc0deb00c_Registry_MI">MI</a></code>
(Market info) struct, which has fields for a base coin type, a quote
coin type, and a so-called "scale exponent" (<code>E</code> as above,
corresponding to a power of 10). These types are represented in
other functions and structs as <code>&lt;B, Q, E&gt;</code>.

Since markets are permissionless, anyone can register a market,
assuming that the correspondingly unique <code><a href="Registry.md#0xc0deb00c_Registry_MI">MI</a></code> specifier has not
already been registered under the market registry, <code><a href="Registry.md#0xc0deb00c_Registry_MR">MR</a></code>, stored at
the Econia address. The account that registers a market is known as
a "host", because during registration they agree to host under their
account an <code>Econia::Book::OB</code> that will facilitate trading.


<a name="@Scale_exponents_and_factors_7"></a>

### Scale exponents and factors


The scale exponent types <code><a href="Registry.md#0xc0deb00c_Registry_E0">E0</a></code>, <code><a href="Registry.md#0xc0deb00c_Registry_E1">E1</a></code>, ..., <code><a href="Registry.md#0xc0deb00c_Registry_E19">E19</a></code>, correspond to the
scale factors <code><a href="Registry.md#0xc0deb00c_Registry_F0">F0</a></code>, <code><a href="Registry.md#0xc0deb00c_Registry_F1">F1</a></code>, ... <code><a href="Registry.md#0xc0deb00c_Registry_F19">F19</a></code>, with lookup
functionality provided by <code><a href="Registry.md#0xc0deb00c_Registry_scale_factor">scale_factor</a>&lt;E&gt;()</code>. Notably, scale
exponents are types, while scale factors are <code>u64</code>, with the former
enabling lookup in global storage, and the latter enabling integer
arithmetic at the matching engine level. From a purely computer
science perspective, it would actually be more straightforward for
scale exponents and factors to correspond to powers of two, but
since the present implementation is financially-motivated, powers of
10 are instead used. Hence the largest scale factor is <code><a href="Registry.md#0xc0deb00c_Registry_F19">F19</a></code>
$= 10^{19} =$ <code>10000000000000000000</code>, the largest power of ten that
can be represented in a <code>u64</code>


<a name="@Test-oriented_architecture_8"></a>

## Test-oriented architecture


The current module relies heavily on Move native functions defined
in the <code>AptosFramework</code>, for which the <code><b>move</b></code> CLI's coverage testing
tool does not offer support. Thus, since the <code>aptos</code> CLI does not
offer any coverage testing support whatsoever, the current module
cannot be coverage tested per straightforward methods.

Other modules, however, do not depend as strongly on such native
functions, and as such, whenever possible, they are implemented
purely in Move to enable coverage testing, for example, like
<code>Econia::CritBit</code>. Occasionally this approach requires workarounds,
for instance like <code><a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a></code>, a cumbersome alternative to the use of
a <code><b>public</b>(<b>friend</b>)</code> function: a more straightforward approach would
involve making <code>Econia::Book::init_book</code> only available to friend
modules, but this would involve the declaration of the present
module as a friend, and since the present module relies on
<code>AptosFramework</code> native functions, the <code><b>move</b></code> CLI test compiler
would thus break when attempting to link the corresponding files,
even when only attempting to run coverage tests on <code>Econia::Book</code>.
Hence the use of <code>Econia::Book::BookInitCap</code> and <code><a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a></code>, an approach
that allows <code>Econia::Book</code> to be implemented purely in Move and to
be coverage tested using the <code><b>move</b></code> CLI.

---


-  [Dynamic scaling](#@Dynamic_scaling_0)
    -  [Coins](#@Coins_1)
    -  [Decimal price](#@Decimal_price_2)
    -  [Scaled integer price](#@Scaled_integer_price_3)
    -  [Market effects](#@Market_effects_4)
-  [Data structures](#@Data_structures_5)
    -  [Market info](#@Market_info_6)
    -  [Scale exponents and factors](#@Scale_exponents_and_factors_7)
-  [Test-oriented architecture](#@Test-oriented_architecture_8)
-  [Resource `BICC`](#0xc0deb00c_Registry_BICC)
-  [Struct `E0`](#0xc0deb00c_Registry_E0)
-  [Struct `E1`](#0xc0deb00c_Registry_E1)
-  [Struct `E2`](#0xc0deb00c_Registry_E2)
-  [Struct `E3`](#0xc0deb00c_Registry_E3)
-  [Struct `E4`](#0xc0deb00c_Registry_E4)
-  [Struct `E5`](#0xc0deb00c_Registry_E5)
-  [Struct `E6`](#0xc0deb00c_Registry_E6)
-  [Struct `E7`](#0xc0deb00c_Registry_E7)
-  [Struct `E8`](#0xc0deb00c_Registry_E8)
-  [Struct `E9`](#0xc0deb00c_Registry_E9)
-  [Struct `E10`](#0xc0deb00c_Registry_E10)
-  [Struct `E11`](#0xc0deb00c_Registry_E11)
-  [Struct `E12`](#0xc0deb00c_Registry_E12)
-  [Struct `E13`](#0xc0deb00c_Registry_E13)
-  [Struct `E14`](#0xc0deb00c_Registry_E14)
-  [Struct `E15`](#0xc0deb00c_Registry_E15)
-  [Struct `E16`](#0xc0deb00c_Registry_E16)
-  [Struct `E17`](#0xc0deb00c_Registry_E17)
-  [Struct `E18`](#0xc0deb00c_Registry_E18)
-  [Struct `E19`](#0xc0deb00c_Registry_E19)
-  [Struct `MI`](#0xc0deb00c_Registry_MI)
-  [Resource `MR`](#0xc0deb00c_Registry_MR)
-  [Resource `OO`](#0xc0deb00c_Registry_OO)
-  [Constants](#@Constants_9)
-  [Function `init_b_i_c_c`](#0xc0deb00c_Registry_init_b_i_c_c)
-  [Function `init_registry`](#0xc0deb00c_Registry_init_registry)
-  [Function `register_market`](#0xc0deb00c_Registry_register_market)
-  [Function `scale_factor`](#0xc0deb00c_Registry_scale_factor)
-  [Function `verify_address`](#0xc0deb00c_Registry_verify_address)
-  [Function `verify_bytestring`](#0xc0deb00c_Registry_verify_bytestring)
-  [Function `verify_market_types`](#0xc0deb00c_Registry_verify_market_types)
-  [Function `verify_t_i`](#0xc0deb00c_Registry_verify_t_i)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/Table.md#0x1_Table">0x1::Table</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo">0x1::TypeInfo</a>;
<b>use</b> <a href="Book.md#0xc0deb00c_Book">0xc0deb00c::Book</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
</code></pre>



<a name="0xc0deb00c_Registry_BICC"></a>

## Resource `BICC`

Book initialization capability container


<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>b_i_c: <a href="Book.md#0xc0deb00c_Book_BookInitCap">Book::BookInitCap</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E0"></a>

## Struct `E0`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E0">E0</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E1"></a>

## Struct `E1`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E1">E1</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E2"></a>

## Struct `E2`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E2">E2</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E3"></a>

## Struct `E3`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E3">E3</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E4"></a>

## Struct `E4`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E4">E4</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E5"></a>

## Struct `E5`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E5">E5</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E6"></a>

## Struct `E6`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E6">E6</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E7"></a>

## Struct `E7`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E7">E7</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E8"></a>

## Struct `E8`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E8">E8</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E9"></a>

## Struct `E9`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E9">E9</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E10"></a>

## Struct `E10`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E10">E10</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E11"></a>

## Struct `E11`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E11">E11</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E12"></a>

## Struct `E12`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E12">E12</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E13"></a>

## Struct `E13`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E13">E13</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E14"></a>

## Struct `E14`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E14">E14</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E15"></a>

## Struct `E15`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E15">E15</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E16"></a>

## Struct `E16`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E16">E16</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E17"></a>

## Struct `E17`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E17">E17</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E18"></a>

## Struct `E18`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E18">E18</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_E19"></a>

## Struct `E19`



<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_E19">E19</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_MI"></a>

## Struct `MI`

Market info


<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_MI">MI</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>b: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Base CoinType TypeInfo
</dd>
<dt>
<code>q: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Quote CoinType TypeInfo
</dd>
<dt>
<code>e: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Scale exponent TypeInfo
</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_MR"></a>

## Resource `MR`

Market registry


<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_MR">MR</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>t: <a href="../../../build/AptosFramework/docs/Table.md#0x1_Table_Table">Table::Table</a>&lt;<a href="Registry.md#0xc0deb00c_Registry_MI">Registry::MI</a>, <b>address</b>&gt;</code>
</dt>
<dd>
 Table from <code><a href="Registry.md#0xc0deb00c_Registry_MI">MI</a></code> to address hosting the corresponding <code>MC</code>
</dd>
</dl>


</details>

<a name="0xc0deb00c_Registry_OO"></a>

## Resource `OO`

Open orders on a user's account


<pre><code><b>struct</b> <a href="Registry.md#0xc0deb00c_Registry_OO">OO</a>&lt;B, Q, E&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>f: u64</code>
</dt>
<dd>
 Scale factor
</dd>
<dt>
<code>a: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;u64&gt;</code>
</dt>
<dd>
 Asks
</dd>
<dt>
<code>b: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;u64&gt;</code>
</dt>
<dd>
 Bids
</dd>
<dt>
<code>b_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;B&gt;</code>
</dt>
<dd>
 Base coins
</dd>
<dt>
<code>b_a: u64</code>
</dt>
<dd>
 Base coins available to withdraw
</dd>
<dt>
<code>q_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;Q&gt;</code>
</dt>
<dd>
 Quote coins
</dd>
<dt>
<code>q_a: u64</code>
</dt>
<dd>
 Quote coins available to withdraw
</dd>
</dl>


</details>

<a name="@Constants_9"></a>

## Constants


<a name="0xc0deb00c_Registry_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Registry_E_HAS_BICC"></a>

When book initialization capability container already published


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_HAS_BICC">E_HAS_BICC</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_Registry_E_NOT_COIN"></a>

When a type does not correspond to a coin


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_NOT_COIN">E_NOT_COIN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_Registry_E_NO_BICC"></a>

When book initialization capability container not published


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_NO_BICC">E_NO_BICC</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_Registry_E_NO_REGISTRY"></a>

When market registry not initialized


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_NO_REGISTRY">E_NO_REGISTRY</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_Registry_E_REGISTERED"></a>

When a given market is already registered


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_REGISTERED">E_REGISTERED</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Registry_E_WRONG_EXPONENT_T"></a>

When wrong type for exponent flag


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_WRONG_EXPONENT_T">E_WRONG_EXPONENT_T</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Registry_E_WRONG_MODULE"></a>

When wrong module


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_E_WRONG_MODULE">E_WRONG_MODULE</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Registry_F0"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F0">F0</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Registry_F1"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F1">F1</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_Registry_F10"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F10">F10</a>: u64 = 10000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F11"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F11">F11</a>: u64 = 100000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F12"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F12">F12</a>: u64 = 1000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F13"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F13">F13</a>: u64 = 10000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F14"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F14">F14</a>: u64 = 100000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F15"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F15">F15</a>: u64 = 1000000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F16"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F16">F16</a>: u64 = 10000000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F17"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F17">F17</a>: u64 = 100000000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F18"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F18">F18</a>: u64 = 1000000000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F19"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F19">F19</a>: u64 = 10000000000000000000;
</code></pre>



<a name="0xc0deb00c_Registry_F2"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F2">F2</a>: u64 = 100;
</code></pre>



<a name="0xc0deb00c_Registry_F3"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F3">F3</a>: u64 = 1000;
</code></pre>



<a name="0xc0deb00c_Registry_F4"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F4">F4</a>: u64 = 10000;
</code></pre>



<a name="0xc0deb00c_Registry_F5"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F5">F5</a>: u64 = 100000;
</code></pre>



<a name="0xc0deb00c_Registry_F6"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F6">F6</a>: u64 = 1000000;
</code></pre>



<a name="0xc0deb00c_Registry_F7"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F7">F7</a>: u64 = 10000000;
</code></pre>



<a name="0xc0deb00c_Registry_F8"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F8">F8</a>: u64 = 100000000;
</code></pre>



<a name="0xc0deb00c_Registry_F9"></a>



<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_F9">F9</a>: u64 = 1000000000;
</code></pre>



<a name="0xc0deb00c_Registry_M_NAME"></a>

This module's name


<pre><code><b>const</b> <a href="Registry.md#0xc0deb00c_Registry_M_NAME">M_NAME</a>: vector&lt;u8&gt; = [82, 101, 103, 105, 115, 116, 114, 121];
</code></pre>



<a name="0xc0deb00c_Registry_init_b_i_c_c"></a>

## Function `init_b_i_c_c`

Publish <code><a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a></code> to Econia acount, aborting for all other accounts


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_init_b_i_c_c">init_b_i_c_c</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_init_b_i_c_c">init_b_i_c_c</a>(
    account: &signer
) {
    // Assert account is Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Registry.md#0xc0deb00c_Registry_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert capability container not already initialized
    <b>assert</b>!(!<b>exists</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a>&gt;(@Econia), <a href="Registry.md#0xc0deb00c_Registry_E_HAS_BICC">E_HAS_BICC</a>);
    // Move book initialization capability container <b>to</b> account
    <b>move_to</b>(account, <a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a>{b_i_c: b_g_b_i_c(account)});
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_init_registry"></a>

## Function `init_registry`

Publish <code><a href="Registry.md#0xc0deb00c_Registry_MR">MR</a></code> to Econia acount, aborting for all other accounts


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_init_registry">init_registry</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_init_registry">init_registry</a>(
    account: &signer
) {
    // Assert account is Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Registry.md#0xc0deb00c_Registry_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Move empty market registry <b>to</b> account
    <b>move_to</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_MR">MR</a>&gt;(account, <a href="Registry.md#0xc0deb00c_Registry_MR">MR</a>{t: t_n&lt;<a href="Registry.md#0xc0deb00c_Registry_MI">MI</a>, <b>address</b>&gt;()});
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_register_market"></a>

## Function `register_market`

Register a market for the given base coin type <code>B</code>, quote coin
type <code>Q</code>, and scale exponent <code>E</code> , aborting if registry not
initialized or if market already registered


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_register_market">register_market</a>&lt;B, Q, E&gt;(host: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_register_market">register_market</a>&lt;B, Q, E&gt;(
    host: &signer
) <b>acquires</b> <a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a>, <a href="Registry.md#0xc0deb00c_Registry_MR">MR</a> {
    <a href="Registry.md#0xc0deb00c_Registry_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;(); // Verify valid type arguments
    // Assert market registry is initialized at Econia account
    <b>assert</b>!(<b>exists</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_MR">MR</a>&gt;(@Econia), <a href="Registry.md#0xc0deb00c_Registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Get market info for given type arguments
    <b>let</b> m_i = <a href="Registry.md#0xc0deb00c_Registry_MI">MI</a>{b: ti_t_o&lt;B&gt;(), q: ti_t_o&lt;Q&gt;(), e: ti_t_o&lt;E&gt;()};
    // Borrow mutable reference <b>to</b> market registry table
    <b>let</b> r_t = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_MR">MR</a>&gt;(@Econia).t;
    // Assert requested market not already registered
    <b>assert</b>!(!t_c(r_t, m_i), <a href="Registry.md#0xc0deb00c_Registry_E_REGISTERED">E_REGISTERED</a>);
    // Assert Econia account <b>has</b> book initialization capability
    <b>assert</b>!(<b>exists</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a>&gt;(@Econia), <a href="Registry.md#0xc0deb00c_Registry_E_NO_BICC">E_NO_BICC</a>);
    // Borrow immutable reference <b>to</b> book initialization capability
    <b>let</b> b_i_c = &<b>borrow_global</b>&lt;<a href="Registry.md#0xc0deb00c_Registry_BICC">BICC</a>&gt;(@Econia).b_i_c;
    // Initialize empty order book under host account
    b_i_b&lt;B, Q, E&gt;(host, <a href="Registry.md#0xc0deb00c_Registry_scale_factor">scale_factor</a>&lt;E&gt;(), b_i_c);
    t_a(r_t, m_i, s_a_o(host)); // Register market-host relationship
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_scale_factor"></a>

## Function `scale_factor`

Return scale factor corresponding to scale exponent type <code>E</code>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_scale_factor">scale_factor</a>&lt;E&gt;(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_scale_factor">scale_factor</a>&lt;E&gt;():
u64 {
    <b>let</b> t_i = ti_t_o&lt;E&gt;(); // Get type info of exponent type flag
    // Verify exponent type flag is from Econia <b>address</b>
    <a href="Registry.md#0xc0deb00c_Registry_verify_address">verify_address</a>(ti_a_a(&t_i), @Econia, <a href="Registry.md#0xc0deb00c_Registry_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Verify exponent type flag is from this <b>module</b>
    <a href="Registry.md#0xc0deb00c_Registry_verify_bytestring">verify_bytestring</a>(ti_m_n(&t_i), <a href="Registry.md#0xc0deb00c_Registry_M_NAME">M_NAME</a>, <a href="Registry.md#0xc0deb00c_Registry_E_WRONG_MODULE">E_WRONG_MODULE</a>);
    <b>let</b> s_n = ti_s_n(&t_i); // Get type <b>struct</b> name
    // Return corresponding scale factor
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E0">E0</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F0">F0</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E1">E1</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F1">F1</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E2">E2</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F2">F2</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E3">E3</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F3">F3</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E4">E4</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F4">F4</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E5">E5</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F5">F5</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E6">E6</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F6">F6</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E7">E7</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F7">F7</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E8">E8</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F8">F8</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E9">E9</a>&gt;() )) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F9">F9</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E10">E10</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F10">F10</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E11">E11</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F11">F11</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E12">E12</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F12">F12</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E13">E13</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F13">F13</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E14">E14</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F14">F14</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E15">E15</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F15">F15</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E16">E16</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F16">F16</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E17">E17</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F17">F17</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E18">E18</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F18">F18</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Registry.md#0xc0deb00c_Registry_E19">E19</a>&gt;())) <b>return</b> <a href="Registry.md#0xc0deb00c_Registry_F19">F19</a>;
    <b>abort</b> <a href="Registry.md#0xc0deb00c_Registry_E_WRONG_EXPONENT_T">E_WRONG_EXPONENT_T</a> // Else <b>abort</b>
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_verify_address"></a>

## Function `verify_address`

Assert <code>a1</code> equals <code>a2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_address">verify_address</a>(a1: <b>address</b>, a2: <b>address</b>, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_address">verify_address</a>(
    a1: <b>address</b>,
    a2: <b>address</b>,
    e: u64
) {
    <b>assert</b>!(a1 == a2, e); // Assert equality
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_verify_bytestring"></a>

## Function `verify_bytestring`

Assert <code>s1</code> equals <code>s2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_bytestring">verify_bytestring</a>(bs1: vector&lt;u8&gt;, bs2: vector&lt;u8&gt;, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_bytestring">verify_bytestring</a>(
    bs1: vector&lt;u8&gt;,
    bs2: vector&lt;u8&gt;,
    e: u64
) {
    <b>assert</b>!(bs1 == bs2, e); // Assert equality
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_verify_market_types"></a>

## Function `verify_market_types`

Assert <code>B</code> and <code>Q</code> are coins, and that <code>E</code> is scale exponent


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;() {
    <b>assert</b>!(c_i_c_i&lt;B&gt;(), <a href="Registry.md#0xc0deb00c_Registry_E_NOT_COIN">E_NOT_COIN</a>); // Assert base quote type
    <b>assert</b>!(c_i_c_i&lt;Q&gt;(), <a href="Registry.md#0xc0deb00c_Registry_E_NOT_COIN">E_NOT_COIN</a>); // Assert quote coin type
    // Assert scale exponent type <b>has</b> corresponding scale factor
    <a href="Registry.md#0xc0deb00c_Registry_scale_factor">scale_factor</a>&lt;E&gt;();
}
</code></pre>



</details>

<a name="0xc0deb00c_Registry_verify_t_i"></a>

## Function `verify_t_i`

Assert <code>t1</code> equals <code>t2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_t_i">verify_t_i</a>(t1: &<a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a>, t2: &<a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a>, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Registry.md#0xc0deb00c_Registry_verify_t_i">verify_t_i</a>(
    t1: &TI,
    t2: &TI,
    e: u64
) {
    <a href="Registry.md#0xc0deb00c_Registry_verify_address">verify_address</a>(ti_a_a(t1), ti_a_a(t2), e); // Verify <b>address</b>
    <a href="Registry.md#0xc0deb00c_Registry_verify_bytestring">verify_bytestring</a>(ti_m_n(t1), ti_m_n(t2), e); // Verify <b>module</b>
    <a href="Registry.md#0xc0deb00c_Registry_verify_bytestring">verify_bytestring</a>(ti_s_n(t1), ti_s_n(t2), e); // Verify <b>struct</b>
}
</code></pre>



</details>
