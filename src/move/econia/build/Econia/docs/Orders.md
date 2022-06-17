
<a name="0xc0deb00c_Orders"></a>

# Module `0xc0deb00c::Orders`

Pure-Move implementation of user-side open orders functionality


-  [Struct `OrdersInitCap`](#0xc0deb00c_Orders_OrdersInitCap)
-  [Resource `OO`](#0xc0deb00c_Orders_OO)
-  [Constants](#@Constants_0)
-  [Function `exists_orders`](#0xc0deb00c_Orders_exists_orders)
-  [Function `get_orders_init_cap`](#0xc0deb00c_Orders_get_orders_init_cap)
-  [Function `init_orders`](#0xc0deb00c_Orders_init_orders)
-  [Function `scale_factor`](#0xc0deb00c_Orders_scale_factor)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
</code></pre>



<a name="0xc0deb00c_Orders_OrdersInitCap"></a>

## Struct `OrdersInitCap`

Open orders initialization capability


<pre><code><b>struct</b> <a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a> <b>has</b> store
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


<a name="0xc0deb00c_Orders_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Orders_E_NO_ORDERS"></a>

When order book does not exist at given address


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_NO_ORDERS">E_NO_ORDERS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Orders_E_ORDERS_EXISTS"></a>

When open orders already exists at given address


<pre><code><b>const</b> <a href="Orders.md#0xc0deb00c_Orders_E_ORDERS_EXISTS">E_ORDERS_EXISTS</a>: u64 = 0;
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

<a name="0xc0deb00c_Orders_get_orders_init_cap"></a>

## Function `get_orders_init_cap`

Return a <code><a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a></code>, aborting if not called by Econia


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_get_orders_init_cap">get_orders_init_cap</a>(account: &signer): <a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">Orders::OrdersInitCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_get_orders_init_cap">get_orders_init_cap</a>(
    account: &signer
): <a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a> {
    // Assert called by Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Orders.md#0xc0deb00c_Orders_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a>{} // Return requested capability
}
</code></pre>



</details>

<a name="0xc0deb00c_Orders_init_orders"></a>

## Function `init_orders`

Initialize open orders under host account, provided
<code><a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_init_orders">init_orders</a>&lt;B, Q, E&gt;(user: &signer, f: u64, _cap: &<a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">Orders::OrdersInitCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Orders.md#0xc0deb00c_Orders_init_orders">init_orders</a>&lt;B, Q, E&gt;(
    user: &signer,
    f: u64,
    _cap: &<a href="Orders.md#0xc0deb00c_Orders_OrdersInitCap">OrdersInitCap</a>
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
