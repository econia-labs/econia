
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
-  [Function `deposit_collateral`](#0xc0deb00c_user_deposit_collateral)
    -  [Abort conditions](#@Abort_conditions_2)
-  [Function `market_account_info`](#0xc0deb00c_user_market_account_info)
-  [Function `withdraw_collateral_custodian`](#0xc0deb00c_user_withdraw_collateral_custodian)
-  [Function `borrow_coins_available_mut`](#0xc0deb00c_user_borrow_coins_available_mut)
    -  [Abort conditions](#@Abort_conditions_3)
    -  [Assumes](#@Assumes_4)
-  [Function `exists_market_account`](#0xc0deb00c_user_exists_market_account)
-  [Function `register_collateral_entry`](#0xc0deb00c_user_register_collateral_entry)
    -  [Abort conditions](#@Abort_conditions_5)
-  [Function `register_market_accounts_entry`](#0xc0deb00c_user_register_market_accounts_entry)
    -  [Abort conditions](#@Abort_conditions_6)
-  [Function `withdraw_collateral_internal`](#0xc0deb00c_user_withdraw_collateral_internal)
    -  [Abort conditions](#@Abort_conditions_7)


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
<code>base_coins_available: u64</code>
</dt>
<dd>
 Base coins available for withdraw
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


<a name="0xc0deb00c_user_E_CUSTODIAN_OVERRIDE"></a>

When user attempts invalid custodian override


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>: u64 = 7;
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


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET"></a>

When no such market has been registered


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET">E_NO_MARKET</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNT"></a>

When a market account is not registered


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_user_E_NO_TRANSFER_AMOUNT"></a>

When a collateral transfer does not have specified amount


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_TRANSFER_AMOUNT">E_NO_TRANSFER_AMOUNT</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN"></a>

When unauthorized custodian ID


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> and <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entries
for given market and <code>custodian_id</code>.


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
    <b>let</b> market_account_info = // Pack <a href="market.md#0xc0deb00c_market">market</a> account info
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
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> account
    <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_collateral"></a>

## Function `deposit_collateral`

Deposit <code><a href="coins.md#0xc0deb00c_coins">coins</a></code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> for given
<code>market_account_info</code>.


<a name="@Abort_conditions_2"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote for market account
* If <code><a href="coins.md#0xc0deb00c_coins">coins</a></code> has a value of 0
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have corresponding market account
registered


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_collateral">deposit_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_collateral">deposit_collateral</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    <a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert attempting <b>to</b> actually deposit <a href="coins.md#0xc0deb00c_coins">coins</a>
    <b>assert</b>!(<a href="_value">coin::value</a>(&<a href="coins.md#0xc0deb00c_coins">coins</a>) != 0, <a href="user.md#0xc0deb00c_user_E_NO_TRANSFER_AMOUNT">E_NO_TRANSFER_AMOUNT</a>);
    // Assert <a href="market.md#0xc0deb00c_market">market</a> account registered for <a href="market.md#0xc0deb00c_market">market</a> account info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> available <a href="">coin</a> count (aborts <b>if</b>
    // <a href="">coin</a> type is neither base nor quote for given <a href="market.md#0xc0deb00c_market">market</a> account)
    <b>let</b> coins_available_ref_mut = <a href="user.md#0xc0deb00c_user_borrow_coins_available_mut">borrow_coins_available_mut</a>&lt;CoinType&gt;(
        market_accounts_map, market_account_info);
    *coins_available_ref_mut = // Increment available <a href="">coin</a> count
        *coins_available_ref_mut + <a href="_value">coin::value</a>(&<a href="coins.md#0xc0deb00c_coins">coins</a>);
    // Borrow mutable reference <b>to</b> collateral map
    <b>let</b> collateral_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> account
    <b>let</b> collateral =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map, market_account_info);
    // Merge <a href="coins.md#0xc0deb00c_coins">coins</a> into <a href="market.md#0xc0deb00c_market">market</a> account collateral
    <a href="_merge">coin::merge</a>(collateral, <a href="coins.md#0xc0deb00c_coins">coins</a>);
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

<a name="0xc0deb00c_user_withdraw_collateral_custodian"></a>

## Function `withdraw_collateral_custodian`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.
Requires a reference to a <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code> for
authorization, and aborts if custodian serial ID does not
correspond to that specified in <code>market_account_info</code>.


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_custodian">withdraw_collateral_custodian</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64, custodian_capability: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_custodian">withdraw_collateral_custodian</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
    custodian_capability: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert serial custodian ID from <a href="capability.md#0xc0deb00c_capability">capability</a> matches ID from
    // <a href="market.md#0xc0deb00c_market">market</a> account info
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability) ==
        market_account_info.custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> account
    <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_borrow_coins_available_mut"></a>

## Function `borrow_coins_available_mut`

Look up the <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> in <code>market_accounts_map</code> having
<code>market_account_info</code>, then return a mutable reference to the
number of available coins of <code>CoinType</code>.


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote coin in
<code>market_account_info</code>.


<a name="@Assumes_4"></a>

### Assumes

* <code>market_accounts_map</code> has an entry with <code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_coins_available_mut">borrow_coins_available_mut</a>&lt;CoinType&gt;(market_accounts_map: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>): &<b>mut</b> u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_coins_available_mut">borrow_coins_available_mut</a>&lt;CoinType&gt;(
    market_accounts_map:
        &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>&gt;,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>
): &<b>mut</b> u64 {
    // Determine <b>if</b> <a href="">coin</a> is base <a href="">coin</a> for <a href="market.md#0xc0deb00c_market">market</a> (aborts <b>if</b> is
    // neither base nor quote
    <b>let</b> is_base_coin = <a href="registry.md#0xc0deb00c_registry_coin_is_base_coin">registry::coin_is_base_coin</a>&lt;CoinType&gt;(
        &market_account_info.market_info);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> account
    <b>let</b> market_account =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts_map, market_account_info);
    // If is base <a href="">coin</a>, <b>return</b> mutable ref <b>to</b> base <a href="coins.md#0xc0deb00c_coins">coins</a> available
    (<b>if</b> (is_base_coin) &<b>mut</b> market_account.base_coins_available <b>else</b>
        &<b>mut</b> market_account.quote_coins_available) // Else quote
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
    // Return <b>if</b> <a href="market.md#0xc0deb00c_market">market</a> account is registered in <a href="">table</a>
    <a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map, market_account_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
and <code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist.


<a name="@Abort_conditions_5"></a>

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
        // Pack an empty one and <b>move</b> <b>to</b> their account
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    <b>let</b> map = // Borrow mutable reference <b>to</b> collateral map
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> account info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(map,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> account info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(map, market_account_info, <a href="_zero">coin::zero</a>&lt;CoinType&gt;());
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_accounts_entry"></a>

## Function `register_market_accounts_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> map entry corresponding to
<code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> if it does
not already exist


<a name="@Abort_conditions_6"></a>

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
        // Pack an empty one and <b>move</b> it <b>to</b> their account
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> map = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(user_address).map;
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> account info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(map, market_account_info),
        <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Get scale factor for corresponding <a href="market.md#0xc0deb00c_market">market</a>
    <b>let</b> scale_factor = <a href="registry.md#0xc0deb00c_registry_scale_factor_from_market_info">registry::scale_factor_from_market_info</a>(
        &market_account_info.market_info);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> account info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(map, market_account_info, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
        scale_factor,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        base_coins_available: 0,
        quote_coins_available: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_internal"></a>

## Function `withdraw_collateral_internal`

Withdraw <code>amount</code> of <code>Coin</code> having <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code>
entry corresponding to <code>market_account_info</code>, then return it.


<a name="@Abort_conditions_7"></a>

### Abort conditions

* If <code>CoinType</code> is neither base nor quote for market account
* If <code><a href="coins.md#0xc0deb00c_coins">coins</a></code> has a value of 0
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have corresponding market account
registered
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> has insufficient collateral to withdraw


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert attempting <b>to</b> actually withdraw <a href="coins.md#0xc0deb00c_coins">coins</a>
    <b>assert</b>!(amount != 0, <a href="user.md#0xc0deb00c_user_E_NO_TRANSFER_AMOUNT">E_NO_TRANSFER_AMOUNT</a>);
    // Assert <a href="market.md#0xc0deb00c_market">market</a> account registered for <a href="market.md#0xc0deb00c_market">market</a> account info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> available <a href="">coin</a> count (aborts <b>if</b>
    // <a href="">coin</a> type is neither base nor quote for given <a href="market.md#0xc0deb00c_market">market</a> account)
    <b>let</b> coins_available_ref_mut = <a href="user.md#0xc0deb00c_user_borrow_coins_available_mut">borrow_coins_available_mut</a>&lt;CoinType&gt;(
        market_accounts_map, market_account_info);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough available collateral <b>to</b> withdraw
    <b>assert</b>!(amount &lt;= *coins_available_ref_mut, <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
    // Decrement withdrawn amount from available <a href="">coin</a> count
    *coins_available_ref_mut = *coins_available_ref_mut - amount;
    // Borrow mutable reference <b>to</b> collateral map
    <b>let</b> collateral_map =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> account
    <b>let</b> collateral =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map, market_account_info);
    // Extract collateral from <a href="market.md#0xc0deb00c_market">market</a> account and <b>return</b>
    <a href="_extract">coin::extract</a>(collateral, amount)
}
</code></pre>



</details>
