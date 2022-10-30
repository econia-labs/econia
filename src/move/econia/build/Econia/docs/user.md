
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`



-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Struct `Order`](#0xc0deb00c_user_Order)
-  [Constants](#@Constants_0)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
    -  [Aborts](#@Aborts_3)
    -  [Testing](#@Testing_4)
-  [Function `register_market_account_generic_base`](#0xc0deb00c_user_register_market_account_generic_base)
    -  [Testing](#@Testing_5)
-  [Function `register_market_account_account_entries`](#0xc0deb00c_user_register_market_account_account_entries)
    -  [Type parameters](#@Type_parameters_6)
    -  [Parameters](#@Parameters_7)
    -  [Aborts](#@Aborts_8)
    -  [Testing](#@Testing_9)
-  [Function `register_market_account_collateral_entry`](#0xc0deb00c_user_register_market_account_collateral_entry)
    -  [Type parameters](#@Type_parameters_10)
    -  [Parameters](#@Parameters_11)
    -  [Testing](#@Testing_12)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
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
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_type</code>.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_name_generic</code>.
</dd>
<dt>
<code>quote_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.quote_type</code>.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.lot_size</code>.
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.tick_size</code>.
</dd>
<dt>
<code>min_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code>.
</dd>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.underwriter_id</code>.
</dd>
<dt>
<code>asks: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="user.md#0xc0deb00c_user_Order">user::Order</a>&gt;</code>
</dt>
<dd>
 Map from order access key to open ask order.
</dd>
<dt>
<code>bids: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="user.md#0xc0deb00c_user_Order">user::Order</a>&gt;</code>
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

<a name="0xc0deb00c_user_Order"></a>

## Struct `Order`

An open order, either ask or bid.


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_order_id: u128</code>
</dt>
<dd>
 Market order ID. <code><a href="user.md#0xc0deb00c_user_NIL">NIL</a></code> if inactive.
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Order size left to fill, in lots. When <code>market_order_id</code> is
 <code><a href="user.md#0xc0deb00c_user_NIL">NIL</a></code>, indicates access key of next inactive order in stack.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_user_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NIL">NIL</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_NO_CUSTODIAN"></a>

Custodian ID flag for no custodian.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

Market account already exists.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN"></a>

Custodian ID has not been registered.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN">E_UNREGISTERED_CUSTODIAN</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_SHIFT_MARKET_ID"></a>

Number of bits market ID is shifted in market account ID.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register market account for indicated market and custodian.


<a name="@Type_parameters_1"></a>

### Type parameters


* <code>BaseType</code>: Base type for indicated market. If base asset is
a generic asset, must be passed as <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>
(alternatively use <code>register_market_account_base_generic()</code>).
* <code>QuoteType</code>: Quote type for indicated market.


<a name="@Parameters_2"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>market_id</code>: Market ID for given market.
* <code>custodian_id</code>: Custodian ID to register account with, or
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>.


<a name="@Aborts_3"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN">E_UNREGISTERED_CUSTODIAN</a></code>: Custodian ID has not been
registered.


<a name="@Testing_4"></a>

### Testing


* <code>test_register_market_account_unregistered_custodian()</code>
* <code>test_register_market_accounts()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    custodian_id: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // If custodian ID indicated, <b>assert</b> it is registered.
    <b>if</b> (custodian_id != <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>) <b>assert</b>!(
        <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(custodian_id),
        <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN">E_UNREGISTERED_CUSTODIAN</a>);
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a> <b>address</b>.
    <b>let</b> market_account_id = // Get market <a href="">account</a> ID.
        ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) | (custodian_id <b>as</b> u128);
    // Register market accounts map entries.
    <a href="user.md#0xc0deb00c_user_register_market_account_account_entries">register_market_account_account_entries</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, user_address, market_account_id, market_id, custodian_id);
    // If base asset is <a href="">coin</a>, register collateral entry.
    <b>if</b> (<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;())
        <a href="user.md#0xc0deb00c_user_register_market_account_collateral_entry">register_market_account_collateral_entry</a>&lt;BaseType&gt;(
            <a href="user.md#0xc0deb00c_user">user</a>, user_address, market_account_id);
    // Register quote asset collateral entry.
    <a href="user.md#0xc0deb00c_user_register_market_account_collateral_entry">register_market_account_collateral_entry</a>&lt;QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, user_address, market_account_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account_generic_base"></a>

## Function `register_market_account_generic_base`

Wrapped <code><a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>()</code> call for generic base asset.


<a name="@Testing_5"></a>

### Testing


* <code>test_register_market_accounts()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_generic_base">register_market_account_generic_base</a>&lt;QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_generic_base">register_market_account_generic_base</a>&lt;
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    custodian_id: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;GenericAsset, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account_account_entries"></a>

## Function `register_market_account_account_entries`

Register market account entries for given market account info.

Inner function for <code><a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>()</code>.


<a name="@Type_parameters_6"></a>

### Type parameters


* <code>BaseType</code>: Base type for indicated market.
* <code>QuoteType</code>: Quote type for indicated market.


<a name="@Parameters_7"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>user_address</code>: Address of user registering a market account.
* <code>market_account_id</code>: Market account ID for given market.
* <code>market_id</code>: Market ID for given market.
* <code>custodian_id</code>: Custodian ID to register account with, or
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>.


<a name="@Aborts_8"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a></code>: Market account already exists.


<a name="@Testing_9"></a>

### Testing


* <code>test_register_market_account_account_entries_exists()</code>
* <code>test_register_market_accounts()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_account_entries">register_market_account_account_entries</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, user_address: <b>address</b>, market_account_id: u128, market_id: u64, custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_account_entries">register_market_account_account_entries</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    user_address: <b>address</b>,
    market_account_id: u128,
    market_id: u64,
    custodian_id: u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <b>let</b> (base_type, quote_type) = // Get base and quote types.
        (<a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(), <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;());
    // Get market info.
    <b>let</b> (base_name_generic, lot_size, tick_size, min_size, underwriter_id)
        = <a href="registry.md#0xc0deb00c_registry_get_market_info_for_market_account">registry::get_market_info_for_market_account</a>(
            market_id, base_type, quote_type);
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a market accounts map initialized:
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address))
        // Pack an empty one and <b>move</b> it <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>{
            map: <a href="_new">table::new</a>(), custodians: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>()});
    // Mutably borrow market accounts map.
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    <b>assert</b>!( // Assert no entry <b>exists</b> for given market <a href="">account</a> ID.
        !<a href="_contains">table::contains</a>(market_accounts_map_ref_mut, market_account_id),
        <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    <a href="_add">table::add</a>( // Add empty market <a href="">account</a> for market <a href="">account</a> ID.
        market_accounts_map_ref_mut, market_account_id, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
            base_type, base_name_generic, quote_type, lot_size, tick_size,
            min_size, underwriter_id, asks: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>(),
            bids: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>(), asks_stack_top: <a href="user.md#0xc0deb00c_user_NIL">NIL</a>, bids_stack_top: <a href="user.md#0xc0deb00c_user_NIL">NIL</a>,
            base_total: 0, base_available: 0, base_ceiling: 0,
            quote_total: 0, quote_available: 0, quote_ceiling: 0});
    <b>let</b> custodians_ref_mut = // Mutably borrow custodians maps.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).custodians;
    // If custodians map <b>has</b> no entry for given market ID:
    <b>if</b> (!<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(custodians_ref_mut, market_id)) {
        // Add new entry indicating new custodian ID.
        <a href="tablist.md#0xc0deb00c_tablist_add">tablist::add</a>(custodians_ref_mut, market_id,
                     <a href="_singleton">vector::singleton</a>(custodian_id));
    } <b>else</b> { // If already entry for given market ID:
        // Mutably borrow <a href="">vector</a> of custodians for given market.
        <b>let</b> market_custodians_ref_mut =
            <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(custodians_ref_mut, market_id);
        // Push back custodian ID for given market <a href="">account</a>.
        <a href="_push_back">vector::push_back</a>(market_custodians_ref_mut, custodian_id);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account_collateral_entry"></a>

## Function `register_market_account_collateral_entry`

Inner function for <code><a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>()</code>.

Does not check if collateral entry already exists for given
market account ID, as market account existence check already
performed by <code>register_market_account_accounts_entries()</code> in
<code><a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>()</code>.


<a name="@Type_parameters_10"></a>

### Type parameters


* <code>CoinType</code>: Phantom coin type for indicated market.


<a name="@Parameters_11"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>user_address</code>: Address of user registering a market account.
* <code>market_account_id</code>: Market account ID for given market.


<a name="@Testing_12"></a>

### Testing


* <code>test_register_market_accounts()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_collateral_entry">register_market_account_collateral_entry</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, user_address: <b>address</b>, market_account_id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account_collateral_entry">register_market_account_collateral_entry</a>&lt;
    CoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    user_address: <b>address</b>,
    market_account_id: u128
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a collateral map initialized, pack an
    // empty one and <b>move</b> it <b>to</b> their <a href="">account</a>.
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address))
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>, <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>{
            map: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>()});
    <b>let</b> collateral_map_ref_mut = // Mutably borrow collateral map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address).map;
    // Add an empty entry for given market <a href="">account</a> ID.
    <a href="tablist.md#0xc0deb00c_tablist_add">tablist::add</a>(collateral_map_ref_mut, market_account_id,
                 <a href="_zero">coin::zero</a>&lt;CoinType&gt;());
}
</code></pre>



</details>
