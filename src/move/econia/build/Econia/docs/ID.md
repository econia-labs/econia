
<a name="0xc0deb00c_ID"></a>

# Module `0xc0deb00c::ID`


<a name="@Bit_structure_0"></a>

## Bit structure


An order id is a 128-bit number, where the most-significant
("first") 64 bits indicate the scaled integer price (see
<code>Econia::Registry</code>) of the order, regardless of whether it is an ask
or bid. The least-significant ("last") 64 bits indicate the Aptos
database version number at which the order was placed, unmodified in
the case of an ask, but with each bit flipped in the case of a bid.


<a name="@Example_ask_1"></a>

### Example ask


For a scaled integer price of <code>255</code> (<code>0b11111111</code>) and an Aptos
database version number of <code>170</code> (<code>0b10101010</code>), an ask would have
an order ID with the first 64 bits
<code>0000000000000000000000000000000000000000000000000000000011111111</code>
and the last 64 bits
<code>0000000000000000000000000000000000000000000000000000000010101010</code>,
corresponding to the base-10 integer <code>4703919738795935662250</code>


<a name="@Example_bid_2"></a>

### Example bid


For a scaled integer price of <code>15</code> (<code>0b1111</code>) and an Aptos database
version number of <code>63</code> (<code>0b111111</code>), a bid would have an order ID
with the first 64 bits
<code>0000000000000000000000000000000000000000000000000000000000001111</code>
and the last 64 bits
<code>1111111111111111111111111111111111111111111111111111111111000000</code>,
corresponding to the base-10 integer <code>295147905179352825792</code>


<a name="@Motivations_3"></a>

## Motivations


Positions in an order book are represented as outer nodes in an
<code>Econia::CritBit</code> tree, which allows for traversal across nodes
during the matching process.


<a name="@Market_buy_example_4"></a>

### Market buy example


In the case of a market buy, the matching engine first fills against
the oldest ask at the lowest price, then fills against the second
oldest ask at the lowest price (if there is one). The process
continues, prioritizing older positions, until the price level has
been exhausted, at which point the matching engine moves onto the
next-lowest price level, similarly filling against positions in
chronological priority.

Here, with the first 64 bits of the order ID corresponding to price
and the last 64 bits corresponding to Aptos database version number,
asks are automatically sorted, upon insertion to the tree, into the
order in which they should be filled: first ascending from lowest
price to highest price, then ascending from lowest version number to
highest version number within a price level. All the matching engine
must do is iterate through inorder successor traversals until the
market buy has been filled.


<a name="@Market_sell_example_5"></a>

### Market sell example


In the case of a market sell, the ordering of prices is reversed,
but the chronology of priority is not: first the matching engine
should fill against bids at the highest price level, starting with
the oldest position, then fill older positions first, before moving
onto the next price level. Hence, the final 64 bits of the order ID
are all flipped, because this allows the matching engine to simply
iterate through inorder predecessor traversals until the market buy
has been filled.

More specifically, by flipping the final 64 bits, order IDs from
lower version numbers are sorted above those from higher version
numbers, within a given price level: at a scaled integer price of
<code>1</code> (<code>0b1</code>), an order from version number <code>15</code> (<code>0b1111</code>) has order
ID with bits
<code>11111111111111111111111111111111111111111111111111111111111110000</code>,
corresponding to the base-10 integer <code>36893488147419103216</code>, while
an order at the same price from version number <code>63</code> (<code>0b111111</code>) has
order ID with bits
<code>11111111111111111111111111111111111111111111111111111111111000000</code>,
corresponding to the base-10 integer <code>36893488147419103168</code>. The
order from version number <code>63</code> thus has an order ID of lesser value
than that of the order from version number <code>15</code>, and as such, during
the matching engine's iterated inorder predecessor traversal, the
order from version number <code>63</code> will be filled second.


-  [Bit structure](#@Bit_structure_0)
    -  [Example ask](#@Example_ask_1)
    -  [Example bid](#@Example_bid_2)
-  [Motivations](#@Motivations_3)
    -  [Market buy example](#@Market_buy_example_4)
    -  [Market sell example](#@Market_sell_example_5)
-  [Constants](#@Constants_6)
-  [Function `id_a`](#0xc0deb00c_ID_id_a)
-  [Function `id_b`](#0xc0deb00c_ID_id_b)
-  [Function `price`](#0xc0deb00c_ID_price)
-  [Function `v_n_a`](#0xc0deb00c_ID_v_n_a)
-  [Function `v_n_b`](#0xc0deb00c_ID_v_n_b)


<pre><code></code></pre>



<a name="@Constants_6"></a>

## Constants


<a name="0xc0deb00c_ID_FIRST_64"></a>

Positions to bitshift for operating on first 64 bits


<pre><code><b>const</b> <a href="ID.md#0xc0deb00c_ID_FIRST_64">FIRST_64</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_ID_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="ID.md#0xc0deb00c_ID_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_ID_id_a"></a>

## Function `id_a`

Return order ID for ask with price <code>p</code> and version number <code>v</code>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_id_a">id_a</a>(p: u64, v: u64): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_id_a">id_a</a>(
    p: u64,
    v: u64
): u128 {
    (p <b>as</b> u128) &lt;&lt; <a href="ID.md#0xc0deb00c_ID_FIRST_64">FIRST_64</a> | (v <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_ID_id_b"></a>

## Function `id_b`

Return order ID for bid with price <code>p</code> and version number <code>v</code>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_id_b">id_b</a>(p: u64, v: u64): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_id_b">id_b</a>(
    p: u64,
    v: u64
): u128 {
    (p <b>as</b> u128) &lt;&lt; <a href="ID.md#0xc0deb00c_ID_FIRST_64">FIRST_64</a> | (v ^ <a href="ID.md#0xc0deb00c_ID_HI_64">HI_64</a> <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_ID_price"></a>

## Function `price`

Return scaled integer price of an order ID, ask or bid


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_price">price</a>(id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_price">price</a>(id: u128): u64 {(id &gt;&gt; <a href="ID.md#0xc0deb00c_ID_FIRST_64">FIRST_64</a> <b>as</b> u64)}
</code></pre>



</details>

<a name="0xc0deb00c_ID_v_n_a"></a>

## Function `v_n_a`

Return version number of order ID corresponding to an ask


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_v_n_a">v_n_a</a>(id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_v_n_a">v_n_a</a>(id: u128): u64 {(id & (<a href="ID.md#0xc0deb00c_ID_HI_64">HI_64</a> <b>as</b> u128) <b>as</b> u64)}
</code></pre>



</details>

<a name="0xc0deb00c_ID_v_n_b"></a>

## Function `v_n_b`

Return version number of order ID corresponding to a bid


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_v_n_b">v_n_b</a>(id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ID.md#0xc0deb00c_ID_v_n_b">v_n_b</a>(id: u128): u64 {(id & (<a href="ID.md#0xc0deb00c_ID_HI_64">HI_64</a> <b>as</b> u128) <b>as</b> u64) ^ <a href="ID.md#0xc0deb00c_ID_HI_64">HI_64</a>}
</code></pre>



</details>
