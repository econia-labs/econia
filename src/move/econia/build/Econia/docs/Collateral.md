
<a name="0xc0deb00c_Collateral"></a>

# Module `0xc0deb00c::Collateral`

Collateral management functionality


-  [Resource `CC`](#0xc0deb00c_Collateral_CC)
-  [Constants](#@Constants_0)
-  [Function `b_a`](#0xc0deb00c_Collateral_b_a)
-  [Function `b_c`](#0xc0deb00c_Collateral_b_c)
-  [Function `exists_c_c`](#0xc0deb00c_Collateral_exists_c_c)
-  [Function `init_c_c`](#0xc0deb00c_Collateral_init_c_c)
-  [Function `q_a`](#0xc0deb00c_Collateral_q_a)
-  [Function `q_c`](#0xc0deb00c_Collateral_q_c)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
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



<a name="0xc0deb00c_Collateral_b_a"></a>

## Function `b_a`

Return number of indivisible subunits of base coin collateral
available for withdraw, for given market, at given address


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_b_a">b_a</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_b_a">b_a</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a> {
    <b>borrow_global</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(addr).b_a
}
</code></pre>



</details>

<a name="0xc0deb00c_Collateral_b_c"></a>

## Function `b_c`

Return number of indivisible subunits of base coin collateral,
for given market, held at given address


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_b_c">b_c</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_b_c">b_c</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a> {
    c_v(&<b>borrow_global</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(addr).b_c)
}
</code></pre>



</details>

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
    // Pack empty order collateral container
    <b>let</b> o_c = <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;{b_c: c_z&lt;B&gt;(), b_a: 0, q_c: c_z&lt;Q&gt;(), q_a: 0};
    <b>move_to</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(user, o_c); // Move <b>to</b> user account
}
</code></pre>



</details>

<a name="0xc0deb00c_Collateral_q_a"></a>

## Function `q_a`

Return number of indivisible subunits of quote coin collateral
available for withdraw, for given market, at given address


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_q_a">q_a</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_q_a">q_a</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a> {
    <b>borrow_global</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(addr).q_a
}
</code></pre>



</details>

<a name="0xc0deb00c_Collateral_q_c"></a>

## Function `q_c`

Return number of indivisible subunits of quote coin collateral,
for given market, held at given address


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_q_c">q_c</a>&lt;B, Q, E&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Collateral.md#0xc0deb00c_Collateral_q_c">q_c</a>&lt;B, Q, E&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a> {
    c_v(&<b>borrow_global</b>&lt;<a href="Collateral.md#0xc0deb00c_Collateral_CC">CC</a>&lt;B, Q, E&gt;&gt;(addr).q_c)
}
</code></pre>



</details>
