
<a name="0xc0deb00c_Book"></a>

# Module `0xc0deb00c::Book`

Pure-move implementation of order book functionality


-  [Struct `BookInitCap`](#0xc0deb00c_Book_BookInitCap)
-  [Resource `OB`](#0xc0deb00c_Book_OB)
-  [Struct `P`](#0xc0deb00c_Book_P)
-  [Constants](#@Constants_0)
-  [Function `exists_book`](#0xc0deb00c_Book_exists_book)
-  [Function `scale_factor`](#0xc0deb00c_Book_scale_factor)
-  [Function `get_book_init_cap`](#0xc0deb00c_Book_get_book_init_cap)
-  [Function `init_book`](#0xc0deb00c_Book_init_book)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
</code></pre>



<a name="0xc0deb00c_Book_BookInitCap"></a>

## Struct `BookInitCap`

Order book initialization capability


<pre><code><b>struct</b> <a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a> <b>has</b> store
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
 Order id of minimum ask
</dd>
<dt>
<code>m_b: u128</code>
</dt>
<dd>
 Order id of maximum bid
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
 Size of position, in base coin subunits. Corresponds to
 <code>AptosFramework::Coin::Coin.value</code>
</dd>
<dt>
<code>a: <b>address</b></code>
</dt>
<dd>
 Address
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

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

<a name="0xc0deb00c_Book_get_book_init_cap"></a>

## Function `get_book_init_cap`

Return a <code><a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a></code>, aborting if not called by Econia account


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_book_init_cap">get_book_init_cap</a>(account: &signer): <a href="Book.md#0xc0deb00c_Book_BookInitCap">Book::BookInitCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_get_book_init_cap">get_book_init_cap</a>(
    account: &signer
): <a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a> {
    // Assert called by Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Book.md#0xc0deb00c_Book_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a>{} // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Book_init_book"></a>

## Function `init_book`

Initialize order book under host account, provided <code><a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(host: &signer, f: u64, _cap: &<a href="Book.md#0xc0deb00c_Book_BookInitCap">Book::BookInitCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Book.md#0xc0deb00c_Book_init_book">init_book</a>&lt;B, Q, E&gt;(
    host: &signer,
    f: u64,
    _cap: &<a href="Book.md#0xc0deb00c_Book_BookInitCap">BookInitCap</a>
) {
    // Assert book does not already exist under host account
    <b>assert</b>!(!<a href="Book.md#0xc0deb00c_Book_exists_book">exists_book</a>&lt;B, Q, E&gt;(s_a_o(host)), <a href="Book.md#0xc0deb00c_Book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>);
    // Pack empty order book
    <b>let</b> o_b = <a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;{f, a: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), b: cb_e&lt;<a href="Book.md#0xc0deb00c_Book_P">P</a>&gt;(), m_a: 0, m_b: 0};
    <b>move_to</b>&lt;<a href="Book.md#0xc0deb00c_Book_OB">OB</a>&lt;B, Q, E&gt;&gt;(host, o_b); // Move <b>to</b> host
}
</code></pre>



</details>
