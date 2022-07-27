
<a name="0xc0deb00c_coins"></a>

# Module `0xc0deb00c::coins`

Mock coin types for on- and off-chain testing


-  [Resource `CoinCapabilities`](#0xc0deb00c_coins_CoinCapabilities)
-  [Struct `BC`](#0xc0deb00c_coins_BC)
-  [Struct `QC`](#0xc0deb00c_coins_QC)
-  [Constants](#@Constants_0)
-  [Function `burn`](#0xc0deb00c_coins_burn)
    -  [Assumes](#@Assumes_1)
-  [Function `init_coin_types`](#0xc0deb00c_coins_init_coin_types)
-  [Function `mint`](#0xc0deb00c_coins_mint)
-  [Function `init_coin_type`](#0xc0deb00c_coins_init_coin_type)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
</code></pre>



<a name="0xc0deb00c_coins_CoinCapabilities"></a>

## Resource `CoinCapabilities`

Container for mock coin type capabilities


<pre><code><b>struct</b> <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>mint_capability: <a href="_MintCapability">coin::MintCapability</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_capability: <a href="_BurnCapability">coin::BurnCapability</a>&lt;CoinType&gt;</code>
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



<a name="0xc0deb00c_coins_E_NO_CAPABILITIES"></a>

When coin capabilities have not been initialized


<pre><code><b>const</b> <a href="coins.md#0xc0deb00c_coins_E_NO_CAPABILITIES">E_NO_CAPABILITIES</a>: u64 = 2;
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



<a name="0xc0deb00c_coins_burn"></a>

## Function `burn`

Burn <code><a href="coins.md#0xc0deb00c_coins">coins</a></code>


<a name="@Assumes_1"></a>

### Assumes

* That since <code><a href="coins.md#0xc0deb00c_coins">coins</a></code> exist in the first place, that
<code><a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a></code> must exist in the Econia account


<pre><code><b>public</b> <b>fun</b> <a href="coins.md#0xc0deb00c_coins_burn">burn</a>&lt;CoinType&gt;(<a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coins.md#0xc0deb00c_coins_burn">burn</a>&lt;CoinType&gt;(
    <a href="coins.md#0xc0deb00c_coins">coins</a>: <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
) <b>acquires</b> <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a> {
    // Borrow immutable reference <b>to</b> burn <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> burn_capability = &<b>borrow_global</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;&gt;(
            @econia).burn_capability;
    <a href="_burn">coin::burn</a>&lt;CoinType&gt;(<a href="coins.md#0xc0deb00c_coins">coins</a>, burn_capability); // Burn <a href="coins.md#0xc0deb00c_coins">coins</a>
}
</code></pre>



</details>

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
    <a href="coins.md#0xc0deb00c_coins_init_coin_type">init_coin_type</a>&lt;<a href="coins.md#0xc0deb00c_coins_BC">BC</a>&gt;(account, <a href="coins.md#0xc0deb00c_coins_BASE_COIN_NAME">BASE_COIN_NAME</a>, <a href="coins.md#0xc0deb00c_coins_BASE_COIN_SYMBOL">BASE_COIN_SYMBOL</a>,
        <a href="coins.md#0xc0deb00c_coins_BASE_COIN_DECIMALS">BASE_COIN_DECIMALS</a>); // Initialize mock base <a href="">coin</a>
    <a href="coins.md#0xc0deb00c_coins_init_coin_type">init_coin_type</a>&lt;<a href="coins.md#0xc0deb00c_coins_QC">QC</a>&gt;(account, <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_NAME">QUOTE_COIN_NAME</a>, <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_SYMBOL">QUOTE_COIN_SYMBOL</a>,
        <a href="coins.md#0xc0deb00c_coins_QUOTE_COIN_DECIMALS">QUOTE_COIN_DECIMALS</a>); // Initialize mock quote <a href="">coin</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_coins_mint"></a>

## Function `mint`

Mint new <code>amount</code> of <code>CoinType</code>, aborting if not called by
Econia account or if <code><a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a></code> uninitialized


<pre><code><b>public</b> <b>fun</b> <a href="coins.md#0xc0deb00c_coins_mint">mint</a>&lt;CoinType&gt;(account: &<a href="">signer</a>, amount: u64): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="coins.md#0xc0deb00c_coins_mint">mint</a>&lt;CoinType&gt;(
    account: &<a href="">signer</a>,
    amount: u64
): <a href="_Coin">coin::Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a> {
    // Get account <b>address</b>
    <b>let</b> account_address = address_of(account);
    // Assert caller is Econia
    <b>assert</b>!(account_address == @econia, <a href="coins.md#0xc0deb00c_coins_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    <b>assert</b>!(<b>exists</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;&gt;(account_address),
        <a href="coins.md#0xc0deb00c_coins_E_NO_CAPABILITIES">E_NO_CAPABILITIES</a>); // Assert <a href="">coin</a> capabilities initialized
    // Borrow immutable reference <b>to</b> mint <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> mint_capability = &<b>borrow_global</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;&gt;(
            account_address).mint_capability;
    // Mint specified amount
    <a href="_mint">coin::mint</a>&lt;CoinType&gt;(amount, mint_capability)
}
</code></pre>



</details>

<a name="0xc0deb00c_coins_init_coin_type"></a>

## Function `init_coin_type`

Initialize given coin type under Econia account


<pre><code><b>fun</b> <a href="coins.md#0xc0deb00c_coins_init_coin_type">init_coin_type</a>&lt;CoinType&gt;(account: &<a href="">signer</a>, coin_name: <a href="">vector</a>&lt;u8&gt;, coin_symbol: <a href="">vector</a>&lt;u8&gt;, decimals: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="coins.md#0xc0deb00c_coins_init_coin_type">init_coin_type</a>&lt;CoinType&gt;(
    account: &<a href="">signer</a>,
    coin_name: <a href="">vector</a>&lt;u8&gt;,
    coin_symbol: <a href="">vector</a>&lt;u8&gt;,
    decimals: u64,
) {
    // Assert caller is Econia
    <b>assert</b>!(address_of(account) == @econia, <a href="coins.md#0xc0deb00c_coins_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert Econia does not already have <a href="">coin</a> capabilities stored
    <b>assert</b>!(!<b>exists</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;&gt;(@econia),
        <a href="coins.md#0xc0deb00c_coins_E_HAS_CAPABILITIES">E_HAS_CAPABILITIES</a>);
    // Initialize <a href="">coin</a>, storing capabilities
    <b>let</b> (mint_capability, burn_capability) = <a href="_initialize">coin::initialize</a>&lt;CoinType&gt;(
        account, utf8(coin_name), utf8(coin_symbol), decimals, <b>false</b>);
    // Store capabilities under Econia account
    <b>move_to</b>&lt;<a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;&gt;(account,
        <a href="coins.md#0xc0deb00c_coins_CoinCapabilities">CoinCapabilities</a>&lt;CoinType&gt;{mint_capability, burn_capability});
}
</code></pre>



</details>
