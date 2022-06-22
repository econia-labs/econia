
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
-  [Function `exists_book`](#0xc0deb00c_Book_exists_book)
-  [Function `get_friend_cap`](#0xc0deb00c_Book_get_friend_cap)
-  [Function `init_book`](#0xc0deb00c_Book_init_book)
-  [Function `scale_factor`](#0xc0deb00c_Book_scale_factor)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
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
    // Pack empty order book
    <b>let</b> o_b = <a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;{f, a: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), b: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), m_a: 0, m_b: 0};
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
