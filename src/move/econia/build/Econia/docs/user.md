
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side book keeping and, optionally, collateral management.

For a given market, a user can register multiple <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s,
with each such market account having a different delegated custodian
ID and therefore a unique <code><a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a></code>: hence, each market
account has a particular "user-specific" custodian ID. For a given
<code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>, a user has entries in a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map for each
asset that is a coin type.

For assets that are not a coin type, the "market-wide generic asset
transfer" custodian (<code><a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a></code>) is required to
verify deposits and withdrawals. Hence a user-specific general
custodian overrides a market-wide generic asset transfer
custodian when placing or cancelling trades on an asset-agnostic
market, whereas the market-wide generic asset transfer custodian
overrides the user-specific general custodian ID when depositing or
withdrawing a non-coin asset.


-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Struct `MarketAccountInfo`](#0xc0deb00c_user_MarketAccountInfo)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Constants](#@Constants_0)
-  [Function `return_0`](#0xc0deb00c_user_return_0)
-  [Function `deposit_coins`](#0xc0deb00c_user_deposit_coins)
-  [Function `deposit_generic_asset`](#0xc0deb00c_user_deposit_generic_asset)
    -  [Abort conditions](#@Abort_conditions_1)
-  [Function `withdraw_coins_custodian`](#0xc0deb00c_user_withdraw_coins_custodian)
    -  [Abort conditions](#@Abort_conditions_2)
-  [Function `withdraw_coins_user`](#0xc0deb00c_user_withdraw_coins_user)
    -  [Abort conditions](#@Abort_conditions_3)
-  [Function `withdraw_generic_asset`](#0xc0deb00c_user_withdraw_generic_asset)
    -  [Abort conditions](#@Abort_conditions_4)
-  [Function `deposit_from_coinstore`](#0xc0deb00c_user_deposit_from_coinstore)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_5)
    -  [Parameters](#@Parameters_6)
    -  [Abort conditions](#@Abort_conditions_7)
-  [Function `withdraw_to_coinstore`](#0xc0deb00c_user_withdraw_to_coinstore)
-  [Function `borrow_asset_counts_mut`](#0xc0deb00c_user_borrow_asset_counts_mut)
    -  [Returns](#@Returns_8)
    -  [Assumes](#@Assumes_9)
    -  [Abort conditions](#@Abort_conditions_10)
-  [Function `deposit_asset`](#0xc0deb00c_user_deposit_asset)
    -  [Assumes](#@Assumes_11)
    -  [Abort conditions](#@Abort_conditions_12)
-  [Function `register_collateral_entry`](#0xc0deb00c_user_register_collateral_entry)
    -  [Abort conditions](#@Abort_conditions_13)
-  [Function `register_market_accounts_entry`](#0xc0deb00c_user_register_market_accounts_entry)
    -  [Abort conditions](#@Abort_conditions_14)
-  [Function `verify_market_account_exists`](#0xc0deb00c_user_verify_market_account_exists)
    -  [Abort conditions](#@Abort_conditions_15)
-  [Function `withdraw_asset`](#0xc0deb00c_user_withdraw_asset)
    -  [Abort conditions](#@Abort_conditions_16)
-  [Function `withdraw_coins`](#0xc0deb00c_user_withdraw_coins)
    -  [Abort conditions](#@Abort_conditions_17)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
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
<code>base_ceiling: u64</code>
</dt>
<dd>
 Amount <code>base_total</code> will increase to if all open bids fill
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
<dt>
<code>quote_ceiling: u64</code>
</dt>
<dd>
 Amount <code>quote_total</code> will increase to if all open asks fill
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
<code>general_custodian_id: u64</code>
</dt>
<dd>
 Serial ID of registered account custodian, set to
 <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code> when given account does not have an
 authorized custodian for general purposes. Otherwise
 corresponding custodian capability required to place trades
 and deposit or withdraw coin assets. Is overridden by
 <code>generic_asset_transfer_custodian_id</code> when depositing or
 withdrawing a non-coin asset, since the market-level
 custodian is required to verify deposit and withdraw amounts
 for non-coin assets. Can be the same as
 <code>generic_asset_transfer_custodian_id</code>.
</dd>
<dt>
<code>generic_asset_transfer_custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to verify deposits and
 withdrawals of assets that are not coins. A "market-wide
 asset transfer custodian ID" that only applies to markets
 having at least one non-coin asset. For a market having
 one coin asset and one generic asset, only applies to the
 generic asset. Marked <code><a href="user.md#0xc0deb00c_user_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and quote
 types are both coins, otherwise overrides
 <code>general_custodian_id</code> for deposits and withdraws of generic
 assets. Can be the same as <code>general_custodian_id</code>.
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



<a name="0xc0deb00c_user_E_CUSTODIAN_OVERRIDE"></a>

When user attempts invalid custodian override


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

When market account already exists for given market account info


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_user_E_NOT_COIN_ASSET"></a>

When asset indicated as coin actually corresponds to a generic


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_COIN_ASSET">E_NOT_COIN_ASSET</a>: u64 = 13;
</code></pre>



<a name="0xc0deb00c_user_E_NOT_ENOUGH_ASSET_AVAILABLE"></a>

When not enough asset avaialable for withdraw


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_ASSET_AVAILABLE">E_NOT_ENOUGH_ASSET_AVAILABLE</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_user_E_NOT_GENERIC_ASSET"></a>

When asset indicated as generic actually corresponds to a coin


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NOT_GENERIC_ASSET">E_NOT_GENERIC_ASSET</a>: u64 = 12;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNT"></a>

When indicated market account does not exist


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_user_E_NO_MARKET_ACCOUNTS"></a>

When a user does not a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code>


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN"></a>

When indicated custodian does not have authority for operation


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID"></a>

When indicated custodian ID is not registered


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID">E_UNREGISTERED_CUSTODIAN_ID</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_return_0"></a>

## Function `return_0`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8 {0}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_coins"></a>

## Function `deposit_coins`

Deposit <code><a href="">coins</a></code> of <code>CoinType</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account having
<code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, <a href="">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    <a href="">coins</a>: Coin&lt;CoinType&gt;
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>,
        <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id, general_custodian_id,
            generic_asset_transfer_custodian_id},
        <a href="_value">coin::value</a>(&<a href="">coins</a>),
        <a href="_some">option::some</a>(<a href="">coins</a>)
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_generic_asset"></a>

## Function `deposit_generic_asset`

Deposit <code>amount</code> of non-coin assets of <code>AssetType</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>, under authority of
custodian indicated by
<code>generic_asset_transfer_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code>


<a name="@Abort_conditions_1"></a>

### Abort conditions

* If generic asset transfer custodian ID for market does not
match that indicated by
<code>generic_asset_transfer_custodian_capbility_ref</code>
* If <code>AssetType</code> corresponds to the <code>CoinType</code> of an initialized
coin


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64, generic_asset_transfer_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64,
    generic_asset_transfer_custodian_capability_ref: &CustodianCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert indicated generic asset transfer custodian ID matches
    // that of capability
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(
        generic_asset_transfer_custodian_capability_ref) ==
        generic_asset_transfer_custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    // Assert asset type does not correspond <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(!<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;AssetType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_GENERIC_ASSET">E_NOT_GENERIC_ASSET</a>);
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;( // Deposit generic asset
        <a href="user.md#0xc0deb00c_user">user</a>,
        <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id, general_custodian_id,
            generic_asset_transfer_custodian_id},
        amount,
        <a href="_none">option::none</a>&lt;Coin&lt;AssetType&gt;&gt;()
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_custodian"></a>

## Function `withdraw_coins_custodian`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>, under authority of
custodian indicated by <code>general_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code>


<a name="@Abort_conditions_2"></a>

### Abort conditions

* If <code>CoinType</code> does not correspond to a coin
* If <code>general_custodian_id</code> is not <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64,
    general_custodian_capability_ref: &CustodianCapability
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert indicated general custodian ID matches that of
    // capability
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref) ==
        general_custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>,
        market_id,
        general_custodian_id,
        generic_asset_transfer_custodian_id,
        amount
    ) // Withdraw <a href="">coins</a> from <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> and <b>return</b>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_user"></a>

## Function `withdraw_coins_user`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>, returning coins

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code>


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If <code>CoinType</code> does not correspond to a coin
* If <code>general_custodian_id</code> is not <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert custodian ID indicates no custodian
    <b>assert</b>!(general_custodian_id == <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>, <a href="user.md#0xc0deb00c_user_E_CUSTODIAN_OVERRIDE">E_CUSTODIAN_OVERRIDE</a>);
    <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        general_custodian_id,
        generic_asset_transfer_custodian_id,
        amount
    ) // Withdraw <a href="">coins</a> from <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> and <b>return</b>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_generic_asset"></a>

## Function `withdraw_generic_asset`

Withdraw <code>amount</code> of non-coin assets of <code>AssetType</code> from
<code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account having <code>market_id</code>,
<code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>, under authority of
custodian indicated by
<code>generic_asset_transfer_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>()</code>


<a name="@Abort_conditions_4"></a>

### Abort conditions

* If <code>AssetType</code> corresponds to the <code>CoinType</code> of an initialized
coin
* If generic asset transfer custodian ID for market does not
match that indicated by
<code>generic_asset_transfer_custodian_capbility_ref</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64, generic_asset_transfer_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64,
    generic_asset_transfer_custodian_capability_ref: &CustodianCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert asset type does not correspond <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(!<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;AssetType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_GENERIC_ASSET">E_NOT_GENERIC_ASSET</a>);
    // Assert indicated generic asset transfer custodian ID matches
    // that of capability
    <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(
        generic_asset_transfer_custodian_capability_ref) ==
        generic_asset_transfer_custodian_id, <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
    // Pack <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id,
        general_custodian_id, generic_asset_transfer_custodian_id};
    <b>let</b> empty_option = <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info,
        amount, <b>false</b>); // Withdraw asset <b>as</b> empty <a href="">option</a>
    <a href="_destroy_none">option::destroy_none</a>(empty_option); // Destroy empty <a href="">option</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_from_coinstore"></a>

## Function `deposit_from_coinstore`

Transfer <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
<code>aptos_framework::coin::CoinStore</code> to their <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> for
market account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>.

See wrapped function <code><a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        general_custodian_id,
        generic_asset_transfer_custodian_id,
        <a href="_withdraw">coin::withdraw</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, amount)
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register user with a market account


<a name="@Type_parameters_5"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_6"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Signing user
* <code>market_id</code>: Serial ID of corresonding market
* <code>general_custodian_id</code>: Serial ID of custodian capability
required for general account authorization, set to
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code> if signing user required for authorization on
market account


<a name="@Abort_conditions_7"></a>

### Abort conditions

* If market is not already registered
* If invalid <code>custodian_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, general_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_account">register_market_account</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    general_custodian_id: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Get generic asset transfer custodian ID for verified <a href="market.md#0xc0deb00c_market">market</a>
    <b>let</b> generic_asset_transfer_custodian_id = registry::
        get_verified_market_custodian_id&lt;BaseType, QuoteType&gt;(market_id);
    // If general custodian ID indicated, <b>assert</b> it is registered
    <b>if</b> (general_custodian_id != <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>) <b>assert</b>!(
        <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(general_custodian_id),
        <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID">E_UNREGISTERED_CUSTODIAN_ID</a>);
    // Pack corresonding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id,
        general_custodian_id, generic_asset_transfer_custodian_id};
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

<a name="0xc0deb00c_user_withdraw_to_coinstore"></a>

## Function `withdraw_to_coinstore`

Transfer <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
<code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> to their <code>aptos_framework::coin::CoinStore</code> for
market account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>.

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Withdraw <a href="">coins</a> from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> <a href="">coins</a> = <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_id,
        general_custodian_id, generic_asset_transfer_custodian_id, amount);
    // Deposit <a href="">coins</a> <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store
    <a href="_deposit">coin::deposit</a>&lt;CoinType&gt;(address_of(<a href="user.md#0xc0deb00c_user">user</a>), <a href="">coins</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_borrow_asset_counts_mut"></a>

## Function `borrow_asset_counts_mut`

Borrow mutable references to market account <code>AssetType</code> counts

Look up the <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> having <code>market_account_info</code> in the
market accounts map indicated by <code>market_accounts_map_ref_mut</code>,
then return a mutable reference to the amount of <code>AssetType</code>
holdings, and a mutable reference to the reference to the amount
of <code>AssetType</code> available for withdraw.


<a name="@Returns_8"></a>

### Returns

* <code>u64</code>: Mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_total</code> for
corresponding market account if <code>AssetType</code> is market base,
else mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_total</code>
* <code>u64</code>: Mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_available</code> for
corresponding market account if <code>AssetType</code> is market base,
else mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_available</code>
* <code>u64</code>: Mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_ceiling</code> for
corresponding market account if <code>AssetType</code> is market base,
else mutable reference to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_ceiling</code>


<a name="@Assumes_9"></a>

### Assumes

* <code>market_accounts_map</code> has an entry with <code>market_account_info</code>


<a name="@Abort_conditions_10"></a>

### Abort conditions

* If <code>AssetType</code> is neither base nor quote for given market
account


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(market_accounts_map_ref_mut: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>): (&<b>mut</b> u64, &<b>mut</b> u64, &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(
    market_accounts_map_ref_mut:
        &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>&gt;,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>
): (
    &<b>mut</b> u64,
    &<b>mut</b> u64,
    &<b>mut</b> u64
) {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
            market_accounts_map_ref_mut, market_account_info);
    // Get asset type info
    <b>let</b> asset_type_info = <a href="_type_of">type_info::type_of</a>&lt;AssetType&gt;();
    // If is base asset, <b>return</b> mutable references <b>to</b> base fields
    <b>if</b> (asset_type_info == market_account_ref_mut.base_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account_ref_mut.base_total,
            &<b>mut</b> market_account_ref_mut.base_available,
            &<b>mut</b> market_account_ref_mut.base_ceiling,
        )
    // If is quote asset, <b>return</b> mutable references <b>to</b> quote fields
    } <b>else</b> <b>if</b> (asset_type_info == market_account_ref_mut.quote_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account_ref_mut.quote_total,
            &<b>mut</b> market_account_ref_mut.quote_available,
            &<b>mut</b> market_account_ref_mut.quote_ceiling
        )
    }; // Otherwise <b>abort</b>
    <b>abort</b> <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_asset"></a>

## Function `deposit_asset`

Deposit <code>amount</code> of <code>AssetType</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account,
which may include <code>optional_coins</code>


<a name="@Assumes_11"></a>

### Assumes

* That if depositing a coin asset, <code>amount</code> matches value of
<code>optional_coins</code>
* That when depositing a coin asset, if the market account
exists, then a corresponding collateral container does too


<a name="@Abort_conditions_12"></a>

### Abort conditions

* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have corresponding market account
registered
* If <code>AssetType</code> is neither base nor quote for market account


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64, optional_coins: <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
    optional_coins: <a href="_Option">option::Option</a>&lt;Coin&lt;AssetType&gt;&gt;
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
            &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total asset holdings, mutable
    // reference <b>to</b> amount of <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal,
    // and mutable reference <b>to</b> total asset holdings ceiling
    <b>let</b> (asset_total_ref_mut, asset_available_ref_mut,
         asset_ceiling_ref_mut) = <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(
            market_accounts_map_ref_mut, market_account_info);
    // Increment total asset holdings amount
    *asset_total_ref_mut = *asset_total_ref_mut + amount;
    // Increment <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal amount
    *asset_available_ref_mut = *asset_available_ref_mut + amount;
    // Increment total asset holdings ceiling amount
    *asset_ceiling_ref_mut = *asset_ceiling_ref_mut + amount;
    <b>if</b> (<a href="_is_some">option::is_some</a>(&optional_coins)) { // If asset is <a href="">coin</a> type
        // Borrow mutable reference <b>to</b> collateral map
        <b>let</b> collateral_map_ref_mut =
            &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;AssetType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
        // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
        <b>let</b> collateral_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
            collateral_map_ref_mut, market_account_info);
        <a href="_merge">coin::merge</a>( // Merge optional <a href="">coins</a> into collateral
            collateral_ref_mut, <a href="_destroy_some">option::destroy_some</a>(optional_coins));
    } <b>else</b> { // If asset is not <a href="">coin</a> type
        // Destroy empty <a href="">option</a> resource
        <a href="_destroy_none">option::destroy_none</a>(optional_coins);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
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


<a name="@Abort_conditions_14"></a>

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
            base_ceiling: 0,
            quote_total: 0,
            quote_available: 0,
            quote_ceiling: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_user_verify_market_account_exists"></a>

## Function `verify_market_account_exists`

Verify <code><a href="user.md#0xc0deb00c_user">user</a></code> has a market account with <code>market_account_info</code>


<a name="@Abort_conditions_15"></a>

### Abort conditions

* If user does not have a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code>
* If user does not have a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> for given
<code>market_account_info</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref =
        &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> an entry in map for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map_ref,
        market_account_info), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_asset"></a>

## Function `withdraw_asset`

Withdraw <code>amount</code> of <code>AssetType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account,
optionally returning coins if <code>asset_is_coin</code> is <code><b>true</b></code>


<a name="@Abort_conditions_16"></a>

### Abort conditions

* If <code><a href="user.md#0xc0deb00c_user">user</a></code> has insufficient assets available for withdrawal


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">user::MarketAccountInfo</a>, amount: u64, asset_is_coin: bool): <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_info: <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>,
    amount: u64,
    asset_is_coin: bool
): <a href="_Option">option::Option</a>&lt;Coin&lt;AssetType&gt;&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
            &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total asset holdings, mutable
    // reference <b>to</b> amount of <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal,
    // and mutable reference <b>to</b> total asset holdings ceiling
    <b>let</b> (asset_total_ref_mut, asset_available_ref_mut,
         asset_ceiling_ref_mut) = <a href="user.md#0xc0deb00c_user_borrow_asset_counts_mut">borrow_asset_counts_mut</a>&lt;AssetType&gt;(
            market_accounts_map_ref_mut, market_account_info);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough available asset <b>to</b> withdraw
    <b>assert</b>!(amount &lt;= *asset_available_ref_mut,
        <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_ASSET_AVAILABLE">E_NOT_ENOUGH_ASSET_AVAILABLE</a>);
    // Decrement total asset holdings amount
    *asset_total_ref_mut = *asset_total_ref_mut - amount;
    // Decrement <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal amount
    *asset_available_ref_mut = *asset_available_ref_mut - amount;
    // Decrement total asset holdings ceiling amount
    *asset_ceiling_ref_mut = *asset_ceiling_ref_mut - amount;
    <b>if</b> (asset_is_coin) { // If asset is <a href="">coin</a> type
        // Borrow mutable reference <b>to</b> collateral map
        <b>let</b> collateral_map_ref_mut =
            &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;AssetType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
        // Borrow mutable reference <b>to</b> collateral for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
        <b>let</b> collateral_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
            collateral_map_ref_mut, market_account_info);
        // Return <a href="">coin</a> in an <a href="">option</a> wrapper
        <b>return</b> <a href="_some">option::some</a>&lt;Coin&lt;AssetType&gt;&gt;(
            <a href="_extract">coin::extract</a>(collateral_ref_mut, amount))
    } <b>else</b> { // If asset is not <a href="">coin</a> type
        // Return empty <a href="">option</a> wrapper
        <b>return</b> <a href="_none">option::none</a>&lt;Coin&lt;AssetType&gt;&gt;()
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins"></a>

## Function `withdraw_coins`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code>, <code>general_custodian_id</code>, and
<code>generic_asset_transfer_custodian_id</code>, returning coins


<a name="@Abort_conditions_17"></a>

### Abort conditions

* If <code>CoinType</code> does not correspond to a coin


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, generic_asset_transfer_custodian_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    generic_asset_transfer_custodian_id: u64,
    amount: u64,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert type corresponds <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;CoinType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_COIN_ASSET">E_NOT_COIN_ASSET</a>);
    // Pack <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <b>let</b> market_account_info = <a href="user.md#0xc0deb00c_user_MarketAccountInfo">MarketAccountInfo</a>{market_id,
        general_custodian_id, generic_asset_transfer_custodian_id};
    // Withdraw corresponding amount of <a href="">coins</a>, <b>as</b> an <a href="">option</a>
    <b>let</b> option_coins = <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_info, amount, <b>true</b>);
    <a href="_destroy_some">option::destroy_some</a>(option_coins) // Return extracted <a href="">coins</a>
}
</code></pre>



</details>
