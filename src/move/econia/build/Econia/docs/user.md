
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side book keeping and, optionally, collateral management.


<a name="@Market_account_custodians_0"></a>

## Market account custodians


For any given market, designated by a unique market ID, a user can
register multiple <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s, distinguished from one another
by their corresponding "general custodian ID". The custodian
capability having this ID is required to approve all market
transactions within the market account with the exception of generic
asset transfers, which are approved by a market-wide "generic
asset transfer custodian" in the case of a market having at least
one non-coin asset. When a general custodian ID is marked
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>, a signing user is required to approve general
transactions rather than a custodian capability.

For example: market 5 has a generic (non-coin) base asset, a coin
quote asset, and generic asset transfer custodian ID 6. A user
opens two market accounts for market 5, one having general
custodian ID 7, and one having general custodian ID <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>.
When a user wishes to deposit base assets to the first market
account, custodian 6 is required for authorization. Then when the
user wishes to submit an ask, custodian 7 must approve it. As for
the second account, a user can deposit and withdraw quote coins,
and place or cancel trades via a signature, but custodian 6 is
still required to verify base deposits and withdrawals.

In other words, the market-wide generic asset transfer custodian ID
overrides the user-specific general custodian ID only when
depositing or withdrawing generic assets, otherwise the
user-specific general custodian ID takes precedence. Notably, a user
can register a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> having the same general custodian ID
and generic asset transfer custodian ID, and here, no overriding
takes place. For example, if market 8 requires generic asset
transfer custodian ID 9, a user can still register a market account
having general custodian ID 9, and then custodian 9 will be required
to authorize all of a user's transactions for the given
<code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>


<a name="@Market_account_ID_1"></a>

## Market account ID


Since any of a user's <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s are specified by a
unique combination of market ID and general custodian ID, a user's
market account ID is thus defined as a 128-bit number, where the
most-significant ("first") 64 bits correspond to the market ID, and
the least-significant ("last") 64 bits correspond to the general
custodian ID.

For a market ID of <code>255</code> (<code>0b11111111</code>) and a general custodian ID
of <code>170</code> (<code>0b10101010</code>), for example, the corresponding market
account ID has the first 64 bits
<code>0000000000000000000000000000000000000000000000000000000011111111</code>
and the last 64 bits
<code>0000000000000000000000000000000000000000000000000000000010101010</code>,
corresponding to the base-10 integer <code>4703919738795935662250</code>. Note
that when a user opts to sign general transactions rather than
delegate to a general custodian, the market account ID uses a
general custodian ID of <code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code>, corresponding to <code>0</code>.


-  [Market account custodians](#@Market_account_custodians_0)
-  [Market account ID](#@Market_account_ID_1)
-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Constants](#@Constants_2)
-  [Function `return_0`](#0xc0deb00c_user_return_0)
-  [Function `get_market_account_id`](#0xc0deb00c_user_get_market_account_id)
-  [Function `get_market_id`](#0xc0deb00c_user_get_market_id)
-  [Function `get_general_custodian_id`](#0xc0deb00c_user_get_general_custodian_id)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_3)
    -  [Parameters](#@Parameters_4)
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
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u128, <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;&gt;</code>
</dt>
<dd>
 Map from market account ID to coins held as collateral for
 given <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>. Separated into different table
 entries to reduce transaction collisions across markets
</dd>
</dl>


</details>

<a name="0xc0deb00c_user_MarketAccount"></a>

## Struct `MarketAccount`

Represents a user's open orders and available assets for a given
<code>MarketAccountInfo</code>


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
<code>generic_asset_transfer_custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to verify deposits and
 withdrawals of assets that are not coins. A "market-wide
 asset transfer custodian ID" that only applies to markets
 having at least one non-coin asset. For a market having
 one coin asset and one generic asset, only applies to the
 generic asset. Marked <code><a href="user.md#0xc0deb00c_user_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and quote
 types are both coins.
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

<a name="0xc0deb00c_user_MarketAccounts"></a>

## Resource `MarketAccounts`

Market account map for all of a user's <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>s


<pre><code><b>struct</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u128, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;</code>
</dt>
<dd>
 Map from market account ID to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code>. Separated
 into different table entries to reduce transaction
 collisions across markets
</dd>
</dl>


</details>

<a name="@Constants_2"></a>

## Constants


<a name="0xc0deb00c_user_ASK"></a>

Flag for asks side


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_user_BID"></a>

Flag for asks side


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_user_FIRST_64"></a>

Positions to bitshift for operating on first 64 bits


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_user_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



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



<a name="0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING"></a>

When depositing an asset would overflow total holdings ceiling


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a>: u64 = 5;
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

When not enough asset available for operation


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



<a name="0xc0deb00c_user_E_OVERFLOW_ASSET_IN"></a>

When filling proposed order overflows asset received from trade


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_OVERFLOW_ASSET_IN">E_OVERFLOW_ASSET_IN</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_user_E_OVERFLOW_ASSET_OUT"></a>

When filling proposed order overflows asset traded away


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_OVERFLOW_ASSET_OUT">E_OVERFLOW_ASSET_OUT</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_user_E_PRICE_0"></a>

When proposed order indicates a price of 0


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_PRICE_0">E_PRICE_0</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_user_E_SIZE_0"></a>

When proposed order indicates a size of 0


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_SIZE_0">E_SIZE_0</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_user_E_TICKS_OVERFLOW"></a>

When number of ticks to fill order overflows a <code>u64</code>


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_TICKS_OVERFLOW">E_TICKS_OVERFLOW</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID"></a>

When indicated custodian ID is not registered


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID">E_UNREGISTERED_CUSTODIAN_ID</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_user_IN"></a>

Flag for inbound coins


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_IN">IN</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_user_OUT"></a>

Flag for outbound coins


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_OUT">OUT</a>: bool = <b>false</b>;
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

<a name="0xc0deb00c_user_get_market_account_id"></a>

## Function `get_market_account_id`

Return market account ID for given <code>market_id</code> and
<code>general_custodian_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id: u64, general_custodian_id: u64): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(
    market_id: u64,
    general_custodian_id: u64
): u128 {
    (market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a> | (general_custodian_id <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_market_id"></a>

## Function `get_market_id`

Get market ID encoded in <code>market_account_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(
    market_account_id: u128
): u64 {
    (market_account_id &gt;&gt; <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a> <b>as</b> u64)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_general_custodian_id"></a>

## Function `get_general_custodian_id`

Get general custodian ID encoded in <code>market_account_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_general_custodian_id">get_general_custodian_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_general_custodian_id">get_general_custodian_id</a>(
    market_account_id: u128
): u64 {
    (market_account_id & (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128) <b>as</b> u64)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register user with a market account


<a name="@Type_parameters_3"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_4"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Signing user
* <code>market_id</code>: Serial ID of corresonding market
* <code>general_custodian_id</code>: Serial ID of custodian capability
required for general account authorization, set to
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code> if signing user required for authorization on
market account


<a name="@Abort_conditions_5"></a>

### Abort conditions

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
    // If general custodian ID indicated, <b>assert</b> it is registered
    <b>if</b> (general_custodian_id != <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>) <b>assert</b>!(
        <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">registry::is_registered_custodian_id</a>(general_custodian_id),
        <a href="user.md#0xc0deb00c_user_E_UNREGISTERED_CUSTODIAN_ID">E_UNREGISTERED_CUSTODIAN_ID</a>);
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(
        market_id, general_custodian_id);
    // Register entry in <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // If base asset is <a href="">coin</a>, register collateral entry
    <b>if</b> (<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;())
        <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;BaseType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // If quote asset is <a href="">coin</a>, register collateral entry
    <b>if</b> (<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteType&gt;())
        <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
and <code>market_account_id</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist.


<a name="@Abort_conditions_6"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given
<code>market_account_id</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_collateral_entry">register_collateral_entry</a>&lt;
    CoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_id: u128,
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
        market_account_id), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(collateral_map_ref_mut, market_account_id,
        <a href="_zero">coin::zero</a>&lt;CoinType&gt;());
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_accounts_entry"></a>

## Function `register_market_accounts_entry`

Register user with a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> map entry for given
<code>BaseType</code>, <code>QuoteType</code>, and <code>market_account_id</code>, initializing
<code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> if it does not already exist


<a name="@Abort_conditions_7"></a>

### Abort conditions

* If user already has a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code> entry for given
<code>market_account_id</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_account_id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_register_market_accounts_entry">register_market_accounts_entry</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_account_id: u128,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Get generic asset transfer custodian ID for verified <a href="market.md#0xc0deb00c_market">market</a>
    <b>let</b> generic_asset_transfer_custodian_id = registry::
        get_verified_market_custodian_id&lt;BaseType, QuoteType&gt;(
            <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(market_account_id));
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
        market_account_id), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> info
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(market_accounts_map_ref_mut, market_account_id,
        <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>{
            base_type_info: <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(),
            quote_type_info: <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(),
            generic_asset_transfer_custodian_id,
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
