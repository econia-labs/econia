
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side collateral and book keeping management. For a given
market, a user can register multiple "market accounts", with each
such market account having a different delegated custodian and a
unique <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>. For a given market account, a user has
entries in both <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> and <code><a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a></code>.


-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccountInfo`](#0xc0deb00c_user_MarketAccountInfo)
-  [Struct `MarketAccountCollateral`](#0xc0deb00c_user_MarketAccountCollateral)
-  [Struct `MarketAccountOpenOrders`](#0xc0deb00c_user_MarketAccountOpenOrders)
-  [Resource `OpenOrders`](#0xc0deb00c_user_OpenOrders)
-  [Constants](#@Constants_0)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Abort conditions](#@Abort_conditions_1)
-  [Function `withdraw_collateral_user`](#0xc0deb00c_user_withdraw_collateral_user)
-  [Function `deposit_collateral`](#0xc0deb00c_user_deposit_collateral)
    -  [Abort conditions](#@Abort_conditions_2)
-  [Function `market_account_info`](#0xc0deb00c_user_market_account_info)
-  [Function `withdraw_collateral_custodian`](#0xc0deb00c_user_withdraw_collateral_custodian)
-  [Function `exists_market_account`](#0xc0deb00c_user_exists_market_account)
-  [Function `register_collateral`](#0xc0deb00c_user_register_collateral)
    -  [Abort conditions](#@Abort_conditions_3)
-  [Function `register_open_orders`](#0xc0deb00c_user_register_open_orders)
    -  [Abort conditions](#@Abort_conditions_4)
-  [Function `withdraw_collateral_internal`](#0xc0deb00c_user_withdraw_collateral_internal)
    -  [Abort conditions](#@Abort_conditions_5)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
</code></pre>



<a name="0xc0deb00c_user_Collateral"></a>

## Resource `Collateral`

All collateral for a given coin type, across all
<code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>s for a given user


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_accounts: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccountCollateral">user::MarketAccountCollateral</a>&lt;CoinType&gt;&gt;</code>
</dt>
<dd>
 Map from <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code> to coins held as collateral on
 given market account. Separated into different table entries
 to prevent transaction collisions across markets
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

<a name="0xc0deb00c_user_MarketAccountCollateral"></a>

## Struct `MarketAccountCollateral`

Collateral for a given <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccountCollateral">MarketAccountCollateral</a>&lt;CoinType&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>
 Coins held as collateral
</dd>
<dt>
<code>coins_available: u64</code>
</dt>
<dd>
 Coins available to withdraw
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccountOpenOrders"></a>

## Struct `MarketAccountOpenOrders`

Open orders for a given <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccountOpenOrders">MarketAccountOpenOrders</a> <b>has</b> store
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
</dl>


</details>

<a name="0xc0deb00c_user_OpenOrders"></a>

## Resource `OpenOrders`

All open orders across all <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>s for a given user


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_accounts: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccountOpenOrders">user::MarketAccountOpenOrders</a>&gt;</code>
</dt>
<dd>
 Map from <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code> to open orders on given market
 account. Separated into different table entries to prevent
 transaction collisions across markets
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_user_E_CUSTODIAN_OVERRIDE"></a>

When user attempts invalid custodian override


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>: u64 = 8;
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


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_E_NOT_IN_MARKET_PAIR"></a>

When specified coin type does not correspond to the trading pair
for a given market


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>: u64 = 5;
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


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with a market account for given market and
<code>custodian_id</code>


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
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Assert the market <b>has</b> alrady been registered
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_registered_types">registry::is_registered_types</a>&lt;B, Q, E&gt;(), <a href="user.md#0xc0deb00c_user_E_NO_MARKET">E_NO_MARKET</a>);
    // Assert that given custodian ID is in bounds
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_valid_custodian_id">registry::is_valid_custodian_id</a>(custodian_id),
        <a href="user.md#0xc0deb00c_user_E_INVALID_CUSTODIAN_ID">E_INVALID_CUSTODIAN_ID</a>);
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{
        market_info: <a href="registry.md#0xc0deb00c_registry_market_info">registry::market_info</a>&lt;B, Q, E&gt;(),
        custodian_id}; // Pack market account info
    <a href="user.md#0xc0deb00c_user_register_open_orders">register_open_orders</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    <a href="user.md#0xc0deb00c_user_register_collateral">register_collateral</a>&lt;B&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    <a href="user.md#0xc0deb00c_user_register_collateral">register_collateral</a>&lt;Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_user"></a>

## Function `withdraw_collateral_user`

Return <code>amount</code> of <code>Coin</code> having <code>CoinType</code> withdrawn from
<code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account specified by <code>market_account_info</code>.
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
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> is not trying <b>to</b> override delegated custody
    <b>assert</b>!(market_account_info.custodian_id == 0, <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>);
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s market account
    <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_collateral"></a>

## Function `deposit_collateral`

Deposit <code><a href="coins.md#0xc0deb00c_coins">coins</a></code> as collateral for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account
specified by <code>market_account_info</code>.


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
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Assert <a href="">coin</a> type is either base or quote for market account
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_coin_is_in_market_pair">registry::coin_is_in_market_pair</a>&lt;CoinType&gt;(
        &market_account_info.market_info), <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>);
    // Assert attempting <b>to</b> actually deposit <a href="coins.md#0xc0deb00c_coins">coins</a>
    <b>assert</b>!(<a href="_value">coin::value</a>(&<a href="coins.md#0xc0deb00c_coins">coins</a>) != 0, <a href="user.md#0xc0deb00c_user_E_NO_TRANSFER_AMOUNT">E_NO_TRANSFER_AMOUNT</a>);
    // Assert market account registered for market account info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> market accounts collateral <a href="">table</a>
    <b>let</b> market_accounts =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).market_accounts;
    // Borrow mutable reference <b>to</b> market account collateral
    <b>let</b> market_account_collateral = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts,
        market_account_info);
    // Increment available <a href="">coin</a> count
    market_account_collateral.coins_available =
        market_account_collateral.coins_available + <a href="_value">coin::value</a>(&<a href="coins.md#0xc0deb00c_coins">coins</a>);
    // Merge <a href="coins.md#0xc0deb00c_coins">coins</a> into market account collateral
    <a href="_merge">coin::merge</a>(&<b>mut</b> market_account_collateral.<a href="coins.md#0xc0deb00c_coins">coins</a>, <a href="coins.md#0xc0deb00c_coins">coins</a>);
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

Return <code>amount</code> of <code>Coin</code> having <code>CoinType</code> withdrawn from
<code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account specified by <code>market_account_info</code>.
Requires a reference to a <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code> for
authorization, and aborts if custodian serial ID does not
correspond to specified <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>


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
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Assert serial custodian ID from <a href="capability.md#0xc0deb00c_capability">capability</a> matches ID from
    // market account info
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability) ==
        market_account_info.custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    // Withdraw collateral from <a href="user.md#0xc0deb00c_user">user</a>'s market account
    <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">withdraw_collateral_internal</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_info, amount)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_exists_market_account"></a>

## Function `exists_market_account`

Return <code><b>true</b></code> if <code><a href="user.md#0xc0deb00c_user">user</a></code> has an <code><a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a></code> entry for
<code>market_account_info</code>, otherwise <code><b>false</b></code>.


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>
): bool
<b>acquires</b> <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Return <b>false</b> <b>if</b> no open orders resource <b>exists</b>
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>)) <b>return</b> <b>false</b>;
    // Borrow immutable ref <b>to</b> open orders market accounts <a href="">table</a>
    <b>let</b> market_accounts = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).market_accounts;
    // Return <b>if</b> market account is registered in <a href="">table</a>
    <a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts, market_account_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral"></a>

## Function `register_collateral`

Register user with a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given <code>CoinType</code>
and <code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist

<a name="@Abort_conditions_3"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral">register_collateral</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral">register_collateral</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <b>address</b>
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have a collateral resource initialized
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(user_address)) {
        // Pack an empty one and <b>move</b> <b>to</b> their account
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>{market_accounts: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    // Borrow mutable reference <b>to</b> collateral market accounts <a href="">table</a>
    <b>let</b> market_accounts =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(
            user_address).market_accounts;
    // Assert no entry <b>exists</b> for given market account info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Add an empty entry for given market account info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(market_accounts, market_account_info,
        <a href="user.md#0xc0deb00c_user_MarketAccountCollateral">MarketAccountCollateral</a>{
            <a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_zero">coin::zero</a>&lt;CoinType&gt;(),
            coins_available: 0});
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_open_orders"></a>

## Function `register_open_orders`

Register user with an <code><a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a></code> entry for the given
<code>market_account_info</code>, initializing <code><a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a></code> if it does not
already exist

<a name="@Abort_conditions_4"></a>

### Abort conditions

* If user already has an <code><a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a></code> entry for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_open_orders">register_open_orders</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_open_orders">register_open_orders</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <b>address</b>
    // If <a href="user.md#0xc0deb00c_user">user</a> does not have an open orders initialized
    <b>if</b>(!<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>&gt;(user_address)) {
        // Pack an empty one and <b>move</b> <b>to</b> their account
        <b>move_to</b>&lt;<a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
            <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>{market_accounts: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()})
    };
    // Borrow mutable reference <b>to</b> open orders market accounts <a href="">table</a>
    <b>let</b> market_accounts =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a>&gt;(user_address).market_accounts;
    // Assert no entry <b>exists</b> for given market account info
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_MARKET_ACCOUNT_REGISTERED">E_MARKET_ACCOUNT_REGISTERED</a>);
    // Get scale factor for corresponding market
    <b>let</b> scale_factor = <a href="registry.md#0xc0deb00c_registry_scale_factor_from_market_info">registry::scale_factor_from_market_info</a>(
        &market_account_info.market_info);
    // Add an empty entry for given market account info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(market_accounts, market_account_info,
        <a href="user.md#0xc0deb00c_user_MarketAccountOpenOrders">MarketAccountOpenOrders</a>{
            scale_factor,
            asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
            bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>()});
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_collateral_internal"></a>

## Function `withdraw_collateral_internal`

Return <code>amount</code> of <code>Coin</code> having <code>CoinType</code> withdrawn from
<code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account specified by <code>market_account_info</code>.


<a name="@Abort_conditions_5"></a>

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
<b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>, <a href="user.md#0xc0deb00c_user_OpenOrders">OpenOrders</a> {
    // Assert <a href="">coin</a> type is either base or quote for market account
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_coin_is_in_market_pair">registry::coin_is_in_market_pair</a>&lt;CoinType&gt;(
        &market_account_info.market_info), <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>);
    // Assert attempting <b>to</b> actually withdraw <a href="coins.md#0xc0deb00c_coins">coins</a>
    <b>assert</b>!(amount != 0, <a href="user.md#0xc0deb00c_user_E_NO_TRANSFER_AMOUNT">E_NO_TRANSFER_AMOUNT</a>);
    // Assert market account registered for market account info
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user_exists_market_account">exists_market_account</a>(market_account_info, <a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
    // Borrow mutable reference <b>to</b> market accounts collateral <a href="">table</a>
    <b>let</b> market_accounts =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).market_accounts;
    // Borrow mutable reference <b>to</b> market account collateral
    <b>let</b> market_account_collateral = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(market_accounts,
        market_account_info);
    // Get mutable reference <b>to</b> available <a href="">coin</a> count
    <b>let</b> coins_available = &<b>mut</b> market_account_collateral.coins_available;
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough available collateral <b>to</b> withdraw
    <b>assert</b>!(amount &lt;= *coins_available, <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
    // Decrement withdrawn amount from available <a href="">coin</a> count
    *coins_available = *coins_available - amount;
    // Extract collateral from market account and <b>return</b>
    <a href="_extract">coin::extract</a>(&<b>mut</b> market_account_collateral.<a href="coins.md#0xc0deb00c_coins">coins</a>, amount)
}
</code></pre>



</details>
