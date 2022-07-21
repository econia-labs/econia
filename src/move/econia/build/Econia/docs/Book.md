
<a name="0xc0deb00c_Book"></a>

# Module `0xc0deb00c::Book`


<a name="@Test_oriented_implementation_0"></a>

## Test oriented implementation


The present module is implemented purely in Move, to enable coverage
testing as described in <code>Econia::Caps</code>. Hence the use of <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>
in public functions.


<a name="@Order_structure_1"></a>

## Order structure


For a market specified by <code>&lt;B, Q, E&gt;</code> (see <code>Econia::Registry</code>), an
order book is stored in an <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code>, which has a <code>Econia::CritBit::CB</code>
for both asks and bids. In each tree, key-value pairs have a key
formatted per <code>Econia::ID</code>, and a value <code><a href="Book.md#0xc0deb00c_Book_P">P</a></code>, which indicates the
user holding the corresponding position in the order book, as well
as the scaled size (see <code>Econia::Orders</code>) of the position remaining
to be filled.


<a name="@Order_placement_2"></a>

### Order placement


---


-  [Test oriented implementation](#@Test_oriented_implementation_0)
-  [Order structure](#@Order_structure_1)
    -  [Order placement](#@Order_placement_2)
-  [Struct `FriendCap`](#0xc0deb00c_Book_FriendCap)
-  [Resource `OB`](#0xc0deb00c_Book_OB)
-  [Struct `P`](#0xc0deb00c_Book_P)
-  [Struct `Order`](#0xc0deb00c_Book_Order)
-  [Struct `PriceLevel`](#0xc0deb00c_Book_PriceLevel)
-  [Constants](#@Constants_3)
-  [Function `add_ask`](#0xc0deb00c_Book_add_ask)
-  [Function `add_bid`](#0xc0deb00c_Book_add_bid)
-  [Function `cancel_ask`](#0xc0deb00c_Book_cancel_ask)
-  [Function `cancel_bid`](#0xc0deb00c_Book_cancel_bid)
-  [Function `cancel_position`](#0xc0deb00c_Book_cancel_position)
    -  [Parameters](#@Parameters_4)
    -  [Assumes](#@Assumes_5)
-  [Function `exists_book`](#0xc0deb00c_Book_exists_book)
-  [Function `get_friend_cap`](#0xc0deb00c_Book_get_friend_cap)
-  [Function `init_book`](#0xc0deb00c_Book_init_book)
-  [Function `n_asks`](#0xc0deb00c_Book_n_asks)
-  [Function `n_bids`](#0xc0deb00c_Book_n_bids)
-  [Function `refresh_extreme_order_id`](#0xc0deb00c_Book_refresh_extreme_order_id)
-  [Function `scale_factor`](#0xc0deb00c_Book_scale_factor)
-  [Function `traverse_init_fill`](#0xc0deb00c_Book_traverse_init_fill)
-  [Function `traverse_pop_fill`](#0xc0deb00c_Book_traverse_pop_fill)
-  [Function `add_position`](#0xc0deb00c_Book_add_position)
    -  [Parameters](#@Parameters_6)
    -  [Returns](#@Returns_7)
    -  [Assumes](#@Assumes_8)
    -  [Spread terminology](#@Spread_terminology_9)
-  [Function `check_size`](#0xc0deb00c_Book_check_size)
    -  [Terminology](#@Terminology_10)
    -  [Parameters](#@Parameters_11)
    -  [Returns](#@Returns_12)
-  [Function `get_orders`](#0xc0deb00c_Book_get_orders)
-  [Function `get_price_levels`](#0xc0deb00c_Book_get_price_levels)
-  [Function `process_fill_scenarios`](#0xc0deb00c_Book_process_fill_scenarios)
    -  [Abort conditions](#@Abort_conditions_13)
-  [Function `traverse_fill`](#0xc0deb00c_Book_traverse_fill)
    -  [Terminology](#@Terminology_14)
    -  [Parameters](#@Parameters_15)
    -  [Returns](#@Returns_16)
    -  [Considerations](#@Considerations_17)
    -  [Assumes](#@Assumes_18)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
<b>use</b> <a href="ID.md#0xc0deb00c_ID">0xc0deb00c::ID</a>;
</code></pre>



<a name="0xc0deb00c_Book_FriendCap"></a>

## Struct `FriendCap`

Friend-like capability, administered instead of declaring as a
friend a module containing Aptos native functions, which would
inhibit coverage testing via the Move CLI. See <code>Econia::Caps</code>


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0xc0deb00c_Book_OB"></a>

## Resource `OB`

Order book with base coin type <code>B</code>, quote coin type <code>Q</code>, and
scale exponent type <code>E</code>


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt; <b>has</b> key
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
<code>a: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;<a href="Book.md#0xc0deb00c_Book_P">Book::P</a>&gt;</code>
</dt>
<dd>
 Asks
</dd>
<dt>
<code>b: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;<a href="Book.md#0xc0deb00c_Book_P">Book::P</a>&gt;</code>
</dt>
<dd>
 Bids
</dd>
<dt>
<code>m_a: u128</code>
</dt>
<dd>
 Order ID (see <code>Econia::ID</code>) of minimum ask
</dd>
<dt>
<code>m_b: u128</code>
</dt>
<dd>
 Order ID (see <code>Econia::ID</code>) of maximum bid
</dd>
</dl>


</details>

<a name="0xc0deb00c_Book_P"></a>

## Struct `P`

Position in an order book


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_P">P</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>s: u64</code>
</dt>
<dd>
 Scaled size (see <code>Econia::Orders</code>) of position to be filled,
 in base coin parcels
</dd>
<dt>
<code>a: <b>address</b></code>
</dt>
<dd>
 Address holding position
</dd>
</dl>


</details>

<a name="0xc0deb00c_Book_Order"></a>

## Struct `Order`

Anonymized position, used only for SDK-generative functions like
<code><a href="Book.md#0xc0deb00c_Book_get_orders">get_orders</a>()</code>


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_Order">Order</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Price from position's order ID
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Number of base coin parcels in order
</dd>
</dl>


</details>

<a name="0xc0deb00c_Book_PriceLevel"></a>

## Struct `PriceLevel`

Price level, used only for SDK-generative functions like
<code><a href="Book.md#0xc0deb00c_Book_get_price_levels">get_price_levels</a>()</code>


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Price from position order IDs
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Net position size for given price, in base coin parcels
</dd>
</dl>


</details>

<a name="@Constants_3"></a>

## Constants


<a name="0xc0deb00c_Book_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_Book_L"></a>

Left direction, denoting predecessor traversal


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_L">L</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Book_R"></a>

Right direction, denoting successor traversal


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_R">R</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Book_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Book_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Book_E_BOOK_EXISTS"></a>

When order book already exists at given address


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Book_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Book_E_NO_BOOK"></a>

When book does not exist at given address


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_NO_BOOK">E_NO_BOOK</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_Book_E_SELF_MATCH"></a>

When both sides of a trade have same address


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_SELF_MATCH">E_SELF_MATCH</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Book_MAX_BID_DEFAULT"></a>

Default value for maximum bid order ID


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_Book_MIN_ASK_DEFAULT"></a>

Default value for minimum ask order ID


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_Book_add_ask"></a>

## Function `add_ask`

Wrapped <code><a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>, requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_ask">add_ask</a>&lt;B, Q, E&gt;(host: <b>address</b>, user: <b>address</b>, id: u128, price: u64, size: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_ask">add_ask</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    user: <b>address</b>,
    id: u128,
    price: u64,
    size: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): bool
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>&lt;B, Q, E&gt;(host, user, <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>, id, price, size)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_add_bid"></a>

## Function `add_bid`

Wrapped <code><a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_bid">add_bid</a>&lt;B, Q, E&gt;(host: <b>address</b>, user: <b>address</b>, id: u128, price: u64, size: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_bid">add_bid</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    user: <b>address</b>,
    id: u128,
    price: u64,
    size: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): bool
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>&lt;B, Q, E&gt;(host, user, <a href="Book.md#0xc0deb00c_Book_BID">BID</a>, id, price, size)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_cancel_ask"></a>

## Function `cancel_ask`

Wrapped <code><a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(host: <b>address</b>, id: u128, friend_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    id: u128,
    friend_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host, <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>, id, friend_cap);
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_cancel_bid"></a>

## Function `cancel_bid`

Wrapped <code><a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(host: <b>address</b>, id: u128, friend_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    id: u128,
    friend_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host, <a href="Book.md#0xc0deb00c_Book_BID">BID</a>, id, friend_cap);
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_cancel_position"></a>

## Function `cancel_position`

Cancel position on book for market <code>&lt;B, Q, E&gt;</code>, skipping
redundant error checks already covered by calling functions


<a name="@Parameters_4"></a>

### Parameters

* <code>host</code>: Address of market host
* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>id</code>: Order ID (see <code>Econia::ID</code>)
* <code>_c</code>: Immutable reference to <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>


<a name="@Assumes_5"></a>

### Assumes

* <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> for given market exists at host address
* Position has already been placed on book properly, by
preceding functions that perform their own error-checking


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host: <b>address</b>, side: bool, id: u128, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    side: bool,
    id: u128,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Borrow mutable reference <b>to</b> order book at host <b>address</b>
    <b>let</b> o_b = <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host);
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) { // If order is an ask
        <b>let</b> asks = &<b>mut</b> o_b.a; // Get mutable reference <b>to</b> asks tree
        <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: _, a: _} = pop&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks, id); // Pop/unpack position
        <b>if</b> (o_b.m_a == id) { // If cancelled order was the <b>min</b> ask
            // If asks tree now empty, set <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default
            o_b.m_a = <b>if</b> (is_empty&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks)) <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b>
                min_key&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks); // Otherwise set <b>to</b> new <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a>
        };
    } <b>else</b> { // If order is a bid
        <b>let</b> bids = &<b>mut</b> o_b.b; // Get mutable reference <b>to</b> bids tree
        <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: _, a: _} = pop&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids, id); // Pop/unpack position
        <b>if</b> (o_b.m_b == id) { // If cancelled order was the max bid
            // If bid tree now empty, set max bid <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default
            o_b.m_b = <b>if</b> (is_empty&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids)) <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a> <b>else</b>
                max_key&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids); // Otherwise set <b>to</b> new max bid <a href="ID.md#0xc0deb00c_ID">ID</a>
        };
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_exists_book"></a>

## Function `exists_book`

Return <code><b>true</b></code> if specified order book type exists at address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(a: <b>address</b>, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(
    a: <b>address</b>,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): bool {
    <b>exists</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(a)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_get_friend_cap"></a>

## Function `get_friend_cap`

Return a <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>, aborting if not called by Econia account


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_friend_cap">get_friend_cap</a>(<a href="">account</a>: &<a href="">signer</a>): <a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_friend_cap">get_friend_cap</a>(
    <a href="">account</a>: &<a href="">signer</a>
): <a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a> {
    // Assert called by Econia
    <b>assert</b>!(address_of(<a href="">account</a>) == @Econia, <a href="Book.md#0xc0deb00c_Book_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>{} // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_init_book"></a>

## Function `init_book`

Initialize order book under host account, provided <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>,
for market <code>&lt;B, Q, E&gt;</code> and corresponding scale factor <code>f</code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(host: &<a href="">signer</a>, f: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(
    host: &<a href="">signer</a>,
    f: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) {
    // Assert book does not already exist under host <a href="">account</a>
    <b>assert</b>!(!<a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(address_of(host), &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>{}),
        <a href="Book.md#0xc0deb00c_Book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>);
    <b>let</b> m_a = <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>; // Declare <b>min</b> ask default order <a href="ID.md#0xc0deb00c_ID">ID</a>
    <b>let</b> m_b = <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>; // Declare max bid default order <a href="ID.md#0xc0deb00c_ID">ID</a>
    <b>let</b> o_b = // Pack empty order book
        <a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;{f, a: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), b: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), m_a, m_b};
    <b>move_to</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host, o_b); // Move <b>to</b> host
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_n_asks"></a>

## Function `n_asks`

Return number of asks on order book, assuming order book exists
at host address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_n_asks">n_asks</a>&lt;B, Q, E&gt;(addr: <b>address</b>, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_n_asks">n_asks</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): u64
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Return length of asks tree
    length&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(&<b>borrow_global</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(addr).a)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_n_bids"></a>

## Function `n_bids`

Return number of bids on order book, assuming order book exists
at host address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_n_bids">n_bids</a>&lt;B, Q, E&gt;(addr: <b>address</b>, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_n_bids">n_bids</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): u64
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Return length of bids tree
    length&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(&<b>borrow_global</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(addr).b)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_refresh_extreme_order_id"></a>

## Function `refresh_extreme_order_id`

If <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>, refresh the minimum ask ID to that of the
minimum ask in the asks tree in <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> at <code>addr</code>, and if <code>side</code>,
is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, the maximum bid ID, assuming <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> already exists at
<code>addr</code>. If no positions, use default values.


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_refresh_extreme_order_id">refresh_extreme_order_id</a>&lt;B, Q, E&gt;(addr: <b>address</b>, side: bool, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_refresh_extreme_order_id">refresh_extreme_order_id</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>,
    side: bool,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Borrow mutable reference <b>to</b> order book at <b>address</b>
    <b>let</b> order_book = <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) { // If refreshing for asks
        // Set <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default value <b>if</b> empty tree
        order_book.m_a = <b>if</b> (is_empty(&order_book.a)) <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b>
            min_key(&order_book.a); // Otherwise set <b>to</b> <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a>
    } <b>else</b> { // If refreshing for bids
        // Set max bid <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default value <b>if</b> empty tree
        order_book.m_b = <b>if</b> (is_empty(&order_book.b)) <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a> <b>else</b>
            max_key(&order_book.b); // Otherwise set <b>to</b> max ask <a href="ID.md#0xc0deb00c_ID">ID</a>
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_scale_factor"></a>

## Function `scale_factor`

Return scale factor of specified order book, assuming order
book exists at host address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(addr: <b>address</b>, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): u64
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <b>borrow_global</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(addr).f // Return book's scale factor
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_traverse_init_fill"></a>

## Function `traverse_init_fill`

Wrapped call to <code><a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>()</code> for <code>init</code> parameter <code><b>true</b></code>,
requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_init_fill">traverse_init_fill</a>&lt;B, Q, E&gt;(host: <b>address</b>, incoming_address: <b>address</b>, side: bool, size_left: u64, quote_available: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): (u128, <b>address</b>, u64, u64, u64, bool, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_init_fill">traverse_init_fill</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    incoming_address: <b>address</b>,
    side: bool,
    size_left: u64,
    quote_available: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
): (
    u128,
    <b>address</b>,
    u64,
    u64,
    u64,
    bool,
    bool
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>&lt;B, Q, E&gt;(host, incoming_address, side, size_left,
        quote_available, <b>true</b>, 0, 0, 0, 0)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_traverse_pop_fill"></a>

## Function `traverse_pop_fill`

Wrapped call to <code><a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>()</code> for <code>init</code> parameter <code><b>false</b></code>,
requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_pop_fill">traverse_pop_fill</a>&lt;B, Q, E&gt;(host: <b>address</b>, incoming_address: <b>address</b>, side: bool, size_left: u64, quote_available: u64, n_positions: u64, start_id: u128, start_parent_field: u64, start_child_index: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): (u128, <b>address</b>, u64, u64, u64, bool, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_pop_fill">traverse_pop_fill</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    incoming_address: <b>address</b>,
    side: bool,
    size_left: u64,
    quote_available: u64,
    n_positions: u64,
    start_id: u128,
    start_parent_field: u64,
    start_child_index: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>,
): (
    u128,
    <b>address</b>,
    u64,
    u64,
    u64,
    bool,
    bool
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>&lt;B, Q, E&gt;(host, incoming_address, side, size_left,
        quote_available, <b>false</b>, n_positions, start_id, start_parent_field,
        start_child_index)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_add_position"></a>

## Function `add_position`

Add new position to book for market <code>&lt;B, Q, E&gt;</code>, as long as
order does not cross the spread, skipping redundant error checks
already covered by calling functions


<a name="@Parameters_6"></a>

### Parameters

* <code>host</code>: Address of market host
* <code>user</code>: Address of user submitting position
* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>id</code>: Order ID (see <code>Econia::ID</code>)
* <code>price</code>: Scaled integer price (see <code>Econia::ID</code>)
* <code>size</code>: Scaled order size (see <code>Econia::Orders</code>)


<a name="@Returns_7"></a>

### Returns

* <code><b>true</b></code> if the new position crosses the spread, <code><b>false</b></code>
otherwise


<a name="@Assumes_8"></a>

### Assumes

* Correspondent order has already passed validation checks per
<code>Econia::Orders::add_order()</code>
* <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> for given market exists at host address


<a name="@Spread_terminology_9"></a>

### Spread terminology

* An order that "encroaches" on the spread may either lie
"within" the spread, or may "cross" the spread. For example,
if the max bid price is 10 and the min ask price is 15, a bid
price of 11 is within the spread, a bid price of 16 crosses
the spread, and both such orders encroach on the spread. A bid
price of 9, however, does not encroach on the spread


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>&lt;B, Q, E&gt;(host: <b>address</b>, user: <b>address</b>, side: bool, id: u128, price: u64, size: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    user: <b>address</b>,
    side: bool,
    id: u128,
    price: u64,
    size: u64
): bool
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Borrow mutable reference <b>to</b> order book at host <b>address</b>
    <b>let</b> o_b = <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host);
    // Get minimum ask price and maximum bid price on book
    <b>let</b> (m_a_p, m_b_p) = (id_price(o_b.m_a), id_price(o_b.m_b));
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) { // If order is an ask
        <b>if</b> (price &gt; m_b_p) { // If order does not cross spread
            // Add corresponding position <b>to</b> ask tree
            insert(&<b>mut</b> o_b.a, id, <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: size, a: user});
            // If order is within spread, <b>update</b> <b>min</b> ask id
            <b>if</b> (price &lt; m_a_p) o_b.m_a = id;
        } <b>else</b> <b>return</b> <b>true</b>; // Otherwise indicate crossed spread
    } <b>else</b> { // If order is a bid
        <b>if</b> (price &lt; m_a_p) { // If order does not cross spread
            // Add corresponding position <b>to</b> bid tree
            insert(&<b>mut</b> o_b.b, id, <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: size, a: user});
            // If order is within spread, <b>update</b> max bid id
            <b>if</b> (price &gt; m_b_p) o_b.m_b = id;
        // Otherwise manage order that crosses spread
        } <b>else</b> <b>return</b> <b>true</b>; // Otherwise indicate crossed spread
    }; // <a href="Book.md#0xc0deb00c_Book_Order">Order</a> is on now on book, and did not cross spread
    <b>false</b> // Indicate spread not crossed
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_check_size"></a>

## Function `check_size`

Return immediately if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, otherwise verify that the
user with the incoming order has enough quote coins to fill
against the target ask on the book, either completely or
partially


<a name="@Terminology_10"></a>

### Terminology

* "Incoming order" has <code>requested_size</code> base coin parcels to be
filled
* "Target position" is the corresponding <code><a href="Book.md#0xc0deb00c_Book_P">P</a></code> on the book


<a name="@Parameters_11"></a>

### Parameters

* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>target_id</code>: The target <code><a href="Book.md#0xc0deb00c_Book_P">P</a></code>
* <code>size_left</code>: Total base coin parcels left to be filled on
incoming order
* <code>quote_available</code>: The number of quote coin subunits that the
user with the incoming order has available for the trade


<a name="@Returns_12"></a>

### Returns

* <code>bool</code>: <code><b>true</b></code> if incoming user has insufficient quote coins
in the case of a filling against an ask, otherwise <code><b>false</b></code>
* <code>u64</code>: <code>size_left</code> if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code> or if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>
and user has enough quote coins available to match against a
target ask, otherwise the max number of base coin parcels that
can be filled against the target ask


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_check_size">check_size</a>(side: bool, target_id: u128, target_size: u64, size_left: u64, quote_available: u64): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_check_size">check_size</a>(
    side: bool,
    target_id: u128,
    target_size: u64,
    size_left: u64,
    quote_available: u64,
): (
    bool,
    u64
) {
    // Do not flag insufficient quote coins, and confirm filling
    // size left
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_BID">BID</a>) <b>return</b> (<b>false</b>, size_left);
    // Otherwise incoming order fills against a target ask, so
    // calculate number of quote coins required for a complete fill
    <b>let</b> target_price = id_price(target_id); // Get target price
    // Get quote coins required <b>to</b> fill against target ask
    <b>let</b> quote_to_fill =
        // If size left on incoming order greater than or equal <b>to</b>
        // target size, then quote coins needed are for a complete
        // target fill
        <b>if</b> (size_left &gt;= target_size) target_price * target_size <b>else</b>
        // Otherwise quote coins needed for partial target fill
        target_price * size_left;
    // If quote coins needed for fill exceed available quote coins
    <b>if</b> (quote_to_fill &gt; quote_available) <b>return</b>
        // Flag insufficient quote coins, and <b>return</b> max fill size
        // possible
        (<b>true</b>, quote_available / target_price) <b>else</b>
        // Otherwise do not flag insufficient quote coins, and
        // confirm filling size left
        <b>return</b> (<b>false</b>, size_left)
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_get_orders"></a>

## Function `get_orders`

Private indexing function for SDK generation: Return a vector
of <code><a href="Book.md#0xc0deb00c_Book_Order">Order</a></code> sorted by price-time priority: if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>,
first element in vector is the oldest ask at the minimum price,
and if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, first element in vector is the oldest
ask at the maximum price


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_orders">get_orders</a>&lt;B, Q, E&gt;(host_address: <b>address</b>, side: bool): <a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_Order">Book::Order</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_orders">get_orders</a>&lt;B, Q, E&gt;(
    host_address: <b>address</b>,
    side: bool
): <a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Assert an order book <b>exists</b> at the given <b>address</b>
    <b>assert</b>!(<b>exists</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host_address), <a href="Book.md#0xc0deb00c_Book_E_NO_BOOK">E_NO_BOOK</a>);
    // Initialize empty <a href="">vector</a> of orders
    <b>let</b> orders = empty_vector&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;();
    <b>let</b> (tree, traversal_dir) = <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) // If an ask
        // Define traversal tree <b>as</b> asks tree, successor iteration
        (&<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host_address).a, <a href="Book.md#0xc0deb00c_Book_R">R</a>) <b>else</b>
        // Otherwise define tree <b>as</b> bids tree, predecessor iteration
        (&<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host_address).b, <a href="Book.md#0xc0deb00c_Book_L">L</a>);
    // Get number of positions in tree
    <b>let</b> n_positions = length(tree);
    // If no positions in tree, <b>return</b> empty <a href="">vector</a> of orders
    <b>if</b> (n_positions == 0) <b>return</b> orders;
    // Calculate number of traversals still remaining
    <b>let</b> remaining_traversals = n_positions - 1;
    // Declare target position order <a href="ID.md#0xc0deb00c_ID">ID</a>, mutable reference <b>to</b>
    // target position, target position tree node parent field,
    // target position tree node child field index
    <b>let</b> (target_id, target_position_ref_mut, target_parent_field, _) =
        traverse_init_mut&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(tree, traversal_dir);
    <b>loop</b> { // Loop over all positions in tree
        <b>let</b> price = id_price(target_id); // Get position price
        <b>let</b> size = target_position_ref_mut.s; // Get position size
        // Push corresponding order onto back of orders <a href="">vector</a>
        vector_push_back&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;(&<b>mut</b> orders, <a href="Book.md#0xc0deb00c_Book_Order">Order</a>{price, size});
        // Return orders <a href="">vector</a> <b>if</b> unable <b>to</b> traverse further
        <b>if</b> (remaining_traversals == 0) <b>return</b> orders;
        // Otherwise traverse <b>to</b> the next position in the tree
        (target_id, target_position_ref_mut, target_parent_field, _) =
            traverse_mut&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(tree, target_id, target_parent_field,
                traversal_dir);
        // Decrement number of remaining traversals
        remaining_traversals = remaining_traversals - 1;
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_get_price_levels"></a>

## Function `get_price_levels`

Private indexing function for SDK generation: aggregates result
of <code><a href="Book.md#0xc0deb00c_Book_get_orders">get_orders</a>()</code> into a vector of <code><a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a></code>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_price_levels">get_price_levels</a>(orders: &<a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_Order">Book::Order</a>&gt;): <a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_PriceLevel">Book::PriceLevel</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_price_levels">get_price_levels</a>(
    orders: &<a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;
): <a href="">vector</a>&lt;<a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>&gt; {
    // Initialize empty <a href="">vector</a> of price levels
    <b>let</b> price_levels = empty_vector&lt;<a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>&gt;();
    // Get number of orders <b>to</b> process
    <b>let</b> n_orders = vector_length&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;(orders);
    // If no orders, <b>return</b> empty <a href="">vector</a> of price levels
    <b>if</b> (n_orders == 0) <b>return</b> price_levels;
    // Initialize <b>loop</b> counter, price level price and size
    <b>let</b> (order_index, level_price, level_size) = (0, 0, 0);
    <b>loop</b> { // Loop over all orders
        // Borrow immutable reference <b>to</b> order for current iteration
        <b>let</b> order = vector_borrow&lt;<a href="Book.md#0xc0deb00c_Book_Order">Order</a>&gt;(orders, order_index);
        <b>if</b> (order.price != level_price) { // If on new price level
            <b>if</b> (order_index &gt; 0) { // If not on first order
                // Store the last price level in <a href="">vector</a>
                vector_push_back&lt;<a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>&gt;(&<b>mut</b> price_levels,
                    <a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>{price: level_price, size: level_size});
            };
            // Start tracking a new price level at given order
            (level_price, level_size) = (order.price, order.size)
        } <b>else</b> { // If order <b>has</b> same price level <b>as</b> last checked
            // Increment size of price level by order size
            level_size = level_size + order.size;
        };
        order_index = order_index + 1; // Increment order index
        // If have looped over all in  0-indexed <a href="">vector</a>
        <b>if</b> (order_index == n_orders) { // If no more iterations left
            // Store final price level in <a href="">vector</a>
            vector_push_back&lt;<a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>&gt;(&<b>mut</b> price_levels,
                <a href="Book.md#0xc0deb00c_Book_PriceLevel">PriceLevel</a>{price: level_price, size: level_size});
            <b>break</b> // Break out of <b>loop</b>
        };
    }; // Now done looping over orders
    price_levels // Return sorted <a href="">vector</a> of price levels
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_process_fill_scenarios"></a>

## Function `process_fill_scenarios`

Compare incoming order <code>size</code> and address <code>i_addr</code> against
fields in target position <code>t_p_r</code>, returning fill amount and if
incoming size is equal to target size. Abort if both have same
address, and decrement target position size (<code><a href="Book.md#0xc0deb00c_Book_P">P</a>.s</code>) by <code>size</code> if
target position only gets partially filled.


<a name="@Abort_conditions_13"></a>

### Abort conditions

* If <code>i_addr</code> (incoming address) is same as target address


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_process_fill_scenarios">process_fill_scenarios</a>(i_addr: <b>address</b>, t_p_r: &<b>mut</b> <a href="Book.md#0xc0deb00c_Book_P">Book::P</a>, size: u64): (u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_process_fill_scenarios">process_fill_scenarios</a>(
    i_addr: <b>address</b>,
    t_p_r: &<b>mut</b> <a href="Book.md#0xc0deb00c_Book_P">P</a>,
    size: u64
): (
    u64,
    bool
) {
    // Assume not a perfect match between incoming/target size
    <b>let</b> perfect_match = <b>false</b>;
    // Assert incoming <b>address</b> is not same <b>as</b> target <b>address</b>
    <b>assert</b>!(i_addr != t_p_r.a, <a href="Book.md#0xc0deb00c_Book_E_SELF_MATCH">E_SELF_MATCH</a>);
    <b>let</b> filled: u64; // Declare fill amount
    // If incoming order size is less than target position size
    <b>if</b> (size &lt; t_p_r.s) { // If partial target fill
        filled = size; // Flag complete fill on incoming order
        // Decrement target position size by incoming order size
        t_p_r.s = t_p_r.s - size;
    } <b>else</b> <b>if</b> (size &gt; t_p_r.s) { // If partial incoming fill
        // Flag incoming order filled by amount in target position
        filled = t_p_r.s;
    } <b>else</b> { // If incoming order and target position have same size
        filled = size; // Flag complete fill on incoming order
        perfect_match = <b>true</b>; // Flag equal size for both sides
    };
    (filled, perfect_match) // Return fill amount & <b>if</b> perfect match
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_traverse_fill"></a>

## Function `traverse_fill`

Either initialize traversal and fill against order book at
<code>host</code> if <code>init</code> is <code><b>true</b></code>, or execute a traversal pop and then
fill if <code>init</code> is <code><b>false</b></code>. If <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>, perform successor
traversal starting at the ask with the minimum order ID, and if
<code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, perform predecessor traversal starting at the
bid with the maximum order ID. Decrement target position by
<code>size</code> if matching results in a partial fill against it, leave
it unmodified if matching results in an exact fill on both sides
of the trade, and leave it unmodified if matching only results
in a partial fill against the incoming order (in both of the
latter cases so that the target position may be popped later).
If <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>, check the fill size per <code><a href="Book.md#0xc0deb00c_Book_check_size">check_size</a>()</code>,
reducing it as needed based on available incoming quote coins.


<a name="@Terminology_14"></a>

### Terminology

* "Incoming order" has <code>size_left</code> base coin parcels to be
filled
* "Target position" is the first <code><a href="Book.md#0xc0deb00c_Book_P">P</a></code> on the book to fill against
if <code>init</code> is <code><b>true</b></code>, and next position on the book to fill
against if <code>init</code> is <code><b>false</b></code>
against
* "Start position" is the position to traverse from if <code>init</code>
is <code><b>false</b></code>


<a name="@Parameters_15"></a>

### Parameters

* <code>host</code>: Host of <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code>
* <code>incoming_address</code>: Address of incoming order to match against
* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>size_left</code>: Total base coin parcels left to be filled on
incoming order
* <code>quote_available</code>: Quote coin parcels available for filling if
filling against asks
* <code>init</code>: If <code><b>true</b></code>, ignore remaining parameters and initialize
traversal before filling. If <code><b>false</b></code>, use remaining parameters
to traverse from start node to target node then pop start node
before filling
* <code>n_position</code>: Number of positions in <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> for corresponding
<code>side</code>
* <code>start_id</code>: Order ID of start position. If <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>,
cannot be maximum ask in order book, and if <code>side</code> is <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>,
cannot be minimum bid in order book (since no traversal is
possible for these cases).
* <code>start_parent_field</code>: Start position tree node parent field
* <code>start_child_index</code>: Child field index of start position tree
node


<a name="@Returns_16"></a>

### Returns

* <code>u128</code>: Target position order ID
* <code><b>address</b></code>: User address holding target position (<code><a href="Book.md#0xc0deb00c_Book_P">P</a>.a</code>)
* <code>u64</code>: Parent field of node corresponding to target position
* <code>u64</code>: Child field index of node corresponding to target
position
* <code>u64</code>: Amount filled, in base coin parcels
* <code>bool</code>: <code><b>true</b></code> if an exact match between incoming order and
target position size
* <code>bool</code>: <code><b>true</b></code> if <code>quote_available</code> was insufficient for
completely filling the target position in the case of an ask


<a name="@Considerations_17"></a>

### Considerations

* Publicly exposes internal tree node indices per canonical
traversal paradigm described at <code>Econia::CritBit</code>


<a name="@Assumes_18"></a>

### Assumes

* Order book has been properly initialized at host address and
has at least one position in corresponding tree in case of
<code>init</code> true
* Caller has tracked <code>n_positions</code> correctly if <code>init</code> is
<code><b>false</b></code>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>&lt;B, Q, E&gt;(host: <b>address</b>, incoming_address: <b>address</b>, side: bool, size_left: u64, quote_available: u64, init: bool, n_positions: u64, start_id: u128, start_parent_field: u64, start_child_index: u64): (u128, <b>address</b>, u64, u64, u64, bool, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_traverse_fill">traverse_fill</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    incoming_address: <b>address</b>,
    side: bool,
    size_left: u64,
    quote_available: u64,
    init: bool,
    n_positions: u64,
    start_id: u128,
    start_parent_field: u64,
    start_child_index: u64,
): (
    u128,
    <b>address</b>,
    u64,
    u64,
    u64,
    bool,
    bool
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <b>let</b> (tree, traversal_dir) = <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) // If an ask
        // Define traversal tree <b>as</b> asks tree, successor iteration
        (&<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host).a, <a href="Book.md#0xc0deb00c_Book_R">R</a>) <b>else</b>
        // Otherwise define tree <b>as</b> bids tree, predecessor iteration
        (&<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host).b, <a href="Book.md#0xc0deb00c_Book_L">L</a>);
    // Declare target position order <a href="ID.md#0xc0deb00c_ID">ID</a>, mutable reference <b>to</b>
    // target position, target position tree node parent field,
    // target position tree node child field index
    <b>let</b> (target_id, target_position_ref_mut, target_parent_field,
         target_child_index): (u128, &<b>mut</b> <a href="Book.md#0xc0deb00c_Book_P">P</a>, u64, u64);
    <b>if</b> (init) { // If initializing traversal
        // Store relevant values from tree traversal initialization
        (target_id, target_position_ref_mut, target_parent_field,
            target_child_index) = traverse_init_mut(tree, traversal_dir);
    } <b>else</b> { // If continuing traversal
        // Store from iterated tree traversal popping, unpacking
        // start position <b>struct</b>
        (target_id, target_position_ref_mut, target_parent_field,
            target_child_index, <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: _, a: _}) = traverse_pop_mut(
                tree, start_id, start_parent_field, start_child_index,
                n_positions, traversal_dir);
    };
    // Store target position user <b>address</b>
    <b>let</b> target_address = target_position_ref_mut.a;
    // Flag <b>if</b> insufficient quote coins in case of ask, check size
    // left <b>to</b> be filled
    <b>let</b> (insufficient_quote, size) = <a href="Book.md#0xc0deb00c_Book_check_size">check_size</a>(side, target_id,
        target_position_ref_mut.s, size_left, quote_available);
    // Process fill scenarios, storing amount filled and <b>if</b> perfect
    // match between incoming and target order
    <b>let</b> (filled, perfect) = <a href="Book.md#0xc0deb00c_Book_process_fill_scenarios">process_fill_scenarios</a>(
        incoming_address, target_position_ref_mut, size);
    // Return target position <a href="ID.md#0xc0deb00c_ID">ID</a>, target position user <b>address</b>,
    // corresponding node's parent field, corresponding node's child
    // field index, the number of base <a href="">coin</a> parcels filled, and <b>if</b>
    // insufficient quote coins in the case of target ask position
    (target_id, target_address, target_parent_field, target_child_index,
     filled, perfect, insufficient_quote)
}
</code></pre>



</details>
