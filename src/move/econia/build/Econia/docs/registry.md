
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`

Manages registration capabilities and operations.


<a name="@Indexing_0"></a>

## Indexing


Custodian capabilities and underwriter capabilities are 1-indexed,
with an ID of 0 reserved as a flag for null. For consistency, market
IDs are thus 1-indexed too.


<a name="@Complete_docgen_index_1"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Indexing](#@Indexing_0)
-  [Complete docgen index](#@Complete_docgen_index_1)
-  [Struct `CustodianCapability`](#0xc0deb00c_registry_CustodianCapability)
-  [Resource `GenericAsset`](#0xc0deb00c_registry_GenericAsset)
-  [Struct `MarketInfo`](#0xc0deb00c_registry_MarketInfo)
-  [Struct `MarketRegistrationEvent`](#0xc0deb00c_registry_MarketRegistrationEvent)
-  [Struct `RecognizedMarketEvent`](#0xc0deb00c_registry_RecognizedMarketEvent)
-  [Struct `RecognizedMarketInfo`](#0xc0deb00c_registry_RecognizedMarketInfo)
-  [Resource `RecognizedMarkets`](#0xc0deb00c_registry_RecognizedMarkets)
-  [Resource `Registry`](#0xc0deb00c_registry_Registry)
-  [Struct `TradingPair`](#0xc0deb00c_registry_TradingPair)
-  [Struct `UnderwriterCapability`](#0xc0deb00c_registry_UnderwriterCapability)
-  [Constants](#@Constants_2)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::type_info</a>;
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
<code>base_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info. When base asset is an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code> (<code><b>address</b>:module::MyCoin</code> rather than
 <code>aptos_framework::coin::Coin&lt;<b>address</b>:module::MyCoin&gt;</code>).
 Otherwise should be <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">GenericAsset</a></code>.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 Custom base asset name for a generic market, provided by the
 underwriter who registers the market. Empty if a pure coin
 market.
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
<code>min_size: u64</code>
</dt>
<dd>
 Minimum number of lots per order.
</dd>
<dt>
<code>underwriter_id: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_NIL">NIL</a></code> if a pure coin market, otherwise ID of underwriter
 capability required to verify generic asset amounts. A
 market-wide ID that only applies to markets having a generic
 base asset.
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
<code>base_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 Base asset generic name, if any.
</dd>
<dt>
<code>quote_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info.
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
<code>min_size: u64</code>
</dt>
<dd>
 Minimum number of lots per order.
</dd>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_NIL">NIL</a></code> if a pure coin market, otherwise ID of underwriter
 capability required to verify generic asset amounts.
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
<code>min_size: u64</code>
</dt>
<dd>
 Minimum number of lots per order.
</dd>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_NIL">NIL</a></code> if a pure coin market, otherwise ID of underwriter
 capability required to verify generic asset amounts.
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
<code>market_id_to_info: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>&gt;</code>
</dt>
<dd>
 Map from 1-indexed market ID to corresponding market info,
 enabling iterated indexing by market ID.
</dd>
<dt>
<code>market_info_to_id: <a href="_Table">table::Table</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>, u64&gt;</code>
</dt>
<dd>
 Map from market info to corresponding 1-indexed market ID,
 enabling market duplicate checks.
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
<code>base_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 Base asset generic name, if any.
</dd>
<dt>
<code>quote_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info.
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

<a name="@Constants_2"></a>

## Constants


<a name="0xc0deb00c_registry_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_NIL">NIL</a>: u8 = 0;
</code></pre>



<a name="0xc0deb00c_registry_MAX_CHARACTERS_GENERIC"></a>

Maximum number of characters permitted in a generic asset name,
equal to the maximum number of characters permitted in a comment
line per PEP 8.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_MAX_CHARACTERS_GENERIC">MAX_CHARACTERS_GENERIC</a>: u8 = 72;
</code></pre>



<a name="0xc0deb00c_registry_MIN_CHARACTERS_GENERIC"></a>

Minimum number of characters permitted in a generic asset name,
equal to the number of spaces in an indentation level per PEP 8.


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_MIN_CHARACTERS_GENERIC">MIN_CHARACTERS_GENERIC</a>: u8 = 4;
</code></pre>
