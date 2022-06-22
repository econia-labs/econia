
<a name="0xc0deb00c_Orders"></a>

# Module `0xc0deb00c::Orders`

Pure-Move implementation of user-side open orders functionality


-  [Struct `FriendCap`](#0xc0deb00c_Orders_FriendCap)
-  [Resource `OO`](#0xc0deb00c_Orders_OO)
-  [Constants](#@Constants_0)
-  [Function `exists_orders`](#0xc0deb00c_Orders_exists_orders)
-  [Function `get_friend_cap`](#0xc0deb00c_Orders_get_friend_cap)
-  [Function `init_orders`](#0xc0deb00c_Orders_init_orders)
-  [Function `scale_factor`](#0xc0deb00c_Orders_scale_factor)
-  [Function `add_order`](#0xc0deb00c_Orders_add_order)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
</code></pre>



<a name="0xc0deb00c_Orders_FriendCap"></a>

## Struct `FriendCap`

Friend-like capability, administered instead of declaring as a
friend a module containing Aptos native functions, which would
inhibit coverage testing via the Move CLI. See <code>Econia::Caps</code>


<pre><code><b>struct</b> <a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0xc0deb00c_Orders_OO"></a>

## Resource `OO`

Open orders, for the given market, on a user's account


<pre><code><b>struct</b> <a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt; <b>has</b> key
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
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Orders_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_Orders_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Orders_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Orders_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Orders_E_AMOUNT_NOT_MULTIPLE"></a>

When amount is not an integer multiple of scale factor


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_AMOUNT_NOT_MULTIPLE">E_AMOUNT_NOT_MULTIPLE</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Orders_E_FILL_OVERFLOW"></a>

When amount of quote coins to fill order overflows u64


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_FILL_OVERFLOW">E_FILL_OVERFLOW</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_Orders_E_NO_ORDERS"></a>

When order book does not exist at given address


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_NO_ORDERS">E_NO_ORDERS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Orders_E_ORDERS_EXISTS"></a>

When open orders already exists at given address


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_ORDERS_EXISTS">E_ORDERS_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Orders_E_PRICE_0"></a>

When indicated price indicated 0


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_PRICE_0">E_PRICE_0</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_Orders_exists_orders"></a>

## Function `exists_orders`

Return <code><b>true</b></code> if specified open orders type exists at address


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_exists_orders">exists_orders</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_exists_orders">exists_orders</a>&lt;B, Q, E&gt;(
    a: <b>address</b>
): bool {
    <b>exists</b>&lt;<a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt;&gt;(a)
}
</code></pre>



</details>

<a name="0xc0deb00c_Orders_get_friend_cap"></a>

## Function `get_friend_cap`

Return a <code><a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a></code>, aborting if not called by Econia


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_get_friend_cap">get_friend_cap</a>(account: &signer): <a href="Orders.md#0xc0deb00c_Orders_FriendCap">Orders::FriendCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_get_friend_cap">get_friend_cap</a>(
    account: &signer
): <a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a> {
    // Assert called by Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Orders.md#0xc0deb00c_Orders_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a>{} // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Orders_init_orders"></a>

## Function `init_orders`

Initialize open orders under host account, provided <code><a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a></code>,
with market types <code>B</code>, <code>Q</code>, <code>E</code>, and scale factor <code>f</code>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_init_orders">init_orders</a>&lt;B, Q, E&gt;(user: &signer, f: u64, _c: <a href="Orders.md#0xc0deb00c_Orders_FriendCap">Orders::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_init_orders">init_orders</a>&lt;B, Q, E&gt;(
    user: &signer,
    f: u64,
    _c: <a href="Orders.md#0xc0deb00c_Orders_FriendCap">FriendCap</a>
) {
    // Assert open orders does not already exist under user account
    <b>assert</b>!(!<a href="Orders.md#0xc0deb00c_Orders_exists_orders">exists_orders</a>&lt;B, Q, E&gt;(s_a_o(user)), <a href="Orders.md#0xc0deb00c_Orders_E_ORDERS_EXISTS">E_ORDERS_EXISTS</a>);
    // Pack empty open orders container
    <b>let</b> o_o = <a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt;{f, a: cb_e&lt;u64&gt;(), b: cb_e&lt;u64&gt;()};
    <b>move_to</b>&lt;<a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt;&gt;(user, o_o); // Move <b>to</b> user
}
</code></pre>



</details>

<a name="0xc0deb00c_Orders_scale_factor"></a>

## Function `scale_factor`

Return scale factor of specified open orders at given address


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Orders.md#0xc0deb00c_Orders_OO">OO</a> {
    // Assert open orders container <b>exists</b> at given <b>address</b>
    <b>assert</b>!(<a href="Orders.md#0xc0deb00c_Orders_exists_orders">exists_orders</a>&lt;B, Q, E&gt;(addr), <a href="Orders.md#0xc0deb00c_Orders_E_NO_ORDERS">E_NO_ORDERS</a>);
    // Return open order container's scale factor
    <b>borrow_global</b>&lt;<a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt;&gt;(addr).f
}
</code></pre>



</details>

<a name="0xc0deb00c_Orders_add_order"></a>

## Function `add_order`

Add new order to <code><a href="Orders.md#0xc0deb00c_Orders_OO">OO</a></code> at <code>addr</code> for side <code>side</code>, order ID <code>id</code>,
scaled price <code>price</code>, and unscaled order size <code>size</code>, aborting
if <code>price</code> is 0, <code><a href="Orders.md#0xc0deb00c_Orders_OO">OO</a></code> not initialized at <code>addr</code>, unscaled order
size is not an integer multiple of price scale factor indicated
by <code><a href="Orders.md#0xc0deb00c_Orders_OO">OO</a></code>, or if the required amount of quote coins to fill the
order cannot fit in a <code>u64</code>


<pre><code><b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_add_order">add_order</a>&lt;B, Q, E&gt;(addr: <b>address</b>, side: bool, id: u128, price: u64, size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_add_order">add_order</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>,
    side: bool,
    id: u128,
    price: u64,
    size: u64,
) <b>acquires</b> <a href="Orders.md#0xc0deb00c_Orders_OO">OO</a> {
    <b>assert</b>!(price &gt; 0, <a href="Orders.md#0xc0deb00c_Orders_E_PRICE_0">E_PRICE_0</a>); // Assert order <b>has</b> actual price
    // Assert open orders container <b>exists</b> at given <b>address</b>
    <b>assert</b>!(<a href="Orders.md#0xc0deb00c_Orders_exists_orders">exists_orders</a>&lt;B, Q, E&gt;(addr), <a href="Orders.md#0xc0deb00c_Orders_E_NO_ORDERS">E_NO_ORDERS</a>);
    // Borrow mutable reference <b>to</b> open orders at given <b>address</b>
    <b>let</b> o_o = <b>borrow_global_mut</b>&lt;<a href="Orders.md#0xc0deb00c_Orders_OO">OO</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>let</b> s_f = o_o.f; // Get price scale factor
    // Assert order size is integer multiple of price scale factor
    <b>assert</b>!(size % s_f == 0, <a href="Orders.md#0xc0deb00c_Orders_E_AMOUNT_NOT_MULTIPLE">E_AMOUNT_NOT_MULTIPLE</a>);
    <b>let</b> scaled_size = size / s_f; // Get scaled order size
    // Determine amount of quote coins needed <b>to</b> fill order, <b>as</b> u128
    <b>let</b> fill_amount = (scaled_size <b>as</b> u128) * (price <b>as</b> u128);
    // Assert that fill amount can fit in a u64
    <b>assert</b>!(!(fill_amount &gt; (<a href="Orders.md#0xc0deb00c_Orders_HI_64">HI_64</a> <b>as</b> u128)), <a href="Orders.md#0xc0deb00c_Orders_E_FILL_OVERFLOW">E_FILL_OVERFLOW</a>);
    // Add order <b>to</b> corresponding tree
    <b>if</b> (side == <a href="Orders.md#0xc0deb00c_Orders_ASK">ASK</a>) cb_i&lt;u64&gt;(&<b>mut</b> o_o.a, id, scaled_size)
        <b>else</b> cb_i&lt;u64&gt;(&<b>mut</b> o_o.b, id, scaled_size);
}
</code></pre>



</details>
