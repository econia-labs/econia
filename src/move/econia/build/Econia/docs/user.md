
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side collateral and book keeping management. For a given
market, a user can register multiple <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s, with each
such market account having a different delegated custodian and a
unique <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>. For a given <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>, a user has
entries in a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map for both base and quote coins.


-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccountInfo`](#0xc0deb00c_user_MarketAccountInfo)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Constants](#@Constants_0)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Abort conditions](#@Abort_conditions_1)
-  [Function `withdraw_collateral_user`](#0xc0deb00c_user_withdraw_collateral_user)
-  [Function `add_order_internal`](#0xc0deb00c_user_add_order_internal)
    -  [Parameters](#@Parameters_2)
    -  [Abort conditions](#@Abort_conditions_3)
-  [Function `deposit_collateral`](#0xc0deb00c_user_deposit_collateral)
    -  [Abort conditions](#@Abort_conditions_4)
-  [Function `fill_order_internal`](#0xc0deb00c_user_fill_order_internal)
    -  [Parameters](#@Parameters_5)
-  [Function `market_account_info`](#0xc0deb00c_user_market_account_info)
-  [Function `remove_order_internal`](#0xc0deb00c_user_remove_order_internal)
    -  [Parameters](#@Parameters_6)
    -  [Assumes](#@Assumes_7)
-  [Function `withdraw_collateral_custodian`](#0xc0deb00c_user_withdraw_collateral_custodian)
-  [Function `withdraw_collateral_internal`](#0xc0deb00c_user_withdraw_collateral_internal)
-  [Function `borrow_coin_counts_mut`](#0xc0deb00c_user_borrow_coin_counts_mut)
    -  [Abort conditions](#@Abort_conditions_8)
    -  [Assumes](#@Assumes_9)
-  [Function `exists_market_account`](#0xc0deb00c_user_exists_market_account)
-  [Function `fill_order_route_collateral`](#0xc0deb00c_user_fill_order_route_collateral)
    -  [Parameters](#@Parameters_10)
-  [Function `fill_order_route_collateral_single`](#0xc0deb00c_user_fill_order_route_collateral_single)
    -  [Parameters](#@Parameters_11)
-  [Function `fill_order_update_market_account`](#0xc0deb00c_user_fill_order_update_market_account)
    -  [Parameters](#@Parameters_12)
-  [Function `range_check_order_fills`](#0xc0deb00c_user_range_check_order_fills)
-  [Function `register_collateral_entry`](#0xc0deb00c_user_register_collateral_entry)
    -  [Abort conditions](#@Abort_conditions_13)
-  [Function `register_market_accounts_entry`](#0xc0deb00c_user_register_market_accounts_entry)
    -  [Abort conditions](#@Abort_conditions_14)
-  [Function `withdraw_collateral`](#0xc0deb00c_user_withdraw_collateral)
    -  [Abort conditions](#@Abort_conditions_15)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="capability.md#0xc0deb00c_capability">0xc0deb00c::capability</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
<b>use</b> <a href="order_id.md#0xc0deb00c_order_id">0xc0deb00c::order_id</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
</code></pre>



<a name="0xc0deb00c_user_Collateral"></a>

## Resource `Collateral`

Collateral map for given coin type, across all <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;&gt;</code>
</dt>
<dd>
 Map from <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code> to coins held as collateral for
 given <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>. Separated into different table
 entries to reduce transaction collisions across markets
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccountInfo"></a>

## Struct `MarketAccountInfo`

Unique ID describing a market and a delegated custodian


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_info: <a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a></code>
</dt>
<dd>
 The market that a user is trading on
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 Serial ID of registered account custodian, set to 0 when
 given account does not have an authorized custodian
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccount"></a>

## Struct `MarketAccount`

Represents a user's open orders and collateral status for a
given <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>scale_factor: u64</code>
</dt>
<dd>
 Scale factor for given market, included as a lookup
 optimization for integer-based arithmetic
</dd>
<dt>
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;u64&gt;</code>
</dt>
<dd>
 Map from order ID to size of order, in base parcels
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;u64&gt;</code>
</dt>
<dd>
 Map from order ID to size of order, in base parcels
</dd>
<dt>
<code>base_coins_total: u64</code>
</dt>
<dd>
 Total base coins held as collateral
</dd>
<dt>
<code>base_coins_available: u64</code>
</dt>
<dd>
 Base coins available for withdraw
</dd>
<dt>
<code>quote_coins_total: u64</code>
</dt>
<dd>
 Total quote coins held as collateral
</dd>
<dt>
<code>quote_coins_available: u64</code>
</dt>
<dd>
 Quote coins available for withdraw
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccounts"></a>

## Resource `MarketAccounts`

Market account map for all of a user's <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;</code>
</dt>
<dd>
 Map from <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code> to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>. Separated
 into different table entries to reduce transaction
 collisions across markets
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_user_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_user_ASK"></a>

Flag for asks side


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_user_BID"></a>

Flag for asks side


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_user_E_BASE_PARCELS_0"></a>

When an order has no base parcel count listed


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_BASE_PARCELS_0">E_BASE_PARCELS_0</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_user_E_CUSTODIAN_OVERRIDE"></a>

When user attempts invalid custodian override


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_E_INVALID_CUSTODIAN_ID"></a>

When the passed custodian ID is invalid


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_INVALID_CUSTODIAN_ID">E_INVALID_CUSTODIAN_ID</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED"></a>

When a market account registered for given market account info


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL"></a>

When not enough collateral


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET"></a>

When no such market has been registered


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET">E_NO_MARKET</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNT"></a>

When a collateral transfer does not have specified amount


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNTS"></a>

When a user does not a market accounts map


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_user_E_OVERFLOW_BASE"></a>

When a base fill amount would not fit into a <code>u64</code>


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_OVERFLOW_BASE">E_OVERFLOW_BASE</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_user_E_OVERFLOW_QUOTE"></a>

When a quote fill amount would not fit into a <code>u64</code>


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_OVERFLOW_QUOTE">E_OVERFLOW_QUOTE</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_user_E_PRICE_0"></a>

When an order has no price listed


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_PRICE_0">E_PRICE_0</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN"></a>

When unauthorized custodian ID


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_user_IN"></a>

Flag for inbound coins


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_IN">IN</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_user_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_OUT"></a>

Flag for outbound coins


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_OUT">OUT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> and <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entries
for given market and <code>custodian_id</code>. If <code>custodian_id</code> is 0,
register user with an account that only they can manage via a
signature.


<a name="@Abort_conditions_1"></a>

### Abort conditions

* If market is not already registered
* If invalid <code>custodian_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    custodian_id: u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Get <a href="market.md#0xc0deb00c_market">market</a> info
    <b>let</b> market_info = <a href="registry.md#0xc0deb00c_registry_market_info">registry::market_info</a>&lt;B, Q, E&gt;();
    // Assert <a href="market.md#0xc0deb00c_market">market</a> <b>has</b> already been registered
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_registered">registry::is_registered</a>(market_info), <a href="user.md#0xc0deb00c_user_E_NO_MARKET">E_NO_MARKET</a>);
    // Assert given custodian ID is in bounds
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_valid_custodian_id">registry::is_valid_custodian_id</a>(custodian_id),
        <a href="user.md#0xc0deb00c_user_E_INVALID_CUSTODIAN_ID">E_INVALID_CUSTODIAN_ID</a>);
    <b>let</b> market_account_info = // Pack <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
        <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_info, custodian_id};
    // Register entry in <a href="market.md#0xc0deb00c_market">market</a> accounts map (aborts <b>if</b> already
    // registered)
    <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // Registry collateral entry for base <a href="">coin</a> (aborts <b>if</b> already
    // registered)
    <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;B&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // Registry collateral entry for quote <a href="">coin</a> (aborts <b>if</b> already
    // registered)
    <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_user"></a>

## Function `withdraw_collateral_user`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.
Aborts if custodian serial ID for given market account is not 0.


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_user">withdraw_collateral_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_user">withdraw_collateral_user</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> is not trying <b>to</b> override delegated custody
    <b>assert</b>!(market_account_info.custodian_id == <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>);
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_withdraw_collateral">withdraw_collateral</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_add_order_internal"></a>

## Function `add_order_internal`

Add an order to a user's market account, provided an immutable
reference to an <code>EconiaCapability</code>.


<a name="@Parameters_2"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>custodian_id</code>: Serial ID of delegated custodian for given
market account
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>base_parcels</code>: Number of base parcels the order is for
* <code>price</code>: Order price


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If user does not have a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code>
* If user does not have a corresponding <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> for
given type arguments and <code>custodian_id</code>
* If user does not have sufficient collateral to cover the order
* If range checking does not pass per <code>range_check_order_fills</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_add_order_internal">add_order_internal</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, base_parcels: u64, price: u64, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_add_order_internal">add_order_internal</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    base_parcels: u64,
    price: u64,
    _econia_capability: &EconiaCapability
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Declare <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_market_account_info">market_account_info</a>&lt;B, Q, E&gt;(custodian_id);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> for given <a href="market.md#0xc0deb00c_market">market</a> info
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map, market_account_info),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts_map, market_account_info);
    // Get base and quote subunits required <b>to</b> fill order
    <b>let</b> (base_to_fill, quote_to_fill) = <a href="user.md#0xc0deb00c_user_range_check_order_fills">range_check_order_fills</a>(
        market_account.scale_factor, base_parcels, price);
    // Get mutable reference <b>to</b> corresponding tree, mutable
    // reference <b>to</b> corresponding <a href="">coins</a> available field, and
    // <a href="">coins</a> required for lockup based on given side
    <b>let</b> (tree_ref_mut, coins_available_ref_mut, coins_required) =
        <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (
            &<b>mut</b> market_account.asks,
            &<b>mut</b> market_account.base_coins_available,
            base_to_fill
        ) <b>else</b> (
            &<b>mut</b> market_account.bids,
            &<b>mut</b> market_account.quote_coins_available,
            quote_to_fill
        );
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough collateral <b>to</b> place the order
    <b>assert</b>!(coins_required &lt;= *coins_available_ref_mut,
        <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
    // Decrement available <a href="">coin</a> amount
    *coins_available_ref_mut = *coins_available_ref_mut - coins_required;
    // Add order <b>to</b> corresponding tree
    <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, base_parcels);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_collateral"></a>

## Function `deposit_collateral`

Deposit <code><a href="">coins</a></code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> for given
<code>market_account_info</code>.


<a name="@Abort_conditions_4"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote for market account
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have corresponding market account
registered


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_collateral">deposit_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_collateral">deposit_collateral</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    <a href="">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> registered for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total <a href="">coins</a> held <b>as</b> collateral,
    // and mutable reference <b>to</b> amount of <a href="">coins</a> available for
    // withdraw (aborts <b>if</b> <a href="">coin</a> type is neither base nor quote for
    // given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>)
    <b>let</b> (coins_total_ref_mut, coins_available_ref_mut) =
        <a href="user.md#0xc0deb00c_user_borrow_coin_counts_mut">borrow_coin_counts_mut</a>&lt;CoinType&gt;(market_accounts_map,
            market_account_info);
    *coins_total_ref_mut = // Increment total <a href="">coin</a> count
        *coins_total_ref_mut + <a href="_value">coin::value</a>(&<a href="">coins</a>);
    *coins_available_ref_mut = // Increment available <a href="">coin</a> count
        *coins_available_ref_mut + <a href="_value">coin::value</a>(&<a href="">coins</a>);
    // Borrow mutable reference <b>to</b> collateral map
    <b>let</b> collateral_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> collateral =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map, market_account_info);
    // Merge <a href="">coins</a> into <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> collateral
    <a href="_merge">coin::merge</a>(collateral, <a href="">coins</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_internal"></a>

## Function `fill_order_internal`

Fill a user's order, routing collateral accordingly.

Only to be called by the matching engine, which has already
calculated the corresponding amount of collateral to route. If
the matching engine gets to this stage, then it is assumed that
given user has the indicated open order and appropriate
collateral to fill it. Hence no error checking.


<a name="@Parameters_5"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>custodian_id</code>: Serial ID of delegated custodian for given
market account
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>complete_fill</code>: If <code><b>true</b></code>, the order is completely filled
* <code>base_parcels_filled</code>: Number of base parcels filled
* <code>base_coins_ref_mut</code>: Mutable reference to base coins passing
through the matching engine
* <code>quote_coins_ref_mut</code>: Mutable reference to quote coins
passing through the matching engine
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base coins to
route from <code><a href="user.md#0xc0deb00c_user">user</a></code> to <code>base_coins_ref_mut</code>, else from
<code>base_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote coins to
route from <code>quote_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>
to <code>quote_coins_ref_mut</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, complete_fill: bool, base_parcels_filled: u64, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;, base_to_route: u64, quote_to_route: u64, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    complete_fill: bool,
    base_parcels_filled: u64,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    base_to_route: u64,
    quote_to_route: u64,
    _econia_capability: &EconiaCapability
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_market_account_info">market_account_info</a>&lt;B, Q, E&gt;(custodian_id);
    // Update <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, complete_fill, base_parcels_filled, base_to_route,
        quote_to_route);
    // Route collateral accordingly
    <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;B, Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, side,
        base_coins_ref_mut, quote_coins_ref_mut, base_to_route,
        quote_to_route);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_market_account_info"></a>

## Function `market_account_info`

Get a <code>MarketInfo</code> for type arguments, pack with <code>custodian_id</code>
into a <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code> and return


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_market_account_info">market_account_info</a>&lt;B, Q, E&gt;(custodian_id: u64): <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_market_account_info">market_account_info</a>&lt;B, Q, E&gt;(
    custodian_id: u64
): <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a> {
    <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{
        market_info: <a href="registry.md#0xc0deb00c_registry_market_info">registry::market_info</a>&lt;B, Q, E&gt;(),
        custodian_id
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_remove_order_internal"></a>

## Function `remove_order_internal`

Remove an order from a user's market account, provided an
immutable reference to an <code>EconiaCapability</code>.


<a name="@Parameters_6"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>custodian_id</code>: Serial ID of delegated custodian for given
market account
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order


<a name="@Assumes_7"></a>

### Assumes

* That order has already been cancelled from the order book, and
as such that user necessarily has an open order as specified:
if an order has been cancelled from the book, then it had to
have been placed on the book, which means that the
corresponding user successfully placed it to begin with.


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_remove_order_internal">remove_order_internal</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_remove_order_internal">remove_order_internal</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    _econia_capability: &EconiaCapability
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Declare <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_market_account_info">market_account_info</a>&lt;B, Q, E&gt;(custodian_id);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts_map, market_account_info);
    // Get mutable reference <b>to</b> corresponding tree, mutable
    // reference <b>to</b> corresponding <a href="">coins</a> available field, and
    // base parcel multiplier based on given side
    <b>let</b> (tree_ref_mut, coins_available_ref_mut, base_parcel_multiplier) =
        <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (
            &<b>mut</b> market_account.asks,
            &<b>mut</b> market_account.base_coins_available,
            market_account.scale_factor
        ) <b>else</b> (
            &<b>mut</b> market_account.bids,
            &<b>mut</b> market_account.quote_coins_available,
            <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(<a href="order_id.md#0xc0deb00c_order_id">order_id</a>)
        );
    // Pop order from corresponding tree, storing number of base
    // parcels it specified
    <b>let</b> base_parcels = <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
    // Calculate number of <a href="">coins</a> unlocked by order cancellation
    <b>let</b> coins_unlocked = base_parcels * base_parcel_multiplier;
    // Increment available <a href="">coin</a> amount
    *coins_available_ref_mut = *coins_available_ref_mut + coins_unlocked;
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_custodian"></a>

## Function `withdraw_collateral_custodian`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.
Requires a reference to a <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code> for
authorization, and aborts if custodian serial ID does not
correspond to that specified in <code>market_account_info</code>.


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_custodian">withdraw_collateral_custodian</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_custodian">withdraw_collateral_custodian</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert serial custodian ID from <a href="capability.md#0xc0deb00c_capability">capability</a> matches ID from
    // <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability_ref) ==
        market_account_info.custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_withdraw_collateral">withdraw_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_internal"></a>

## Function `withdraw_collateral_internal`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.
Reserved for internal cross-module clls, and requires a
reference to an <code>EconiaCapability</code>.


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
    _econia_capability: &EconiaCapability
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_withdraw_collateral">withdraw_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_borrow_coin_counts_mut"></a>

## Function `borrow_coin_counts_mut`

Look up the <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> in <code>market_accounts_map</code> having
<code>market_account_info</code>, then return a mutable reference to the
number of coins of <code>CoinType</code> held as collateral, and a mutable
reference to the number of coins available for withdraw.


<a name="@Abort_conditions_8"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote coin in
<code>market_account_info</code>.


<a name="@Assumes_9"></a>

### Assumes

* <code>market_accounts_map</code> has an entry with <code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_coin_counts_mut">borrow_coin_counts_mut</a>&lt;CoinType&gt;(market_accounts_map: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>): (&<b>mut</b> u64, &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_coin_counts_mut">borrow_coin_counts_mut</a>&lt;CoinType&gt;(
    market_accounts_map:
        &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>&gt;,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>
): (
    &<b>mut</b> u64,
    &<b>mut</b> u64
)
{
    // Determine <b>if</b> <a href="">coin</a> is base <a href="">coin</a> for <a href="market.md#0xc0deb00c_market">market</a> (aborts <b>if</b> is
    // neither base nor quote
    <b>let</b> is_base_coin = <a href="registry.md#0xc0deb00c_registry_coin_is_base_coin">registry::coin_is_base_coin</a>&lt;CoinType&gt;(
        &market_account_info.market_info);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts_map, market_account_info);
    <b>if</b> (is_base_coin) ( // If is base <a href="">coin</a>, <b>return</b> base <a href="">coin</a> refs
        &<b>mut</b> market_account.base_coins_total,
        &<b>mut</b> market_account.base_coins_available
    ) <b>else</b> ( // Else quote <a href="">coin</a> refs
        &<b>mut</b> market_account.quote_coins_total,
        &<b>mut</b> market_account.quote_coins_available
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_exists_market_account"></a>

## Function `exists_market_account`

Return <code><b>true</b></code> if <code><a href="user.md#0xc0deb00c_user">user</a></code> has an <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> entry for
<code>market_account_info</code>, otherwise <code><b>false</b></code>.


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>
): bool
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Return <b>false</b> <b>if</b> no <a href="market.md#0xc0deb00c_market">market</a> accounts map <b>exists</b>
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> <b>false</b>;
    // Borrow immutable ref <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Return <b>if</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> is registered in <a href="">table</a>
    <a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map, market_account_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_route_collateral"></a>

## Function `fill_order_route_collateral`

Route collateral when filling an order.

Inner function for <code><a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>()</code>.


<a name="@Parameters_10"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_info</code>: Corresponding <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code>base_coins_ref_mut</code>: Mutable reference to base coins passing
through the matching engine
* <code>quote_coins_ref_mut</code>: Mutable reference to quote coins
passing through the matching engine
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base coins to
route from <code><a href="user.md#0xc0deb00c_user">user</a></code> to <code>base_coins_ref_mut</code>, else from
<code>base_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote coins to
route from <code>quote_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>
to <code>quote_coins_ref_mut</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;B, Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, side: bool, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;, base_to_route: u64, quote_to_route: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;B, Q&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    side: bool,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    base_to_route: u64,
    quote_to_route: u64,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    // Determine route direction for base and quote relative <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>
    <b>let</b> (base_direction, quote_direction) =
        <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (<a href="user.md#0xc0deb00c_user_OUT">OUT</a>, <a href="user.md#0xc0deb00c_user_IN">IN</a>) <b>else</b> (<a href="user.md#0xc0deb00c_user_IN">IN</a>, <a href="user.md#0xc0deb00c_user_OUT">OUT</a>);
    // Route base <a href="">coins</a>
    <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;B&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info,
        base_coins_ref_mut, base_to_route, base_direction);
    // Route quote <a href="">coins</a>
    <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info,
        quote_coins_ref_mut, quote_to_route, quote_direction);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_route_collateral_single"></a>

## Function `fill_order_route_collateral_single`

Route <code>amount</code> of <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> in <code>direction</code> either <code><a href="user.md#0xc0deb00c_user_IN">IN</a></code> or
<code><a href="user.md#0xc0deb00c_user_OUT">OUT</a></code>, relative to <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code>market_account_info</code>, either
from or to, respectively, coins at <code>external_coins_ref_mut</code>.

Inner function for <code><a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>()</code>


<a name="@Parameters_11"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_info</code>: Corresponding <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>
* <code>external_coins_ref_mut</code>: Effectively a counterparty to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>amount</code>: Amount of coins to route
* <code>direction</code>: <code><a href="user.md#0xc0deb00c_user_IN">IN</a></code> or <code><a href="user.md#0xc0deb00c_user_OUT">OUT</a></code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, external_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;, amount: u64, direction: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    external_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;,
    amount: u64,
    direction: bool
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    // Borrow mutable reference <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral map
    <b>let</b> collateral_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral
    <b>let</b> collateral_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map_ref_mut,
        market_account_info);
    // If inbound collateral <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>
    <b>if</b> (direction == <a href="user.md#0xc0deb00c_user_IN">IN</a>)
        // Merge <b>to</b> their collateral store extracted external <a href="">coins</a>
        <a href="_merge">coin::merge</a>(collateral_ref_mut,
            <a href="_extract">coin::extract</a>(external_coins_ref_mut, amount)) <b>else</b>
        // If outbound collateral from <a href="user.md#0xc0deb00c_user">user</a>, merge <b>to</b> external <a href="">coins</a>
        // those extracted from <a href="user.md#0xc0deb00c_user">user</a>'s collateral
        <a href="_merge">coin::merge</a>(external_coins_ref_mut,
            <a href="_extract">coin::extract</a>(collateral_ref_mut, amount));
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_update_market_account"></a>

## Function `fill_order_update_market_account`

Update a user's market account when filling an order.

Inner function for <code><a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>()</code>.


<a name="@Parameters_12"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_info</code>: Corresponding <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>complete_fill</code>: If <code><b>true</b></code>, the order is completely filled
* <code>base_parcels_filled</code>: Number of base parcels filled
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base coins
routed from <code><a href="user.md#0xc0deb00c_user">user</a></code>, else to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote coins
routed to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, complete_fill: bool, base_parcels_filled: u64, base_to_route: u64, quote_to_route: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    complete_fill: bool,
    base_parcels_filled: u64,
    base_to_route: u64,
    quote_to_route: u64,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
        market_accounts_map_ref_mut, market_account_info);
    <b>let</b> ( // Get mutable reference <b>to</b> corresponding orders tree,
        order_tree_ref_mut,
        coins_in, // Amount of inbound <a href="">coins</a>
        coins_in_total_ref_mut, // Totals field for inbound <a href="">coins</a>
        coins_in_available_ref_mut, // Available field
        coins_out, // Amount of outbound <a href="">coins</a>
        coins_out_total_ref_mut, // Totals field for outbound <a href="">coins</a>
    ) = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) ( // If an ask is matched
        &<b>mut</b> market_account_ref_mut.asks,
        quote_to_route,
        &<b>mut</b> market_account_ref_mut.quote_coins_total,
        &<b>mut</b> market_account_ref_mut.quote_coins_available,
        base_to_route,
        &<b>mut</b> market_account_ref_mut.base_coins_total,
    ) <b>else</b> ( // If a bid is matched
        &<b>mut</b> market_account_ref_mut.bids,
        base_to_route,
        &<b>mut</b> market_account_ref_mut.base_coins_total,
        &<b>mut</b> market_account_ref_mut.base_coins_available,
        quote_to_route,
        &<b>mut</b> market_account_ref_mut.quote_coins_total,
    );
    <b>if</b> (complete_fill) { // If completely filling the order
        <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(order_tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>); // Pop order
    } <b>else</b> { // If only partially filling the order
        // Get mutable reference <b>to</b> base parcels left <b>to</b> be filled
        // on the order
        <b>let</b> order_base_parcels_ref_mut =
            <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">critbit::borrow_mut</a>(order_tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
        // Decrement amount still unfilled
        *order_base_parcels_ref_mut = *order_base_parcels_ref_mut -
            base_parcels_filled;
    };
    // Update <a href="">coin</a> counts for incoming and outgoing <a href="">coins</a>
    *coins_in_total_ref_mut = *coins_in_total_ref_mut + coins_in;
    *coins_in_available_ref_mut = *coins_in_available_ref_mut + coins_in;
    *coins_out_total_ref_mut = *coins_out_total_ref_mut - coins_out;
}
</code></pre>



</details>

<a name="0xc0deb00c_user_range_check_order_fills"></a>

## Function `range_check_order_fills`

For order with given <code>scale_factor</code>, <code>base_parcels</code>, and
<code>price</code>, check that price and size are zero, and that fill
amounts can fit in a <code>u64</code>. Then return the number of base coins
and quote coins required to fill the order.


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_range_check_order_fills">range_check_order_fills</a>(scale_factor: u64, base_parcels: u64, price: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_range_check_order_fills">range_check_order_fills</a>(
    scale_factor: u64,
    base_parcels: u64,
    price: u64
): (
    u64,
    u64
) {
    <b>assert</b>!(price &gt; 0, <a href="user.md#0xc0deb00c_user_E_PRICE_0">E_PRICE_0</a>); // Assert order <b>has</b> actual price
    // Assert actually trying <b>to</b> trade amount of base parcels
    <b>assert</b>!(base_parcels &gt; 0, <a href="user.md#0xc0deb00c_user_E_BASE_PARCELS_0">E_BASE_PARCELS_0</a>);
    // Calculate base <a href="">coins</a> required <b>to</b> fill the order
    <b>let</b> base_to_fill = (scale_factor <b>as</b> u128) * (base_parcels <b>as</b> u128);
    // Assert that amount can fit in a u64
    <b>assert</b>!(!(base_to_fill &gt; (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)), <a href="user.md#0xc0deb00c_user_E_OVERFLOW_BASE">E_OVERFLOW_BASE</a>);
    // Determine amount of quote <a href="">coins</a> needed <b>to</b> fill order
    <b>let</b> quote_to_fill = (price <b>as</b> u128) * (base_parcels <b>as</b> u128);
    // Assert that amount can fit in a u64
    <b>assert</b>!(!(quote_to_fill &gt; (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)), <a href="user.md#0xc0deb00c_user_E_OVERFLOW_QUOTE">E_OVERFLOW_QUOTE</a>);
    // Return casted, range-checked amounts
    ((base_to_fill <b>as</b> u64), (quote_to_fill <b>as</b> u64))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
and <code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist.


<a name="@Abort_conditions_13"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <b>address</b>
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a collateral map initialized
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address)) {
        // Pack an empty one and <b>move</b> <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    <b>let</b> map = // Borrow mutable reference <b>to</b> collateral map
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(map,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(map, market_account_info, <a href="_zero">coin::zero</a>&lt;CoinType&gt;());
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_accounts_entry"></a>

## Function `register_market_accounts_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> map entry corresponding to
<code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> if it does
not already exist


<a name="@Abort_conditions_14"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <b>address</b>
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a <a href="market.md#0xc0deb00c_market">market</a> accounts map initialized
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address)) {
        // Pack an empty one and <b>move</b> it <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> map = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(map, market_account_info),
        <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Get scale factor for corresponding <a href="market.md#0xc0deb00c_market">market</a>
    <b>let</b> scale_factor = <a href="registry.md#0xc0deb00c_registry_scale_factor_from_market_info">registry::scale_factor_from_market_info</a>(
        &market_account_info.market_info);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(map, market_account_info, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
        scale_factor,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        base_coins_total: 0,
        base_coins_available: 0,
        quote_coins_total: 0,
        quote_coins_available: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral"></a>

## Function `withdraw_collateral`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.


<a name="@Abort_conditions_15"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote for market account
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have corresponding market account
registered
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> has insufficient collateral to withdraw


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral">withdraw_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral">withdraw_collateral</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> registered for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total <a href="">coins</a> held <b>as</b> collateral,
    // and mutable reference <b>to</b> amount of <a href="">coins</a> available for
    // withdraw (aborts <b>if</b> <a href="">coin</a> type is neither base nor quote for
    // given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>)
    <b>let</b> (coins_total_ref_mut, coins_available_ref_mut) =
        <a href="user.md#0xc0deb00c_user_borrow_coin_counts_mut">borrow_coin_counts_mut</a>&lt;CoinType&gt;(market_accounts_map,
            market_account_info);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough available collateral <b>to</b> withdraw
    <b>assert</b>!(amount &lt;= *coins_available_ref_mut, <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
    // Decrement withdrawn amount from total <a href="">coin</a> count
    *coins_total_ref_mut = *coins_total_ref_mut - amount;
    // Decrement withdrawn amount from available <a href="">coin</a> count
    *coins_available_ref_mut = *coins_available_ref_mut - amount;
    // Borrow mutable reference <b>to</b> collateral map
    <b>let</b> collateral_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> collateral =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map, market_account_info);
    // Extract collateral from <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> and <b>return</b>
    <a href="_extract">coin::extract</a>(collateral, amount)
}
</code></pre>



</details>
