
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
-  [Constants](#@Constants_3)
-  [Function `add_ask`](#0xc0deb00c_Book_add_ask)
-  [Function `add_bid`](#0xc0deb00c_Book_add_bid)
-  [Function `cancel_ask`](#0xc0deb00c_Book_cancel_ask)
-  [Function `cancel_bid`](#0xc0deb00c_Book_cancel_bid)
-  [Function `exists_book`](#0xc0deb00c_Book_exists_book)
-  [Function `get_friend_cap`](#0xc0deb00c_Book_get_friend_cap)
-  [Function `init_book`](#0xc0deb00c_Book_init_book)
-  [Function `scale_factor`](#0xc0deb00c_Book_scale_factor)
-  [Function `add_position`](#0xc0deb00c_Book_add_position)
    -  [Parameters](#@Parameters_4)
    -  [Returns](#@Returns_5)
    -  [Assumes](#@Assumes_6)
    -  [Spread terminology](#@Spread_terminology_7)
-  [Function `cancel_position`](#0xc0deb00c_Book_cancel_position)
    -  [Parameters](#@Parameters_8)
    -  [Assumes](#@Assumes_9)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
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
 Scaled size (see <code>Econia::Orders</code>) of position to be filled
</dd>
<dt>
<code>a: <b>address</b></code>
</dt>
<dd>
 Address holding position
</dd>
</dl>


</details>

<a name="@Constants_3"></a>

## Constants


<a name="0xc0deb00c_Book_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
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


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Book_E_NO_BOOK"></a>

When order book does not exist at given address


<pre><code><b>const</b> <a href="Book.md#0xc0deb00c_Book_E_NO_BOOK">E_NO_BOOK</a>: u64 = 1;
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

Wrapped <code><a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code>, requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(host: <b>address</b>, id: u128, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    id: u128,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host, <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>, id);
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_cancel_bid"></a>

## Function `cancel_bid`

Wrapped <code><a href="Book.md#0xc0deb00c_Book_add_position">add_position</a>()</code> call for <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>, requiring <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(host: <b>address</b>, id: u128, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    id: u128,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host, <a href="Book.md#0xc0deb00c_Book_BID">BID</a>, id);
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_exists_book"></a>

## Function `exists_book`

Return <code><b>true</b></code> if specified order book type exists at address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool {<b>exists</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(a)}
</code></pre>



</details>

<a name="0xc0deb00c_Book_get_friend_cap"></a>

## Function `get_friend_cap`

Return a <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>, aborting if not called by Econia account


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_friend_cap">get_friend_cap</a>(account: &signer): <a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_friend_cap">get_friend_cap</a>(
    account: &signer
): <a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a> {
    // Assert called by Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Book.md#0xc0deb00c_Book_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>{} // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_init_book"></a>

## Function `init_book`

Initialize order book under host account, provided <code><a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a></code>,
with market types <code>B</code>, <code>Q</code>, <code>E</code>, and scale factor <code>f</code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(host: &signer, f: u64, _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(
    host: &signer,
    f: u64,
    _c: &<a href="Book.md#0xc0deb00c_Book_FriendCap">FriendCap</a>
) {
    // Assert book does not already exist under host account
    <b>assert</b>!(!<a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(s_a_o(host)), <a href="Book.md#0xc0deb00c_Book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>);
    <b>let</b> m_a = <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>; // Declare <b>min</b> ask default order <a href="ID.md#0xc0deb00c_ID">ID</a>
    <b>let</b> m_b = <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>; // Declare max bid default order <a href="ID.md#0xc0deb00c_ID">ID</a>
    <b>let</b> o_b = // Pack empty order book
        <a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;{f, a: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), b: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), m_a, m_b};
    <b>move_to</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host, o_b); // Move <b>to</b> host
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_scale_factor"></a>

## Function `scale_factor`

Return scale factor of specified order book at given address


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Assert book <b>exists</b> at given <b>address</b>
    <b>assert</b>!(<a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(addr), <a href="Book.md#0xc0deb00c_Book_E_NO_BOOK">E_NO_BOOK</a>);
    <b>borrow_global</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(addr).f // Return book's scale factor
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_add_position"></a>

## Function `add_position`

Add new position to book for market <code>&lt;B, Q, E&gt;</code>, as long as
order does not cross the spread, skipping redundant error checks
already covered by calling functions


<a name="@Parameters_4"></a>

### Parameters

* <code>host</code>: Address of market host
* <code>user</code>: Address of user submitting position
* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>id</code>: Order ID (see <code>Econia::ID</code>)
* <code>price</code>: Scaled integer price (see <code>Econia::ID</code>)
* <code>size</code>: Scaled order size (see <code>Econia::Orders</code>)


<a name="@Returns_5"></a>

### Returns

* <code><b>true</b></code> if the new position crosses the spread, <code><b>false</b></code>
otherwise


<a name="@Assumes_6"></a>

### Assumes

* Correspondent order has already passed validation checks per
<code>Econia::Orders::add_order()</code>
* <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> for given market exists at host address


<a name="@Spread_terminology_7"></a>

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
    <b>let</b> (m_a_p, m_b_p) = (id_p(o_b.m_a), id_p(o_b.m_b));
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) { // If order is an ask
        <b>if</b> (price &gt; m_b_p) { // If order does not cross spread
            // Add corresponding position <b>to</b> ask tree
            cb_i(&<b>mut</b> o_b.a, id, <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: size, a: user});
            // If order is within spread, <b>update</b> <b>min</b> ask id
            <b>if</b> (price &lt; m_a_p) o_b.m_a = id;
        } <b>else</b> <b>return</b> <b>true</b>; // Otherwise indicate crossed spread
    } <b>else</b> { // If order is a bid
        <b>if</b> (price &lt; m_a_p) { // If order does not cross spread
            // Add corresponding position <b>to</b> bid tree
            cb_i(&<b>mut</b> o_b.b, id, <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: size, a: user});
            // If order is within spread, <b>update</b> max bid id
            <b>if</b> (price &gt; m_b_p) o_b.m_b = id;
        // Otherwise manage order that crosses spread
        } <b>else</b> <b>return</b> <b>true</b>; // Otherwise indicate crossed spread
    }; // Order is on now on book, and did not cross spread
    <b>false</b> // Indicate spread not crossed
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_cancel_position"></a>

## Function `cancel_position`

Cancel position on book for market <code>&lt;B, Q, E&gt;</code>, skipping
redundant error checks already covered by calling functions


<a name="@Parameters_8"></a>

### Parameters

* <code>host</code>: Address of market host
* <code>side</code>: <code><a href="Book.md#0xc0deb00c_Book_ASK">ASK</a></code> or <code><a href="Book.md#0xc0deb00c_Book_BID">BID</a></code>
* <code>id</code>: Order ID (see <code>Econia::ID</code>)


<a name="@Assumes_9"></a>

### Assumes

* <code><a href="Book.md#0xc0deb00c_Book_OB">OB</a></code> for given market exists at host address
* Position has already been placed on book properly, by
preceding functions that perform their own error-checking


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(host: <b>address</b>, side: bool, id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Book.md#0xc0deb00c_Book_cancel_position">cancel_position</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    side: bool,
    id: u128
) <b>acquires</b> <a href="Book.md#0xc0deb00c_Book_OB">OB</a> {
    // Borrow mutable reference <b>to</b> order book at host <b>address</b>
    <b>let</b> o_b = <b>borrow_global_mut</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host);
    <b>if</b> (side == <a href="Book.md#0xc0deb00c_Book_ASK">ASK</a>) { // If order is an ask
        <b>let</b> asks = &<b>mut</b> o_b.a; // Get mutable reference <b>to</b> asks tree
        <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: _, a: _} = cb_p&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks, id); // Pop/unpack position
        <b>if</b> (o_b.m_a == id) { // If cancelled order was the <b>min</b> ask
            // If asks tree now empty, set <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default
            o_b.m_a = <b>if</b> (cb_i_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks)) <a href="Book.md#0xc0deb00c_Book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b>
                cb_mi_k&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(asks); // Otherwise set <b>to</b> new <b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a>
        };
    } <b>else</b> { // If order is a bid
        <b>let</b> bids = &<b>mut</b> o_b.b; // Get mutable reference <b>to</b> bids tree
        <a href="Book.md#0xc0deb00c_Book_P">P</a>{s: _, a: _} = cb_p&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids, id); // Pop/unpack position
        <b>if</b> (o_b.m_b == id) { // If cancelled order was the max bid
            // If bid tree now empty, set max bid <a href="ID.md#0xc0deb00c_ID">ID</a> <b>to</b> default
            o_b.m_b = <b>if</b> (cb_i_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids)) <a href="Book.md#0xc0deb00c_Book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a> <b>else</b>
                cb_ma_k&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(bids); // Otherwise set <b>to</b> new max bid <a href="ID.md#0xc0deb00c_ID">ID</a>
        };
    }
}
</code></pre>



</details>
