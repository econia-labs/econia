
<a name="0xc0deb00c_assets"></a>

# Module `0xc0deb00c::assets`

Mock asset types for on- and off-chain testing.


-  [Resource `CoinCapabilities`](#0xc0deb00c_assets_CoinCapabilities)
-  [Struct `BC`](#0xc0deb00c_assets_BC)
-  [Struct `QC`](#0xc0deb00c_assets_QC)
-  [Struct `UC`](#0xc0deb00c_assets_UC)
-  [Constants](#@Constants_0)
-  [Function `burn`](#0xc0deb00c_assets_burn)
-  [Function `mint`](#0xc0deb00c_assets_mint)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
</code></pre>



<a name="0xc0deb00c_assets_CoinCapabilities"></a>

## Resource `CoinCapabilities`

Stores mock coin type capabilities.


<pre><code><b>struct</b> <a href="assets.md#0xc0deb00c_assets_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<a name="0xc0deb00c_assets_BC"></a>

## Struct `BC`

Base coin type.


<pre><code><b>struct</b> <a href="assets.md#0xc0deb00c_assets_BC">BC</a>
</code></pre>



<a name="0xc0deb00c_assets_QC"></a>

## Struct `QC`

Quote coin type.


<pre><code><b>struct</b> <a href="assets.md#0xc0deb00c_assets_QC">QC</a>
</code></pre>



<a name="0xc0deb00c_assets_UC"></a>

## Struct `UC`

Utility coin type.


<pre><code><b>struct</b> <a href="assets.md#0xc0deb00c_assets_UC">UC</a>
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_assets_BASE_COIN_DECIMALS"></a>

Base coin decimals.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_BASE_COIN_DECIMALS">BASE_COIN_DECIMALS</a>: u8 = 4;
</code></pre>



<a name="0xc0deb00c_assets_BASE_COIN_NAME"></a>

Base coin name.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_BASE_COIN_NAME">BASE_COIN_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [66, 97, 115, 101, 32, 99, 111, 105, 110];
</code></pre>



<a name="0xc0deb00c_assets_BASE_COIN_SYMBOL"></a>

Base coin symbol.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_BASE_COIN_SYMBOL">BASE_COIN_SYMBOL</a>: <a href="">vector</a>&lt;u8&gt; = [66, 67];
</code></pre>



<a name="0xc0deb00c_assets_E_HAS_CAPABILITIES"></a>

Coin capabilities have already been initialized.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_E_HAS_CAPABILITIES">E_HAS_CAPABILITIES</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_assets_E_NOT_ECONIA"></a>

Caller is not Econia.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_assets_QUOTE_COIN_DECIMALS"></a>

Quote coin decimals.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_QUOTE_COIN_DECIMALS">QUOTE_COIN_DECIMALS</a>: u8 = 12;
</code></pre>



<a name="0xc0deb00c_assets_QUOTE_COIN_NAME"></a>

Quote coin name.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_QUOTE_COIN_NAME">QUOTE_COIN_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [81, 117, 111, 116, 101, 32, 99, 111, 105, 110];
</code></pre>



<a name="0xc0deb00c_assets_QUOTE_COIN_SYMBOL"></a>

Quote coin symbol.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_QUOTE_COIN_SYMBOL">QUOTE_COIN_SYMBOL</a>: <a href="">vector</a>&lt;u8&gt; = [81, 67];
</code></pre>



<a name="0xc0deb00c_assets_UTILITY_COIN_DECIMALS"></a>

Utility coin decimals.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_UTILITY_COIN_DECIMALS">UTILITY_COIN_DECIMALS</a>: u8 = 10;
</code></pre>



<a name="0xc0deb00c_assets_UTILITY_COIN_NAME"></a>

Utility coin name.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_UTILITY_COIN_NAME">UTILITY_COIN_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [85, 116, 105, 108, 105, 116, 121, 32, 99, 111, 105, 110];
</code></pre>



<a name="0xc0deb00c_assets_UTILITY_COIN_SYMBOL"></a>

Utility coin symbol.


<pre><code><b>const</b> <a href="assets.md#0xc0deb00c_assets_UTILITY_COIN_SYMBOL">UTILITY_COIN_SYMBOL</a>: <a href="">vector</a>&lt;u8&gt; = [85, 67];
</code></pre>



<a name="0xc0deb00c_assets_burn"></a>

## Function `burn`

Burn <code>coins</code> for which <code>CoinType</code> is defined at Econia account.


<pre><code><b>public</b> <b>fun</b> <a href="assets.md#0xc0deb00c_assets_burn">burn</a>&lt;CoinType&gt;(coins: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<a name="0xc0deb00c_assets_mint"></a>

## Function `mint`

Mint new <code>amount</code> of <code>CoinType</code>, aborting if not called by
Econia account.


<pre><code><b>public</b> <b>fun</b> <a href="assets.md#0xc0deb00c_assets_mint">mint</a>&lt;CoinType&gt;(<a href="">account</a>: &<a href="">signer</a>, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>
