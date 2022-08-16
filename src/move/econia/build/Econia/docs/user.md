
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
-  [Function `add_market_account`](#0xc0deb00c_user_add_market_account)
    -  [Abort conditions](#@Abort_conditions_1)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
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

Unique ID describing a market and a user-specific custodian


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


<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

When market account already exists for given market account info


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_user_add_market_account"></a>

## Function `add_market_account`

Register user with a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> map entry corresponding to
<code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> if it does
not already exist


<a name="@Abort_conditions_1"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_add_market_account">add_market_account</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_add_market_account">add_market_account</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <b>address</b>
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a market accounts map initialized
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address)) {
        // Pack an empty one and <b>move</b> it <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    // Borrow mutable reference <b>to</b> market accounts map
    <b>let</b> map = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given market <a href="">account</a> info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(map, market_account_info),
        <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given market <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(map, market_account_info, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
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
