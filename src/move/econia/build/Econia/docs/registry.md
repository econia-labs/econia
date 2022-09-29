
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`

Manages registration operations and capabilities.


<a name="@Functions_0"></a>

## Functions



<a name="@Public_getters_1"></a>

### Public getters


* <code><a href="registry.md#0xc0deb00c_registry_get_custodian_id">get_custodian_id</a>()</code>
* <code><a href="registry.md#0xc0deb00c_registry_get_underwriter_id">get_underwriter_id</a>()</code>


<a name="@Public_registration_functions_2"></a>

### Public registration functions


* <code><a href="registry.md#0xc0deb00c_registry_register_custodian_capability">register_custodian_capability</a>()</code>
* <code><a href="registry.md#0xc0deb00c_registry_register_underwriter_capability">register_underwriter_capability</a>()</code>


<a name="@Complete_docgen_index_3"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Functions](#@Functions_0)
    -  [Public getters](#@Public_getters_1)
    -  [Public registration functions](#@Public_registration_functions_2)
-  [Complete docgen index](#@Complete_docgen_index_3)
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
-  [Constants](#@Constants_4)
-  [Function `get_custodian_id`](#0xc0deb00c_registry_get_custodian_id)
    -  [Testing](#@Testing_5)
-  [Function `get_underwriter_id`](#0xc0deb00c_registry_get_underwriter_id)
    -  [Testing](#@Testing_6)
-  [Function `register_custodian_capability`](#0xc0deb00c_registry_register_custodian_capability)
    -  [Testing](#@Testing_7)
-  [Function `register_underwriter_capability`](#0xc0deb00c_registry_register_underwriter_capability)
    -  [Testing](#@Testing_8)
-  [Function `init_module`](#0xc0deb00c_registry_init_module)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
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
 asset amounts. None when base and quote types are both
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
 Market ID of recognized market.
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
 Map from market info to corresponding market ID, enabling
 duplicate checks and iterated indexing.
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

<a name="@Constants_4"></a>

## Constants


<a name="0xc0deb00c_registry_CUSTODIAN"></a>

Flag for custodian capability.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_CUSTODIAN">CUSTODIAN</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_registry_UNDERWRITER"></a>

Flag for underwriter capability.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_UNDERWRITER">UNDERWRITER</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_registry_get_custodian_id"></a>

## Function `get_custodian_id`

Return serial ID of given <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a></code>.


<a name="@Testing_5"></a>

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


<a name="@Testing_6"></a>

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


<a name="@Testing_7"></a>

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


<a name="@Testing_8"></a>

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
