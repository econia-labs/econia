
<a name="0xc0deb00c_Caps"></a>

# Module `0xc0deb00c::Caps`


<a name="@Test-oriented_architecture_0"></a>

## Test-oriented architecture


Some modules, like <code>Econia::Registry</code> rely heavily on Move native
functions defined in the <code>AptosFramework</code>, for which the <code><b>move</b></code>
CLI's coverage testing tool does not offer general support. Thus,
since the <code>aptos</code> CLI does not offer any coverage testing support
whatsoever, at least as of the time of this writing, such modules
cannot be coverage tested per straightforward methods. Other
modules, however, do not depend as strongly on <code>AptosFramework</code>
functions, and as such, whenever possible, they are implemented
purely in Move to enable coverage testing, for example, like
<code>Econia::CritBit</code>.

The pairing of pure-Move and non-pure-Move modules occasionally
requires workarounds, for instance, like the capability <code>BFC</code>, a
cumbersome alternative to the use of a <code><b>public</b>(<b>friend</b>)</code> function: a
more straightforward approach would involve only exposing
<code>Econia::Book::init_book</code>, to friend modules, for example, but this
would involve the declaration of <code>Econia::Registry</code> module as a
friend, and since <code>Econia::Registry</code> relies on <code>AptosFramework</code>
native functions, the <code><b>move</b></code> CLI test compiler would thus break when
attempting to link the corresponding files, even when only
attempting to run coverage tests on <code>Econia::Book</code>. Hence, the use
of <code>BFC</code>, a friend-like capability, which allows <code>Econia::Book</code> to
be implemented purely in Move and to be coverage tested using the
<code><b>move</b></code> CLI, while also restricting access to friend-like modules.

---


-  [Test-oriented architecture](#@Test-oriented_architecture_0)
-  [Resource `FC`](#0xc0deb00c_Caps_FC)
-  [Constants](#@Constants_1)
-  [Function `init_caps`](#0xc0deb00c_Caps_init_caps)
-  [Function `book_f_c`](#0xc0deb00c_Caps_book_f_c)
-  [Function `has_f_c`](#0xc0deb00c_Caps_has_f_c)
-  [Function `orders_f_c`](#0xc0deb00c_Caps_orders_f_c)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Book.md#0xc0deb00c_Book">0xc0deb00c::Book</a>;
<b>use</b> <a href="Orders.md#0xc0deb00c_Orders">0xc0deb00c::Orders</a>;
</code></pre>



<a name="0xc0deb00c_Caps_FC"></a>

## Resource `FC`

Container for friend-like capabilities


<pre><code><b>struct</b> <a href="Caps.md#0xc0deb00c_Caps_FC">FC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>b: <a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a></code>
</dt>
<dd>
 <code>Econia::Book</code> capability
</dd>
<dt>
<code>o: <a href="Orders.md#0xc0deb00c_Orders_FriendCap">Orders::FriendCap</a></code>
</dt>
<dd>
 <code>Econia::Orders</code> capability
</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="0xc0deb00c_Caps_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Caps.md#0xc0deb00c_Caps_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Caps_E_FC_EXISTS"></a>

When friend-like capabilities container already exists


<pre><code><b>const</b> <a href="Caps.md#0xc0deb00c_Caps_E_FC_EXISTS">E_FC_EXISTS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Caps_E_NO_FC"></a>

When no friend-like capabilities container


<pre><code><b>const</b> <a href="Caps.md#0xc0deb00c_Caps_E_NO_FC">E_NO_FC</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Caps_init_caps"></a>

## Function `init_caps`

Initialize friend-like capabilities, storing under Econia
account, aborting if called by another account or if capability
container already exists


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_init_caps">init_caps</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_init_caps">init_caps</a>(
    account: &signer
) {
    <b>let</b> addr = s_a_o(account); // Get signer <b>address</b>
    <b>assert</b>!(addr == @Econia, <a href="Caps.md#0xc0deb00c_Caps_E_NOT_ECONIA">E_NOT_ECONIA</a>); // Assert Econia signer
    // Assert <b>friend</b>-like capabilities container does not yet exist
    <b>assert</b>!(!<b>exists</b>&lt;<a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>&gt;(addr), <a href="Caps.md#0xc0deb00c_Caps_E_FC_EXISTS">E_FC_EXISTS</a>);
    // Move <b>friend</b>-like capabilities container <b>to</b> Econia account
    <b>move_to</b>&lt;<a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>&gt;(account, <a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>{b: b_g_f_c(account), o: o_g_f_c(account)});
}
</code></pre>



</details>

<a name="0xc0deb00c_Caps_book_f_c"></a>

## Function `book_f_c`

Return <code>Econia::Book</code> friend-like capability


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_book_f_c">book_f_c</a>(): <a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_book_f_c">book_f_c</a>():
BFC
<b>acquires</b> <a href="Caps.md#0xc0deb00c_Caps_FC">FC</a> {
    <b>assert</b>!(<a href="Caps.md#0xc0deb00c_Caps_has_f_c">has_f_c</a>(), <a href="Caps.md#0xc0deb00c_Caps_E_NO_FC">E_NO_FC</a>); // Assert capabilities initialized
    <b>borrow_global</b>&lt;<a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>&gt;(@Econia).b // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Caps_has_f_c"></a>

## Function `has_f_c`

Return true if friend capability container initialized


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_has_f_c">has_f_c</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_has_f_c">has_f_c</a>(): bool {<b>exists</b>&lt;<a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>&gt;(@Econia)}
</code></pre>



</details>

<a name="0xc0deb00c_Caps_orders_f_c"></a>

## Function `orders_f_c`

Return <code>Econia::Orders</code> friend-like capability


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_orders_f_c">orders_f_c</a>(): <a href="Orders.md#0xc0deb00c_Orders_FriendCap">Orders::FriendCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Caps.md#0xc0deb00c_Caps_orders_f_c">orders_f_c</a>():
OFC
<b>acquires</b> <a href="Caps.md#0xc0deb00c_Caps_FC">FC</a> {
    <b>assert</b>!(<a href="Caps.md#0xc0deb00c_Caps_has_f_c">has_f_c</a>(), <a href="Caps.md#0xc0deb00c_Caps_E_NO_FC">E_NO_FC</a>); // Assert capabilities initialized
    <b>borrow_global</b>&lt;<a href="Caps.md#0xc0deb00c_Caps_FC">FC</a>&gt;(@Econia).o // Return requested capability
}
</code></pre>



</details>
