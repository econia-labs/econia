
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side book keeping and, optionally, collateral management.

For a given market, a user can register multiple <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s,
with each such market account having a different delegated custodian
ID and therefore a unique <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>: hence, each market
account has a particular "user-specific" custodian ID. For a given
<code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>, a user has entries in a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map for each
asset that is a coin type.

For assets that are not a coin type, the "market-wide" custodian
(<code><a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a></code>) is required to verify
deposits and withdrawals. Hence a user-specific custodian ID
overrides a market-wide custodian ID when placing or cancelling
trades on an asset-agnostic market, whereas the market-wide
custodian ID overrides the user-specific custodian ID when
depositing or withdrawing a non-coin asset.


-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Struct `MarketAccountInfo`](#0xc0deb00c_user_MarketAccountInfo)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Constants](#@Constants_0)
-  [Function `invoke_registry`](#0xc0deb00c_user_invoke_registry)
-  [Function `return_0`](#0xc0deb00c_user_return_0)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
    -  [Abort conditions](#@Abort_conditions_3)
-  [Function `borrow_asset_counts_mut`](#0xc0deb00c_user_borrow_asset_counts_mut)
    -  [Assumes](#@Assumes_4)
    -  [Abort conditions](#@Abort_conditions_5)
-  [Function `register_collateral_entry`](#0xc0deb00c_user_register_collateral_entry)
    -  [Abort conditions](#@Abort_conditions_6)
-  [Function `register_market_accounts_entry`](#0xc0deb00c_user_register_market_accounts_entry)
    -  [Abort conditions](#@Abort_conditions_7)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
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

<a name="0xc0deb00c_user_MarketAccount"></a>

## Struct `MarketAccount`

Represents a user's open orders and available assets for a given
<code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a> <b>has</b> store
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
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to <code>GenericAsset</code>, or
 a non-coin asset indicated by the market host.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to <code>GenericAsset</code>, or
 a non-coin asset indicated by the market host.
</dd>
<dt>
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;u64&gt;</code>
</dt>
<dd>
 Map from order ID to size of outstanding order, measured in
 lots lefts to fill
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;u64&gt;</code>
</dt>
<dd>
 Map from order ID to size of outstanding order, measured in
 lots lefts to fill
</dd>
<dt>
<code>base_total: u64</code>
</dt>
<dd>
 Total base asset units held as collateral
</dd>
<dt>
<code>base_available: u64</code>
</dt>
<dd>
 Base asset units available for withdraw
</dd>
<dt>
<code>quote_total: u64</code>
</dt>
<dd>
 Total quote asset units held as collateral
</dd>
<dt>
<code>quote_available: u64</code>
</dt>
<dd>
 Quote asset units available for withdraw
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccountInfo"></a>

## Struct `MarketAccountInfo`

Unique ID for a user's market account


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_id: u64</code>
</dt>
<dd>
 Serial ID of the market that a user is trading on
</dd>
<dt>
<code>user_level_custodian_id: u64</code>
</dt>
<dd>
 Serial ID of registered account custodian, set to
 <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code> when given account does not have an
 authorized user-level custodian. Otherwise corresponding
 custodian capability required to place trades and, in the
 case of a pure coin market, to withdraw/deposit collateral.
 For an asset-agnostic market, is overridden by
 <code>market_level_custodian_id</code> when depositing or withdrawing a
 non-coin asset, since the market-level custodian is required
 to verify deposit and withdraw amounts. Can be the same as
 <code>market_level_custodian_id</code>.
</dd>
<dt>
<code>market_level_custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to withdraw/deposit
 collateral for an asset that is not a coin. A "market-wide"
 collateral transfer custodian ID, required to verify deposit
 and withdraw amounts for asset-agnostic markets. Marked as
 <code><a href="user.md#0xc0deb00c_user_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and quote types are both coins.
 Otherwise overrides the <code>user_level_custodian_id</code> for
 deposits and withdrawals only. Can be the same as
 <code>market_level_custodian_id</code>.
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


<a name="0xc0deb00c_user_E_NOT_IN_MARKET_PAIR"></a>

When indicated asset is not in the market pair


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_PURE_COIN_PAIR"></a>

When both base and quote assets are coins


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_PURE_COIN_PAIR">PURE_COIN_PAIR</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

When market account already exists for given market account info


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_user_E_INVALID_CUSTODIAN_ID"></a>

When the passed custodian ID is invalid


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_INVALID_CUSTODIAN_ID">E_INVALID_CUSTODIAN_ID</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_invoke_registry"></a>

## Function `invoke_registry`



<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_invoke_registry">invoke_registry</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_invoke_registry">invoke_registry</a>() {<a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(0);}
</code></pre>



</details>

<a name="0xc0deb00c_user_return_0"></a>

## Function `return_0`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8 {0}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register user with a market account


<a name="@Type_parameters_1"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_2"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Signing user
* <code>market_id</code>: Serial ID of corresonding market
* <code>user_level_custodian_id</code>: Serial ID of custodian capability
required for user-level authorization, set to <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>
if signing user required for authorization on market account


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If market is not already registered
* If invalid <code>custodian_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, user_level_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    user_level_custodian_id: u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Get <a href="market.md#0xc0deb00c_market">market</a>-level custodian ID for verified <a href="market.md#0xc0deb00c_market">market</a>
    <b>let</b> market_level_custodian_id = registry::
        get_verified_market_custodian_id&lt;BaseType, QuoteType&gt;(market_id);
    // If <a href="user.md#0xc0deb00c_user">user</a>-level custodian ID indicated, <b>assert</b> it is registered
    <b>if</b> (user_level_custodian_id != <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>) <b>assert</b>!(
        <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(user_level_custodian_id),
        <a href="user.md#0xc0deb00c_user_E_INVALID_CUSTODIAN_ID">E_INVALID_CUSTODIAN_ID</a>);
    // Pack corresonding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id,
        user_level_custodian_id, market_level_custodian_id};
    // Register entry in <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // If base asset is <a href="">coin</a>, register collateral entry
    <b>if</b> (<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;())
        <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;BaseType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // If quote asset is <a href="">coin</a>, register collateral entry
    <b>if</b> (<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteType&gt;())
        <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_borrow_asset_counts_mut"></a>

## Function `borrow_asset_counts_mut`

Look up the <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> in <code>market_accounts_map</code> having
<code>market_account_info</code>, then return a mutable reference to the
amount of <code>AssetType</code> holdings, and a mutable reference to the
reference to the amount of <code>AssetType</code> available for withdraw.


<a name="@Assumes_4"></a>

### Assumes

* <code>market_accounts_map</code> has an entry with <code>market_account_info</code>


<a name="@Abort_conditions_5"></a>

### Abort conditions

* If <code>AssetType</code> is neither base nor quote for given market
account


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(market_accounts_map: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>): (&<b>mut</b> u64, &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(
    market_accounts_map:
        &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>&gt;,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>
): (
    &<b>mut</b> u64,
    &<b>mut</b> u64
) {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts_map, market_account_info);
    // Get asset type info
    <b>let</b> asset_type_info = <a href="_type_of">type_info::type_of</a>&lt;AssetType&gt;();
    // If is base asset, <b>return</b> mutable references <b>to</b> base fields
    <b>if</b> (asset_type_info == market_account.base_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account.base_total,
            &<b>mut</b> market_account.base_available
        )
    // If is quote asset, <b>return</b> mutable references <b>to</b> quote fields
    } <b>else</b> <b>if</b> (asset_type_info == market_account.quote_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account.quote_total,
            &<b>mut</b> market_account.quote_available
        )
    }; // Otherwise <b>abort</b>
    <b>abort</b> <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
and <code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist.


<a name="@Abort_conditions_6"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;
    CoinType
&gt;(
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
    // Borrow mutable reference <b>to</b> collateral map
    <b>let</b> collateral_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(collateral_map_ref_mut,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(collateral_map_ref_mut, market_account_info,
        <a href="_zero">coin::zero</a>&lt;CoinType&gt;());
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_accounts_entry"></a>

## Function `register_market_accounts_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> map entry for given
<code>BaseType</code>, <code>QuoteType</code>, and <code>market_account_info</code>, initializing
<code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> if it does not already exist


<a name="@Abort_conditions_7"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;
    BaseType,
    QuoteType
&gt;(
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
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map_ref_mut,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(market_accounts_map_ref_mut, market_account_info,
        <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
            base_type_info: <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(),
            quote_type_info: <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(),
            asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
            bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
            base_total: 0,
            base_available: 0,
            quote_total: 0,
            quote_available: 0
    });
}
</code></pre>



</details>
