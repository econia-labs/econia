
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

---


-  [Market account custodians](#@Market_account_custodians_0)
-  [Market account ID](#@Market_account_ID_1)
-  [Resource `Collateral`](#0xc0deb00c_user_Collateral)
-  [Struct `MarketAccount`](#0xc0deb00c_user_MarketAccount)
-  [Resource `MarketAccounts`](#0xc0deb00c_user_MarketAccounts)
-  [Constants](#@Constants_2)
-  [Function `deposit_coins`](#0xc0deb00c_user_deposit_coins)
-  [Function `deposit_generic_asset`](#0xc0deb00c_user_deposit_generic_asset)
    -  [Abort conditions](#@Abort_conditions_3)
-  [Function `get_asset_counts_custodian`](#0xc0deb00c_user_get_asset_counts_custodian)
    -  [Restrictions](#@Restrictions_4)
-  [Function `get_asset_counts_user`](#0xc0deb00c_user_get_asset_counts_user)
    -  [Restrictions](#@Restrictions_5)
-  [Function `get_market_account_id`](#0xc0deb00c_user_get_market_account_id)
-  [Function `get_market_id`](#0xc0deb00c_user_get_market_id)
-  [Function `get_general_custodian_id`](#0xc0deb00c_user_get_general_custodian_id)
-  [Function `withdraw_coins_custodian`](#0xc0deb00c_user_withdraw_coins_custodian)
-  [Function `withdraw_coins_user`](#0xc0deb00c_user_withdraw_coins_user)
-  [Function `withdraw_generic_asset`](#0xc0deb00c_user_withdraw_generic_asset)
    -  [Abort conditions](#@Abort_conditions_6)
-  [Function `deposit_from_coinstore`](#0xc0deb00c_user_deposit_from_coinstore)
-  [Function `register_market_account`](#0xc0deb00c_user_register_market_account)
    -  [Type parameters](#@Type_parameters_7)
    -  [Parameters](#@Parameters_8)
    -  [Abort conditions](#@Abort_conditions_9)
-  [Function `withdraw_to_coinstore`](#0xc0deb00c_user_withdraw_to_coinstore)
-  [Function `fill_order_internal`](#0xc0deb00c_user_fill_order_internal)
    -  [Type parameters](#@Type_parameters_10)
    -  [Parameters](#@Parameters_11)
-  [Function `get_asset_counts_internal`](#0xc0deb00c_user_get_asset_counts_internal)
    -  [Restrictions](#@Restrictions_12)
-  [Function `get_n_orders_internal`](#0xc0deb00c_user_get_n_orders_internal)
    -  [Restrictions](#@Restrictions_13)
-  [Function `get_order_id_nearest_spread_internal`](#0xc0deb00c_user_get_order_id_nearest_spread_internal)
    -  [Restrictions](#@Restrictions_14)
-  [Function `register_order_internal`](#0xc0deb00c_user_register_order_internal)
    -  [Parameters](#@Parameters_15)
    -  [Assumes](#@Assumes_16)
-  [Function `remove_order_internal`](#0xc0deb00c_user_remove_order_internal)
    -  [Parameters](#@Parameters_17)
    -  [Assumes](#@Assumes_18)
-  [Function `withdraw_coins_as_option_internal`](#0xc0deb00c_user_withdraw_coins_as_option_internal)
-  [Function `borrow_transfer_fields_mixed`](#0xc0deb00c_user_borrow_transfer_fields_mixed)
    -  [Returns](#@Returns_19)
    -  [Assumes](#@Assumes_20)
    -  [Abort conditions](#@Abort_conditions_21)
-  [Function `deposit_asset`](#0xc0deb00c_user_deposit_asset)
    -  [Assumes](#@Assumes_22)
    -  [Abort conditions](#@Abort_conditions_23)
-  [Function `fill_order_route_collateral`](#0xc0deb00c_user_fill_order_route_collateral)
    -  [Type parameters](#@Type_parameters_24)
    -  [Parameters](#@Parameters_25)
-  [Function `fill_order_route_collateral_single`](#0xc0deb00c_user_fill_order_route_collateral_single)
    -  [Parameters](#@Parameters_26)
    -  [Assumes](#@Assumes_27)
-  [Function `fill_order_update_market_account`](#0xc0deb00c_user_fill_order_update_market_account)
    -  [Parameters](#@Parameters_28)
    -  [Assumes](#@Assumes_29)
-  [Function `get_asset_counts`](#0xc0deb00c_user_get_asset_counts)
    -  [Returns](#@Returns_30)
    -  [Restrictions](#@Restrictions_31)
-  [Function `range_check_new_order`](#0xc0deb00c_user_range_check_new_order)
    -  [Parameters](#@Parameters_32)
    -  [Returns](#@Returns_33)
    -  [Abort conditions](#@Abort_conditions_34)
-  [Function `register_collateral_entry`](#0xc0deb00c_user_register_collateral_entry)
    -  [Abort conditions](#@Abort_conditions_35)
-  [Function `register_market_accounts_entry`](#0xc0deb00c_user_register_market_accounts_entry)
    -  [Abort conditions](#@Abort_conditions_36)
-  [Function `verify_market_account_exists`](#0xc0deb00c_user_verify_market_account_exists)
    -  [Abort conditions](#@Abort_conditions_37)
-  [Function `withdraw_asset`](#0xc0deb00c_user_withdraw_asset)
    -  [Abort conditions](#@Abort_conditions_38)
-  [Function `withdraw_coins`](#0xc0deb00c_user_withdraw_coins)
    -  [Abort conditions](#@Abort_conditions_39)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
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
market account ID


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
 ID of custodian capability required to verify deposits,
 swaps, and withdrawals of assets that are not coins. A
 "market-wide asset transfer custodian ID" that only applies
 to markets having at least one non-coin asset. For a market
 having one coin asset and one generic asset, only applies to
 the generic asset. Marked <code><a href="user.md#0xc0deb00c_user_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and
 quote types are both coins.
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



<a name="0xc0deb00c_user_COIN_ASSET_TRANSFER"></a>

Flag for asset transfer of coin type


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_COIN_ASSET_TRANSFER">COIN_ASSET_TRANSFER</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING"></a>

When depositing an asset would overflow total holdings ceiling


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT"></a>

When market account already exists for given market account ID


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



<a name="0xc0deb00c_user_E_NO_ORDERS"></a>

When no orders for indicated operation


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_NO_ORDERS">E_NO_ORDERS</a>: u64 = 15;
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



<a name="0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN"></a>

When indicated custodian unauthorized to perform operation


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>: u64 = 14;
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



<a name="0xc0deb00c_user_deposit_coins"></a>

## Function `deposit_coins`

Deposit <code>coins</code> of <code>CoinType</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account having
<code>market_id</code> and <code>general_custodian_id</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, coins: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    coins: Coin&lt;CoinType&gt;
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>,
        <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id, general_custodian_id),
        <a href="_value">coin::value</a>(&coins),
        <a href="_some">option::some</a>(coins),
        <a href="user.md#0xc0deb00c_user_COIN_ASSET_TRANSFER">COIN_ASSET_TRANSFER</a>
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_generic_asset"></a>

## Function `deposit_generic_asset`

Deposit <code>amount</code> of non-coin assets of <code>AssetType</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account having <code>market_id</code> and <code>general_custodian_id</code>,
under authority of custodian indicated by
<code>generic_asset_transfer_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>()</code>


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If <code>AssetType</code> corresponds to the <code>CoinType</code> of an initialized
coin


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, amount: u64, generic_asset_transfer_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_generic_asset">deposit_generic_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    amount: u64,
    generic_asset_transfer_custodian_capability_ref: &CustodianCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert asset type does not correspond <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(!<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;AssetType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_GENERIC_ASSET">E_NOT_GENERIC_ASSET</a>);
    // Get generic asset transfer custodian ID
    <b>let</b> generic_asset_transfer_custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(
        generic_asset_transfer_custodian_capability_ref);
    <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;( // Deposit generic asset
        <a href="user.md#0xc0deb00c_user">user</a>,
        <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id, general_custodian_id),
        amount,
        <a href="_none">option::none</a>&lt;Coin&lt;AssetType&gt;&gt;(),
        generic_asset_transfer_custodian_id
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_custodian"></a>

## Function `get_asset_counts_custodian`

Return <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> asset count fields for given <code><a href="user.md#0xc0deb00c_user">user</a></code> and
<code>market_account_id</code>, under authority of general custodian
indicated by <code>general_custodian_capability_ref()</code>.

See wrapped call <code><a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>()</code>.


<a name="@Restrictions_4"></a>

### Restrictions

* Restricted to general custodian for given account to prevent
excessive public queries and thus transaction collisions


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_custodian">get_asset_counts_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_custodian">get_asset_counts_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_capability_ref: &CustodianCapability
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>(<a href="user.md#0xc0deb00c_user">user</a>, <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref)
    ))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_user"></a>

## Function `get_asset_counts_user`

Return <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> asset count fields for given <code><a href="user.md#0xc0deb00c_user">user</a></code> and
<code>market_account_id</code>, under authority of signing user for a
market account without a delegated general custodian.

See wrapped call <code><a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>()</code>.


<a name="@Restrictions_5"></a>

### Restrictions

* Restricted to signing user for given account to prevent
excessive public queries and thus transaction collisions


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_user">get_asset_counts_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_user">get_asset_counts_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id, <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>)
    )
}
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

<a name="0xc0deb00c_user_withdraw_coins_custodian"></a>

## Function `withdraw_coins_custodian`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code>, under authority of custodian
indicated by <code>general_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, amount: u64, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_custodian">withdraw_coins_custodian</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    amount: u64,
    general_custodian_capability_ref: &CustodianCapability
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        amount
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_user"></a>

## Function `withdraw_coins_user`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code> and no general custodian,returning
coins

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    amount: u64,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        amount
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_generic_asset"></a>

## Function `withdraw_generic_asset`

Withdraw <code>amount</code> of non-coin assets of <code>AssetType</code> from
<code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account having <code>market_id</code> and
<code>general_custodian_id</code>, under authority of custodian indicated
by <code>generic_asset_transfer_custodian_capability_ref</code>

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>()</code>


<a name="@Abort_conditions_6"></a>

### Abort conditions

* If <code>AssetType</code> corresponds to the <code>CoinType</code> of an initialized
coin


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, amount: u64, generic_asset_transfer_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_generic_asset">withdraw_generic_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    amount: u64,
    generic_asset_transfer_custodian_capability_ref: &CustodianCapability
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert asset type does not correspond <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(!<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;AssetType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_GENERIC_ASSET">E_NOT_GENERIC_ASSET</a>);
    // Get generic asset transfer custodian ID
    <b>let</b> generic_asset_transfer_custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(
        generic_asset_transfer_custodian_capability_ref);
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id,
        general_custodian_id);
    // Withdraw asset <b>as</b> empty <a href="">option</a>
    <b>let</b> empty_option = <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id,
        amount, <b>false</b>, generic_asset_transfer_custodian_id);
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


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, general_custodian_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_from_coinstore">deposit_from_coinstore</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    general_custodian_id: u64,
    amount: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_deposit_coins">deposit_coins</a>&lt;CoinType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        general_custodian_id,
        <a href="_withdraw">coin::withdraw</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, amount)
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_market_account"></a>

## Function `register_market_account`

Register user with a market account


<a name="@Type_parameters_7"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_8"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Signing user
* <code>market_id</code>: Serial ID of corresonding market
* <code>general_custodian_id</code>: Serial ID of custodian capability
required for general account authorization, set to
<code><a href="user.md#0xc0deb00c_user_NO_CUSTODIAN">NO_CUSTODIAN</a></code> if signing user required for authorization on
market account


<a name="@Abort_conditions_9"></a>

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

<a name="0xc0deb00c_user_withdraw_to_coinstore"></a>

## Function `withdraw_to_coinstore`

Transfer <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
<code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> to their <code>aptos_framework::coin::CoinStore</code> for
market account having <code>market_id</code> and
<code>generic_asset_transfer_custodian_id</code> but no general custodian

See wrapped function <code><a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_to_coinstore">withdraw_to_coinstore</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    amount: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Withdraw coins from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> coins = <a href="user.md#0xc0deb00c_user_withdraw_coins_user">withdraw_coins_user</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_id, amount);
    // Deposit coins <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store
    <a href="_deposit">coin::deposit</a>&lt;CoinType&gt;(address_of(<a href="user.md#0xc0deb00c_user">user</a>), coins);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_internal"></a>

## Function `fill_order_internal`

Fill a user's order, routing coin collateral as needed.

Only to be called by the matching engine, which has already
calculated the corresponding amount of assets to fill. If the
matching engine gets to this stage, then it is assumed that
given user has the indicated open order and sufficient assets
to fill it. Hence no error checking.


<a name="@Type_parameters_10"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_11"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account ID
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>complete_fill</code>: If <code><b>true</b></code>, the order is completely filled
* <code>fill_size</code>: Number of lots filled
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base asset
units routed from <code><a href="user.md#0xc0deb00c_user">user</a></code>, else to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote asset
units routed to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, complete_fill: bool, fill_size: u64, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, base_to_route: u64, quote_to_route: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    complete_fill: bool,
    fill_size: u64,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    base_to_route: u64,
    quote_to_route: u64,
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Update <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, complete_fill, fill_size, base_to_route, quote_to_route);
    // Route collateral accordingly, <b>as</b> needed
    <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>,
        market_account_id, side, optional_base_coins_ref_mut,
        optional_quote_coins_ref_mut, base_to_route, quote_to_route);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts_internal"></a>

## Function `get_asset_counts_internal`

Return <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> asset count fields for given <code><a href="user.md#0xc0deb00c_user">user</a></code> and
<code>market_account_id</code> .

See wrapped call <code><a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>()</code>.


<a name="@Restrictions_12"></a>

### Restrictions

* Restricted to friend modules to prevent excessive public
queries and thus transaction collisions


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">get_asset_counts_internal</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    <a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_n_orders_internal"></a>

## Function `get_n_orders_internal`

Return number of open orders for given <code><a href="user.md#0xc0deb00c_user">user</a></code>,
<code>market_account_id</code>, and <code>side</code>


<a name="@Restrictions_13"></a>

### Restrictions

* Restricted to friends prevent excessive public queries and
thus transaction collisions


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_n_orders_internal">get_n_orders_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_n_orders_internal">get_n_orders_internal</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool
): u64
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow immutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref =
        <a href="open_table.md#0xc0deb00c_open_table_borrow">open_table::borrow</a>(market_accounts_map_ref, market_account_id);
    // Borrow immutable reference <b>to</b> corresponding orders tree
    <b>let</b> tree_ref = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) &market_account_ref.asks <b>else</b>
        &market_account_ref.bids;
    <a href="critbit.md#0xc0deb00c_critbit_length">critbit::length</a>(tree_ref) // Return number of orders
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_order_id_nearest_spread_internal"></a>

## Function `get_order_id_nearest_spread_internal`

Return order ID of order nearest the spread, for given <code><a href="user.md#0xc0deb00c_user">user</a></code>,
<code>market_account_id</code>, and <code>side</code>


<a name="@Restrictions_14"></a>

### Restrictions

* Restricted to friends prevent excessive public queries and
thus transaction collisions


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_order_id_nearest_spread_internal">get_order_id_nearest_spread_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_get_order_id_nearest_spread_internal">get_order_id_nearest_spread_internal</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool
): u128
<b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow immutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref =
        <a href="open_table.md#0xc0deb00c_open_table_borrow">open_table::borrow</a>(market_accounts_map_ref, market_account_id);
    // Borrow immutable reference <b>to</b> corresponding orders tree
    <b>let</b> tree_ref = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) &market_account_ref.asks <b>else</b>
        &market_account_ref.bids;
    // Assert tree is not empty
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref), <a href="user.md#0xc0deb00c_user_E_NO_ORDERS">E_NO_ORDERS</a>);
    <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) <a href="critbit.md#0xc0deb00c_critbit_min_key">critbit::min_key</a>(tree_ref) <b>else</b>
        <a href="critbit.md#0xc0deb00c_critbit_max_key">critbit::max_key</a>(tree_ref)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_order_internal"></a>

## Function `register_order_internal`

Register a new order under a user's market account


<a name="@Parameters_15"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account ID
* <code>side:</code> <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>size</code>: Size of order in lots
* <code>price</code>: Price of order in ticks per lot
* <code>lot_size</code>: Base asset units per lot
* <code>tick_size</code>: Quote asset units per tick


<a name="@Assumes_16"></a>

### Assumes

* <code>price</code> is same as that encoded in <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>, since called by
the matching engine
* <code>lot_size</code> and <code>tick_size</code> correspond to market ID encoded in
<code>market_account_id</code>, since called by the matching engine


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_register_order_internal">register_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, size: u64, price: u64, lot_size: u64, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_register_order_internal">register_order_internal</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    size: u64,
    price: u64,
    lot_size: u64,
    tick_size: u64,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
        market_accounts_map_ref_mut, market_account_id);
    // Borrow mutable reference <b>to</b> open orders tree, mutable
    // reference <b>to</b> ceiling field for asset received from trade, and
    // mutable reference <b>to</b> available field for asset traded away
    <b>let</b> (
        tree_ref_mut,
        in_asset_ceiling_ref_mut,
        out_asset_available_ref_mut
    ) = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (
            &<b>mut</b> market_account_ref_mut.asks,
            &<b>mut</b> market_account_ref_mut.quote_ceiling,
            &<b>mut</b> market_account_ref_mut.base_available
        ) <b>else</b> (
            &<b>mut</b> market_account_ref_mut.bids,
            &<b>mut</b> market_account_ref_mut.base_ceiling,
            &<b>mut</b> market_account_ref_mut.quote_available
        );
    // Range check proposed order, store fill amounts
    <b>let</b> (in_asset_fill, out_asset_fill) = <a href="user.md#0xc0deb00c_user_range_check_new_order">range_check_new_order</a>(
        side, size, price, lot_size, tick_size,
        *in_asset_ceiling_ref_mut, *out_asset_available_ref_mut);
    // Add order <b>to</b> corresponding tree
    <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, size);
    // Increment asset ceiling amount for asset received from trade
    *in_asset_ceiling_ref_mut = *in_asset_ceiling_ref_mut + in_asset_fill;
    // Decrement asset available amount for asset traded away
    *out_asset_available_ref_mut =
        *out_asset_available_ref_mut - out_asset_fill;
}
</code></pre>



</details>

<a name="0xc0deb00c_user_remove_order_internal"></a>

## Function `remove_order_internal`

Remove an order from a user's market account


<a name="@Parameters_17"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account ID
* <code>lot_size</code>: Base asset units per lot
* <code>tick_size</code>: Quote asset units per tick
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order


<a name="@Assumes_18"></a>

### Assumes

* That order has already been cancelled from the order book, and
as such that user necessarily has an open order as specified:
if an order has been cancelled from the book, then it had to
have been placed on the book, which means that the
corresponding user successfully placed it to begin with.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_remove_order_internal">remove_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, lot_size: u64, tick_size: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_remove_order_internal">remove_order_internal</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    lot_size: u64,
    tick_size: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
        market_accounts_map_ref_mut, market_account_id);
    // Get mutable reference <b>to</b> corresponding tree, mutable
    // reference <b>to</b> corresponding <a href="assets.md#0xc0deb00c_assets">assets</a> available field, mutable
    // reference <b>to</b> corresponding asset ceiling fields, available
    // size multiplier, and ceiling size multipler, based on side
    <b>let</b> (tree_ref_mut, asset_available_ref_mut, asset_ceiling_ref_mut,
         size_multiplier_available, size_multiplier_ceiling) =
        <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (
            &<b>mut</b> market_account_ref_mut.asks,
            &<b>mut</b> market_account_ref_mut.base_available,
            &<b>mut</b> market_account_ref_mut.quote_ceiling,
            lot_size,
            <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(<a href="order_id.md#0xc0deb00c_order_id">order_id</a>) * tick_size
        ) <b>else</b> (
            &<b>mut</b> market_account_ref_mut.bids,
            &<b>mut</b> market_account_ref_mut.quote_available,
            &<b>mut</b> market_account_ref_mut.base_ceiling,
            <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(<a href="order_id.md#0xc0deb00c_order_id">order_id</a>) * tick_size,
            lot_size
        );
    // Pop order from corresponding tree, storing specified size
    <b>let</b> size = <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
    // Calculate amount of asset unlocked by order cancellation
    <b>let</b> unlocked = size * size_multiplier_available;
    // Update available asset field for amount unlocked
    *asset_available_ref_mut = *asset_available_ref_mut + unlocked;
    // Calculate amount that ceiling decrements due <b>to</b> cancellation
    <b>let</b> ceiling_decrement_amount = size * size_multiplier_ceiling;
    // Decrement ceiling amount accordingly
    *asset_ceiling_ref_mut = *asset_ceiling_ref_mut -
        ceiling_decrement_amount;
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins_as_option_internal"></a>

## Function `withdraw_coins_as_option_internal`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account indicated by <code>market_account_id</code>, returning them
wrapped in an option


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_as_option_internal">withdraw_coins_as_option_internal</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, amount: u64): <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;CoinType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins_as_option_internal">withdraw_coins_as_option_internal</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    amount: u64
): <a href="_Option">option::Option</a>&lt;Coin&lt;CoinType&gt;&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, amount, <b>true</b>,
        <a href="user.md#0xc0deb00c_user_COIN_ASSET_TRANSFER">COIN_ASSET_TRANSFER</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_borrow_transfer_fields_mixed"></a>

## Function `borrow_transfer_fields_mixed`

Borrow mutable/immutable references to <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> fields
required when depositing/withdrawing <code>AssetType</code>

Look up the <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> having <code>market_account_id</code> in the
market accounts map indicated by <code>market_accounts_map_ref_mut</code>,
then return a mutable reference to the amount of <code>AssetType</code>
holdings, a mutable reference to the amount of <code>AssetType</code>
available for withdraw, a mutable reference to <code>AssetType</code>
ceiling, and an immutable reference to the generic asset
transfer custodian ID for the given market


<a name="@Returns_19"></a>

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
* <code>u64</code>: Immutable reference to generic asset transfer custodian
ID


<a name="@Assumes_20"></a>

### Assumes

* <code>market_accounts_map</code> has an entry with <code>market_account_id</code>


<a name="@Abort_conditions_21"></a>

### Abort conditions

* If <code>AssetType</code> is neither base nor quote for given market
account


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_transfer_fields_mixed">borrow_transfer_fields_mixed</a>&lt;AssetType&gt;(market_accounts_map_ref_mut: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u128, <a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>&gt;, market_account_id: u128): (&<b>mut</b> u64, &<b>mut</b> u64, &<b>mut</b> u64, &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_borrow_transfer_fields_mixed">borrow_transfer_fields_mixed</a>&lt;AssetType&gt;(
    market_accounts_map_ref_mut:
        &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u128, <a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>&gt;,
    market_account_id: u128
): (
    &<b>mut</b> u64,
    &<b>mut</b> u64,
    &<b>mut</b> u64,
    &u64,
) {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
            market_accounts_map_ref_mut, market_account_id);
    // Get asset type info
    <b>let</b> asset_type_info = <a href="_type_of">type_info::type_of</a>&lt;AssetType&gt;();
    // If is base asset, <b>return</b> mutable references <b>to</b> base fields
    <b>if</b> (asset_type_info == market_account_ref_mut.base_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account_ref_mut.base_total,
            &<b>mut</b> market_account_ref_mut.base_available,
            &<b>mut</b> market_account_ref_mut.base_ceiling,
            &market_account_ref_mut.generic_asset_transfer_custodian_id
        )
    // If is quote asset, <b>return</b> mutable references <b>to</b> quote fields
    } <b>else</b> <b>if</b> (asset_type_info == market_account_ref_mut.quote_type_info) {
        <b>return</b> (
            &<b>mut</b> market_account_ref_mut.quote_total,
            &<b>mut</b> market_account_ref_mut.quote_available,
            &<b>mut</b> market_account_ref_mut.quote_ceiling,
            &market_account_ref_mut.generic_asset_transfer_custodian_id
        )
    }; // Otherwise <b>abort</b>
    <b>abort</b> <a href="user.md#0xc0deb00c_user_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_user_deposit_asset"></a>

## Function `deposit_asset`

Deposit <code>amount</code> of <code>AssetType</code>, which may include
<code>optional_coins</code>, to <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account
having <code>market_account_id</code>, optionally verifying
<code>generic_asset_transfer_custodian_id</code> in the case of depositing
a generic asset (ignored if depositing coin type)


<a name="@Assumes_22"></a>

### Assumes

* That if depositing a coin asset, <code>amount</code> matches value of
<code>optional_coins</code>
* That when depositing a coin asset, if the market account
exists, then a corresponding collateral container does too


<a name="@Abort_conditions_23"></a>

### Abort conditions

* If deposit would overflow the total asset holdings ceiling
* If unauthorized <code>generic_asset_transfer_custodian_id</code> in the
case of depositing a generic asset


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, amount: u64, optional_coins: <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;, generic_asset_transfer_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_deposit_asset">deposit_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    amount: u64,
    optional_coins: <a href="_Option">option::Option</a>&lt;Coin&lt;AssetType&gt;&gt;,
    generic_asset_transfer_custodian_id: u64
) <b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total asset holdings, mutable
    // reference <b>to</b> amount of <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal,
    // mutable reference <b>to</b> total asset holdings ceiling, and
    // immutable reference <b>to</b> generic asset transfer custodian ID
    <b>let</b> (asset_total_ref_mut, asset_available_ref_mut,
         asset_ceiling_ref_mut, generic_asset_transfer_custodian_id_ref) =
            <a href="user.md#0xc0deb00c_user_borrow_transfer_fields_mixed">borrow_transfer_fields_mixed</a>&lt;AssetType&gt;(
                market_accounts_map_ref_mut, market_account_id);
    // Assert deposit does not overflow asset ceiling
    <b>assert</b>!(!((*asset_ceiling_ref_mut <b>as</b> u128) + (amount <b>as</b> u128) &gt;
        (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)), <a href="user.md#0xc0deb00c_user_E_DEPOSIT_OVERFLOW_ASSET_CEILING">E_DEPOSIT_OVERFLOW_ASSET_CEILING</a>);
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
            collateral_map_ref_mut, market_account_id);
        <a href="_merge">coin::merge</a>( // Merge optional coins into collateral
            collateral_ref_mut, <a href="_destroy_some">option::destroy_some</a>(optional_coins));
    } <b>else</b> { // If asset is not <a href="">coin</a> type
        // Verify indicated generic asset transfer custodian ID
        <b>assert</b>!(generic_asset_transfer_custodian_id ==
            *generic_asset_transfer_custodian_id_ref,
            <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
        // Destroy empty <a href="">option</a> resource
        <a href="_destroy_none">option::destroy_none</a>(optional_coins);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_route_collateral"></a>

## Function `fill_order_route_collateral`

Route collateral when filling an order, for coin assets.

Inner function for <code><a href="user.md#0xc0deb00c_user_fill_order_internal">fill_order_internal</a>()</code>.


<a name="@Type_parameters_24"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_25"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account ID
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base coins to
route from <code><a href="user.md#0xc0deb00c_user">user</a></code> to <code>base_coins_ref_mut</code>, else from
<code>base_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote coins to
route from <code>quote_coins_ref_mut</code> to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>
to <code>quote_coins_ref_mut</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, base_to_route: u64, quote_to_route: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    base_to_route: u64,
    quote_to_route: u64,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    // Determine route direction for base and quote relative <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>
    <b>let</b> (base_direction, quote_direction) =
        <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) (<a href="user.md#0xc0deb00c_user_OUT">OUT</a>, <a href="user.md#0xc0deb00c_user_IN">IN</a>) <b>else</b> (<a href="user.md#0xc0deb00c_user_IN">IN</a>, <a href="user.md#0xc0deb00c_user_OUT">OUT</a>);
    // If base asset is <a href="">coin</a> type then route base coins
    <b>if</b> (<a href="_is_some">option::is_some</a>(optional_base_coins_ref_mut))
        <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;BaseType&gt;(
            <a href="user.md#0xc0deb00c_user">user</a>, market_account_id,
            <a href="_borrow_mut">option::borrow_mut</a>(optional_base_coins_ref_mut),
            base_to_route, base_direction);
    // If quote asset is <a href="">coin</a> type then route quote coins
    <b>if</b> (<a href="_is_some">option::is_some</a>(optional_quote_coins_ref_mut))
        <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;QuoteType&gt;(
            <a href="user.md#0xc0deb00c_user">user</a>, market_account_id,
            <a href="_borrow_mut">option::borrow_mut</a>(optional_quote_coins_ref_mut),
            quote_to_route, quote_direction);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_fill_order_route_collateral_single"></a>

## Function `fill_order_route_collateral_single`

Route <code>amount</code> of <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> in <code>direction</code> either <code><a href="user.md#0xc0deb00c_user_IN">IN</a></code> or
<code><a href="user.md#0xc0deb00c_user_OUT">OUT</a></code>, relative to <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code>market_account_id</code>, either
from or to, respectively, coins at <code>external_coins_ref_mut</code>.

Inner function for <code><a href="user.md#0xc0deb00c_user_fill_order_route_collateral">fill_order_route_collateral</a>()</code>.


<a name="@Parameters_26"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account id
* <code>external_coins_ref_mut</code>: Effectively a counterparty to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>amount</code>: Amount of coins to route
* <code>direction</code>: <code><a href="user.md#0xc0deb00c_user_IN">IN</a></code> or <code><a href="user.md#0xc0deb00c_user_OUT">OUT</a></code>


<a name="@Assumes_27"></a>

### Assumes

* User has a <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> entry for given <code>market_account_id</code>
with range-checked coin amount for given operation: should
only be called after a user has successfully placed an order
in the first place.


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, external_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;, amount: u64, direction: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_route_collateral_single">fill_order_route_collateral_single</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    external_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;,
    amount: u64,
    direction: bool
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a> {
    // Borrow mutable reference <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral map
    <b>let</b> collateral_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral
    <b>let</b> collateral_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(collateral_map_ref_mut,
        market_account_id);
    // If inbound collateral <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>
    <b>if</b> (direction == <a href="user.md#0xc0deb00c_user_IN">IN</a>)
        // Merge <b>to</b> their collateral the extracted external coins
        <a href="_merge">coin::merge</a>(collateral_ref_mut,
            <a href="_extract">coin::extract</a>(external_coins_ref_mut, amount)) <b>else</b>
        // If outbound collateral from <a href="user.md#0xc0deb00c_user">user</a>, merge <b>to</b> external coins
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


<a name="@Parameters_28"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>market_account_id</code>: Corresponding market account ID
* <code>side</code>: <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order
* <code>complete_fill</code>: If <code><b>true</b></code>, the order is completely filled
* <code>fill_size</code>: Number of lots filled
* <code>base_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of base asset
units routed from <code><a href="user.md#0xc0deb00c_user">user</a></code>, else to <code><a href="user.md#0xc0deb00c_user">user</a></code>
* <code>quote_to_route</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, number of quote asset
units routed to <code><a href="user.md#0xc0deb00c_user">user</a></code>, else from <code><a href="user.md#0xc0deb00c_user">user</a></code>


<a name="@Assumes_29"></a>

### Assumes

* User has an open order as specified: should only be called
after a user has successfully placed an order in the first
place.


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, complete_fill: bool, fill_size: u64, base_to_route: u64, quote_to_route: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_fill_order_update_market_account">fill_order_update_market_account</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    complete_fill: bool,
    fill_size: u64,
    base_to_route: u64,
    quote_to_route: u64,
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref_mut = <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(
        market_accounts_map_ref_mut, market_account_id);
    <b>let</b> ( // Get mutable reference <b>to</b> corresponding orders tree,
        tree_ref_mut,
        asset_in, // Amount of inbound asset
        asset_in_total_ref_mut, // Inbound asset total field
        asset_in_available_ref_mut, // Available field
        asset_out, // Amount of outbound asset
        asset_out_total_ref_mut, // Outbound asset total field
        asset_out_ceiling_ref_mut, // Ceiling field
    ) = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>) ( // If an ask is matched
        &<b>mut</b> market_account_ref_mut.asks,
        quote_to_route,
        &<b>mut</b> market_account_ref_mut.quote_total,
        &<b>mut</b> market_account_ref_mut.quote_available,
        base_to_route,
        &<b>mut</b> market_account_ref_mut.base_total,
        &<b>mut</b> market_account_ref_mut.base_ceiling,
    ) <b>else</b> ( // If a bid is matched
        &<b>mut</b> market_account_ref_mut.bids,
        base_to_route,
        &<b>mut</b> market_account_ref_mut.base_total,
        &<b>mut</b> market_account_ref_mut.base_available,
        quote_to_route,
        &<b>mut</b> market_account_ref_mut.quote_total,
        &<b>mut</b> market_account_ref_mut.quote_ceiling,
    );
    <b>if</b> (complete_fill) { // If completely filling the order
        <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>); // Pop order
    } <b>else</b> { // If only partially filling the order
        // Get mutable reference <b>to</b> size left <b>to</b> fill on order
        <b>let</b> order_size_ref_mut =
            <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">critbit::borrow_mut</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
        // Decrement amount still unfilled
        *order_size_ref_mut = *order_size_ref_mut - fill_size;
    };
    // Increment asset in total amount by asset in amount
    *asset_in_total_ref_mut = *asset_in_total_ref_mut + asset_in;
    // Increment asset in available amount by asset in amount
    *asset_in_available_ref_mut = *asset_in_available_ref_mut + asset_in;
    // Decrement asset out total amount by asset out amount
    *asset_out_total_ref_mut = *asset_out_total_ref_mut - asset_out;
    // Decrement asset out ceiling amount by asset out amount
    *asset_out_ceiling_ref_mut = *asset_out_ceiling_ref_mut - asset_out;
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_asset_counts"></a>

## Function `get_asset_counts`

Return <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> asset count fields for given <code><a href="user.md#0xc0deb00c_user">user</a></code> and
<code>market_account_id</code>.


<a name="@Returns_30"></a>

### Returns

* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_total</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_available</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_ceiling</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_total</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_available</code>
* <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_ceiling</code>


<a name="@Restrictions_31"></a>

### Restrictions

* Restricted to private function to prevent excessive public
queries and thus transaction collisions


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128): (u64, u64, u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_get_asset_counts">get_asset_counts</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128
): (
    u64,
    u64,
    u64,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow immutable reference <b>to</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> market_account_ref =
        <a href="open_table.md#0xc0deb00c_open_table_borrow">open_table::borrow</a>(market_accounts_map_ref, market_account_id);
    ( // Return asset count fields
        market_account_ref.base_total,
        market_account_ref.base_available,
        market_account_ref.base_ceiling,
        market_account_ref.quote_total,
        market_account_ref.quote_available,
        market_account_ref.quote_ceiling
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_user_range_check_new_order"></a>

## Function `range_check_new_order`

Range check proposed order


<a name="@Parameters_32"></a>

### Parameters

* <code>side:</code> <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> or <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
* <code>size</code>: Order size, in lots
* <code>price</code>: Order price, in ticks per lot
* <code>lot_size</code>: Base asset units per lot
* <code>tick_size</code>: Quote asset units per tick
* <code>in_asset_ceiling</code>: <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_ceiling</code> if <code>side</code> is
<code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, and <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_ceiling</code> if <code>side</code> is <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code>
(total holdings ceiling amount for asset received from trade)
* <code>out_asset_available</code>: <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.base_available</code> if
<code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code>, and <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a>.quote_available</code> if <code>side</code>
is <code><a href="user.md#0xc0deb00c_user_BID">BID</a></code> (available withdraw amount for asset traded away)


<a name="@Returns_33"></a>

### Returns

* <code>u64</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> quote asset units required to fill
order, else base asset units (inbound asset fill)
* <code>u64</code>: If <code>side</code> is <code><a href="user.md#0xc0deb00c_user_ASK">ASK</a></code> base asset units required to fill
order, else quote asset units (outbound asset fill)


<a name="@Abort_conditions_34"></a>

### Abort conditions

* If <code>size</code> is 0
* If <code>price</code> is 0
* If number of ticks required to fill order overflows a <code>u64</code>
* If filling the order results in an overflow for incoming asset
* If filling the order results in an overflow for outgoing asset
* If not enough available outgoing asset to fill the order


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_range_check_new_order">range_check_new_order</a>(side: bool, size: u64, price: u64, lot_size: u64, tick_size: u64, in_asset_ceiling: u64, out_asset_available: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_range_check_new_order">range_check_new_order</a>(
    side: bool,
    size: u64,
    price: u64,
    lot_size: u64,
    tick_size: u64,
    in_asset_ceiling: u64,
    out_asset_available: u64
): (
    u64,
    u64
) {
    // Assert order <b>has</b> actual price
    <b>assert</b>!(size &gt; 0, <a href="user.md#0xc0deb00c_user_E_SIZE_0">E_SIZE_0</a>);
    // Assert order <b>has</b> actual size
    <b>assert</b>!(price &gt; 0, <a href="user.md#0xc0deb00c_user_E_PRICE_0">E_PRICE_0</a>);
    // Calculate base units needed <b>to</b> fill order
    <b>let</b> base_fill = (size <b>as</b> u128) * (lot_size <b>as</b> u128);
    // Calculate ticks <b>to</b> fill order
    <b>let</b> ticks = (size <b>as</b> u128) * (price <b>as</b> u128);
    // Assert ticks count can fit in a u64
    <b>assert</b>!(!(ticks &gt; (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)), <a href="user.md#0xc0deb00c_user_E_TICKS_OVERFLOW">E_TICKS_OVERFLOW</a>);
    // Calculate quote units <b>to</b> fill order
    <b>let</b> quote_fill = ticks * (tick_size <b>as</b> u128);
    // If an ask, <a href="user.md#0xc0deb00c_user">user</a> gets quote and trades away base, <b>else</b> flipped
    <b>let</b> (in_asset_fill, out_asset_fill) = <b>if</b> (side == <a href="user.md#0xc0deb00c_user_ASK">ASK</a>)
        (quote_fill, base_fill) <b>else</b> (base_fill, quote_fill);
    <b>assert</b>!( // Assert inbound asset does not overflow
        !(in_asset_fill + (in_asset_ceiling <b>as</b> u128) &gt; (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)),
        <a href="user.md#0xc0deb00c_user_E_OVERFLOW_ASSET_IN">E_OVERFLOW_ASSET_IN</a>);
    // Assert outbound asset fill amount fits in a u64
    <b>assert</b>!(!(out_asset_fill &gt; (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128)), <a href="user.md#0xc0deb00c_user_E_OVERFLOW_ASSET_OUT">E_OVERFLOW_ASSET_OUT</a>);
    // Assert enough outbound asset <b>to</b> cover the fill
    <b>assert</b>!(!(out_asset_fill &gt; (out_asset_available <b>as</b> u128)),
        <a href="user.md#0xc0deb00c_user_E_NOT_ENOUGH_ASSET_AVAILABLE">E_NOT_ENOUGH_ASSET_AVAILABLE</a>);
    // Return re-casted, range-checked amounts
    ((in_asset_fill <b>as</b> u64), (out_asset_fill <b>as</b> u64))
}
</code></pre>



</details>

<a name="0xc0deb00c_user_register_collateral_entry"></a>

## Function `register_collateral_entry`

Register <code><a href="user.md#0xc0deb00c_user">user</a></code> with <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> map entry for given <code>CoinType</code>
and <code>market_account_id</code>, initializing <code><a href="user.md#0xc0deb00c_user_Collateral">Collateral</a></code> if it does
not already exist.


<a name="@Abort_conditions_35"></a>

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
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(collateral_map_ref_mut,
        market_account_id), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
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


<a name="@Abort_conditions_36"></a>

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
    // Assert no entry <b>exists</b> for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map_ref_mut,
        market_account_id), <a href="user.md#0xc0deb00c_user_E_EXISTS_MARKET_ACCOUNT">E_EXISTS_MARKET_ACCOUNT</a>);
    // Add an empty entry for given <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
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

<a name="0xc0deb00c_user_verify_market_account_exists"></a>

## Function `verify_market_account_exists`

Verify <code><a href="user.md#0xc0deb00c_user">user</a></code> has a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> with <code>market_account_id</code>


<a name="@Abort_conditions_37"></a>

### Abort conditions

* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have a <code><a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a></code>
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> does not have a <code><a href="user.md#0xc0deb00c_user_MarketAccount">MarketAccount</a></code> for given
<code>market_account_id</code>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128
) <b>acquires</b> <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a> {
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> a <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>assert</b>!(<b>exists</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNTS">E_NO_MARKET_ACCOUNTS</a>);
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref = &<b>borrow_global</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> an entry in map for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(market_accounts_map_ref,
        market_account_id), <a href="user.md#0xc0deb00c_user_E_NO_MARKET_ACCOUNT">E_NO_MARKET_ACCOUNT</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_asset"></a>

## Function `withdraw_asset`

Withdraw <code>amount</code> of <code>AssetType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account
indicated by <code>market_account_id</code>, optionally returning coins if
<code>asset_is_coin</code> is <code><b>true</b></code>, optionally verifying
<code>generic_asset_transfer_custodian_id</code> in the case of withdrawing
a generic asset (ignored for withdrawing coin type)


<a name="@Abort_conditions_38"></a>

### Abort conditions

* If <code><a href="user.md#0xc0deb00c_user">user</a></code> has insufficient assets available for withdrawal
* If unauthorized <code>generic_asset_transfer_custodian_id</code> in the
case of depositing a generic asset


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_account_id: u128, amount: u64, asset_is_coin: bool, generic_asset_transfer_custodian_id: u64): <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;AssetType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;AssetType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_account_id: u128,
    amount: u64,
    asset_is_coin: bool,
    generic_asset_transfer_custodian_id: u64
): <a href="_Option">option::Option</a>&lt;Coin&lt;AssetType&gt;&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Verify <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> corresponding <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_verify_market_account_exists">verify_market_account_exists</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id);
    // Borrow mutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> market_accounts_map_ref_mut =
            &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>&gt;(<a href="user.md#0xc0deb00c_user">user</a>).map;
    // Borrow mutable reference <b>to</b> total asset holdings, mutable
    // reference <b>to</b> amount of <a href="assets.md#0xc0deb00c_assets">assets</a> available for withdrawal,
    // mutable reference <b>to</b> total asset holdings ceiling, and
    // immutable reference <b>to</b> generic asset transfer custodian ID
    <b>let</b> (asset_total_ref_mut, asset_available_ref_mut,
         asset_ceiling_ref_mut, generic_asset_transfer_custodian_id_ref) =
            <a href="user.md#0xc0deb00c_user_borrow_transfer_fields_mixed">borrow_transfer_fields_mixed</a>&lt;AssetType&gt;(
                market_accounts_map_ref_mut, market_account_id);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> enough available asset <b>to</b> withdraw
    <b>assert</b>!(!(amount &gt; *asset_available_ref_mut),
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
            collateral_map_ref_mut, market_account_id);
        // Return <a href="">coin</a> in an <a href="">option</a> wrapper
        <b>return</b> <a href="_some">option::some</a>&lt;Coin&lt;AssetType&gt;&gt;(
            <a href="_extract">coin::extract</a>(collateral_ref_mut, amount))
    } <b>else</b> { // If asset is not <a href="">coin</a> type
        // Verify indicated generic asset transfer custodian ID
        <b>assert</b>!(generic_asset_transfer_custodian_id ==
            *generic_asset_transfer_custodian_id_ref,
            <a href="user.md#0xc0deb00c_user_E_UNAUTHORIZED_CUSTODIAN">E_UNAUTHORIZED_CUSTODIAN</a>);
        // Return empty <a href="">option</a> wrapper
        <b>return</b> <a href="_none">option::none</a>&lt;Coin&lt;AssetType&gt;&gt;()
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_user_withdraw_coins"></a>

## Function `withdraw_coins`

Withdraw <code>amount</code> of coins of <code>CoinType</code> from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market
account having <code>market_id</code> and <code>general_custodian_id</code>,
returning coins


<a name="@Abort_conditions_39"></a>

### Abort conditions

* If <code>CoinType</code> does not correspond to a coin


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, general_custodian_id: u64, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="user.md#0xc0deb00c_user_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    amount: u64,
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b>
    <a href="user.md#0xc0deb00c_user_Collateral">Collateral</a>,
    <a href="user.md#0xc0deb00c_user_MarketAccounts">MarketAccounts</a>
{
    // Assert type corresponds <b>to</b> an initialized <a href="">coin</a>
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;CoinType&gt;(), <a href="user.md#0xc0deb00c_user_E_NOT_COIN_ASSET">E_NOT_COIN_ASSET</a>);
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id,
        general_custodian_id);
    // Withdraw corresponding amount of coins, <b>as</b> an <a href="">option</a>
    <b>let</b> option_coins = <a href="user.md#0xc0deb00c_user_withdraw_asset">withdraw_asset</a>&lt;CoinType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_account_id, amount, <b>true</b>, <a href="user.md#0xc0deb00c_user_COIN_ASSET_TRANSFER">COIN_ASSET_TRANSFER</a>);
    <a href="_destroy_some">option::destroy_some</a>(option_coins) // Return extracted coins
}
</code></pre>



</details>
