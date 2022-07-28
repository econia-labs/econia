
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`



-  [Struct `E0`](#0xc0deb00c_registry_E0)
-  [Struct `E1`](#0xc0deb00c_registry_E1)
-  [Struct `E2`](#0xc0deb00c_registry_E2)
-  [Struct `E3`](#0xc0deb00c_registry_E3)
-  [Struct `E4`](#0xc0deb00c_registry_E4)
-  [Struct `E5`](#0xc0deb00c_registry_E5)
-  [Struct `E6`](#0xc0deb00c_registry_E6)
-  [Struct `E7`](#0xc0deb00c_registry_E7)
-  [Struct `E8`](#0xc0deb00c_registry_E8)
-  [Struct `E9`](#0xc0deb00c_registry_E9)
-  [Struct `E10`](#0xc0deb00c_registry_E10)
-  [Struct `E11`](#0xc0deb00c_registry_E11)
-  [Struct `E12`](#0xc0deb00c_registry_E12)
-  [Struct `E13`](#0xc0deb00c_registry_E13)
-  [Struct `E14`](#0xc0deb00c_registry_E14)
-  [Struct `E15`](#0xc0deb00c_registry_E15)
-  [Struct `E16`](#0xc0deb00c_registry_E16)
-  [Struct `E17`](#0xc0deb00c_registry_E17)
-  [Struct `E18`](#0xc0deb00c_registry_E18)
-  [Struct `E19`](#0xc0deb00c_registry_E19)
-  [Struct `CustodianCapability`](#0xc0deb00c_registry_CustodianCapability)
-  [Struct `MarketInfo`](#0xc0deb00c_registry_MarketInfo)
-  [Resource `Registry`](#0xc0deb00c_registry_Registry)
-  [Constants](#@Constants_0)
-  [Function `coin_is_in_market_pair`](#0xc0deb00c_registry_coin_is_in_market_pair)
-  [Function `coin_is_base_coin`](#0xc0deb00c_registry_coin_is_base_coin)
-  [Function `custodian_id`](#0xc0deb00c_registry_custodian_id)
-  [Function `init_registry`](#0xc0deb00c_registry_init_registry)
-  [Function `market_info`](#0xc0deb00c_registry_market_info)
-  [Function `n_custodians`](#0xc0deb00c_registry_n_custodians)
-  [Function `register_market_internal`](#0xc0deb00c_registry_register_market_internal)
    -  [Abort conditions](#@Abort_conditions_1)
-  [Function `scale_factor`](#0xc0deb00c_registry_scale_factor)
-  [Function `scale_factor_from_type_info`](#0xc0deb00c_registry_scale_factor_from_type_info)
-  [Function `scale_factor_from_market_info`](#0xc0deb00c_registry_scale_factor_from_market_info)
-  [Function `is_registered`](#0xc0deb00c_registry_is_registered)
-  [Function `is_registered_types`](#0xc0deb00c_registry_is_registered_types)
-  [Function `is_valid_custodian_id`](#0xc0deb00c_registry_is_valid_custodian_id)
-  [Function `register_custodian_capability`](#0xc0deb00c_registry_register_custodian_capability)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="capability.md#0xc0deb00c_capability">0xc0deb00c::capability</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
<b>use</b> <a href="util.md#0xc0deb00c_util">0xc0deb00c::util</a>;
</code></pre>



<a name="0xc0deb00c_registry_E0"></a>

## Struct `E0`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F0">F0</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E0">E0</a>
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

<a name="0xc0deb00c_registry_E1"></a>

## Struct `E1`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F1">F1</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E1">E1</a>
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

<a name="0xc0deb00c_registry_E2"></a>

## Struct `E2`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F2">F2</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E2">E2</a>
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

<a name="0xc0deb00c_registry_E3"></a>

## Struct `E3`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F3">F3</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E3">E3</a>
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

<a name="0xc0deb00c_registry_E4"></a>

## Struct `E4`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F4">F4</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E4">E4</a>
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

<a name="0xc0deb00c_registry_E5"></a>

## Struct `E5`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F5">F5</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E5">E5</a>
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

<a name="0xc0deb00c_registry_E6"></a>

## Struct `E6`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F6">F6</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E6">E6</a>
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

<a name="0xc0deb00c_registry_E7"></a>

## Struct `E7`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F7">F7</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E7">E7</a>
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

<a name="0xc0deb00c_registry_E8"></a>

## Struct `E8`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F8">F8</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E8">E8</a>
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

<a name="0xc0deb00c_registry_E9"></a>

## Struct `E9`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F9">F9</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E9">E9</a>
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

<a name="0xc0deb00c_registry_E10"></a>

## Struct `E10`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F10">F10</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E10">E10</a>
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

<a name="0xc0deb00c_registry_E11"></a>

## Struct `E11`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F11">F11</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E11">E11</a>
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

<a name="0xc0deb00c_registry_E12"></a>

## Struct `E12`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F12">F12</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E12">E12</a>
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

<a name="0xc0deb00c_registry_E13"></a>

## Struct `E13`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F13">F13</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E13">E13</a>
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

<a name="0xc0deb00c_registry_E14"></a>

## Struct `E14`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F14">F14</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E14">E14</a>
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

<a name="0xc0deb00c_registry_E15"></a>

## Struct `E15`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F15">F15</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E15">E15</a>
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

<a name="0xc0deb00c_registry_E16"></a>

## Struct `E16`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F16">F16</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E16">E16</a>
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

<a name="0xc0deb00c_registry_E17"></a>

## Struct `E17`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F17">F17</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E17">E17</a>
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

<a name="0xc0deb00c_registry_E18"></a>

## Struct `E18`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F18">F18</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E18">E18</a>
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

<a name="0xc0deb00c_registry_E19"></a>

## Struct `E19`

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_F19">F19</a></code>


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_E19">E19</a>
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

Type info for a <code>&lt;B, Q, E&gt;</code>-style market


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_coin_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Generic <code>CoinType</code> of <code>aptos_framework::coin::Coin</code>
</dd>
<dt>
<code>quote_coin_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Generic <code>CoinType</code> of <code>aptos_framework::coin::Coin</code>
</dd>
<dt>
<code>scale_exponent_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Scale exponent type defined in this module
</dd>
</dl>


</details>

<a name="0xc0deb00c_registry_Registry"></a>

## Resource `Registry`

Container for core key-value pair maps


<pre><code><b>struct</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>scales: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="_TypeInfo">type_info::TypeInfo</a>, u64&gt;</code>
</dt>
<dd>
 Map from scale exponent type (like <code><a href="registry.md#0xc0deb00c_registry_E0">E0</a></code> or <code><a href="registry.md#0xc0deb00c_registry_E12">E12</a></code>) to scale
 factor value (like <code><a href="registry.md#0xc0deb00c_registry_F0">F0</a></code> or <code><a href="registry.md#0xc0deb00c_registry_F12">F12</a></code>)
</dd>
<dt>
<code>markets: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>, <b>address</b>&gt;</code>
</dt>
<dd>
 Map from market to the order book host address
</dd>
<dt>
<code>n_custodians: u64</code>
</dt>
<dd>
 Number of custodians who have registered
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_registry_E_NOT_ECONIA"></a>

When caller is not Econia


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_registry_E_MARKET_EXISTS"></a>

When a given market is already registered


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_MARKET_EXISTS">E_MARKET_EXISTS</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_registry_E_MARKET_NOT_REGISTERED"></a>

When no such market exists


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_MARKET_NOT_REGISTERED">E_MARKET_NOT_REGISTERED</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_registry_E_NOT_COIN_BASE"></a>

When base type is not a valid coin


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_COIN_BASE">E_NOT_COIN_BASE</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_registry_E_NOT_COIN_QUOTE"></a>

When quote type is not a valid coin


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_COIN_QUOTE">E_NOT_COIN_QUOTE</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_registry_E_NOT_EXPONENT_TYPE"></a>

When looking up a type that is not a valid scale exponent


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_EXPONENT_TYPE">E_NOT_EXPONENT_TYPE</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR"></a>

When a coin is neither base nor quote on given market


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_registry_E_NO_REGISTRY"></a>

When registry not already initialized


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_registry_E_REGISTRY_EXISTS"></a>

When registry already initialized


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_REGISTRY_EXISTS">E_REGISTRY_EXISTS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_registry_E_SAME_COIN_TYPE"></a>

When base and quote type are same


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_E_SAME_COIN_TYPE">E_SAME_COIN_TYPE</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_registry_F0"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E0">E0</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F0">F0</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_registry_F1"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E1">E1</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F1">F1</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_registry_F10"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E10">E10</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F10">F10</a>: u64 = 10000000000;
</code></pre>



<a name="0xc0deb00c_registry_F11"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E11">E11</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F11">F11</a>: u64 = 100000000000;
</code></pre>



<a name="0xc0deb00c_registry_F12"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E12">E12</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F12">F12</a>: u64 = 1000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F13"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E13">E13</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F13">F13</a>: u64 = 10000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F14"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E14">E14</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F14">F14</a>: u64 = 100000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F15"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E15">E15</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F15">F15</a>: u64 = 1000000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F16"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E16">E16</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F16">F16</a>: u64 = 10000000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F17"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E17">E17</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F17">F17</a>: u64 = 100000000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F18"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E18">E18</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F18">F18</a>: u64 = 1000000000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F19"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E19">E19</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F19">F19</a>: u64 = 10000000000000000000;
</code></pre>



<a name="0xc0deb00c_registry_F2"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E2">E2</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F2">F2</a>: u64 = 100;
</code></pre>



<a name="0xc0deb00c_registry_F3"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E3">E3</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F3">F3</a>: u64 = 1000;
</code></pre>



<a name="0xc0deb00c_registry_F4"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E4">E4</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F4">F4</a>: u64 = 10000;
</code></pre>



<a name="0xc0deb00c_registry_F5"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E5">E5</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F5">F5</a>: u64 = 100000;
</code></pre>



<a name="0xc0deb00c_registry_F6"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E6">E6</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F6">F6</a>: u64 = 1000000;
</code></pre>



<a name="0xc0deb00c_registry_F7"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E7">E7</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F7">F7</a>: u64 = 10000000;
</code></pre>



<a name="0xc0deb00c_registry_F8"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E8">E8</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F8">F8</a>: u64 = 100000000;
</code></pre>



<a name="0xc0deb00c_registry_F9"></a>

Corresponds to <code><a href="registry.md#0xc0deb00c_registry_E9">E9</a></code>


<pre><code><b>const</b> <a href="registry.md#0xc0deb00c_registry_F9">F9</a>: u64 = 1000000000;
</code></pre>



<a name="0xc0deb00c_registry_coin_is_in_market_pair"></a>

## Function `coin_is_in_market_pair`

Return <code><b>true</b></code> if <code>CoinType</code> is either base or quote coin in
<code>market_info</code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_coin_is_in_market_pair">coin_is_in_market_pair</a>&lt;CoinType&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_coin_is_in_market_pair">coin_is_in_market_pair</a>&lt;CoinType&gt;(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool {
    // Get <a href="">coin</a> type info
    <b>let</b> coin_type_info = <a href="_type_of">type_info::type_of</a>&lt;CoinType&gt;();
    // Return <b>if</b> <a href="">coin</a> is either base or quote
    are_same_type_info(&coin_type_info, &market_info.base_coin_type) ||
    are_same_type_info(&coin_type_info, &market_info.quote_coin_type)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_coin_is_base_coin"></a>

## Function `coin_is_base_coin`

Return <code><b>true</b></code> if <code>CoinType</code> is base coin in <code>market_info</code>,
<code><b>false</b></code> if is quote coin, and abort otherwise


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_coin_is_base_coin">coin_is_base_coin</a>&lt;CoinType&gt;(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_coin_is_base_coin">coin_is_base_coin</a>&lt;CoinType&gt;(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool {
    // Get <a href="">coin</a> type info
    <b>let</b> coin_type_info = <a href="_type_of">type_info::type_of</a>&lt;CoinType&gt;();
    <b>if</b> (are_same_type_info(&coin_type_info, &market_info.base_coin_type))
        <b>return</b> <b>true</b>; // Return <b>true</b> <b>if</b> base <a href="">coin</a> match
    <b>if</b> (are_same_type_info(&coin_type_info, &market_info.quote_coin_type))
        <b>return</b> <b>false</b>; // Return <b>false</b> <b>if</b> quote <a href="">coin</a> match
    <b>abort</b> <a href="registry.md#0xc0deb00c_registry_E_NOT_IN_MARKET_PAIR">E_NOT_IN_MARKET_PAIR</a> // Else <b>abort</b>
}
</code></pre>



</details>

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

Move empty registry to the Econia account, then add scale map


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(account: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_init_registry">init_registry</a>(
    account: &<a href="">signer</a>,
) <b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert caller is Econia account
    <b>assert</b>!(address_of(account) == @econia, <a href="registry.md#0xc0deb00c_registry_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> does not already exist at Econia account
    <b>assert</b>!(!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_REGISTRY_EXISTS">E_REGISTRY_EXISTS</a>);
    // Move an empty <a href="registry.md#0xc0deb00c_registry">registry</a> <b>to</b> the Econia Account
    <b>move_to</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(account, <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>{
        scales: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>(),
        markets: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>(),
        n_custodians: 0
    });
    // Borrow mutable reference <b>to</b> the scales <a href="">table</a>
    <b>let</b> scales = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia).scales;
    // Add all entries <b>to</b> map from scale exponent <b>to</b> scale factor
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E0">E0</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F0">F0</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E1">E1</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F1">F1</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E2">E2</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F2">F2</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E3">E3</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F3">F3</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E4">E4</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F4">F4</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E5">E5</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F5">F5</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E6">E6</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F6">F6</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E7">E7</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F7">F7</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E8">E8</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F8">F8</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E9">E9</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F9">F9</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E10">E10</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F10">F10</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E11">E11</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F11">F11</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E12">E12</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F12">F12</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E13">E13</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F13">F13</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E14">E14</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F14">F14</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E15">E15</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F15">F15</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E16">E16</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F16">F16</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E17">E17</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F17">F17</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E18">E18</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F18">F18</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(scales, <a href="_type_of">type_info::type_of</a>&lt;<a href="registry.md#0xc0deb00c_registry_E19">E19</a>&gt;(), <a href="registry.md#0xc0deb00c_registry_F19">F19</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_market_info"></a>

## Function `market_info`

Pack provided type arguments into a <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a></code> and return


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_market_info">market_info</a>&lt;B, Q, E&gt;(): <a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_market_info">market_info</a>&lt;B, Q, E&gt;(
): <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a> {
    <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>{
        base_coin_type: <a href="_type_of">type_info::type_of</a>&lt;B&gt;(),
        quote_coin_type: <a href="_type_of">type_info::type_of</a>&lt;Q&gt;(),
        scale_exponent_type: <a href="_type_of">type_info::type_of</a>&lt;E&gt;(),
    }
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

<a name="0xc0deb00c_registry_register_market_internal"></a>

## Function `register_market_internal`

Register a market for the given base type, quote type,
scale exponent type, and <code>host</code>, provided an immutable reference
to an <code>EconiaCapability</code>.


<a name="@Abort_conditions_1"></a>

### Abort conditions

* If registry is not initialized
* If either of <code>B</code> or <code>Q</code> are not valid coin types
* If <code>B</code> and <code>Q</code> are the same type
* If market is already registered
* If <code>E</code> is not a valid scale exponent type


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;B, Q, E&gt;(host: <b>address</b>, _econia_capability: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_register_market_internal">register_market_internal</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    _econia_capability: &EconiaCapability
) <b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert the <a href="registry.md#0xc0deb00c_registry">registry</a> is already initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Assert base type is a valid <a href="">coin</a> type
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;B&gt;(), <a href="registry.md#0xc0deb00c_registry_E_NOT_COIN_BASE">E_NOT_COIN_BASE</a>);
    // Assert quote type is a valid <a href="">coin</a> type
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;Q&gt;(), <a href="registry.md#0xc0deb00c_registry_E_NOT_COIN_QUOTE">E_NOT_COIN_QUOTE</a>);
    // Get base type type info
    <b>let</b> base_coin_type = <a href="_type_of">type_info::type_of</a>&lt;B&gt;();
    // Get quote type type info
    <b>let</b> quote_coin_type = <a href="_type_of">type_info::type_of</a>&lt;Q&gt;();
    <b>assert</b>!(!are_same_type_info(&base_coin_type, &quote_coin_type),
        <a href="registry.md#0xc0deb00c_registry_E_SAME_COIN_TYPE">E_SAME_COIN_TYPE</a>); // Assert base and quote not same type
    // Get scale exponent type type info
    <b>let</b> scale_exponent_type = <a href="_type_of">type_info::type_of</a>&lt;E&gt;();
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> <a href="registry.md#0xc0deb00c_registry">registry</a> = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(&<a href="registry.md#0xc0deb00c_registry">registry</a>.scales, scale_exponent_type),
        <a href="registry.md#0xc0deb00c_registry_E_NOT_EXPONENT_TYPE">E_NOT_EXPONENT_TYPE</a>); // Verify valid exponent type
    <b>let</b> market_info = <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>{base_coin_type, quote_coin_type,
        scale_exponent_type}; // Pack new <a href="market.md#0xc0deb00c_market">market</a> info for types
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(&<a href="registry.md#0xc0deb00c_registry">registry</a>.markets, market_info),
        <a href="registry.md#0xc0deb00c_registry_E_MARKET_EXISTS">E_MARKET_EXISTS</a>); // Assert <a href="market.md#0xc0deb00c_market">market</a> is not already registered
    // Register host-<a href="market.md#0xc0deb00c_market">market</a> relationship
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(&<b>mut</b> <a href="registry.md#0xc0deb00c_registry">registry</a>.markets, market_info, host);
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_scale_factor"></a>

## Function `scale_factor`

Wrapper for <code><a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>()</code>, for type argument


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor">scale_factor</a>&lt;E&gt;(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor">scale_factor</a>&lt;E&gt;():
u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Pass type info, returning result
    <a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>(<a href="_type_of">type_info::type_of</a>&lt;E&gt;())
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_scale_factor_from_type_info"></a>

## Function `scale_factor_from_type_info`

Return scale factor corresponding to <code>scale_exponent_type_info</code>,
aborting if registry not initialized or if an invalid type


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>(scale_exponent_type_info: <a href="_TypeInfo">type_info::TypeInfo</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>(
    scale_exponent_type_info: <a href="_TypeInfo">type_info::TypeInfo</a>
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Assert <a href="registry.md#0xc0deb00c_registry">registry</a> initialized under Econia account
    <b>assert</b>!(<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia), <a href="registry.md#0xc0deb00c_registry_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Borrow immutable reference <b>to</b> scales <a href="">table</a>
    <b>let</b> scales = &<b>borrow_global</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia).scales;
    // Assert valid exponent type passed
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(scales, scale_exponent_type_info),
        <a href="registry.md#0xc0deb00c_registry_E_NOT_EXPONENT_TYPE">E_NOT_EXPONENT_TYPE</a>);
    // Return scale factor corresponding <b>to</b> scale exponent type
    *<a href="open_table.md#0xc0deb00c_open_table_borrow">open_table::borrow</a>(scales, scale_exponent_type_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_scale_factor_from_market_info"></a>

## Function `scale_factor_from_market_info`

Wrapper for <code><a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>()</code>, for <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a></code>
reference


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor_from_market_info">scale_factor_from_market_info</a>(market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_scale_factor_from_market_info">scale_factor_from_market_info</a>(
    market_info: &<a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): u64
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return query on accessed field
    <a href="registry.md#0xc0deb00c_registry_scale_factor_from_type_info">scale_factor_from_type_info</a>(market_info.scale_exponent_type)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_registered"></a>

## Function `is_registered`

Return <code><b>true</b></code> if <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a></code> is registered, else <code><b>false</b></code>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered">is_registered</a>(market_info: <a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered">is_registered</a>(
    market_info: <a href="registry.md#0xc0deb00c_registry_MarketInfo">MarketInfo</a>
): bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return <b>false</b> <b>if</b> no <a href="registry.md#0xc0deb00c_registry">registry</a> initialized
    <b>if</b> (!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia)) <b>return</b> <b>false</b>;
    // Borrow mutable reference <b>to</b> <a href="registry.md#0xc0deb00c_registry">registry</a>
    <b>let</b> <a href="registry.md#0xc0deb00c_registry">registry</a> = <b>borrow_global_mut</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia);
    // Return <b>if</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="registry.md#0xc0deb00c_registry">registry</a> cointains given <a href="market.md#0xc0deb00c_market">market</a> info
    <a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(&<a href="registry.md#0xc0deb00c_registry">registry</a>.markets, market_info)
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_registered_types"></a>

## Function `is_registered_types`

Wrapper for <code><a href="registry.md#0xc0deb00c_registry_is_registered">is_registered</a>()</code>, accepting type arguments


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_types">is_registered_types</a>&lt;B, Q, E&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_registered_types">is_registered_types</a>&lt;B, Q, E&gt;():
bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Pass type argument <a href="market.md#0xc0deb00c_market">market</a> info info
    <a href="registry.md#0xc0deb00c_registry_is_registered">is_registered</a>(<a href="registry.md#0xc0deb00c_registry_market_info">market_info</a>&lt;B, Q, E&gt;())
}
</code></pre>



</details>

<a name="0xc0deb00c_registry_is_valid_custodian_id"></a>

## Function `is_valid_custodian_id`

Return <code><b>true</b></code> if <code>custodian_id</code> has already been registered


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_valid_custodian_id">is_valid_custodian_id</a>(custodian_id: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="registry.md#0xc0deb00c_registry_is_valid_custodian_id">is_valid_custodian_id</a>(
    custodian_id: u64
): bool
<b>acquires</b> <a href="registry.md#0xc0deb00c_registry_Registry">Registry</a> {
    // Return <b>false</b> <b>if</b> <a href="registry.md#0xc0deb00c_registry">registry</a> hasn't been initialized
    <b>if</b> (!<b>exists</b>&lt;<a href="registry.md#0xc0deb00c_registry_Registry">Registry</a>&gt;(@econia)) <b>return</b> <b>false</b>;
    <a href="registry.md#0xc0deb00c_registry_custodian_id">custodian_id</a> &lt;= <a href="registry.md#0xc0deb00c_registry_n_custodians">n_custodians</a>()
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
    // Pack a <b>return</b> corresponding <a href="capability.md#0xc0deb00c_capability">capability</a>
    <a href="registry.md#0xc0deb00c_registry_CustodianCapability">CustodianCapability</a>{custodian_id}
}
</code></pre>



</details>
