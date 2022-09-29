
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`

Manages registration capabilities and operations.


<a name="@Indexing_0"></a>

## Indexing


Custodian and underwriter capabilities IDs are 1-indexed, since they
are optional: an ID of 0 is thus reserved as a flag for when there
is no associated capability.

For consistency, market IDs are thus 1-indexed as well.


<a name="@Functions_1"></a>

## Functions



<a name="@Public_getters_2"></a>

### Public getters


* <code><a href="registry.md#0xc0deb00c_registry_get_custodian_id">get_custodian_id</a>()</code>
* <code><a href="registry.md#0xc0deb00c_registry_get_underwriter_id">get_underwriter_id</a>()</code>


<a name="@Public_registration_functions_3"></a>

### Public registration functions


* <code><a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>()</code>
* <code><a href="registry.md#0xc0deb00c_registry_register_underwriter_capability">register_underwriter_capability</a>()</code>


<a name="@Complete_docgen_index_4"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Indexing](#@Indexing_0)
-  [Functions](#@Functions_1)
    -  [Public getters](#@Public_getters_2)
    -  [Public registration functions](#@Public_registration_functions_3)
-  [Complete docgen index](#@Complete_docgen_index_4)
-  [Struct `CustodianCapability`](#0xc0deb00c_registry_CustodianCapability)
-  [Struct `CapabilityRegistrationEvent`](#0xc0deb00c_registry_CapabilityRegistrationEvent)
-  [Resource `GenericAsset`](#0xc0deb00c_registry_GenericAsset)
-  [Struct `MarketInfo`](#0xc0deb00c_registry_MarketInfo)
-  [Struct `MarketRegistrationEvent`](#0xc0deb00c_registry_MarketRegistrationEvent)
-  [Struct `RecognizedMarketEvent`](#0xc0deb00c_registry_RecognizedMarketEvent)
-  [Struct `RecognizedMarketInfo`](#0xc0deb00c_registry_RecognizedMarketInfo)
-  [Resource `RecognizedMarkets`](#0xc0deb00c_registry_RecognizedMarkets)
-  [Resource `Registry`](#0xc0deb00c_registry_Registry)
-  [Struct `TradingPair`](#0xc0deb00c_registry_TradingPair)
-  [Struct `UnderwriterCapability`](#0xc0deb00c_registry_UnderwriterCapability)
-  [Constants](#@Constants_5)
-  [Function `get_custodian_id`](#0xc0deb00c_registry_get_custodian_id)
    -  [Testing](#@Testing_6)
-  [Function `get_underwriter_id`](#0xc0deb00c_registry_get_underwriter_id)
    -  [Testing](#@Testing_7)
-  [Function `register_custodian_capability`](#0xc0deb00c_registry_register_custodian_capability)
    -  [Testing](#@Testing_8)
-  [Function `register_underwriter_capability`](#0xc0deb00c_registry_register_underwriter_capability)
    -  [Testing](#@Testing_9)
-  [Function `register_market_base_coin_internal`](#0xc0deb00c_registry_register_market_base_coin_internal)
    -  [Aborts](#@Aborts_10)
-  [Function `register_market_base_generic_internal`](#0xc0deb00c_registry_register_market_base_generic_internal)
    -  [Aborts](#@Aborts_11)
-  [Function `init_module`](#0xc0deb00c_registry_init_module)
-  [Function `register_market_internal`](#0xc0deb00c_registry_register_market_internal)
    -  [Type parameters](#@Type_parameters_12)
    -  [Parameters](#@Parameters_13)
    -  [Emits](#@Emits_14)
    -  [Aborts](#@Aborts_15)
    -  [Assumptions](#@Assumptions_16)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="incentives.md#0xc0deb00c_incentives">0xc0deb00c::incentives</a>;
<b>use</b> <a href="tablist.md#0xc0deb00c_tablist">0xc0deb00c::tablist</a>;
</code></pre>



<a name="0xc0deb00c_registry_CustodianCapability"></a>

## Struct `CustodianCapability`

Custodian capability required to approve order placement, order
cancellation, and coin withdrawals. Administered to third-party
registrants who may store it as they wish.


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
 custodian.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_CapabilityRegistrationEvent"></a>

## Struct `CapabilityRegistrationEvent`

Emitted when a capability is registered.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_CapabilityRegistrationEvent">CapabilityRegistrationEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>capability_type: bool</code>
</dt>
<dd>
 Either <code><a href="registry.md#0xc0deb00c_registry_CUSTODIAN">CUSTODIAN</a></code> or <code><a href="registry.md#0xc0deb00c_registry_UNDERWRITER">UNDERWRITER</a></code>, the capability type
 just registered.
</dd>
<dt>
<code>capability_id: u64</code>
</dt>
<dd>
 ID of capability just registered.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_GenericAsset"></a>

## Resource `GenericAsset`

Type flag for generic asset. Must be passed as base asset type
argument for generic market operations.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a> <b>has</b> key
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

Information about a market.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Base asset type name. When base asset is an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code> (<code><b>address</b>:module::MyCoin</code> rather than
 <code>aptos_framework::coin::Coin&lt;<b>address</b>:module::MyCoin&gt;</code>), and
 <code>underwriter_id</code> is none. Otherwise can be any value, and
 <code>underwriter</code> is some.
</dd>
<dt>
<code>quote_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Quote asset coin type name. Corresponds to a phantom
 <code>CoinType</code> (<code><b>address</b>:module::MyCoin</code> rather than
 <code>aptos_framework::coin::Coin&lt;<b>address</b>:module::MyCoin&gt;</code>).
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot (when base asset is
 a coin, corresponds to <code>aptos_framework::coin::Coin.value</code>).
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote coin units exchanged per tick (corresponds
 to <code>aptos_framework::coin::Coin.value</code>).
</dd>
<dt>
<code>underwriter_id: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 ID of underwriter capability required to verify generic
 asset amounts. A market-wide ID that only applies to markets
 having a generic base asset. None when base and quote types
 are both coins.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_MarketRegistrationEvent"></a>

## Struct `MarketRegistrationEvent`

Emitted when a market is registered.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_MarketRegistrationEvent">MarketRegistrationEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_id: u64</code>
</dt>
<dd>
 Market ID of the market just registered.
</dd>
<dt>
<code>base_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Base asset type name.
</dd>
<dt>
<code>quote_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Quote asset type name.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot.
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per tick.
</dd>
<dt>
<code>underwriter_id: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 ID of <code><a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a></code> required to verify generic
 asset amounts. None when base and quote assets are both
 coins.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_RecognizedMarketEvent"></a>

## Struct `RecognizedMarketEvent`

Emitted when a recognized market is added, removed, or updated.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_RecognizedMarketEvent">RecognizedMarketEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>trading_pair: <a href="registry.md#0xc0deb00c_registry_TradingPair">registry::TradingPair</a></code>
</dt>
<dd>
 The associated trading pair.
</dd>
<dt>
<code>recognized_market_info: <a href="_Option">option::Option</a>&lt;<a href="registry.md#0xc0deb00c_registry_RecognizedMarketInfo">registry::RecognizedMarketInfo</a>&gt;</code>
</dt>
<dd>
 The recognized market info for the given trading pair after
 an addition or update. None if a removal.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_RecognizedMarketInfo"></a>

## Struct `RecognizedMarketInfo`

Recognized market info for a given trading pair.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_RecognizedMarketInfo">RecognizedMarketInfo</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>market_id: u64</code>
</dt>
<dd>
 Market ID of recognized market, 0-indexed.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot.
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per tick.
</dd>
<dt>
<code>underwriter_id: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 ID of underwriter capability required to verify generic
 asset amounts. A market-wide ID that only applies to
 markets having a generic base asset. None when base and
 quote types are both coins.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_RecognizedMarkets"></a>

## Resource `RecognizedMarkets`

Recognized markets for specific trading pairs.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_RecognizedMarkets">RecognizedMarkets</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;<a href="registry.md#0xc0deb00c_registry_TradingPair">registry::TradingPair</a>, <a href="registry.md#0xc0deb00c_registry_RecognizedMarketInfo">registry::RecognizedMarketInfo</a>&gt;</code>
</dt>
<dd>
 Map from trading pair info to market information for the
 recognized market, if any, for given trading pair.
</dd>
<dt>
<code>recognized_market_events: <a href="_EventHandle">event::EventHandle</a>&lt;<a href="registry.md#0xc0deb00c_registry_RecognizedMarketEvent">registry::RecognizedMarketEvent</a>&gt;</code>
</dt>
<dd>
 Event handle for recognized market events.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_Registry"></a>

## Resource `Registry`

Global registration information.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>markets: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>, u64&gt;</code>
</dt>
<dd>
 Map from market info to corresponding 1-indexed market ID,
 enabling duplicate checks and iterated indexing.
</dd>
<dt>
<code>n_custodians: u64</code>
</dt>
<dd>
 The number of registered custodians.
</dd>
<dt>
<code>n_underwriters: u64</code>
</dt>
<dd>
 The number of registered underwriters.
</dd>
<dt>
<code>market_registration_events: <a href="_EventHandle">event::EventHandle</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketRegistrationEvent">registry::MarketRegistrationEvent</a>&gt;</code>
</dt>
<dd>
 Event handle for market registration events.
</dd>
<dt>
<code>capability_registration_events: <a href="_EventHandle">event::EventHandle</a>&lt;<a href="registry.md#0xc0deb00c_registry_CapabilityRegistrationEvent">registry::CapabilityRegistrationEvent</a>&gt;</code>
</dt>
<dd>
 Event handle for capability registration events.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_TradingPair"></a>

## Struct `TradingPair`

A combination of a base asset and a quote asset.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_TradingPair">TradingPair</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Base type name.
</dd>
<dt>
<code>quote_type: <a href="_String">string::String</a></code>
</dt>
<dd>
 Quote type name.
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_UnderwriterCapability"></a>

## Struct `UnderwriterCapability`

Underwriter capability required to verify generic asset
amounts. Administered to third-party registrants who may store
it as they wish.


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 Serial ID, 1-indexed, generated upon registration as an
 underwriter.
</dd>
</dl>


</details>

<a name="@Constants_5"></a>

## Constants


<a name="0xc0deb00c_registry_CUSTODIAN"></a>

Flag for custodian capability.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_CUSTODIAN">CUSTODIAN</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_registry_E_BASE_NOT_COIN"></a>

Base coin type has not been initialized for a pure coin market.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_BASE_NOT_COIN">E_BASE_NOT_COIN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_E_BASE_QUOTE_SAME"></a>

Base and quote asset descriptors are identical.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_BASE_QUOTE_SAME">E_BASE_QUOTE_SAME</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_registry_E_GENERIC_TOO_FEW_CHARACTERS"></a>

Generic base asset descriptor has too few charaters.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_FEW_CHARACTERS">E_GENERIC_TOO_FEW_CHARACTERS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_registry_E_GENERIC_TOO_MANY_CHARACTERS"></a>

Generic base asset descriptor has too many charaters.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_MANY_CHARACTERS">E_GENERIC_TOO_MANY_CHARACTERS</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_registry_E_LOT_SIZE_0"></a>

Lot size specified as 0.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_registry_E_MARKET_REGISTERED"></a>

Market is already registered.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_MARKET_REGISTERED">E_MARKET_REGISTERED</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_registry_E_QUOTE_NOT_COIN"></a>

Quote asset type has not been initialized as a coin.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_QUOTE_NOT_COIN">E_QUOTE_NOT_COIN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_registry_E_TICK_SIZE_0"></a>

Tick size specified as 0.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_registry_MAX_CHARACTERS_GENERIC"></a>

Maximum number of characters permitted in a generic asset name,
equal to the maximum number of characters permitted in a comment
line per PEP 8.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_MAX_CHARACTERS_GENERIC">MAX_CHARACTERS_GENERIC</a>: u64 = 72;
</code></pre>



<a name="0xc0deb00c_registry_MIN_CHARACTERS_GENERIC"></a>

Minimum number of characters permitted in a generic asset name,
equal to the number of spaces in an indentation level per PEP 8.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_MIN_CHARACTERS_GENERIC">MIN_CHARACTERS_GENERIC</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_registry_UNDERWRITER"></a>

Flag for underwriter capability.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_UNDERWRITER">UNDERWRITER</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_registry_get_custodian_id"></a>

## Function `get_custodian_id`

Return serial ID of given <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a></code>.


<a name="@Testing_6"></a>

### Testing


* <code>test_register_capabilities()</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_custodian_id">get_custodian_id</a>(custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_custodian_id">get_custodian_id</a>(
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>
): u64 {
    custodian_capability_ref.custodian_id
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_get_underwriter_id"></a>

## Function `get_underwriter_id`

Return serial ID of given <code><a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a></code>.


<a name="@Testing_7"></a>

### Testing


* <code>test_register_capabilities()</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">get_underwriter_id</a>(underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">get_underwriter_id</a>(
    underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a>
): u64 {
    underwriter_capability_ref.underwriter_id
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_custodian_capability"></a>

## Function `register_custodian_capability`

Return a unique <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a></code>.

Increment the number of registered custodians, then issue a
capability with the corresponding serial ID. Requires utility
coins to cover the custodian registration fee.


<a name="@Testing_8"></a>

### Testing


* <code>test_register_capabilities()</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>&lt;UtilityCoinType&gt;(utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityCoinType&gt;): <a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>&lt;UtilityCoinType&gt;(
    utility_coins: Coin&lt;UtilityCoinType&gt;
): <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>.
    <b>let</b> registry_ref_mut = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Set custodian serial ID <b>to</b> the new number of custodians.
    <b>let</b> custodian_id = registry_ref_mut.n_custodians + 1;
    // Update the <a href="registry.md#0xc0deb00c_registry">registry</a> for the new count.
    registry_ref_mut.n_custodians = custodian_id;
    <a href="incentives.md#0xc0deb00c_incentives">incentives</a>:: // Deposit provided utility coins.
        deposit_custodian_registration_utility_coins(utility_coins);
    // Pack and <b>return</b> corresponding capability.
    <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>{custodian_id}
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_underwriter_capability"></a>

## Function `register_underwriter_capability`

Return a unique <code><a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a></code>.

Increment the number of registered underwriters, then issue a
capability with the corresponding serial ID. Requires utility
coins to cover the underwriter registration fee.


<a name="@Testing_9"></a>

### Testing


* <code>test_register_capabilities()</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_underwriter_capability">register_underwriter_capability</a>&lt;UtilityCoinType&gt;(utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityCoinType&gt;): <a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_underwriter_capability">register_underwriter_capability</a>&lt;UtilityCoinType&gt;(
    utility_coins: Coin&lt;UtilityCoinType&gt;
): <a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a>
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>.
    <b>let</b> registry_ref_mut = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Set underwriter serial ID <b>to</b> the new number of underwriters.
    <b>let</b> underwriter_id = registry_ref_mut.n_underwriters + 1;
    // Update the <a href="registry.md#0xc0deb00c_registry">registry</a> for the new count.
    registry_ref_mut.n_underwriters = underwriter_id;
    <a href="incentives.md#0xc0deb00c_incentives">incentives</a>:: // Deposit provided utility coins.
        deposit_underwriter_registration_utility_coins(utility_coins);
    // Pack and <b>return</b> corresponding capability.
    <a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a>{underwriter_id}
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_market_base_coin_internal"></a>

## Function `register_market_base_coin_internal`

Wrapped market registration call for a base coin type.

See inner function <code><a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>()</code>.


<a name="@Aborts_10"></a>

### Aborts


* <code><a href="registry.md#0xc0deb00c_registry_E_BASE_NOT_COIN">E_BASE_NOT_COIN</a></code>: Base coin type is not initialized.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_base_coin_internal">register_market_base_coin_internal</a>&lt;BaseCoinType, QuoteCoinType, UtilityCoinType&gt;(lot_size: u64, tick_size: u64, utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityCoinType&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_base_coin_internal">register_market_base_coin_internal</a>&lt;
    BaseCoinType,
    QuoteCoinType,
    UtilityCoinType
&gt;(
    lot_size: u64,
    tick_size: u64,
    utility_coins: Coin&lt;UtilityCoinType&gt;
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert base <a href="">coin</a> type is initialized.
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseCoinType&gt;(), <a href="registry.md#0xc0deb00c_registry_E_BASE_NOT_COIN">E_BASE_NOT_COIN</a>);
    // Add <b>to</b> the <a href="registry.md#0xc0deb00c_registry">registry</a> a corresponding entry, returnig new
    // market ID.
    <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;QuoteCoinType, UtilityCoinType&gt;(
        <a href="_type_name">type_info::type_name</a>&lt;BaseCoinType&gt;(), lot_size, tick_size,
        <a href="_none">option::none</a>(), utility_coins)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_market_base_generic_internal"></a>

## Function `register_market_base_generic_internal`

Wrapped market registration call for a generic base type,
requiring immutable reference to corresponding
<code><a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a></code> for the market, and <code>base_type</code>
descriptor.

See inner function <code><a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>()</code>.


<a name="@Aborts_11"></a>

### Aborts


* <code><a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_FEW_CHARACTERS">E_GENERIC_TOO_FEW_CHARACTERS</a></code>: Asset descriptor is too short.
* <code><a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_MANY_CHARACTERS">E_GENERIC_TOO_MANY_CHARACTERS</a></code>: Asset descriptor is too long.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_base_generic_internal">register_market_base_generic_internal</a>&lt;QuoteCoinType, UtilityCoinType&gt;(base_type: <a href="_String">string::String</a>, lot_size: u64, tick_size: u64, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>, utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityCoinType&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_base_generic_internal">register_market_base_generic_internal</a>&lt;
    QuoteCoinType,
    UtilityCoinType
&gt;(
    base_type: String,
    lot_size: u64,
    tick_size: u64,
    underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">UnderwriterCapability</a>,
    utility_coins: Coin&lt;UtilityCoinType&gt;
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert generic base asset <a href="">string</a> is not too short.
    <b>assert</b>!(<a href="_length">string::length</a>(&base_type) &gt;= <a href="registry.md#0xc0deb00c_registry_MIN_CHARACTERS_GENERIC">MIN_CHARACTERS_GENERIC</a>,
        <a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_FEW_CHARACTERS">E_GENERIC_TOO_FEW_CHARACTERS</a>);
    // Assert generic base asset <a href="">string</a> is not too long.
    <b>assert</b>!(<a href="_length">string::length</a>(&base_type) &lt;= <a href="registry.md#0xc0deb00c_registry_MAX_CHARACTERS_GENERIC">MAX_CHARACTERS_GENERIC</a>,
        <a href="registry.md#0xc0deb00c_registry_E_GENERIC_TOO_MANY_CHARACTERS">E_GENERIC_TOO_MANY_CHARACTERS</a>);
    // Get underwriter ID.
    <b>let</b> underwriter_id = <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">get_underwriter_id</a>(underwriter_capability_ref);
    // Add <b>to</b> the <a href="registry.md#0xc0deb00c_registry">registry</a> a corresponding entry, returnig new
    // market ID.
    <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;QuoteCoinType, UtilityCoinType&gt;(
        base_type, lot_size, tick_size, <a href="_some">option::some</a>(underwriter_id),
        utility_coins)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_init_module"></a>

## Function `init_module`

Initialize the Econia registry and recognized markets list upon
module publication.


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {
    // Initialize <a href="registry.md#0xc0deb00c_registry">registry</a>.
    <b>move_to</b>(econia, <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>{
        markets: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>(),
        n_custodians: 0,
        n_underwriters: 0,
        market_registration_events:
            <a href="_new_event_handle">account::new_event_handle</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketRegistrationEvent">MarketRegistrationEvent</a>&gt;(econia),
        capability_registration_events:
            <a href="_new_event_handle">account::new_event_handle</a>&lt;<a href="registry.md#0xc0deb00c_registry_CapabilityRegistrationEvent">CapabilityRegistrationEvent</a>&gt;(econia)
    });
    // Initialize recognized markets list.
    <b>move_to</b>(econia, <a href="registry.md#0xc0deb00c_registry_RecognizedMarkets">RecognizedMarkets</a>{
        map: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>(),
        recognized_market_events:
            <a href="_new_event_handle">account::new_event_handle</a>&lt;<a href="registry.md#0xc0deb00c_registry_RecognizedMarketEvent">RecognizedMarketEvent</a>&gt;(econia)
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_register_market_internal"></a>

## Function `register_market_internal`

Register a market in the global registry.


<a name="@Type_parameters_12"></a>

### Type parameters


* <code>QuoteCoinType</code>: The quote coin type for the market.
* <code>UtilityCoinType</code>: The utility coin type.


<a name="@Parameters_13"></a>

### Parameters


* <code>base_type</code>: The base asset type. Should correspond to a coin
type if called by <code><a href="registry.md#0xc0deb00c_registry_register_market_base_coin_internal">register_market_base_coin_internal</a>()</code>, else
provided by the market registrant.
* <code>lot_size</code>: Lot size for the market.
* <code>tick_size</code>: Tick size for the market.
* <code>underwriter_id</code>: Optional underwriter ID for a market with a
generic base asset.
* <code>utility_coins</code>: Utility coins paid to register a market.


<a name="@Emits_14"></a>

### Emits


* <code><a href="registry.md#0xc0deb00c_registry_MarketRegistrationEvent">MarketRegistrationEvent</a></code>: Parameters of the market just
registered.


<a name="@Aborts_15"></a>

### Aborts


* <code><a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a></code>: Lot size is 0.
* <code><a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a></code>: Tick size is 0.
* <code><a href="registry.md#0xc0deb00c_registry_E_QUOTE_NOT_COIN">E_QUOTE_NOT_COIN</a></code>: Tick size is 0.
* <code><a href="registry.md#0xc0deb00c_registry_E_BASE_QUOTE_SAME">E_BASE_QUOTE_SAME</a></code>: Base and quote type are the same.
* <code><a href="registry.md#0xc0deb00c_registry_E_MARKET_REGISTERED">E_MARKET_REGISTERED</a></code>: Markets map already contains an entry
for specified market info.


<a name="@Assumptions_16"></a>

### Assumptions


* <code>underwriter_id</code> has been properly packed and passed by either
<code>register_market_base_coin_internal</code> or
<code>register_market_base_generic_interal</code>.


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;QuoteCoinType, UtilityCoinType&gt;(base_type: <a href="_String">string::String</a>, lot_size: u64, tick_size: u64, underwriter_id: <a href="_Option">option::Option</a>&lt;u64&gt;, utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityCoinType&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;
    QuoteCoinType,
    UtilityCoinType
&gt;(
    base_type: String,
    lot_size: u64,
    tick_size: u64,
    underwriter_id: Option&lt;u64&gt;,
    utility_coins: Coin&lt;UtilityCoinType&gt;
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert lot size is nonzero.
    <b>assert</b>!(lot_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_LOT_SIZE_0">E_LOT_SIZE_0</a>);
    // Assert tick size is nonzero.
    <b>assert</b>!(tick_size &gt; 0, <a href="registry.md#0xc0deb00c_registry_E_TICK_SIZE_0">E_TICK_SIZE_0</a>);
    // Assert quote <a href="">coin</a> type is initialized.
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteCoinType&gt;(), <a href="registry.md#0xc0deb00c_registry_E_QUOTE_NOT_COIN">E_QUOTE_NOT_COIN</a>);
    // Get quote type name.
    <b>let</b> quote_type = <a href="_type_name">type_info::type_name</a>&lt;QuoteCoinType&gt;();
    // Assert base and quote type names are not the same.
    <b>assert</b>!(base_type != quote_type, <a href="registry.md#0xc0deb00c_registry_E_BASE_QUOTE_SAME">E_BASE_QUOTE_SAME</a>);
    <b>let</b> market_info = <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>{ // Pack market info.
        base_type, quote_type, lot_size, tick_size, underwriter_id};
    // Mutably borrow <a href="registry.md#0xc0deb00c_registry">registry</a>.
    <b>let</b> registry_ref_mut = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Mutably borrow markets map.
    <b>let</b> markets_ref_mut = &<b>mut</b> registry_ref_mut.markets;
    <b>assert</b>!(!<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(markets_ref_mut, market_info),
        <a href="registry.md#0xc0deb00c_registry_E_MARKET_REGISTERED">E_MARKET_REGISTERED</a>); // Assert market not registered.
    // Get 1-indexed market ID.
    <b>let</b> market_id = <a href="tablist.md#0xc0deb00c_tablist_length">tablist::length</a>(markets_ref_mut) + 1;
    // Register a market entry.
    <a href="tablist.md#0xc0deb00c_tablist_add">tablist::add</a>(markets_ref_mut, market_info, market_id);
    // Emit a market registration <a href="">event</a>.
    <a href="_emit_event">event::emit_event</a>(&<b>mut</b> registry_ref_mut.market_registration_events,
        <a href="registry.md#0xc0deb00c_registry_MarketRegistrationEvent">MarketRegistrationEvent</a>{market_id, base_type, quote_type,
            lot_size, tick_size, underwriter_id});
    <a href="incentives.md#0xc0deb00c_incentives_deposit_market_registration_utility_coins">incentives::deposit_market_registration_utility_coins</a>&lt;UtilityCoinType&gt;(
            utility_coins); // Deposit utility coins.
    market_id // Return market ID.
}
</code></pre>



</details>
