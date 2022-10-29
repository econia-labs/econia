
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`



-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Struct `OpenOrder`](#0xc0deb00c_user_OpenOrder)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="tablist.md#0xc0deb00c_tablist">0xc0deb00c::tablist</a>;
</code></pre>



<a name="0xc0deb00c_user_Collateral"></a>

## Resource `Collateral`

All of a user's collateral across all market accounts.


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u128, <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;&gt;</code>
</dt>
<dd>
 Map from market account ID to collateral for market account.
 Separated into different table entries to reduce transaction
 collisions across markets. Enables off-chain iterated
 indexing by market account ID.
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccount"></a>

## Struct `MarketAccount`

Represents a user's open orders and asset counts for a given
market account ID. Contains <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a></code> field
duplicates to reduce global storage item queries.


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 <code>registry::MarketInfo::base_type</code>.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 <code>registry::MarketInfo::base_name_generic</code>.
</dd>
<dt>
<code>quote_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 <code>registry::MarketInfo::quote_type</code>.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 <code>registry::MarketInfo::lot_size</code>.
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 <code>registry::MarketInfo::tick_size</code>.
</dd>
<dt>
<code>min_size: u64</code>
</dt>
<dd>
 <code>registry::MarketInfo::min_size</code>.
</dd>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 <code>registry::MarketInfo::underwriter_id</code>.
</dd>
<dt>
<code>asks: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="user.md#0xc0deb00c_user_OpenOrder">user::OpenOrder</a>&gt;</code>
</dt>
<dd>
 Map from order access key to open ask order.
</dd>
<dt>
<code>bids: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="user.md#0xc0deb00c_user_OpenOrder">user::OpenOrder</a>&gt;</code>
</dt>
<dd>
 Map from order access key to open bid order.
</dd>
<dt>
<code>asks_stack_top: u64</code>
</dt>
<dd>
 Access key of ask order at top of inactive stack, if any.
</dd>
<dt>
<code>bids_stack_top: u64</code>
</dt>
<dd>
 Access key of bid order at top of inactive stack, if any.
</dd>
<dt>
<code>base_total: u64</code>
</dt>
<dd>
 Total base asset units held as collateral.
</dd>
<dt>
<code>base_available: u64</code>
</dt>
<dd>
 Base asset units available to withdraw.
</dd>
<dt>
<code>base_ceiling: u64</code>
</dt>
<dd>
 Amount <code>base_total</code> will increase to if all open bids fill.
</dd>
<dt>
<code>quote_total: u64</code>
</dt>
<dd>
 Total quote asset units held as collateral.
</dd>
<dt>
<code>quote_available: u64</code>
</dt>
<dd>
 Quote asset units available to withdraw.
</dd>
<dt>
<code>quote_ceiling: u64</code>
</dt>
<dd>
 Amount <code>quote_total</code> will increase to if all open asks fill.
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccounts"></a>

## Resource `MarketAccounts`

All of a user's market accounts.


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="_Table">table::Table</a>&lt;u128, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;</code>
</dt>
<dd>
 Map from market account ID to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>.
</dd>
<dt>
<code>custodians: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="">vector</a>&lt;u64&gt;&gt;</code>
</dt>
<dd>
 Map from market ID to vector of custodian IDs for which
 a market account has been registered on the given market.
 Enables off-chain iterated indexing by market account ID and
 assorted on-chain queries.
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_OpenOrder"></a>

## Struct `OpenOrder`

An open order, either ask or bid.


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_OpenOrder">OpenOrder</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_order_id: u128</code>
</dt>
<dd>
 Market order ID. <code>NIL</code> if inactive.
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Order size left to fill, in lots. When <code>market_order_id</code> is
 <code>NIL</code>, indicates access key of next inactive order in stack.
</dd>
</dl>


</details>
