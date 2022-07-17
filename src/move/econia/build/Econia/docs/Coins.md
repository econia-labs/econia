
<a name="0xc0deb00c_Coins"></a>

# Module `0xc0deb00c::Coins`



-  [Struct `BCT`](#0xc0deb00c_Coins_BCT)
-  [Resource `BCC`](#0xc0deb00c_Coins_BCC)
-  [Struct `QCT`](#0xc0deb00c_Coins_QCT)
-  [Resource `QCC`](#0xc0deb00c_Coins_QCC)
-  [Constants](#@Constants_0)
-  [Function `init_coin_types`](#0xc0deb00c_Coins_init_coin_types)
-  [Function `mint_to`](#0xc0deb00c_Coins_mint_to)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/ASCII.md#0x1_ASCII">0x1::ASCII</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0xc0deb00c_Coins_BCT"></a>

## Struct `BCT`

Base coin type


<pre><code><b>struct</b> <a href="Coins.md#0xc0deb00c_Coins_BCT">BCT</a>
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

<a name="0xc0deb00c_Coins_BCC"></a>

## Resource `BCC`

Base coin capabilities


<pre><code><b>struct</b> <a href="Coins.md#0xc0deb00c_Coins_BCC">BCC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>m: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_MintCapability">Coin::MintCapability</a>&lt;<a href="Coins.md#0xc0deb00c_Coins_BCT">Coins::BCT</a>&gt;</code>
</dt>
<dd>
 Mint capability
</dd>
<dt>
<code>b: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_BurnCapability">Coin::BurnCapability</a>&lt;<a href="Coins.md#0xc0deb00c_Coins_BCT">Coins::BCT</a>&gt;</code>
</dt>
<dd>
 Burn capability
</dd>
</dl>


</details>

<a name="0xc0deb00c_Coins_QCT"></a>

## Struct `QCT`

Quote coin type


<pre><code><b>struct</b> <a href="Coins.md#0xc0deb00c_Coins_QCT">QCT</a>
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

<a name="0xc0deb00c_Coins_QCC"></a>

## Resource `QCC`

Quote coin capabilities


<pre><code><b>struct</b> <a href="Coins.md#0xc0deb00c_Coins_QCC">QCC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>m: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_MintCapability">Coin::MintCapability</a>&lt;<a href="Coins.md#0xc0deb00c_Coins_QCT">Coins::QCT</a>&gt;</code>
</dt>
<dd>
 Mint capability
</dd>
<dt>
<code>b: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_BurnCapability">Coin::BurnCapability</a>&lt;<a href="Coins.md#0xc0deb00c_Coins_QCT">Coins::QCT</a>&gt;</code>
</dt>
<dd>
 Burn capability
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Coins_E_NOT_ECONIA"></a>

When access-controlled function called by non-Econia account


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Coins_BCT_CN"></a>

Base coin type coin name


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_BCT_CN">BCT_CN</a>: vector&lt;u8&gt; = [66, 97, 115, 101];
</code></pre>



<a name="0xc0deb00c_Coins_BCT_CS"></a>

Base coin type coin symbol


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_BCT_CS">BCT_CS</a>: vector&lt;u8&gt; = [66];
</code></pre>



<a name="0xc0deb00c_Coins_BCT_D"></a>

Base coin type decimal


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_BCT_D">BCT_D</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Coins_BCT_TN"></a>

Base coin type type name


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_BCT_TN">BCT_TN</a>: vector&lt;u8&gt; = [66, 67, 84];
</code></pre>



<a name="0xc0deb00c_Coins_QCT_CN"></a>

Quote coin type coin name


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_QCT_CN">QCT_CN</a>: vector&lt;u8&gt; = [81, 117, 111, 116, 101];
</code></pre>



<a name="0xc0deb00c_Coins_QCT_CS"></a>

Quote coin type coin symbol


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_QCT_CS">QCT_CS</a>: vector&lt;u8&gt; = [81];
</code></pre>



<a name="0xc0deb00c_Coins_QCT_D"></a>

Base coin type decimal


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_QCT_D">QCT_D</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_Coins_QCT_TN"></a>

Quote coin type type name


<pre><code><b>const</b> <a href="Coins.md#0xc0deb00c_Coins_QCT_TN">QCT_TN</a>: vector&lt;u8&gt; = [81, 67, 84];
</code></pre>



<a name="0xc0deb00c_Coins_init_coin_types"></a>

## Function `init_coin_types`

Initialize base and quote coin types under Econia account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coins.md#0xc0deb00c_Coins_init_coin_types">init_coin_types</a>(econia: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coins.md#0xc0deb00c_Coins_init_coin_types">init_coin_types</a>(
    econia: &signer
) {
    // Assert initializing coin types under Econia account
    <b>assert</b>!(address_of(econia) == @Econia, <a href="Coins.md#0xc0deb00c_Coins_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Initialize base coin type, storing mint/burn capabilities
    <b>let</b>(m, b) = initialize&lt;<a href="Coins.md#0xc0deb00c_Coins_BCT">BCT</a>&gt;(
        econia, string(<a href="Coins.md#0xc0deb00c_Coins_BCT_CN">BCT_CN</a>), string(<a href="Coins.md#0xc0deb00c_Coins_BCT_CS">BCT_CS</a>), <a href="Coins.md#0xc0deb00c_Coins_BCT_D">BCT_D</a>, <b>false</b>);
    // Save capabilities in <b>global</b> storage
    <b>move_to</b>(econia, <a href="Coins.md#0xc0deb00c_Coins_BCC">BCC</a>{m, b});
    // Initialize quote coin type, storing mint/burn capabilities
    <b>let</b>(m, b) = initialize&lt;<a href="Coins.md#0xc0deb00c_Coins_QCT">QCT</a>&gt;(
        econia, string(<a href="Coins.md#0xc0deb00c_Coins_QCT_CN">QCT_CN</a>), string(<a href="Coins.md#0xc0deb00c_Coins_QCT_CS">QCT_CS</a>), <a href="Coins.md#0xc0deb00c_Coins_QCT_D">QCT_D</a>, <b>false</b>);
    // Save capabilities in <b>global</b> storage
    <b>move_to</b>(econia, <a href="Coins.md#0xc0deb00c_Coins_QCC">QCC</a>{m, b});
}
</code></pre>



</details>

<a name="0xc0deb00c_Coins_mint_to"></a>

## Function `mint_to`

Mint <code>val_bct</code> of <code><a href="Coins.md#0xc0deb00c_Coins_BCT">BCT</a></code> and <code>val_qct</code> of <code><a href="Coins.md#0xc0deb00c_Coins_QCT">QCT</a></code> to <code>user</code>'s
<code>AptosFramework::Coin::Coinstore</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coins.md#0xc0deb00c_Coins_mint_to">mint_to</a>(econia: &signer, user: <b>address</b>, val_bct: u64, val_qct: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coins.md#0xc0deb00c_Coins_mint_to">mint_to</a>(
    econia: &signer,
    user: <b>address</b>,
    val_bct: u64,
    val_qct: u64
) <b>acquires</b> <a href="Coins.md#0xc0deb00c_Coins_BCC">BCC</a>, <a href="Coins.md#0xc0deb00c_Coins_QCC">QCC</a> {
    // Assert called by Econia account
    <b>assert</b>!(address_of(econia) == @Econia, <a href="Coins.md#0xc0deb00c_Coins_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mint and deposit <b>to</b> user
    deposit&lt;<a href="Coins.md#0xc0deb00c_Coins_BCT">BCT</a>&gt;(user, mint&lt;<a href="Coins.md#0xc0deb00c_Coins_BCT">BCT</a>&gt;(val_bct, &<b>borrow_global</b>&lt;<a href="Coins.md#0xc0deb00c_Coins_BCC">BCC</a>&gt;(@Econia).m));
    // Mint and deposit <b>to</b> user
    deposit&lt;<a href="Coins.md#0xc0deb00c_Coins_QCT">QCT</a>&gt;(user, mint&lt;<a href="Coins.md#0xc0deb00c_Coins_QCT">QCT</a>&gt;(val_qct, &<b>borrow_global</b>&lt;<a href="Coins.md#0xc0deb00c_Coins_QCC">QCC</a>&gt;(@Econia).m));
}
</code></pre>



</details>
