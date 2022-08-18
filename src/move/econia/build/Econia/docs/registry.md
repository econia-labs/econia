
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`

Econia-wide registry functionality. Provides permissionless market
registration and tracking, delegated custodian registration.


-  [Struct `CustodianCapability`](#0xc0deb00c_registry_CustodianCapability)
-  [Struct `GenericAsset`](#0xc0deb00c_registry_GenericAsset)
-  [Struct `MarketInfo`](#0xc0deb00c_registry_MarketInfo)
-  [Resource `Registry`](#0xc0deb00c_registry_Registry)
-  [Struct `TradingPairInfo`](#0xc0deb00c_registry_TradingPairInfo)
-  [Constants](#@Constants_0)
-  [Function `custodian_id`](#0xc0deb00c_registry_custodian_id)
-  [Function `register_custodian_capability`](#0xc0deb00c_registry_register_custodian_capability)
-  [Function `init_registry`](#0xc0deb00c_registry_init_registry)
-  [Function `get_verified_market_custodian_id`](#0xc0deb00c_registry_get_verified_market_custodian_id)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
    -  [Returns](#@Returns_3)
-  [Function `is_base_asset`](#0xc0deb00c_registry_is_base_asset)
-  [Function `is_base_or_quote`](#0xc0deb00c_registry_is_base_or_quote)
-  [Function `is_registered_custodian_id`](#0xc0deb00c_registry_is_registered_custodian_id)
-  [Function `register_market_internal`](#0xc0deb00c_registry_register_market_internal)
    -  [Type parameters](#@Type_parameters_4)
    -  [Parameters](#@Parameters_5)
    -  [Abort conditions](#@Abort_conditions_6)
    -  [Coin types](#@Coin_types_7)
    -  [Non-coin types](#@Non-coin_types_8)
-  [Function `is_registered_trading_pair`](#0xc0deb00c_registry_is_registered_trading_pair)
-  [Function `n_custodians`](#0xc0deb00c_registry_n_custodians)
-  [Function `n_markets`](#0xc0deb00c_registry_n_markets)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::type_info</a>;
</code></pre>



<a name="0xc0deb00c_registry_CustodianCapability"></a>

## Struct `CustodianCapability`

Custodian capability used to manage delegated trading
permissions, administered to third-party registrants who may
store it as they wish.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 Serial ID, 1-indexed, generated upon registration as a
 custodian
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_GenericAsset"></a>

## Struct `GenericAsset`

Type flag for generic asset


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_MarketInfo"></a>

## Struct `MarketInfo`

Unique identifier for a market


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>host: <b>address</b></code>
</dt>
<dd>
 Account hosting corresponding <code>OrderBook</code>
</dd>
<dt>
<code>trading_pair_info: <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a></code>
</dt>
<dd>
 Trading pair parameters
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_Registry"></a>

## Resource `Registry`

Container for core registration information


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>hosts: <a href="_Table">table::Table</a>&lt;<a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a>, <b>address</b>&gt;</code>
</dt>
<dd>
 Map from trading pair to order book host address, used for
 duplicacy checks on pure-coin trading pairs
</dd>
<dt>
<code>markets: <a href="">vector</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>&gt;</code>
</dt>
<dd>
 List of all available markets, with each market's serial ID
 defined as its vector index (0-indexed)
</dd>
<dt>
<code>n_custodians: u64</code>
</dt>
<dd>
 Number of registered custodians
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_TradingPairInfo"></a>

## Struct `TradingPairInfo`

Information about a trading pair


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a> <b>has</b> <b>copy</b>, drop, store
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
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a></code>, or
 a non-coin asset indicated by the market host.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a></code>, or
 a non-coin asset indicated by the market host.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per lot
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to withdraw/deposit
 collateral for an asset that is not a coin. A "market-wide"
 collateral transfer custodian ID, required to verify deposit
 and withdraw amounts for asset-agnostic markets. Marked as
 <code><a href="registry.md#0xc0deb00c_registry_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and quote types are both coins.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_registry_E_NOT_ECONIA"></a>

When caller is not Econia


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_E_INVALID_BASE_ASSET"></a>

When an invalid base asset specified


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_INVALID_BASE_ASSET">E_INVALID_BASE_ASSET</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_registry_E_INVALID_CUSTODIAN"></a>

When invalid custodian ID


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_registry_E_INVALID_MARKET_ID"></a>

When invalid market ID


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_registry_E_INVALID_QUOTE_ASSET"></a>

When an invalid quote asset specified


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_INVALID_QUOTE_ASSET">E_INVALID_QUOTE_ASSET</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_registry_E_LOT_SIZE_0"></a>

When lot size specified as 0


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_registry_E_MARKET_EXISTS"></a>

When a given market is already registered


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_MARKET_EXISTS">E_MARKET_EXISTS</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR"></a>

When a type is neither base nor quote on given market


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_registry_E_NO_REGISTRY"></a>

When registry not already initialized


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_registry_E_REGISTRY_EXISTS"></a>

When registry already initialized


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_REGISTRY_EXISTS">E_REGISTRY_EXISTS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_registry_E_SAME_COIN"></a>

When base and quote types are the same for a pure-coin market


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_SAME_COIN">E_SAME_COIN</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_registry_E_TICK_SIZE_0"></a>

When tick size specified as 0


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_registry_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_PURE_COIN_PAIR"></a>

When both base and quote assets are coins


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_PURE_COIN_PAIR">PURE_COIN_PAIR</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_custodian_id"></a>

## Function `custodian_id`

Return serial ID of <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_custodian_id">custodian_id</a>(custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_custodian_id">custodian_id</a>(
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>
): u64 {
    custodian_capability_ref.custodian_id // Return serial ID
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_custodian_capability"></a>

## Function `register_custodian_capability`

Update the number of registered custodians and issue a
<code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a></code> with the corresponding serial ID. Abort if
registry is not initialized


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>(): <a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>():
<a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert the <a href="registry.md#0xc0deb00c_registry">registry</a> is already initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Borrow mutable reference <b>to</b> registy
    <b>let</b> registry_ref_mut = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Set custodian serial ID <b>to</b> the new number of custodians
    <b>let</b> custodian_id = registry_ref_mut.n_custodians + 1;
    // Update the <a href="registry.md#0xc0deb00c_registry">registry</a> for the new count
    registry_ref_mut.n_custodians = custodian_id;
    // Pack and <b>return</b> corresponding capability
    <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>{custodian_id}
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_init_registry"></a>

## Function `init_registry`

Move empty registry to the Econia account


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(
    <a href="">account</a>: &<a href="">signer</a>,
) {
    // Assert caller is Econia <a href="">account</a>
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="registry.md#0xc0deb00c_registry_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> does not already exist at Econia <a href="">account</a>
    <b>assert</b>!(!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_REGISTRY_EXISTS">E_REGISTRY_EXISTS</a>);
    // Move an empty <a href="registry.md#0xc0deb00c_registry">registry</a> <b>to</b> the Econia Account
    <b>move_to</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(<a href="">account</a>, <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>{
        hosts: <a href="_new">table::new</a>(),
        markets: <a href="_empty">vector::empty</a>(),
        n_custodians: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_get_verified_market_custodian_id"></a>

## Function `get_verified_market_custodian_id`

Verify assets for market with given serial ID, then return
corresponding custodian ID


<a name="@Type_parameters_1"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_2"></a>

### Parameters

* <code>market_id</code>: Serial ID of market to look up


<a name="@Returns_3"></a>

### Returns

* ID of custodian capability required to withdraw/deposit
collateral on an asset-agnostic market, else <code><a href="registry.md#0xc0deb00c_registry_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_verified_market_custodian_id">get_verified_market_custodian_id</a>&lt;BaseType, QuoteType&gt;(market_id: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_verified_market_custodian_id">get_verified_market_custodian_id</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id: u64,
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert the <a href="registry.md#0xc0deb00c_registry">registry</a> is already initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Borrow immutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> registry_ref = <b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Assert that a <a href="market.md#0xc0deb00c_market">market</a> <b>exists</b> <b>with</b> the given serial ID
    <b>assert</b>!(market_id &lt; <a href="_length">vector::length</a>(&registry_ref.markets),
        <a href="registry.md#0xc0deb00c_registry_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>);
    // Borrow immutable reference <b>to</b> corresponding trading pair info
    <b>let</b> trading_pair_info_ref = &<a href="_borrow">vector::borrow</a>(
        &registry_ref.markets, market_id).trading_pair_info;
    // Assert valid base asset type info
    <b>assert</b>!(trading_pair_info_ref.base_type_info ==
        <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(), <a href="registry.md#0xc0deb00c_registry_E_INVALID_BASE_ASSET">E_INVALID_BASE_ASSET</a>);
    // Assert valid quote asset type info
    <b>assert</b>!(trading_pair_info_ref.quote_type_info ==
        <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(), <a href="registry.md#0xc0deb00c_registry_E_INVALID_QUOTE_ASSET">E_INVALID_QUOTE_ASSET</a>);
    // Return <a href="market.md#0xc0deb00c_market">market</a>-wide collateral transfer custodian ID
    trading_pair_info_ref.custodian_id
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_base_asset"></a>

## Function `is_base_asset`

Return <code><b>true</b></code> if <code>T</code> is base type in <code>market_info</code>, <code><b>false</b></code> if
is quote type, and abort otherwise

Set as friend function to restrict excess registry queries


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_base_asset">is_base_asset</a>&lt;T&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_base_asset">is_base_asset</a>&lt;T&gt;(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool {
    <b>let</b> <a href="">type_info</a> = <a href="_type_of">type_info::type_of</a>&lt;T&gt;(); // Get type info
    <b>if</b> (<a href="">type_info</a> ==  market_info.trading_pair_info.base_type_info)
        <b>return</b> <b>true</b>; // Return <b>true</b> <b>if</b> base match
    <b>if</b> (<a href="">type_info</a> ==  market_info.trading_pair_info.quote_type_info)
        <b>return</b> <b>false</b>; // Return <b>false</b> <b>if</b> quote match
    <b>abort</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a> // Else <b>abort</b>
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_base_or_quote"></a>

## Function `is_base_or_quote`

Return <code><b>true</b></code> if <code>T</code> is either base or quote in <code>market_info</code>

Set as friend function to restrict excess registry queries


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_base_or_quote">is_base_or_quote</a>&lt;T&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_base_or_quote">is_base_or_quote</a>&lt;T&gt;(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool {
    <b>let</b> <a href="">type_info</a> = <a href="_type_of">type_info::type_of</a>&lt;T&gt;(); // Get type info
    // Return <b>if</b> type is either base or quote
    <a href="">type_info</a> == market_info.trading_pair_info.base_type_info ||
    <a href="">type_info</a> == market_info.trading_pair_info.quote_type_info
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_registered_custodian_id"></a>

## Function `is_registered_custodian_id`

Return <code><b>true</b></code> if <code>custodian_id</code> has been registered

Set as friend function to restrict excess registry queries


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(custodian_id: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(
    custodian_id: u64
): bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return <b>false</b> <b>if</b> <a href="registry.md#0xc0deb00c_registry">registry</a> hasn't been initialized
    <b>if</b> (!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia)) <b>return</b> <b>false</b>;
    // Return <b>if</b> custodian ID <b>has</b> been registered
    <a href="registry.md#0xc0deb00c_registry_custodian_id">custodian_id</a> &lt;= <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>() && custodian_id != <a href="registry.md#0xc0deb00c_registry_NO_CUSTODIAN">NO_CUSTODIAN</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_market_internal"></a>

## Function `register_market_internal`

Register a market


<a name="@Type_parameters_4"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_5"></a>

### Parameters

* <code>host</code>: Host of corresponding order book
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per lot
* <code>custodian_id</code>: ID of custodian capability required to approve
deposits and withdrawals of non-coin assets (passed as no
<code><a href="registry.md#0xc0deb00c_registry_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and quote are both coins)


<a name="@Abort_conditions_6"></a>

### Abort conditions

* If registry is not initialized
* If <code>lot_size</code> is zero
* If <code>tick_size</code> is zero
* If <code>BaseType</code> and <code>QuoteType</code> are the same coin type
* If corresponding pure-coin market is already registered
* If attempting to register an asset-agnostic order book for an
invalid <code>custodian_id</code>


<a name="@Coin_types_7"></a>

### Coin types

* When registering a market with an asset corresponding to an
<code>aptos_framework::coin::Coin</code>, use only the phantom
<code>CoinType</code> as a type parameter: for example pass <code>MyCoin</code>
rather than <code>Coin&lt;MyCoin&gt;</code>
* If both <code>BaseType</code> and <code>QuoteType</code> are coins, only one such
market may be registered with the corresponding <code>lot_size</code> and
<code>tick_size</code> for the given base/quote combination


<a name="@Non-coin_types_8"></a>

### Non-coin types

* If either <code>BaseType</code> or <code>QuoteType</code> is a non-coin type, then
the trading pair will be considered asset-agnostic, and
registration will thus require a registered custodian ID
* Registrants may optionally supply their own custom types
rather than <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a></code>, which is considered the default


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;BaseType, QuoteType&gt;(host: <b>address</b>, lot_size: u64, tick_size: u64, custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: <b>address</b>,
    lot_size: u64,
    tick_size: u64,
    custodian_id: u64,
) <b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert the <a href="registry.md#0xc0deb00c_registry">registry</a> is already initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Assert lot size is nonzero
    <b>assert</b>!(lot_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a>);
    // Assert tick size is nonzero
    <b>assert</b>!(tick_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>);
    // Get base type info
    <b>let</b> base_type_info = <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;();
    // Get quote type info
    <b>let</b> quote_type_info = <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;();
    // Determine <b>if</b> base is a <a href="">coin</a> type
    <b>let</b> base_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;();
    // Determine <b>if</b> quote is a <a href="">coin</a> type
    <b>let</b> quote_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteType&gt;();
    // Determine <b>if</b> a pure <a href="">coin</a> pair
    <b>let</b> pure_coin = base_is_coin && quote_is_coin;
    // Pack corresponding trading pair info
    <b>let</b> trading_pair_info = <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a>{base_type_info,
        quote_type_info, lot_size, tick_size, custodian_id};
    <b>if</b> (pure_coin) { // If attempting <b>to</b> register pure <a href="">coin</a> pair
        // Assert base and quote not same type
        <b>assert</b>!(base_type_info != quote_type_info, <a href="registry.md#0xc0deb00c_registry_E_SAME_COIN">E_SAME_COIN</a>);
        // Assert <a href="market.md#0xc0deb00c_market">market</a> is not already registered
        <b>assert</b>!(!<a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(trading_pair_info),
            <a href="registry.md#0xc0deb00c_registry_E_MARKET_EXISTS">E_MARKET_EXISTS</a>);
        // Assert no <a href="market.md#0xc0deb00c_market">market</a>-level custodian for withdraw/deposits
        <b>assert</b>!(custodian_id == <a href="registry.md#0xc0deb00c_registry_PURE_COIN_PAIR">PURE_COIN_PAIR</a>, <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    } <b>else</b> { // If an asset agnostic order book
        // Assert custodian ID <b>has</b> been registered
        <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(custodian_id),
            <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    };
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> registry_ref_mut = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Register host for given trading pair
    <a href="_add">table::add</a>(&<b>mut</b> registry_ref_mut.hosts, trading_pair_info, host);
    // Push back onto markets list a packed <a href="market.md#0xc0deb00c_market">market</a> info
    <a href="_push_back">vector::push_back</a>(&<b>mut</b> registry_ref_mut.markets,
        <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>{host, trading_pair_info});
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_registered_trading_pair"></a>

## Function `is_registered_trading_pair`

Return <code><b>true</b></code> if <code><a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a></code> is registered, else <code><b>false</b></code>

Set as private function to restrict excess registry queries


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(trading_pair_info: <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(
    trading_pair_info: <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a>
): bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return <b>false</b> <b>if</b> no <a href="registry.md#0xc0deb00c_registry">registry</a> initialized
    <b>if</b> (!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia)) <b>return</b> <b>false</b>;
    // Borrow immutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> registry_ref = <b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Return <b>if</b> hosts <a href="">table</a> contains given trading pair info
    <a href="_contains">table::contains</a>(&registry_ref.hosts, trading_pair_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_n_custodians"></a>

## Function `n_custodians`

Return the number of registered custodians, aborting if registry
is not initialized

Set as private function to restrict excess registry queries


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>():
u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> <b>exists</b>
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Return number of registered custodians
    <b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia).n_custodians
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_n_markets"></a>

## Function `n_markets`

Return the number of registered markets, aborting if registry
is not initialized

Set as private function to restrict excess registry queries


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_markets">n_markets</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_markets">n_markets</a>():
u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> <b>exists</b>
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Return number of registered markets
    <a href="_length">vector::length</a>(&<b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia).markets)
}
</code></pre>



</details>
