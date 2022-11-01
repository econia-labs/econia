
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`



-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Struct `Order`](#0xc0deb00c_user_Order)
-  [Constants](#@Constants_0)
-  [Function `deposit_coins`](#0xc0deb00c_user_deposit_coins)
    -  [Testing](#@Testing_1)
-  [Function `deposit_generic_asset`](#0xc0deb00c_user_deposit_generic_asset)
    -  [Testing](#@Testing_2)
-  [Function `get_all_market_account_ids_for_market_id`](#0xc0deb00c_user_get_all_market_account_ids_for_market_id)
    -  [Parameters](#@Parameters_3)
    -  [Returns](#@Returns_4)
    -  [Gas considerations](#@Gas_considerations_5)
    -  [Testing](#@Testing_6)
-  [Function `get_asset_counts_custodian`](#0xc0deb00c_user_get_asset_counts_custodian)
    -  [Testing](#@Testing_7)
-  [Function `get_asset_counts_user`](#0xc0deb00c_user_get_asset_counts_user)
    -  [Testing](#@Testing_8)
-  [Function `get_all_market_account_ids_for_user`](#0xc0deb00c_user_get_all_market_account_ids_for_user)
    -  [Parameters](#@Parameters_9)
    -  [Returns](#@Returns_10)
    -  [Gas considerations](#@Gas_considerations_11)
    -  [Testing](#@Testing_12)
-  [Function `get_custodian_id`](#0xc0deb00c_user_get_custodian_id)
    -  [Testing](#@Testing_13)
-  [Function `get_market_account_id`](#0xc0deb00c_user_get_market_account_id)
    -  [Testing](#@Testing_14)
-  [Function `get_market_id`](#0xc0deb00c_user_get_market_id)
    -  [Testing](#@Testing_15)
-  [Function `has_market_account_by_market_account_id`](#0xc0deb00c_user_has_market_account_by_market_account_id)
    -  [Testing](#@Testing_16)
-  [Function `has_market_account_by_market_id`](#0xc0deb00c_user_has_market_account_by_market_id)
    -  [Testing](#@Testing_17)
-  [Function `withdraw_coins_custodian`](#0xc0deb00c_user_withdraw_coins_custodian)
    -  [Testing](#@Testing_18)
-  [Function `withdraw_coins_user`](#0xc0deb00c_user_withdraw_coins_user)
    -  [Testing](#@Testing_19)
-  [Function `withdraw_generic_asset_custodian`](#0xc0deb00c_user_withdraw_generic_asset_custodian)
    -  [Testing](#@Testing_20)
-  [Function `withdraw_generic_asset_user`](#0xc0deb00c_user_withdraw_generic_asset_user)
    -  [Testing](#@Testing_21)
-  [Function `deposit_from_coinstore`](#0xc0deb00c_user_deposit_from_coinstore)
    -  [Testing](#@Testing_22)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_23)
    -  [Parameters](#@Parameters_24)
    -  [Aborts](#@Aborts_25)
    -  [Testing](#@Testing_26)
-  [Function `register_market_account_generic_base`](#0xc0deb00c_user_register_market_account_generic_base)
    -  [Testing](#@Testing_27)
-  [Function `withdraw_to_coinstore`](#0xc0deb00c_user_withdraw_to_coinstore)
    -  [Testing](#@Testing_28)
-  [Function `get_asset_counts_internal`](#0xc0deb00c_user_get_asset_counts_internal)
    -  [Parameters](#@Parameters_29)
    -  [Returns](#@Returns_30)
    -  [Aborts](#@Aborts_31)
    -  [Testing](#@Testing_32)
-  [Function `deposit_asset`](#0xc0deb00c_user_deposit_asset)
    -  [Type parameters](#@Type_parameters_33)
    -  [Parameters](#@Parameters_34)
    -  [Aborts](#@Aborts_35)
    -  [Assumptions](#@Assumptions_36)
    -  [Testing](#@Testing_37)
-  [Function `register_market_account_account_entries`](#0xc0deb00c_user_register_market_account_account_entries)
    -  [Type parameters](#@Type_parameters_38)
    -  [Parameters](#@Parameters_39)
    -  [Aborts](#@Aborts_40)
    -  [Testing](#@Testing_41)
-  [Function `register_market_account_collateral_entry`](#0xc0deb00c_user_register_market_account_collateral_entry)
    -  [Type parameters](#@Type_parameters_42)
    -  [Parameters](#@Parameters_43)
    -  [Testing](#@Testing_44)
-  [Function `withdraw_asset`](#0xc0deb00c_user_withdraw_asset)
    -  [Type parameters](#@Type_parameters_45)
    -  [Parameters](#@Parameters_46)
    -  [Returns](#@Returns_47)
    -  [Aborts](#@Aborts_48)
    -  [Testing](#@Testing_49)
-  [Function `withdraw_generic_asset`](#0xc0deb00c_user_withdraw_generic_asset)
    -  [Testing](#@Testing_50)
-  [Function `withdraw_coins`](#0xc0deb00c_user_withdraw_coins)
    -  [Testing](#@Testing_51)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
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


<a name="0xc0deb00c_user_HI_64"></a>

<code>u64</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 64, 2))</code>.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_user_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NIL">NIL</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_NO_CUSTODIAN"></a>

Custodian ID flag for no custodian.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_NO_UNDERWRITER"></a>

Underwriter ID flag for no underwriter.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_UNDERWRITER">NO_UNDERWRITER</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_ASSET_NOT_IN_PAIR"></a>

Asset type is not in trading pair for market.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_ASSET_NOT_IN_PAIR">E_ASSET_NOT_IN_PAIR</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING"></a>

Deposit would overflow asset ceiling.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

Market account already exists.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_INVALID_UNDERWRITER"></a>

Underwriter is not valid for indicated market.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNT"></a>

No market account resource found.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNTS"></a>

No market accounts resource found.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN"></a>

Custodian ID has not been registered.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN">E_UNREGISTERED_CUSTODIAN</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_E_WITHDRAW_TOO_LITTLE_AVAILABLE"></a>

Too little available for withdrawal.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_WITHDRAW_TOO_LITTLE_AVAILABLE">E_WITHDRAW_TOO_LITTLE_AVAILABLE</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_user_SHIFT_MARKET_ID"></a>

Number of bits market ID is shifted in market account ID.


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_user_deposit_coins"></a>

## Function `deposit_coins`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code> for depositing coins.


<a name="@Testing_1"></a>

### Testing


* <code>test_deposits()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, coins: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;
    CoinType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    coins: Coin&lt;CoinType&gt;
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;CoinType&gt;(
        user_address,
        market_id,
        custodian_id,
        <a href="_value">coin::value</a>(&coins),
        <a href="_some">option::some</a>(coins),
        <a href="user.md#0xc0deb00c_user_NO_UNDERWRITER">NO_UNDERWRITER</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_generic_asset"></a>

## Function `deposit_generic_asset`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code> for depositing generic asset.


<a name="@Testing_2"></a>

### Testing


* <code>test_deposits()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>(user_address: <b>address</b>, market_id: u64, custodian_id: u64, amount: u64, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
    underwriter_capability_ref: &UnderwriterCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;GenericAsset&gt;(
        user_address,
        market_id,
        custodian_id,
        amount,
        <a href="_none">option::none</a>(),
        <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">registry::get_underwriter_id</a>(underwriter_capability_ref));
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_all_market_account_ids_for_market_id"></a>

## Function `get_all_market_account_ids_for_market_id`

Return all market account IDs associated with market ID.


<a name="@Parameters_3"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user to check market account IDs for.
* <code>market_id</code>: Market ID to check market accounts for.


<a name="@Returns_4"></a>

### Returns


* <code><a href="">vector</a>&lt;u128&gt;</code>: Vector of user's market account IDs for given
market, empty if no market accounts.


<a name="@Gas_considerations_5"></a>

### Gas considerations


Loops over all elements within a vector that is itself a single
item in global storage, and returns a vector via pass-by-value.


<a name="@Testing_6"></a>

### Testing


* <code>test_market_account_getters()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_all_market_account_ids_for_market_id">get_all_market_account_ids_for_market_id</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64): <a href="">vector</a>&lt;u128&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_all_market_account_ids_for_market_id">get_all_market_account_ids_for_market_id</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64
): <a href="">vector</a>&lt;u128&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <b>let</b> market_account_ids = <a href="_empty">vector::empty</a>(); // Init empty <a href="">vector</a>.
    // Return empty <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> no market accounts resource.
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> market_account_ids;
    <b>let</b> custodians_map_ref = // Immutably borrow custodians map.
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).custodians;
    // Return empty <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> no market accounts for given market.
    <b>if</b> (!<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(custodians_map_ref, market_id))
        <b>return</b> market_account_ids;
    // Immutably borrow list of custodians for given market.
    <b>let</b> custodians_ref = <a href="tablist.md#0xc0deb00c_tablist_borrow">tablist::borrow</a>(custodians_map_ref, market_id);
    // Initialize <b>loop</b> counter and number of elements in <a href="">vector</a>.
    <b>let</b> (i, n_custodians) = (0, <a href="_length">vector::length</a>(custodians_ref));
    <b>while</b> (i &lt; n_custodians) { // Loop over all elements.
        // Get custodian ID.
        <b>let</b> custodian_id = *<a href="_borrow">vector::borrow</a>(custodians_ref, i);
        // Get market <a href="">account</a> ID.
        <b>let</b> market_account_id = ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) |
                                (custodian_id <b>as</b> u128);
        // Push back onto ongoing market <a href="">account</a> ID <a href="">vector</a>.
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> market_account_ids, market_account_id);
        i = i + 1; // Increment <b>loop</b> counter
    };
    market_account_ids // Return market <a href="">account</a> IDs.
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_custodian"></a>

## Function `get_asset_counts_custodian`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>()</code> for custodian.

Restricted to custodian for given market account to prevent
excessive public queries and thus transaction collisions.


<a name="@Testing_7"></a>

### Testing


* <code>test_deposits()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_custodian">get_asset_counts_custodian</a>(user_address: <b>address</b>, market_id: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_custodian">get_asset_counts_custodian</a>(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_capability_ref: &CustodianCapability
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(
        user_address, market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_user"></a>

## Function `get_asset_counts_user`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>()</code> for signing user.

Restricted to signing user for given market account to prevent
excessive public queries and thus transaction collisions.


<a name="@Testing_8"></a>

### Testing


* <code>test_deposits()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_user">get_asset_counts_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_user">get_asset_counts_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(address_of(<a href="user.md#0xc0deb00c_user">user</a>), market_id, <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_all_market_account_ids_for_user"></a>

## Function `get_all_market_account_ids_for_user`

Return all of a user's market account IDs.


<a name="@Parameters_9"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user to check market account IDs for.


<a name="@Returns_10"></a>

### Returns


* <code><a href="">vector</a>&lt;u128&gt;</code>: Vector of user's market account IDs, empty if
no market accounts.


<a name="@Gas_considerations_11"></a>

### Gas considerations


For each market that a user has market accounts for, loops over
a separate item in global storage, incurring a per-item read
cost. Additionally loops over a vector for each such per-item
read, incurring linearly-scaled vector operation costs. Returns
a vector via pass-by-value.


<a name="@Testing_12"></a>

### Testing


* <code>test_market_account_getters()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_all_market_account_ids_for_user">get_all_market_account_ids_for_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>): <a href="">vector</a>&lt;u128&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_all_market_account_ids_for_user">get_all_market_account_ids_for_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
): <a href="">vector</a>&lt;u128&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <b>let</b> market_account_ids = <a href="_empty">vector::empty</a>(); // Init empty <a href="">vector</a>.
    // Return empty <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> no market accounts resource.
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> market_account_ids;
    <b>let</b> custodians_map_ref = // Immutably borrow custodians map.
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).custodians;
    // Get market ID <a href="">option</a> at head of market ID list.
    <b>let</b> market_id_option = <a href="tablist.md#0xc0deb00c_tablist_get_head_key">tablist::get_head_key</a>(custodians_map_ref);
    // While market IDs left <b>to</b> <b>loop</b> over:
    <b>while</b> (<a href="_is_some">option::is_some</a>(&market_id_option)) {
        // Get market ID.
        <b>let</b> market_id = *<a href="_borrow">option::borrow</a>(&market_id_option);
        // Immutably borrow list of custodians for given market and
        // next market ID <a href="">option</a> in list.
        <b>let</b> (custodians_ref, _, next) = <a href="tablist.md#0xc0deb00c_tablist_borrow_iterable">tablist::borrow_iterable</a>(
            custodians_map_ref, market_id);
        // Initialize <b>loop</b> counter and number of elements in <a href="">vector</a>.
        <b>let</b> (i, n_custodians) = (0, <a href="_length">vector::length</a>(custodians_ref));
        <b>while</b> (i &lt; n_custodians) { // Loop over all elements.
            // Get custodian ID.
            <b>let</b> custodian_id = *<a href="_borrow">vector::borrow</a>(custodians_ref, i);
            <b>let</b> market_account_id = // Get market <a href="">account</a> ID.
                ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) |
                (custodian_id <b>as</b> u128);
            // Push back onto ongoing market <a href="">account</a> ID <a href="">vector</a>.
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> market_account_ids, market_account_id);
            i = i + 1; // Increment <b>loop</b> counter
        };
        // Review next market ID <a href="">option</a> in list.
        market_id_option = next;
    };
    market_account_ids // Return market <a href="">account</a> IDs.
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_custodian_id"></a>

## Function `get_custodian_id`

Return custodian ID encoded in market account ID.


<a name="@Testing_13"></a>

### Testing


* <code>test_market_account_id_getters()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_custodian_id">get_custodian_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_custodian_id">get_custodian_id</a>(
    market_account_id: u128
): u64 {
    ((market_account_id & (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)) <b>as</b> u64)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_market_account_id"></a>

## Function `get_market_account_id`

Return market account ID with encoded market and custodian IDs.


<a name="@Testing_14"></a>

### Testing


* <code>test_market_account_id_getters()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id: u64, custodian_id: u64): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(
    market_id: u64,
    custodian_id: u64
): u128 {
    ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) | (custodian_id <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_market_id"></a>

## Function `get_market_id`

Return market ID encoded in market account ID.


<a name="@Testing_15"></a>

### Testing


* <code>test_market_account_id_getters()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(
    market_account_id: u128
): u64 {
    (market_account_id &gt;&gt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a> <b>as</b> u64)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_has_market_account_by_market_account_id"></a>

## Function `has_market_account_by_market_account_id`

Return <code><b>true</b></code> if <code><a href="user.md#0xc0deb00c_user">user</a></code> has at market account registered with
given <code>market_account_id</code>.


<a name="@Testing_16"></a>

### Testing


* <code>test_market_account_getters()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_has_market_account_by_market_account_id">has_market_account_by_market_account_id</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_has_market_account_by_market_account_id">has_market_account_by_market_account_id</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128
): bool
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Return <b>false</b> <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> no market accounts resource.
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> <b>false</b>;
    // Immutably borrow market accounts map.
    <b>let</b> market_accounts_map =
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Return <b>if</b> map <b>has</b> entry for given market <a href="">account</a> ID.
    <a href="_contains">table::contains</a>(market_accounts_map, market_account_id)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_has_market_account_by_market_id"></a>

## Function `has_market_account_by_market_id`

Return <code><b>true</b></code> if <code><a href="user.md#0xc0deb00c_user">user</a></code> has at least one market account
registered with given <code>market_id</code>.


<a name="@Testing_17"></a>

### Testing


* <code>test_market_account_getters()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_has_market_account_by_market_id">has_market_account_by_market_id</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_has_market_account_by_market_id">has_market_account_by_market_id</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64
): bool
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Return <b>false</b> <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> no market accounts resource.
    <b>if</b> (!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> <b>false</b>;
    <b>let</b> custodians_map_ref = // Immutably borrow custodians map.
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).custodians;
    // Return <b>if</b> custodians map <b>has</b> entry for given market ID.
    <a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(custodians_map_ref, market_id)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_custodian"></a>

## Function `withdraw_coins_custodian`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code> for withdrawing under
authority of delegated custodian.


<a name="@Testing_18"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;CoinType&gt;(user_address: <b>address</b>, market_id: u64, amount: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;
    CoinType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    amount: u64,
    custodian_capability_ref: &CustodianCapability
): Coin&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="_destroy_some">option::destroy_some</a>(<a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        amount,
        <a href="user.md#0xc0deb00c_user_NO_UNDERWRITER">NO_UNDERWRITER</a>))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_user"></a>

## Function `withdraw_coins_user`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code> for withdrawing under
authority of signing user.


<a name="@Testing_19"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;
    CoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    amount: u64,
): Coin&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="_destroy_some">option::destroy_some</a>(<a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        amount,
        <a href="user.md#0xc0deb00c_user_NO_UNDERWRITER">NO_UNDERWRITER</a>))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_generic_asset_custodian"></a>

## Function `withdraw_generic_asset_custodian`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>()</code> for withdrawing under
authority of delegated custodian.


<a name="@Testing_20"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset_custodian">withdraw_generic_asset_custodian</a>(user_address: <b>address</b>, market_id: u64, amount: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset_custodian">withdraw_generic_asset_custodian</a>(
    user_address: <b>address</b>,
    market_id: u64,
    amount: u64,
    custodian_capability_ref: &CustodianCapability,
    underwriter_capability_ref: &UnderwriterCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        amount,
        underwriter_capability_ref)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_generic_asset_user"></a>

## Function `withdraw_generic_asset_user`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>()</code> for withdrawing under
authority of signing user.


<a name="@Testing_21"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset_user">withdraw_generic_asset_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, amount: u64, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset_user">withdraw_generic_asset_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    amount: u64,
    underwriter_capability_ref: &UnderwriterCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        amount,
        underwriter_capability_ref)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_from_coinstore"></a>

## Function `deposit_from_coinstore`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>()</code> for depositing from an
<code>aptos_framework::coin::CoinStore</code>.


<a name="@Testing_22"></a>

### Testing


* <code>test_deposits()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, custodian_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;
    CoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    custodian_id: u64,
    amount: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        custodian_id,
        <a href="_withdraw">coin::withdraw</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, amount));
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register market account for indicated market and custodian.


<a name="@Type_parameters_23"></a>

### Type parameters


* <code>BaseType</code>: Base type for indicated market. If base asset is
a generic asset, must be passed as <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>
(alternatively use <code>register_market_account_base_generic()</code>).
* <code>QuoteType</code>: Quote type for indicated market.


<a name="@Parameters_24"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>market_id</code>: Market ID for given market.
* <code>custodian_id</code>: Custodian ID to register account with, or
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>.


<a name="@Aborts_25"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN">E_UNREGISTERED_CUSTODIAN</a></code>: Custodian ID has not been
registered.


<a name="@Testing_26"></a>

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


<a name="@Testing_27"></a>

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

<a name="0xc0deb00c_user_withdraw_to_coinstore"></a>

## Function `withdraw_to_coinstore`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>()</code> for withdrawing from
market account to user's <code>aptos_framework::coin::CoinStore</code>.


<a name="@Testing_28"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;
    CoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    amount: u64,
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Register <a href="">coin</a> store <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> does not have one.
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;CoinType&gt;(address_of(<a href="user.md#0xc0deb00c_user">user</a>)))
        <a href="_register">coin::register</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>);
    // Deposit <b>to</b> <a href="">coin</a> store coins withdrawn from market <a href="">account</a>.
    <a href="_deposit">coin::deposit</a>&lt;CoinType&gt;(address_of(<a href="user.md#0xc0deb00c_user">user</a>), <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, amount));
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_internal"></a>

## Function `get_asset_counts_internal`

Return asset counts for specified market account.


<a name="@Parameters_29"></a>

### Parameters


* <code>user_address</code>: User address for market account.
* <code>market_id</code>: Market ID for market account.
* <code>custodian_id</code>: Custodian ID for market account.


<a name="@Returns_30"></a>

### Returns


* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_total</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_available</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_ceiling</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_total</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_available</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_ceiling</code>


<a name="@Aborts_31"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a></code>: No market accounts resource found.
* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a></code>: No market account resource found.


<a name="@Testing_32"></a>

### Testing


* <code>test_deposits()</code>
* <code>test_get_asset_counts_internal_no_account()</code>
* <code>test_get_asset_counts_internal_no_accounts()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(user_address: <b>address</b>, market_id: u64, custodian_id: u64): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market accounts resource.
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Immutably borrow market accounts map.
    <b>let</b> market_accounts_map_ref =
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    <b>let</b> market_account_id = // Get market <a href="">account</a> ID.
        ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) | (custodian_id <b>as</b> u128);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market <a href="">account</a> for given ID.
    <b>assert</b>!(<a href="_contains">table::contains</a>(market_accounts_map_ref, market_account_id),
            <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    <b>let</b> market_account_ref = // Immutably borrow market <a href="">account</a>.
        <a href="_borrow">table::borrow</a>(market_accounts_map_ref, market_account_id);
    (market_account_ref.base_total,
     market_account_ref.base_available,
     market_account_ref.base_ceiling,
     market_account_ref.quote_total,
     market_account_ref.quote_available,
     market_account_ref.quote_ceiling) // Return asset count fields.
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_asset"></a>

## Function `deposit_asset`

Deposit an asset to a user's market account.

Update asset counts, deposit optional coins as collateral.


<a name="@Type_parameters_33"></a>

### Type parameters


* <code>AssetType</code>: Asset type to deposit, <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>
if a generic asset.


<a name="@Parameters_34"></a>

### Parameters


* <code>user_address</code>: User address for market account.
* <code>market_id</code>: Market ID for market account.
* <code>custodian_id</code>: Custodian ID for market account.
* <code>amount</code>: Amount to deposit.
* <code>optional_coins</code>: Optional coins to deposit.
* <code>underwriter_id</code>: Underwriter ID for market, ignored when
depositing coins.


<a name="@Aborts_35"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a></code>: No market accounts resource found.
* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a></code>: No market account resource found.
* <code><a href="user.md#0xc0deb00c_user_E_ASSET_NOT_IN_PAIR">E_ASSET_NOT_IN_PAIR</a></code>: Asset type is not in trading pair for
market.
* <code><a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a></code>: Deposit would overflow
asset ceiling.
* <code><a href="user.md#0xc0deb00c_user_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a></code>: Underwriter is not valid for
indicated market, in the case of a generic asset deposit.


<a name="@Assumptions_36"></a>

### Assumptions


* If optional coins provided, their value equals <code>amount</code>.
* When depositing coins, if a market account exists, then so
does a corresponding collateral map entry.


<a name="@Testing_37"></a>

### Testing


* <code>test_deposit_asset_no_account()</code>
* <code>test_deposit_asset_no_accounts()</code>
* <code>test_deposit_asset_not_in_pair()</code>
* <code>test_deposit_asset_overflow()</code>
* <code>test_deposit_asset_underwriter()</code>
* <code>test_deposits()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, amount: u64, optional_coins: <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;, underwriter_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;
    AssetType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
    optional_coins: Option&lt;Coin&lt;AssetType&gt;&gt;,
    underwriter_id: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market accounts resource.
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Mutably borrow market accounts map.
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    <b>let</b> market_account_id = // Get market <a href="">account</a> ID.
        ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) | (custodian_id <b>as</b> u128);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market <a href="">account</a> for given ID.
    <b>assert</b>!(<a href="_contains">table::contains</a>(market_accounts_map_ref_mut, market_account_id),
            <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    <b>let</b> market_account_ref_mut = // Mutably borrow market <a href="">account</a>.
        <a href="_borrow_mut">table::borrow_mut</a>(market_accounts_map_ref_mut, market_account_id);
    // Get asset type info.
    <b>let</b> asset_type = <a href="_type_of">type_info::type_of</a>&lt;AssetType&gt;();
    // Get asset total, available, and ceiling amounts based on <b>if</b>
    // asset is base or quote for trading pair, aborting <b>if</b> neither.
    <b>let</b> (total_ref_mut, available_ref_mut, ceiling_ref_mut) =
        <b>if</b> (asset_type == market_account_ref_mut.base_type) (
            &<b>mut</b> market_account_ref_mut.base_total,
            &<b>mut</b> market_account_ref_mut.base_available,
            &<b>mut</b> market_account_ref_mut.base_ceiling
        ) <b>else</b> <b>if</b> (asset_type == market_account_ref_mut.quote_type) (
            &<b>mut</b> market_account_ref_mut.quote_total,
            &<b>mut</b> market_account_ref_mut.quote_available,
            &<b>mut</b> market_account_ref_mut.quote_ceiling
        ) <b>else</b> <b>abort</b> <a href="user.md#0xc0deb00c_user_E_ASSET_NOT_IN_PAIR">E_ASSET_NOT_IN_PAIR</a>;
    <b>assert</b>!( // Assert deposit does not overflow asset ceiling.
        ((*ceiling_ref_mut <b>as</b> u128) + (amount <b>as</b> u128)) &lt;= (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128),
        <a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a>);
    *total_ref_mut = *total_ref_mut + amount; // Update total.
    // Update available asset amount.
    *available_ref_mut = *available_ref_mut + amount;
    *ceiling_ref_mut = *ceiling_ref_mut + amount; // Update ceiling.
    // If asset is generic:
    <b>if</b> (asset_type == <a href="_type_of">type_info::type_of</a>&lt;GenericAsset&gt;()) {
        <b>assert</b>!(underwriter_id == market_account_ref_mut.underwriter_id,
                <a href="user.md#0xc0deb00c_user_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a>); // Assert underwriter ID.
        <a href="_destroy_none">option::destroy_none</a>(optional_coins); // Destroy <a href="">option</a>.
    } <b>else</b> { // If asset is <a href="">coin</a>:
        // Mutably borrow collateral map.
        <b>let</b> collateral_map_ref_mut = &<b>mut</b> <b>borrow_global_mut</b>&lt;
            <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;AssetType&gt;&gt;(user_address).map;
        // Mutably borrow collateral for market <a href="">account</a>.
        <b>let</b> collateral_ref_mut = <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(
            collateral_map_ref_mut, market_account_id);
        <a href="_merge">coin::merge</a>( // Merge optional coins into collateral.
            collateral_ref_mut, <a href="_destroy_some">option::destroy_some</a>(optional_coins));
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account_account_entries"></a>

## Function `register_market_account_account_entries`

Register market account entries for given market account info.

Inner function for <code><a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>()</code>.


<a name="@Type_parameters_38"></a>

### Type parameters


* <code>BaseType</code>: Base type for indicated market.
* <code>QuoteType</code>: Quote type for indicated market.


<a name="@Parameters_39"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>user_address</code>: Address of user registering a market account.
* <code>market_account_id</code>: Market account ID for given market.
* <code>market_id</code>: Market ID for given market.
* <code>custodian_id</code>: Custodian ID to register account with, or
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>.


<a name="@Aborts_40"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a></code>: Market account already exists.


<a name="@Testing_41"></a>

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


<a name="@Type_parameters_42"></a>

### Type parameters


* <code>CoinType</code>: Phantom coin type for indicated market.


<a name="@Parameters_43"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: User registering a market account.
* <code>user_address</code>: Address of user registering a market account.
* <code>market_account_id</code>: Market account ID for given market.


<a name="@Testing_44"></a>

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

<a name="0xc0deb00c_user_withdraw_asset"></a>

## Function `withdraw_asset`

Withdraw an asset from a user's market account.

Update asset counts, withdraw optional coins as collateral.


<a name="@Type_parameters_45"></a>

### Type parameters


* <code>AssetType</code>: Asset type to withdraw, <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>
if a generic asset.


<a name="@Parameters_46"></a>

### Parameters


* <code>user_address</code>: User address for market account.
* <code>market_id</code>: Market ID for market account.
* <code>custodian_id</code>: Custodian ID for market account.
* <code>amount</code>: Amount to withdraw.
* <code>underwriter_id</code>: Underwriter ID for market, ignored when
withdrawing coins.


<a name="@Returns_47"></a>

### Returns


* <code>Option&lt;Coin&lt;AssetType&gt;&gt;</code>: Optional coins as collateral.


<a name="@Aborts_48"></a>

### Aborts


* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a></code>: No market accounts resource found.
* <code><a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a></code>: No market account resource found.
* <code><a href="user.md#0xc0deb00c_user_E_ASSET_NOT_IN_PAIR">E_ASSET_NOT_IN_PAIR</a></code>: Asset type is not in trading pair for
market.
* <code><a href="user.md#0xc0deb00c_user_E_WITHDRAW_TOO_LITTLE_AVAILABLE">E_WITHDRAW_TOO_LITTLE_AVAILABLE</a></code>: Too little available for
withdrawal.
* <code><a href="user.md#0xc0deb00c_user_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a></code>: Underwriter is not valid for
indicated market, in the case of a generic asset withdrawal.


<a name="@Testing_49"></a>

### Testing


* <code>test_withdraw_asset_no_account()</code>
* <code>test_withdraw_asset_no_accounts()</code>
* <code>test_withdraw_asset_not_in_pair()</code>
* <code>test_withdraw_asset_underflow()</code>
* <code>test_withdraw_asset_underwriter()</code>
* <code>test_withdrawals()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, amount: u64, underwriter_id: u64): <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;
    AssetType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
    underwriter_id: u64
): Option&lt;Coin&lt;AssetType&gt;&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market accounts resource.
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Mutably borrow market accounts map.
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    <b>let</b> market_account_id = // Get market <a href="">account</a> ID.
        ((market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_SHIFT_MARKET_ID">SHIFT_MARKET_ID</a>) | (custodian_id <b>as</b> u128);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> market <a href="">account</a> for given ID.
    <b>assert</b>!(<a href="_contains">table::contains</a>(market_accounts_map_ref_mut, market_account_id),
            <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    <b>let</b> market_account_ref_mut = // Mutably borrow market <a href="">account</a>.
        <a href="_borrow_mut">table::borrow_mut</a>(market_accounts_map_ref_mut, market_account_id);
    // Get asset type info.
    <b>let</b> asset_type = <a href="_type_of">type_info::type_of</a>&lt;AssetType&gt;();
    // Get asset total, available, and ceiling amounts based on <b>if</b>
    // asset is base or quote for trading pair, aborting <b>if</b> neither.
    <b>let</b> (total_ref_mut, available_ref_mut, ceiling_ref_mut) =
        <b>if</b> (asset_type == market_account_ref_mut.base_type) (
            &<b>mut</b> market_account_ref_mut.base_total,
            &<b>mut</b> market_account_ref_mut.base_available,
            &<b>mut</b> market_account_ref_mut.base_ceiling
        ) <b>else</b> <b>if</b> (asset_type == market_account_ref_mut.quote_type) (
            &<b>mut</b> market_account_ref_mut.quote_total,
            &<b>mut</b> market_account_ref_mut.quote_available,
            &<b>mut</b> market_account_ref_mut.quote_ceiling
        ) <b>else</b> <b>abort</b> <a href="user.md#0xc0deb00c_user_E_ASSET_NOT_IN_PAIR">E_ASSET_NOT_IN_PAIR</a>;
    // Assert enough asset available for withdraw.
    <b>assert</b>!(amount &lt;= *available_ref_mut, <a href="user.md#0xc0deb00c_user_E_WITHDRAW_TOO_LITTLE_AVAILABLE">E_WITHDRAW_TOO_LITTLE_AVAILABLE</a>);
    *total_ref_mut = *total_ref_mut - amount; // Update total.
    // Update available asset amount.
    *available_ref_mut = *available_ref_mut - amount;
    *ceiling_ref_mut = *ceiling_ref_mut - amount; // Update ceiling.
    // Return based on <b>if</b> asset type. If is generic:
    <b>return</b> <b>if</b> (asset_type == <a href="_type_of">type_info::type_of</a>&lt;GenericAsset&gt;()) {
        <b>assert</b>!(underwriter_id == market_account_ref_mut.underwriter_id,
                <a href="user.md#0xc0deb00c_user_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a>); // Assert underwriter ID.
        <a href="_none">option::none</a>() // Return empty <a href="">option</a>.
    } <b>else</b> { // If asset is <a href="">coin</a>:
        // Mutably borrow collateral map.
        <b>let</b> collateral_map_ref_mut = &<b>mut</b> <b>borrow_global_mut</b>&lt;
            <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;AssetType&gt;&gt;(user_address).map;
        // Mutably borrow collateral for market <a href="">account</a>.
        <b>let</b> collateral_ref_mut = <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(
            collateral_map_ref_mut, market_account_id);
        // Withdraw <a href="">coin</a> and <b>return</b> in an <a href="">option</a>.
        <a href="_some">option::some</a>&lt;Coin&lt;AssetType&gt;&gt;(
            <a href="_extract">coin::extract</a>(collateral_ref_mut, amount))
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_generic_asset"></a>

## Function `withdraw_generic_asset`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>()</code> for withdrawing generic
asset.


<a name="@Testing_50"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>(user_address: <b>address</b>, market_id: u64, custodian_id: u64, amount: u64, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
    underwriter_capability_ref: &UnderwriterCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="_destroy_none">option::destroy_none</a>(<a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;GenericAsset&gt;(
        user_address,
        market_id,
        custodian_id,
        amount,
        <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">registry::get_underwriter_id</a>(underwriter_capability_ref)))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins"></a>

## Function `withdraw_coins`

Wrapped call to <code><a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>()</code> for withdrawing coins.


<a name="@Testing_51"></a>

### Testing


* <code>test_withdrawals()</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;
    CoinType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
): Coin&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="_destroy_some">option::destroy_some</a>(<a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(
        user_address,
        market_id,
        custodian_id,
        amount,
        <a href="user.md#0xc0deb00c_user_NO_UNDERWRITER">NO_UNDERWRITER</a>))
}
</code></pre>



</details>
