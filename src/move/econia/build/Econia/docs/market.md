
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market-level book keeping functionality, with matching engine.


-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Struct `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Function `invoke_registry`](#0xc0deb00c_market_invoke_registry)
-  [Function `invoke_user`](#0xc0deb00c_market_invoke_user)


<pre><code><b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="0xc0deb00c_market_Order"></a>

## Struct `Order`

An order on the order book


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Number of lots to be filled
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of corresponding user
</dd>
<dt>
<code>general_custodian_id: u64</code>
</dt>
<dd>
 For given user, the ID of the custodian required to approve
 transactions other than generic asset transfers
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBook"></a>

## Struct `OrderBook`

An order book for a given market


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to a non-coin asset
 indicated by the market host.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds a non-coin asset
 indicated by the market host.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per lot
</dd>
<dt>
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Asks tree
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Bids tree
</dd>
<dt>
<code>min_ask: u128</code>
</dt>
<dd>
 Order ID of minimum ask, per price-time priority. The ask
 side "spread maker".
</dd>
<dt>
<code>max_bid: u128</code>
</dt>
<dd>
 Order ID of maximum bid, per price-time priority. The bid
 side "spread maker".
</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>
 Number of limit orders placed on book
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_invoke_registry"></a>

## Function `invoke_registry`



<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_registry">invoke_registry</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_registry">invoke_registry</a>() {<a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(0);}
</code></pre>



</details>

<a name="0xc0deb00c_market_invoke_user"></a>

## Function `invoke_user`



<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_user">invoke_user</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_user">invoke_user</a>() {<a href="user.md#0xc0deb00c_user_return_0">user::return_0</a>();}
</code></pre>



</details>
