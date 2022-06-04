
<a name="0xc0deb00c_Market"></a>

# Module `0xc0deb00c::Market`


<a name="@Prices_and_scales_0"></a>

## Prices and scales

* "Scale exponent"
* "Scale factor"


-  [Prices and scales](#@Prices_and_scales_0)
-  [Struct `E0`](#0xc0deb00c_Market_E0)
-  [Struct `E1`](#0xc0deb00c_Market_E1)
-  [Struct `E2`](#0xc0deb00c_Market_E2)
-  [Struct `E3`](#0xc0deb00c_Market_E3)
-  [Struct `E4`](#0xc0deb00c_Market_E4)
-  [Struct `E5`](#0xc0deb00c_Market_E5)
-  [Struct `E6`](#0xc0deb00c_Market_E6)
-  [Struct `E7`](#0xc0deb00c_Market_E7)
-  [Struct `E8`](#0xc0deb00c_Market_E8)
-  [Struct `E9`](#0xc0deb00c_Market_E9)
-  [Struct `E10`](#0xc0deb00c_Market_E10)
-  [Struct `E11`](#0xc0deb00c_Market_E11)
-  [Struct `E12`](#0xc0deb00c_Market_E12)
-  [Struct `E13`](#0xc0deb00c_Market_E13)
-  [Struct `E14`](#0xc0deb00c_Market_E14)
-  [Struct `E15`](#0xc0deb00c_Market_E15)
-  [Struct `E16`](#0xc0deb00c_Market_E16)
-  [Struct `E17`](#0xc0deb00c_Market_E17)
-  [Struct `E18`](#0xc0deb00c_Market_E18)
-  [Struct `E19`](#0xc0deb00c_Market_E19)
-  [Resource `MC`](#0xc0deb00c_Market_MC)
-  [Struct `MI`](#0xc0deb00c_Market_MI)
-  [Resource `MR`](#0xc0deb00c_Market_MR)
-  [Struct `OB`](#0xc0deb00c_Market_OB)
-  [Resource `OO`](#0xc0deb00c_Market_OO)
-  [Struct `P`](#0xc0deb00c_Market_P)
-  [Constants](#@Constants_1)
    -  [Error codes](#@Error_codes_2)
    -  [Type name bytestrings](#@Type_name_bytestrings_3)
-  [Function `init_registry`](#0xc0deb00c_Market_init_registry)
-  [Function `register_market`](#0xc0deb00c_Market_register_market)
-  [Function `scale_factor`](#0xc0deb00c_Market_scale_factor)
-  [Function `verify_address`](#0xc0deb00c_Market_verify_address)
-  [Function `verify_bytestring`](#0xc0deb00c_Market_verify_bytestring)
-  [Function `verify_market_types`](#0xc0deb00c_Market_verify_market_types)
-  [Function `verify_t`](#0xc0deb00c_Market_verify_t)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/Table.md#0x1_Table">0x1::Table</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo">0x1::TypeInfo</a>;
<b>use</b> <a href="CritBit.md#0xc0deb00c_CritBit">0xc0deb00c::CritBit</a>;
</code></pre>



<a name="0xc0deb00c_Market_E0"></a>

## Struct `E0`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E0">E0</a>
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

<a name="0xc0deb00c_Market_E1"></a>

## Struct `E1`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E1">E1</a>
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

<a name="0xc0deb00c_Market_E2"></a>

## Struct `E2`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E2">E2</a>
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

<a name="0xc0deb00c_Market_E3"></a>

## Struct `E3`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E3">E3</a>
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

<a name="0xc0deb00c_Market_E4"></a>

## Struct `E4`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E4">E4</a>
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

<a name="0xc0deb00c_Market_E5"></a>

## Struct `E5`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E5">E5</a>
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

<a name="0xc0deb00c_Market_E6"></a>

## Struct `E6`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E6">E6</a>
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

<a name="0xc0deb00c_Market_E7"></a>

## Struct `E7`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E7">E7</a>
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

<a name="0xc0deb00c_Market_E8"></a>

## Struct `E8`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E8">E8</a>
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

<a name="0xc0deb00c_Market_E9"></a>

## Struct `E9`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E9">E9</a>
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

<a name="0xc0deb00c_Market_E10"></a>

## Struct `E10`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E10">E10</a>
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

<a name="0xc0deb00c_Market_E11"></a>

## Struct `E11`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E11">E11</a>
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

<a name="0xc0deb00c_Market_E12"></a>

## Struct `E12`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E12">E12</a>
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

<a name="0xc0deb00c_Market_E13"></a>

## Struct `E13`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E13">E13</a>
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

<a name="0xc0deb00c_Market_E14"></a>

## Struct `E14`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E14">E14</a>
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

<a name="0xc0deb00c_Market_E15"></a>

## Struct `E15`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E15">E15</a>
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

<a name="0xc0deb00c_Market_E16"></a>

## Struct `E16`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E16">E16</a>
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

<a name="0xc0deb00c_Market_E17"></a>

## Struct `E17`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E17">E17</a>
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

<a name="0xc0deb00c_Market_E18"></a>

## Struct `E18`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E18">E18</a>
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

<a name="0xc0deb00c_Market_E19"></a>

## Struct `E19`



<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_E19">E19</a>
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

<a name="0xc0deb00c_Market_MC"></a>

## Resource `MC`

Market container


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_MC">MC</a>&lt;B, Q, E&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>ob: <a href="Market.md#0xc0deb00c_Market_OB">Market::OB</a>&lt;B, Q, E&gt;</code>
</dt>
<dd>
 Order book
</dd>
</dl>


</details>

<a name="0xc0deb00c_Market_MI"></a>

## Struct `MI`

Market info


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_MI">MI</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>b: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Base CoinType TypeInfo
</dd>
<dt>
<code>q: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Quote CoinType TypeInfo
</dd>
<dt>
<code>e: <a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a></code>
</dt>
<dd>
 Scale exponent TypeInfo
</dd>
</dl>


</details>

<a name="0xc0deb00c_Market_MR"></a>

## Resource `MR`

Market registry


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_MR">MR</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>t: <a href="../../../build/AptosFramework/docs/Table.md#0x1_Table_Table">Table::Table</a>&lt;<a href="Market.md#0xc0deb00c_Market_MI">Market::MI</a>, <b>address</b>&gt;</code>
</dt>
<dd>
 Table from <code><a href="Market.md#0xc0deb00c_Market_MI">MI</a></code> to address hosting the corresponding <code><a href="Market.md#0xc0deb00c_Market_MC">MC</a></code>
</dd>
</dl>


</details>

<a name="0xc0deb00c_Market_OB"></a>

## Struct `OB`

Order book


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_OB">OB</a>&lt;B, Q, E&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>f: u64</code>
</dt>
<dd>
 Scale factor
</dd>
<dt>
<code>a: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;<a href="Market.md#0xc0deb00c_Market_P">Market::P</a>&gt;</code>
</dt>
<dd>
 Asks
</dd>
<dt>
<code>b: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;<a href="Market.md#0xc0deb00c_Market_P">Market::P</a>&gt;</code>
</dt>
<dd>
 Bids
</dd>
</dl>


</details>

<a name="0xc0deb00c_Market_OO"></a>

## Resource `OO`

Open orders on a user's account


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_OO">OO</a>&lt;B, Q, E&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>f: u64</code>
</dt>
<dd>
 Scale factor
</dd>
<dt>
<code>a: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;u64&gt;</code>
</dt>
<dd>
 Asks
</dd>
<dt>
<code>b: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;u64&gt;</code>
</dt>
<dd>
 Bids
</dd>
<dt>
<code>b_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;B&gt;</code>
</dt>
<dd>
 Base coins
</dd>
<dt>
<code>b_a: u64</code>
</dt>
<dd>
 Base coins available to withdraw
</dd>
<dt>
<code>q_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;Q&gt;</code>
</dt>
<dd>
 Quote coins
</dd>
<dt>
<code>q_a: u64</code>
</dt>
<dd>
 Quote coins available to withdraw
</dd>
</dl>


</details>

<a name="0xc0deb00c_Market_P"></a>

## Struct `P`

Position in an order book


<pre><code><b>struct</b> <a href="Market.md#0xc0deb00c_Market_P">P</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>s: u64</code>
</dt>
<dd>
 Size of position, in base coin subunits. Corresponds to
 <code>AptosFramework::Coin::Coin.value</code>
</dd>
<dt>
<code>a: <b>address</b></code>
</dt>
<dd>
 Address
</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="0xc0deb00c_Market_BCT_CN"></a>

Base coin type coin name


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_BCT_CN">BCT_CN</a>: vector&lt;u8&gt; = [66, 97, 115, 101];
</code></pre>



<a name="0xc0deb00c_Market_BCT_CS"></a>

Base coin type coin symbol


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_BCT_CS">BCT_CS</a>: vector&lt;u8&gt; = [66];
</code></pre>



<a name="0xc0deb00c_Market_BCT_D"></a>

Base coin type decimal


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_BCT_D">BCT_D</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Market_BCT_TN"></a>

Base coin type type name


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_BCT_TN">BCT_TN</a>: vector&lt;u8&gt; = [66, 67, 84];
</code></pre>



<a name="0xc0deb00c_Market_E_NOT_COIN"></a>

When a type does not correspond to a coin


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_NOT_COIN">E_NOT_COIN</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_Market_E_NOT_ECONIA"></a>


<a name="@Error_codes_2"></a>

### Error codes

When account/address is not Econia


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Market_E_NO_REGISTRY"></a>

When market registry not initialized


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_NO_REGISTRY">E_NO_REGISTRY</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_Market_E_REGISTERED"></a>

When a given market is already registered


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_REGISTERED">E_REGISTERED</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Market_E_WRONG_EXPONENT_T"></a>

When wrong type for exponent flag


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_WRONG_EXPONENT_T">E_WRONG_EXPONENT_T</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Market_E_WRONG_MODULE"></a>

When wrong module


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_E_WRONG_MODULE">E_WRONG_MODULE</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Market_F0"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F0">F0</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Market_F1"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F1">F1</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_Market_F10"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F10">F10</a>: u64 = 10000000000;
</code></pre>



<a name="0xc0deb00c_Market_F11"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F11">F11</a>: u64 = 100000000000;
</code></pre>



<a name="0xc0deb00c_Market_F12"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F12">F12</a>: u64 = 1000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F13"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F13">F13</a>: u64 = 10000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F14"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F14">F14</a>: u64 = 100000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F15"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F15">F15</a>: u64 = 1000000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F16"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F16">F16</a>: u64 = 10000000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F17"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F17">F17</a>: u64 = 100000000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F18"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F18">F18</a>: u64 = 1000000000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F19"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F19">F19</a>: u64 = 10000000000000000000;
</code></pre>



<a name="0xc0deb00c_Market_F2"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F2">F2</a>: u64 = 100;
</code></pre>



<a name="0xc0deb00c_Market_F3"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F3">F3</a>: u64 = 1000;
</code></pre>



<a name="0xc0deb00c_Market_F4"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F4">F4</a>: u64 = 10000;
</code></pre>



<a name="0xc0deb00c_Market_F5"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F5">F5</a>: u64 = 100000;
</code></pre>



<a name="0xc0deb00c_Market_F6"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F6">F6</a>: u64 = 1000000;
</code></pre>



<a name="0xc0deb00c_Market_F7"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F7">F7</a>: u64 = 10000000;
</code></pre>



<a name="0xc0deb00c_Market_F8"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F8">F8</a>: u64 = 100000000;
</code></pre>



<a name="0xc0deb00c_Market_F9"></a>



<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_F9">F9</a>: u64 = 1000000000;
</code></pre>



<a name="0xc0deb00c_Market_M_NAME"></a>


<a name="@Type_name_bytestrings_3"></a>

### Type name bytestrings

This module's name


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_M_NAME">M_NAME</a>: vector&lt;u8&gt; = [77, 97, 114, 107, 101, 116];
</code></pre>



<a name="0xc0deb00c_Market_QCT_CN"></a>

Quote coin type coin name


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_QCT_CN">QCT_CN</a>: vector&lt;u8&gt; = [81, 117, 111, 116, 101];
</code></pre>



<a name="0xc0deb00c_Market_QCT_CS"></a>

Quote coin type coin symbol


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_QCT_CS">QCT_CS</a>: vector&lt;u8&gt; = [81];
</code></pre>



<a name="0xc0deb00c_Market_QCT_D"></a>

Base coin type decimal


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_QCT_D">QCT_D</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_Market_QCT_TN"></a>

Quote coin type type name


<pre><code><b>const</b> <a href="Market.md#0xc0deb00c_Market_QCT_TN">QCT_TN</a>: vector&lt;u8&gt; = [81, 67, 84];
</code></pre>



<a name="0xc0deb00c_Market_init_registry"></a>

## Function `init_registry`

Publish <code><a href="Market.md#0xc0deb00c_Market_MR">MR</a></code> to Econia's acount, aborting for all other accounts


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Market.md#0xc0deb00c_Market_init_registry">init_registry</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Market.md#0xc0deb00c_Market_init_registry">init_registry</a>(
    account: &signer
) {
    // Assert account is Econia
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Market.md#0xc0deb00c_Market_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Move empty market registry <b>to</b> account
    <b>move_to</b>&lt;<a href="Market.md#0xc0deb00c_Market_MR">MR</a>&gt;(account, <a href="Market.md#0xc0deb00c_Market_MR">MR</a>{t: t_n&lt;<a href="Market.md#0xc0deb00c_Market_MI">MI</a>, <b>address</b>&gt;()});
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_register_market"></a>

## Function `register_market`

Register a market for the given base coin type <code>B</code>, quote coin
type <code>Q</code>, and scale exponent <code>E</code> , aborting if registry not
initialized or if market already registered


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Market.md#0xc0deb00c_Market_register_market">register_market</a>&lt;B, Q, E&gt;(host: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Market.md#0xc0deb00c_Market_register_market">register_market</a>&lt;B, Q, E&gt;(
    host: &signer
) <b>acquires</b> <a href="Market.md#0xc0deb00c_Market_MR">MR</a> {
    <a href="Market.md#0xc0deb00c_Market_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;(); // Verify valid type arguments
    // Assert market registry is initialized at Econia account
    <b>assert</b>!(<b>exists</b>&lt;<a href="Market.md#0xc0deb00c_Market_MR">MR</a>&gt;(@Econia), <a href="Market.md#0xc0deb00c_Market_E_NO_REGISTRY">E_NO_REGISTRY</a>);
    // Get market info for given type arguments
    <b>let</b> m_i = <a href="Market.md#0xc0deb00c_Market_MI">MI</a>{b: ti_t_o&lt;B&gt;(), q: ti_t_o&lt;Q&gt;(), e: ti_t_o&lt;E&gt;()};
    // Borrow mutable reference <b>to</b> market registry table
    <b>let</b> r_t = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Market.md#0xc0deb00c_Market_MR">MR</a>&gt;(@Econia).t;
    // Assert requested market not already registered
    <b>assert</b>!(!t_c(r_t, m_i), <a href="Market.md#0xc0deb00c_Market_E_REGISTERED">E_REGISTERED</a>);
    // Pack empty order book <b>with</b> corresponding scale factor
    <b>let</b> ob = <a href="Market.md#0xc0deb00c_Market_OB">OB</a>&lt;B, Q, E&gt;{f: <a href="Market.md#0xc0deb00c_Market_scale_factor">scale_factor</a>&lt;E&gt;(), a: cb_e&lt;<a href="Market.md#0xc0deb00c_Market_P">P</a>&gt;(), b: cb_e&lt;<a href="Market.md#0xc0deb00c_Market_P">P</a>&gt;()};
    // Pack market container <b>with</b> order book, <b>move</b> <b>to</b> host
    <b>move_to</b>&lt;<a href="Market.md#0xc0deb00c_Market_MC">MC</a>&lt;B, Q, E&gt;&gt;(host, <a href="Market.md#0xc0deb00c_Market_MC">MC</a>{ob});
    t_a(r_t, m_i, s_a_o(host)); // Register market-host relationship
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_scale_factor"></a>

## Function `scale_factor`

Return scale factor corresponding to scale exponent type <code>E</code>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_scale_factor">scale_factor</a>&lt;E&gt;(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_scale_factor">scale_factor</a>&lt;E&gt;():
u64 {
    <b>let</b> t_i = ti_t_o&lt;E&gt;(); // Get type info of exponent type flag
    // Verify exponent type flag is from Econia <b>address</b>
    <a href="Market.md#0xc0deb00c_Market_verify_address">verify_address</a>(ti_a_a(&t_i), @Econia, <a href="Market.md#0xc0deb00c_Market_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Verify exponent type flag is from this <b>module</b>
    <a href="Market.md#0xc0deb00c_Market_verify_bytestring">verify_bytestring</a>(ti_m_n(&t_i), <a href="Market.md#0xc0deb00c_Market_M_NAME">M_NAME</a>, <a href="Market.md#0xc0deb00c_Market_E_WRONG_MODULE">E_WRONG_MODULE</a>);
    <b>let</b> s_n = ti_s_n(&t_i); // Get type <b>struct</b> name
    // Return corresponding scale factor
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E0">E0</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F0">F0</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E1">E1</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F1">F1</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E2">E2</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F2">F2</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E3">E3</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F3">F3</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E4">E4</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F4">F4</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E5">E5</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F5">F5</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E6">E6</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F6">F6</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E7">E7</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F7">F7</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E8">E8</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F8">F8</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E9">E9</a>&gt;() )) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F9">F9</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E10">E10</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F10">F10</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E11">E11</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F11">F11</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E12">E12</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F12">F12</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E13">E13</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F13">F13</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E14">E14</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F14">F14</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E15">E15</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F15">F15</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E16">E16</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F16">F16</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E17">E17</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F17">F17</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E18">E18</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F18">F18</a>;
    <b>if</b> (s_n == ti_s_n(&ti_t_o&lt;<a href="Market.md#0xc0deb00c_Market_E19">E19</a>&gt;())) <b>return</b> <a href="Market.md#0xc0deb00c_Market_F19">F19</a>;
    <b>abort</b> <a href="Market.md#0xc0deb00c_Market_E_WRONG_EXPONENT_T">E_WRONG_EXPONENT_T</a> // Else <b>abort</b>
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_verify_address"></a>

## Function `verify_address`

Assert <code>a1</code> equals <code>a2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_address">verify_address</a>(a1: <b>address</b>, a2: <b>address</b>, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_address">verify_address</a>(
    a1: <b>address</b>,
    a2: <b>address</b>,
    e: u64
) {
    <b>assert</b>!(a1 == a2, e); // Assert equality
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_verify_bytestring"></a>

## Function `verify_bytestring`

Assert <code>s1</code> equals <code>s2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_bytestring">verify_bytestring</a>(bs1: vector&lt;u8&gt;, bs2: vector&lt;u8&gt;, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_bytestring">verify_bytestring</a>(
    bs1: vector&lt;u8&gt;,
    bs2: vector&lt;u8&gt;,
    e: u64
) {
    <b>assert</b>!(bs1 == bs2, e); // Assert equality
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_verify_market_types"></a>

## Function `verify_market_types`

Assert <code>B</code> and <code>Q</code> are coins, and that <code>E</code> is scale exponent


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_market_types">verify_market_types</a>&lt;B, Q, E&gt;() {
    <b>assert</b>!(c_i_c_i&lt;B&gt;(), <a href="Market.md#0xc0deb00c_Market_E_NOT_COIN">E_NOT_COIN</a>); // Assert base quote type
    <b>assert</b>!(c_i_c_i&lt;Q&gt;(), <a href="Market.md#0xc0deb00c_Market_E_NOT_COIN">E_NOT_COIN</a>); // Assert quote coin type
    // Assert scale exponent type <b>has</b> corresponding scale factor
    <a href="Market.md#0xc0deb00c_Market_scale_factor">scale_factor</a>&lt;E&gt;();
}
</code></pre>



</details>

<a name="0xc0deb00c_Market_verify_t"></a>

## Function `verify_t`

Assert <code>t1</code> equals <code>t2</code>, aborting with code <code>e</code> if not


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_t">verify_t</a>(t1: &<a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a>, t2: &<a href="../../../build/AptosFramework/docs/TypeInfo.md#0x1_TypeInfo_TypeInfo">TypeInfo::TypeInfo</a>, e: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Market.md#0xc0deb00c_Market_verify_t">verify_t</a>(
    t1: &TI,
    t2: &TI,
    e: u64
) {
    <a href="Market.md#0xc0deb00c_Market_verify_address">verify_address</a>(ti_a_a(t1), ti_a_a(t2), e); // Verify <b>address</b>
    <a href="Market.md#0xc0deb00c_Market_verify_bytestring">verify_bytestring</a>(ti_m_n(t1), ti_m_n(t2), e); // Verify <b>module</b>
    <a href="Market.md#0xc0deb00c_Market_verify_bytestring">verify_bytestring</a>(ti_s_n(t1), ti_s_n(t2), e); // Verify <b>struct</b>
}
</code></pre>



</details>
