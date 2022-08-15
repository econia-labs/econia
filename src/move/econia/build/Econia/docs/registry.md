
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`

Econia-wide registry functionality. Provides permissionless market
registration and tracking, delegated custodian registration.


-  [Struct `CustodianCapability`](#0xc0deb00c_registry_CustodianCapability)
-  [Struct `MarketInfo`](#0xc0deb00c_registry_MarketInfo)
-  [Resource `Registry`](#0xc0deb00c_registry_Registry)
-  [Struct `TradingPairInfo`](#0xc0deb00c_registry_TradingPairInfo)
-  [Constants](#@Constants_0)
-  [Function `custodian_id`](#0xc0deb00c_registry_custodian_id)
-  [Function `init_registry`](#0xc0deb00c_registry_init_registry)
-  [Function `is_in_market_pair`](#0xc0deb00c_registry_is_in_market_pair)
-  [Function `is_market_base`](#0xc0deb00c_registry_is_market_base)
-  [Function `is_registered_custodian_id`](#0xc0deb00c_registry_is_registered_custodian_id)
-  [Function `is_registered_trading_pair`](#0xc0deb00c_registry_is_registered_trading_pair)
-  [Function `n_custodians`](#0xc0deb00c_registry_n_custodians)
-  [Function `register_custodian_capability`](#0xc0deb00c_registry_register_custodian_capability)
-  [Function `register_market_internal`](#0xc0deb00c_registry_register_market_internal)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
    -  [Abort conditions](#@Abort_conditions_3)
    -  [Coin types](#@Coin_types_4)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="capability.md#0xc0deb00c_capability">0xc0deb00c::capability</a>;
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
 Serial ID generated upon registration as a custodian
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
 Map from trading pair to order book host address
</dd>
<dt>
<code>markets: <a href="">vector</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>&gt;</code>
</dt>
<dd>
 List of all available markets
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
 <code>Coin&lt;MyCoin&gt;</code>.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>.
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
<code>base_is_coin: bool</code>
</dt>
<dd>
 <code><b>true</b></code> if base asset is an <code>aptos_framework::coin::Coin</code>,
 stored as a field for lookup optimization
</dd>
<dt>
<code>quote_is_coin: bool</code>
</dt>
<dd>
 <code><b>true</b></code> if quote asset is an <code>aptos_framework::coin::Coin</code>,
 stored as a field for lookup optimization
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to withdraw/deposit
 collateral for an asset that is not a coin. A "market-wide"
 collateral transfer custodian ID, required to verify deposit
 and withdraw amounts for asset-agnostic markets.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_registry_E_NOT_ECONIA"></a>

When caller is not Econia


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_E_INVALID_CUSTODIAN"></a>

When invalid custodian ID


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 5;
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



<a name="0xc0deb00c_registry_E_SAME_TYPE"></a>

When base and quote type are same


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_SAME_TYPE">E_SAME_TYPE</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_registry_E_TICK_SIZE_0"></a>

When tick size specified as 0


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_registry_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
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

<a name="0xc0deb00c_registry_init_registry"></a>

## Function `init_registry`

Move empty registry to the Econia account


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(
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

<a name="0xc0deb00c_registry_is_in_market_pair"></a>

## Function `is_in_market_pair`

Return <code><b>true</b></code> if <code>T</code> is either base or quote in <code>market_info</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_in_market_pair">is_in_market_pair</a>&lt;T&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_in_market_pair">is_in_market_pair</a>&lt;T&gt;(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool {
    <b>let</b> <a href="">type_info</a> = <a href="_type_of">type_info::type_of</a>&lt;T&gt;(); // Get type info
    // Return <b>if</b> type is either base or quote
    <a href="">type_info</a> == market_info.trading_pair_info.base_type_info ||
    <a href="">type_info</a> == market_info.trading_pair_info.quote_type_info
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_market_base"></a>

## Function `is_market_base`

Return <code><b>true</b></code> if <code>T</code> is base type in <code>market_info</code>, <code><b>false</b></code> if
is quote type, and abort otherwise


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_market_base">is_market_base</a>&lt;T&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_market_base">is_market_base</a>&lt;T&gt;(
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

<a name="0xc0deb00c_registry_is_registered_custodian_id"></a>

## Function `is_registered_custodian_id`

Return <code><b>true</b></code> if <code>custodian_id</code> has been registered


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(custodian_id: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(
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

<a name="0xc0deb00c_registry_is_registered_trading_pair"></a>

## Function `is_registered_trading_pair`

Return <code><b>true</b></code> if <code><a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a></code> is registered, else <code><b>false</b></code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(trading_pair_info: <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(
    trading_pair_info: <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a>
): bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return <b>false</b> <b>if</b> no <a href="registry.md#0xc0deb00c_registry">registry</a> initialized
    <b>if</b> (!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia)) <b>return</b> <b>false</b>;
    // Borrow immutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> <a href="registry.md#0xc0deb00c_registry">registry</a> = <b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Return <b>if</b> hosts <a href="">table</a> contains given trading pair info
    <a href="_contains">table::contains</a>(&<a href="registry.md#0xc0deb00c_registry">registry</a>.hosts, trading_pair_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_n_custodians"></a>

## Function `n_custodians`

Return the number of registered custodians, aborting if registry
is not initialized


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>():
u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> <b>exists</b>
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Return number of registered custodians
    <b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia).n_custodians
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
    <b>let</b> <a href="registry.md#0xc0deb00c_registry">registry</a> = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Set custodian serial ID <b>to</b> the new number of custodians
    <b>let</b> custodian_id = <a href="registry.md#0xc0deb00c_registry">registry</a>.n_custodians + 1;
    // Update the <a href="registry.md#0xc0deb00c_registry">registry</a> for the new count
    <a href="registry.md#0xc0deb00c_registry">registry</a>.n_custodians = custodian_id;
    // Pack and <b>return</b> corresponding <a href="capability.md#0xc0deb00c_capability">capability</a>
    <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>{custodian_id}
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_market_internal"></a>

## Function `register_market_internal`

Register a market, provided an immutable reference to an
<code>EconiaCapability</code>.


<a name="@Type_parameters_1"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_2"></a>

### Parameters

* <code>host</code>: Host of corresponding order book
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per lot
* <code>custodian_id</code>: ID of custodian capability required
to withdraw/deposit collateral for an asset that is not a coin


<a name="@Abort_conditions_3"></a>

### Abort conditions

* If registry is not initialized
* If <code>BaseType</code> and <code>QuoteType</code> are the same
* If <code>lot_size</code> is zero
* If <code>tick_size</code> is zero
* If market is already registered
* If attempting to register an asset-agnostic order book for an
invalid <code>custodian_id</code>


<a name="@Coin_types_4"></a>

### Coin types

When registering a market with an asset corresponding to an
<code>aptos_framework::coin::Coin</code>, use only the phantom
<code>CoinType</code> as a type parameter. For example pass <code>MyCoin</code> rather
than <code>Coin&lt;MyCoin&gt;</code>.


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;BaseType, QuoteType&gt;(host: <b>address</b>, lot_size: u64, tick_size: u64, custodian_id: u64, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: <b>address</b>,
    lot_size: u64,
    tick_size: u64,
    custodian_id: u64,
    _econia_capability: &EconiaCapability
) <b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert the <a href="registry.md#0xc0deb00c_registry">registry</a> is already initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Get base type info
    <b>let</b> base_type_info = <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;();
    // Get quote type info
    <b>let</b> quote_type_info = <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;();
    // Assert base and quote not same type
    <b>assert</b>!(base_type_info != quote_type_info, <a href="registry.md#0xc0deb00c_registry_E_SAME_TYPE">E_SAME_TYPE</a>);
    // Determine <b>if</b> base is a <a href="">coin</a> type
    <b>let</b> base_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;();
    // Determine <b>if</b> quote is a <a href="">coin</a> type
    <b>let</b> quote_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteType&gt;();
    // Assert lot size is nonzero
    <b>assert</b>!(lot_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a>);
    // Assert tick size is nonzero
    <b>assert</b>!(tick_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>);
    // Pack corresponding trading pair info
    <b>let</b> trading_pair_info = <a href="registry.md#0xc0deb00c_registry_TradingPairInfo">TradingPairInfo</a>{
        base_type_info, quote_type_info, lot_size, tick_size,
        base_is_coin, quote_is_coin, custodian_id};
    <b>assert</b>!(!<a href="registry.md#0xc0deb00c_registry_is_registered_trading_pair">is_registered_trading_pair</a>(trading_pair_info),
        <a href="registry.md#0xc0deb00c_registry_E_MARKET_EXISTS">E_MARKET_EXISTS</a>); // Assert market is not already registered
    <b>if</b> (!base_is_coin || !quote_is_coin) { // If asset-agnostic
        // Assert custodian ID <b>has</b> been registered
        <b>assert</b>!(<a href="registry.md#0xc0deb00c_registry_is_registered_custodian_id">is_registered_custodian_id</a>(custodian_id),
            <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    } <b>else</b> { // If both base and quote are <a href="">coins</a>
        // Assert no market-level custodian for withdraw/deposits
        <b>assert</b>!(custodian_id == <a href="registry.md#0xc0deb00c_registry_NO_CUSTODIAN">NO_CUSTODIAN</a>, <a href="registry.md#0xc0deb00c_registry_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    };
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> <a href="registry.md#0xc0deb00c_registry">registry</a> = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Register host for given trading pair
    <a href="_add">table::add</a>(&<b>mut</b> <a href="registry.md#0xc0deb00c_registry">registry</a>.hosts, trading_pair_info, host);
    // Push back onto markets list a packed market info
    <a href="_push_back">vector::push_back</a>(&<b>mut</b> <a href="registry.md#0xc0deb00c_registry">registry</a>.markets,
        <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>{host, trading_pair_info});
}
</code></pre>



</details>
