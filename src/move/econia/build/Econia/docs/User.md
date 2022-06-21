
<a name="0xc0deb00c_User"></a>

# Module `0xc0deb00c::User`

User-facing trading functionality


-  [Resource `OC`](#0xc0deb00c_User_OC)
-  [Resource `SC`](#0xc0deb00c_User_SC)
-  [Constants](#@Constants_0)
-  [Function `init_containers`](#0xc0deb00c_User_init_containers)
-  [Function `init_user`](#0xc0deb00c_User_init_user)
-  [Function `update_sequence_counter`](#0xc0deb00c_User_update_sequence_counter)
-  [Function `exists_o_c`](#0xc0deb00c_User_exists_o_c)
-  [Function `init_o_c`](#0xc0deb00c_User_init_o_c)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Account.md#0x1_Account">0x1::Account</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Caps.md#0xc0deb00c_Caps">0xc0deb00c::Caps</a>;
<b>use</b> <a href="Orders.md#0xc0deb00c_Orders">0xc0deb00c::Orders</a>;
<b>use</b> <a href="Registry.md#0xc0deb00c_Registry">0xc0deb00c::Registry</a>;
</code></pre>



<a name="0xc0deb00c_User_OC"></a>

## Resource `OC`

Order collateral for a given market


<pre><code><b>struct</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt; <b>has</b> key
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

<a name="0xc0deb00c_User_SC"></a>

## Resource `SC`

Counter for sequence number of last monitored Econia transaction


<pre><code><b>struct</b> <a href="User.md#0xc0deb00c_User_SC">SC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>i: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_User_E_INVALID_S_N"></a>

When invalid sequence number for current transaction


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_INVALID_S_N">E_INVALID_S_N</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_User_E_NO_MARKET"></a>

When no corresponding market


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_User_E_NO_S_C"></a>

When sequence number counter does not exist for user


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_S_C">E_NO_S_C</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_User_E_O_C_EXISTS"></a>

When order collateral container already exists


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_O_C_EXISTS">E_O_C_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_User_E_O_O_EXISTS"></a>

When open orders container already exists


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_O_O_EXISTS">E_O_O_EXISTS</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_User_E_S_C_EXISTS"></a>

When sequence number counter already exists for user


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_S_C_EXISTS">E_S_C_EXISTS</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_User_init_containers"></a>

## Function `init_containers`

Initialize a user with <code>Econia::Orders::OO</code> and <code><a href="User.md#0xc0deb00c_User_OC">OC</a></code> for market
with base coin type <code>B</code>, quote coin type <code>Q</code>, and scale exponent
<code>E</code>, aborting if no such market or if containers already
initialized for market


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_init_containers">init_containers</a>&lt;B, Q, E&gt;(user: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_init_containers">init_containers</a>&lt;B, Q, E&gt;(
    user: &signer
) {
    <b>assert</b>!(r_i_r&lt;B, Q, E&gt;(), <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>); // Assert market <b>exists</b>
    <b>let</b> user_addr = s_a_o(user); // Get user <b>address</b>
    // Assert user does not already have collateral container
    <b>assert</b>!(!<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(user_addr), <a href="User.md#0xc0deb00c_User_E_O_C_EXISTS">E_O_C_EXISTS</a>);
    // Assert user does not already have open orders container
    <b>assert</b>!(!o_e_o&lt;B, Q, E&gt;(user_addr), <a href="User.md#0xc0deb00c_User_E_O_O_EXISTS">E_O_O_EXISTS</a>);
    // Pack empty collateral container
    <b>let</b> o_c = <a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;{b_c: c_z&lt;B&gt;(), b_a: 0, q_c: c_z&lt;Q&gt;(), q_a: 0};
    <b>move_to</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(user, o_c); // Move <b>to</b> user account
    // Initialize empty open orders container under user account
    o_i_o&lt;B, Q, E&gt;(user, r_s_f&lt;E&gt;(), c_o_f_c());
}
</code></pre>



</details>

<a name="0xc0deb00c_User_init_user"></a>

## Function `init_user`

Initialize an <code><a href="User.md#0xc0deb00c_User_SC">SC</a></code> with the sequence number of the initializing
transaction, aborting if one already exists


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_init_user">init_user</a>(user: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_init_user">init_user</a>(
    user: &signer
) {
    <b>let</b> user_addr = s_a_o(user); // Get user <b>address</b>
    // Assert user <b>has</b> not already initialized a sequence counter
    <b>assert</b>!(!<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_SC">SC</a>&gt;(user_addr), <a href="User.md#0xc0deb00c_User_E_S_C_EXISTS">E_S_C_EXISTS</a>);
    // Initialize sequence counter <b>with</b> user's sequence number
    <b>move_to</b>&lt;<a href="User.md#0xc0deb00c_User_SC">SC</a>&gt;(user, <a href="User.md#0xc0deb00c_User_SC">SC</a>{i: a_g_s_n(user_addr)});
}
</code></pre>



</details>

<a name="0xc0deb00c_User_update_sequence_counter"></a>

## Function `update_sequence_counter`

Update sequence counter for user <code>u</code> with the sequence number of
the current transaction, aborting if user does not have an
initialized sequence counter or if sequence number is not
greater than the number indicated by the user's <code><a href="User.md#0xc0deb00c_User_SC">SC</a></code>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_update_sequence_counter">update_sequence_counter</a>(u: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_update_sequence_counter">update_sequence_counter</a>(
    u: &signer,
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <b>let</b> user_addr = s_a_o(u); // Get user <b>address</b>
    // Assert user <b>has</b> already initialized a sequence counter
    <b>assert</b>!(<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_SC">SC</a>&gt;(user_addr), <a href="User.md#0xc0deb00c_User_E_NO_S_C">E_NO_S_C</a>);
    // Borrow mutable reference <b>to</b> user's sequence counter
    <b>let</b> s_c = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_SC">SC</a>&gt;(user_addr);
    <b>let</b> s_n = a_g_s_n(user_addr); // Get current sequence number
    // Assert new sequence number greater than that of counter
    <b>assert</b>!(s_n &gt; s_c.i, <a href="User.md#0xc0deb00c_User_E_INVALID_S_N">E_INVALID_S_N</a>);
    s_c.i = s_n; // Update counter <b>with</b> current sequence number
}
</code></pre>



</details>

<a name="0xc0deb00c_User_exists_o_c"></a>

## Function `exists_o_c`

Return <code><b>true</b></code> if address has specified order collateral type


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_exists_o_c">exists_o_c</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_exists_o_c">exists_o_c</a>&lt;B, Q, E&gt;(a: <b>address</b>): bool {<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(a)}
</code></pre>



</details>

<a name="0xc0deb00c_User_init_o_c"></a>

## Function `init_o_c`

Initialize order collateral container for given user, aborting
if already initialized


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_init_o_c">init_o_c</a>&lt;B, Q, E&gt;(user: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_init_o_c">init_o_c</a>&lt;B, Q, E&gt;(
    user: &signer,
) {
    // Assert user does not already have order collateral for market
    <b>assert</b>!(!<a href="User.md#0xc0deb00c_User_exists_o_c">exists_o_c</a>&lt;B, Q, E&gt;(s_a_o(user)), <a href="User.md#0xc0deb00c_User_E_O_C_EXISTS">E_O_C_EXISTS</a>);
    // Assert given market <b>has</b> actually been registered
    <b>assert</b>!(r_i_r&lt;B, Q, E&gt;(), <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>);
    // Pack empty order collateral container
    <b>let</b> o_c = <a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;{b_c: c_z&lt;B&gt;(), b_a: 0, q_c: c_z&lt;Q&gt;(), q_a: 0};
    <b>move_to</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(user, o_c); // Move <b>to</b> user account
}
</code></pre>



</details>
