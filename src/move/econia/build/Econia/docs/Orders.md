
<a name="0xc0deb00c_Orders"></a>

# Module `0xc0deb00c::Orders`

Pure-Move implementation of user-side open orders functionality


-  [Struct `OrdersInitCap`](#0xc0deb00c_Orders_OrdersInitCap)
-  [Resource `OO`](#0xc0deb00c_Orders_OO)


<pre><code><b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
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
