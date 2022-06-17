
<a name="0xc0deb00c_Collateral"></a>

# Module `0xc0deb00c::Collateral`

Collateral management functionality


-  [Resource `CC`](#0xc0deb00c_Collateral_CC)
-  [Constants](#@Constants_0)
-  [Function `exists_c_c`](#0xc0deb00c_Collateral_exists_c_c)
-  [Function `init_c_c`](#0xc0deb00c_Collateral_init_c_c)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Registry.md#0xc0deb00c_Registry">0xc0deb00c::Registry</a>;
</code></pre>



<a name="0xc0deb00c_Collateral_CC"></a>

## Resource `CC`

Order collateral container for a given market


<pre><code><b>struct</b> <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>b_a: u64</code>
</dt>
<dd>
 Indivisible subunits of base coins available to withdraw
</dd>
<dt>
<code>b_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;B&gt;</code>
</dt>
<dd>
 Base coins held as collateral
</dd>
<dt>
<code>q_a: u64</code>
</dt>
<dd>
 Indivisible subunits of quote coins available to withdraw
</dd>
<dt>
<code>q_c: <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin_Coin">Coin::Coin</a>&lt;Q&gt;</code>
</dt>
<dd>
 Quote coins held as collateral
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Collateral_E_C_C_EXISTS"></a>

When order collateral container already exists at given address


<pre><code><b>const</b> <a href="Collateral.md#0xc0deb00c_Collateral_E_C_C_EXISTS">E_C_C_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Collateral_E_NO_MARKET"></a>

When no corresponding market to register collateral for


<pre><code><b>const</b> <a href="Collateral.md#0xc0deb00c_Collateral_E_NO_MARKET">E_NO_MARKET</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Collateral_exists_c_c"></a>

## Function `exists_c_c`

Return <code><b>true</b></code> if address has specified collateral container type


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_exists_c_c">exists_c_c</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_exists_c_c">exists_c_c</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool {<b>exists</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(a)}
</code></pre>



</details>

<a name="0xc0deb00c_Collateral_init_c_c"></a>

## Function `init_c_c`

Initialize order collateral container for given user, aborting
if already initialized


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_init_c_c">init_c_c</a>&lt;B, Q, E&gt;(user: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_init_c_c">init_c_c</a>&lt;B, Q, E&gt;(
    user: &signer,
) {
    // Assert user does not already have order collateral for market
    <b>assert</b>!(!<a href="Collateral.md#0xc0deb00c_Collateral_exists_c_c">exists_c_c</a>&lt;B, Q, E&gt;(s_a_o(user)), <a href="Collateral.md#0xc0deb00c_Collateral_E_C_C_EXISTS">E_C_C_EXISTS</a>);
    // Assert given market <b>has</b> actually been registered
    <b>assert</b>!(r_i_r&lt;B, Q, E&gt;(), <a href="Collateral.md#0xc0deb00c_Collateral_E_NO_MARKET">E_NO_MARKET</a>);
    // Pack empty collateral container
    <b>let</b> o_c = <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;{b_c: c_z&lt;B&gt;(), b_a: 0, q_c: c_z&lt;Q&gt;(), q_a: 0};
    <b>move_to</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(user, o_c); // Move <b>to</b> user account
}
</code></pre>



</details>
