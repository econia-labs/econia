
<a name="0xc0deb00c_coins"></a>

# Module `0xc0deb00c::coins`

Mock coin types for on- and off-chain testing


-  [Resource `CoinCapabilities`](#0xc0deb00c_coins_CoinCapabilities)
-  [Struct `BC`](#0xc0deb00c_coins_BC)
-  [Struct `QC`](#0xc0deb00c_coins_QC)
-  [Constants](#@Constants_0)
-  [Function `init_coin_types`](#0xc0deb00c_coins_init_coin_types)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
</code></pre>



<a name="0xc0deb00c_coins_CoinCapabilities"></a>

## Resource `CoinCapabilities`

Container for mock coin type capabilities


<pre><code><b>struct</b> <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_mint_cap: <a href="_MintCapability">coin::MintCapability</a>&lt;<a href="coins.md#0xc0deb00c_coins_BC">coins::BC</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>base_burn_cap: <a href="_BurnCapability">coin::BurnCapability</a>&lt;<a href="coins.md#0xc0deb00c_coins_BC">coins::BC</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>quote_mint_cap: <a href="_MintCapability">coin::MintCapability</a>&lt;<a href="coins.md#0xc0deb00c_coins_QC">coins::QC</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>quote_burn_cap: <a href="_BurnCapability">coin::BurnCapability</a>&lt;<a href="coins.md#0xc0deb00c_coins_QC">coins::QC</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_coins_BC"></a>

## Struct `BC`

Base coin type


<pre><code><b>struct</b> <a href="coins.md#0xc0deb00c_coins_BC">BC</a>
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

<a name="0xc0deb00c_coins_QC"></a>

## Struct `QC`

Quote coin type


<pre><code><b>struct</b> <a href="coins.md#0xc0deb00c_coins_QC">QC</a>
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

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_coins_E_NOT_ECONIA"></a>

When caller is not Econia


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_coins_BASE_COIN_DECIMALS"></a>

Base coin decimals


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_BASE_COIN_DECIMALS">BASE_COIN_DECIMALS</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_coins_BASE_COIN_NAME"></a>

Base coin name


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_BASE_COIN_NAME">BASE_COIN_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [66, 97, 115, 101, 32, 99, 111, 105, 110];
</code></pre>



<a name="0xc0deb00c_coins_BASE_COIN_SYMBOL"></a>

Base coin symbol


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_BASE_COIN_SYMBOL">BASE_COIN_SYMBOL</a>: <a href="">vector</a>&lt;u8&gt; = [66, 67];
</code></pre>



<a name="0xc0deb00c_coins_E_HAS_CAPABILITIES"></a>

When coin capabilities have already been initialized


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_E_HAS_CAPABILITIES">E_HAS_CAPABILITIES</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_coins_QUOTE_COIN_DECIMALS"></a>

Quote coin decimals


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_DECIMALS">QUOTE_COIN_DECIMALS</a>: u64 = 12;
</code></pre>



<a name="0xc0deb00c_coins_QUOTE_COIN_NAME"></a>

Quote coin name


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_NAME">QUOTE_COIN_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [81, 117, 111, 116, 101, 32, 99, 111, 105, 110];
</code></pre>



<a name="0xc0deb00c_coins_QUOTE_COIN_SYMBOL"></a>

Quote coin symbol


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_SYMBOL">QUOTE_COIN_SYMBOL</a>: <a href="">vector</a>&lt;u8&gt; = [81, 67];
</code></pre>



<a name="0xc0deb00c_coins_init_coin_types"></a>

## Function `init_coin_types`

Initialize mock base and quote coin types under Econia account


<pre><code><b>public</b> <b>fun</b> <a href="coins.md#0xc0deb00c_coins_init_coin_types">init_coin_types</a>(account: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="coins.md#0xc0deb00c_coins_init_coin_types">init_coin_types</a>(
    account: &<a href="">signer</a>
) {
    // Assert caller is Econia
    <b>assert</b>!(address_of(account) == @econia, <a href="coins.md#0xc0deb00c_coins_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert Econia does not already have <a href="">coin</a> capabilities stored
    <b>assert</b>!(!<b>exists</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&gt;(@econia), <a href="coins.md#0xc0deb00c_coins_E_HAS_CAPABILITIES">E_HAS_CAPABILITIES</a>);
    // Initialize base <a href="">coin</a>, storing capabilities
    <b>let</b> (base_mint_cap, base_burn_cap) = <a href="_initialize">coin::initialize</a>&lt;<a href="coins.md#0xc0deb00c_coins_BC">BC</a>&gt;(
        account, utf8(<a href="coins.md#0xc0deb00c_coins_BASE_COIN_NAME">BASE_COIN_NAME</a>), utf8(<a href="coins.md#0xc0deb00c_coins_BASE_COIN_SYMBOL">BASE_COIN_SYMBOL</a>),
        <a href="coins.md#0xc0deb00c_coins_BASE_COIN_DECIMALS">BASE_COIN_DECIMALS</a>, <b>false</b>);
    // Initialize quote <a href="">coin</a>, storing capabilities
    <b>let</b> (quote_mint_cap, quote_burn_cap) = <a href="_initialize">coin::initialize</a>&lt;<a href="coins.md#0xc0deb00c_coins_QC">QC</a>&gt;(
        account, utf8(<a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_NAME">QUOTE_COIN_NAME</a>), utf8(<a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_SYMBOL">QUOTE_COIN_SYMBOL</a>),
        <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_DECIMALS">QUOTE_COIN_DECIMALS</a>, <b>false</b>);
    // Store capabilities under Econia account
    <b>move_to</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&gt;(account, <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>{
        base_mint_cap, base_burn_cap, quote_mint_cap, quote_burn_cap});
}
</code></pre>



</details>
