
<a name="0xc0deb00c_User"></a>

# Module `0xc0deb00c::User`

User-facing trading functionality


-  [Resource `OC`](#0xc0deb00c_User_OC)
-  [Resource `SC`](#0xc0deb00c_User_SC)
-  [Constants](#@Constants_0)
-  [Function `deposit`](#0xc0deb00c_User_deposit)
-  [Function `cancel_ask`](#0xc0deb00c_User_cancel_ask)
-  [Function `cancel_bid`](#0xc0deb00c_User_cancel_bid)
-  [Function `init_containers`](#0xc0deb00c_User_init_containers)
-  [Function `init_user`](#0xc0deb00c_User_init_user)
-  [Function `submit_ask`](#0xc0deb00c_User_submit_ask)
-  [Function `submit_bid`](#0xc0deb00c_User_submit_bid)
-  [Function `withdraw`](#0xc0deb00c_User_withdraw)
-  [Function `process_fill`](#0xc0deb00c_User_process_fill)
    -  [Terminology](#@Terminology_1)
    -  [Parameters](#@Parameters_2)
    -  [Assumptions](#@Assumptions_3)
-  [Function `cancel_order`](#0xc0deb00c_User_cancel_order)
    -  [Parameters](#@Parameters_4)
-  [Function `init_o_c`](#0xc0deb00c_User_init_o_c)
-  [Function `submit_limit_order`](#0xc0deb00c_User_submit_limit_order)
    -  [Parameters](#@Parameters_5)
    -  [Abort conditions](#@Abort_conditions_6)
-  [Function `update_s_c`](#0xc0deb00c_User_update_s_c)


<pre><code><b>use</b> <a href="../../../build/AptosFramework/docs/Account.md#0x1_Account">0x1::Account</a>;
<b>use</b> <a href="../../../build/AptosFramework/docs/Coin.md#0x1_Coin">0x1::Coin</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Book.md#0xc0deb00c_Book">0xc0deb00c::Book</a>;
<b>use</b> <a href="Caps.md#0xc0deb00c_Caps">0xc0deb00c::Caps</a>;
<b>use</b> <a href="ID.md#0xc0deb00c_ID">0xc0deb00c::ID</a>;
<b>use</b> <a href="Orders.md#0xc0deb00c_Orders">0xc0deb00c::Orders</a>;
<b>use</b> <a href="Registry.md#0xc0deb00c_Registry">0xc0deb00c::Registry</a>;
<b>use</b> <a href="Version.md#0xc0deb00c_Version">0xc0deb00c::Version</a>;
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


<a name="0xc0deb00c_User_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_User_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_User_E_CROSSES_SPREAD"></a>

When an attempted limit order crosses the spread


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_CROSSES_SPREAD">E_CROSSES_SPREAD</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_User_E_INVALID_S_N"></a>

When invalid sequence number for current transaction


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_INVALID_S_N">E_INVALID_S_N</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_User_E_NOT_ENOUGH_COLLATERAL"></a>

When not enough collateral for an operation


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_User_E_NO_MARKET"></a>

When no corresponding market


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_User_E_NO_O_C"></a>

When no order collateral container


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_O_C">E_NO_O_C</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_User_E_NO_S_C"></a>

When sequence number counter does not exist for user


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_S_C">E_NO_S_C</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_User_E_NO_TRANSFER"></a>

When no transfer of funds indicated


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_NO_TRANSFER">E_NO_TRANSFER</a>: u64 = 7;
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



<a name="0xc0deb00c_User_E_WITHDRAW_TOO_MUCH"></a>

When attempting to withdraw more than is available


<pre><code><b>const</b> <a href="User.md#0xc0deb00c_User_E_WITHDRAW_TOO_MUCH">E_WITHDRAW_TOO_MUCH</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_User_deposit"></a>

## Function `deposit`

Deposit <code>b_val</code> base coin and <code>q_val</code> quote coin into <code>user</code>'s
<code><a href="User.md#0xc0deb00c_User_OC">OC</a></code>, from their <code>AptosFramework::Coin::CoinStore</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_deposit">deposit</a>&lt;B, Q, E&gt;(user: &signer, b_val: u64, q_val: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_deposit">deposit</a>&lt;B, Q, E&gt;(
    user: &signer,
    b_val: u64,
    q_val: u64
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <b>let</b> addr = s_a_o(user); // Get user <b>address</b>
    // Assert user <b>has</b> order collateral container
    <b>assert</b>!(<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr), <a href="User.md#0xc0deb00c_User_E_NO_O_C">E_NO_O_C</a>);
    // Assert user actually attempting <b>to</b> deposit
    <b>assert</b>!(b_val &gt; 0 || q_val &gt; 0, <a href="User.md#0xc0deb00c_User_E_NO_TRANSFER">E_NO_TRANSFER</a>);
    // Borrow mutable reference <b>to</b> user collateral container
    <b>let</b> o_c = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>if</b> (b_val &gt; 0) { // If base coin <b>to</b> be deposited
        // Withdraw from CoinStore, merge into <a href="User.md#0xc0deb00c_User_OC">OC</a>
        coin_merge&lt;B&gt;(&<b>mut</b> o_c.b_c, coin_withdraw&lt;B&gt;(user, b_val));
        o_c.b_a = o_c.b_a + b_val; // Increment available base coin
    };
    <b>if</b> (q_val &gt; 0) { // If quote coin <b>to</b> be deposited
        // Withdraw from CoinStore, merge into <a href="User.md#0xc0deb00c_User_OC">OC</a>
        coin_merge&lt;Q&gt;(&<b>mut</b> o_c.q_c, coin_withdraw&lt;Q&gt;(user, q_val));
        o_c.q_a = o_c.q_a + q_val; // Increment available quote coin
    };
    <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(user); // Update user sequence counter
}
</code></pre>



</details>

<a name="0xc0deb00c_User_cancel_ask"></a>

## Function `cancel_ask`

Wrapped <code><a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>()</code> call for <code><a href="User.md#0xc0deb00c_User_ASK">ASK</a></code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_ask">cancel_ask</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    id: u128
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>&lt;B, Q, E&gt;(user, host, <a href="User.md#0xc0deb00c_User_ASK">ASK</a>, id);
}
</code></pre>



</details>

<a name="0xc0deb00c_User_cancel_bid"></a>

## Function `cancel_bid`

Wrapped <code><a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>()</code> call for <code><a href="User.md#0xc0deb00c_User_BID">BID</a></code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_bid">cancel_bid</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    id: u128
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>&lt;B, Q, E&gt;(user, host, <a href="User.md#0xc0deb00c_User_BID">BID</a>, id);
}
</code></pre>



</details>

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
    o_i_o&lt;B, Q, E&gt;(user, r_s_f&lt;E&gt;(), &orders_cap());
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

<a name="0xc0deb00c_User_submit_ask"></a>

## Function `submit_ask`

Wrapped <code><a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>()</code> call for <code><a href="User.md#0xc0deb00c_User_ASK">ASK</a></code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_submit_ask">submit_ask</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, price: u64, size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_submit_ask">submit_ask</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    price: u64,
    size: u64
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>&lt;B, Q, E&gt;(user, host, <a href="User.md#0xc0deb00c_User_ASK">ASK</a>, price, size);
}
</code></pre>



</details>

<a name="0xc0deb00c_User_submit_bid"></a>

## Function `submit_bid`

Wrapped <code><a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>()</code> call for <code><a href="User.md#0xc0deb00c_User_BID">BID</a></code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_submit_bid">submit_bid</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, price: u64, size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_submit_bid">submit_bid</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    price: u64,
    size: u64
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>&lt;B, Q, E&gt;(user, host, <a href="User.md#0xc0deb00c_User_BID">BID</a>, price, size);
}
</code></pre>



</details>

<a name="0xc0deb00c_User_withdraw"></a>

## Function `withdraw`

Withdraw <code>b_val</code> base coin and <code>q_val</code> quote coin from <code>user</code>'s
<code><a href="User.md#0xc0deb00c_User_OC">OC</a></code>, into their <code>AptosFramework::Coin::CoinStore</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_withdraw">withdraw</a>&lt;B, Q, E&gt;(user: &signer, b_val: u64, q_val: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_withdraw">withdraw</a>&lt;B, Q, E&gt;(
    user: &signer,
    b_val: u64,
    q_val: u64
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <b>let</b> addr = s_a_o(user); // Get user <b>address</b>
    // Assert user <b>has</b> order collateral container
    <b>assert</b>!(<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr), <a href="User.md#0xc0deb00c_User_E_NO_O_C">E_NO_O_C</a>);
    // Assert user actually attempting <b>to</b> withdraw
    <b>assert</b>!(b_val &gt; 0 || q_val &gt; 0, <a href="User.md#0xc0deb00c_User_E_NO_TRANSFER">E_NO_TRANSFER</a>);
    // Borrow mutable reference <b>to</b> user collateral container
    <b>let</b> o_c = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>if</b> (b_val &gt; 0) { // If base coin <b>to</b> be withdrawn
        // Assert not trying <b>to</b> withdraw more than available
        <b>assert</b>!(!(b_val &gt; o_c.b_a), <a href="User.md#0xc0deb00c_User_E_WITHDRAW_TOO_MUCH">E_WITHDRAW_TOO_MUCH</a>);
        // Withdraw from order collateral, deposit <b>to</b> coin store
        c_d&lt;B&gt;(addr, coin_extract&lt;B&gt;(&<b>mut</b> o_c.b_c, b_val));
        o_c.b_a = o_c.b_a - b_val; // Update available amount
    };
    <b>if</b> (q_val &gt; 0) { // If quote coin <b>to</b> be withdrawn
        // Assert not trying <b>to</b> withdraw more than available
        <b>assert</b>!(!(q_val &gt; o_c.q_a), <a href="User.md#0xc0deb00c_User_E_WITHDRAW_TOO_MUCH">E_WITHDRAW_TOO_MUCH</a>);
        // Withdraw from order collateral, deposit <b>to</b> coin store
        c_d&lt;Q&gt;(addr, coin_extract&lt;Q&gt;(&<b>mut</b> o_c.q_c, q_val));
        o_c.q_a = o_c.q_a - q_val; // Update available amount
    };
    <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(user); // Update user sequence counter
}
</code></pre>



</details>

<a name="0xc0deb00c_User_process_fill"></a>

## Function `process_fill`

Update open orders for a user who has an order on the book and
route the corresponding funds between them and a counterparty
during a match fill, updating available collateral amounts
accordingly. Should only be called by the matching engine and
thus skips redundant error checking that should be performed by
other functions if execution sequence has reached this step.


<a name="@Terminology_1"></a>

### Terminology

* The "target" user has an order that is on the order book
* The "incoming" user's order has just been matched against the
target order by the matching engine


<a name="@Parameters_2"></a>

### Parameters

* <code>target</code>: Target user address
* <code>incoming</code>: Incoming user address
* <code>side</code>: <code><a href="User.md#0xc0deb00c_User_ASK">ASK</a></code> or <code><a href="User.md#0xc0deb00c_User_BID">BID</a></code>
* <code>id</code>: Order ID of target order (See <code>Econia::ID</code>)
* <code>size</code>: The fill size, in base coin parcels (See
<code>Econia::Registry</code>)
* <code>scale_factor</code>: The scale factor for the given market (see
<code>Econia::Registry</code>)
* <code>complete</code>: If <code><b>true</b></code>, target user's order is completely
filled, else only partially filled


<a name="@Assumptions_3"></a>

### Assumptions

* Both users have order collateral containers with sufficient
collateral on hand
* Target user has an open orders having an order with the
specified ID on the specified side, of sufficient size


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_process_fill">process_fill</a>&lt;B, Q, E&gt;(target: <b>address</b>, incoming: <b>address</b>, side: bool, id: u128, size: u64, scale_factor: u64, complete: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="User.md#0xc0deb00c_User_process_fill">process_fill</a>&lt;B, Q, E&gt;(
    target: <b>address</b>,
    incoming: <b>address</b>,
    side: bool,
    id: u128,
    size: u64,
    scale_factor: u64,
    complete: bool,
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a> {
    <b>let</b> orders_cap = orders_cap(); // Get orders <b>friend</b> capability
    // If target user's order completely filled, remove it from
    // their open orders
    <b>if</b> (complete) remove_order&lt;B, Q, E&gt;(target, side, id, &orders_cap) <b>else</b>
        // Else decrement their order size by the fill amount
        decrement_order_size&lt;B, Q, E&gt;(target, side, id, size, &orders_cap);
    // Compute amount of base coin subunits <b>to</b> route
    <b>let</b> base_to_route = size * scale_factor;
    // Compute amount of quote coin subunits <b>to</b> route
    <b>let</b> quote_to_route = size * id_price(id);
    // If target order is an ask, incoming user gets base coin from
    // target user
    <b>let</b> (base_to, base_from) = <b>if</b> (side == <a href="User.md#0xc0deb00c_User_ASK">ASK</a>) (incoming, target) <b>else</b>
        (target, incoming); // Flip the polarity <b>if</b> a bid
    // Get mutable reference <b>to</b> container yielding base coins
    <b>let</b> yields_base = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(base_from);
    // Withdraw base coins from yielding container
    <b>let</b> base_coins = coin_extract&lt;B&gt;(&<b>mut</b> yields_base.b_c, base_to_route);
    // Get mutable reference <b>to</b> container receiving base coins
    <b>let</b> gets_base = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(base_to);
    // Merge base coins into receiving container
    coin_merge&lt;B&gt;(&<b>mut</b> gets_base.b_c, base_coins);
    // Increment base coin recipient's available amount
    gets_base.b_a = gets_base.b_a + base_to_route;
    // Withdraw quote coins from base coin recipient
    <b>let</b> quote_coins = coin_extract&lt;Q&gt;(&<b>mut</b> gets_base.q_c, quote_to_route);
    // Get mutable reference <b>to</b> container getting quote coins
    <b>let</b> gets_quote = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(base_from);
    // Merge quote coins into receiving container
    coin_merge&lt;Q&gt;(&<b>mut</b> gets_quote.q_c, quote_coins);
    // Increment quote coin recipient's available amount
    gets_quote.q_a = gets_quote.q_a + quote_to_route;
}
</code></pre>



</details>

<a name="0xc0deb00c_User_cancel_order"></a>

## Function `cancel_order`

Cancel order for market <code>&lt;B, Q, E&gt;</code> and update available
collateral accordingly, aborting if user does not have an order
collateral container


<a name="@Parameters_4"></a>

### Parameters

* <code>user</code>: User cancelling an order
* <code>host</code>: The market host (See <code>Econia::Registry</code>)
* <code>side</code>: <code><a href="User.md#0xc0deb00c_User_ASK">ASK</a></code> or <code><a href="User.md#0xc0deb00c_User_BID">BID</a></code>
* <code>id</code>: Order ID (see <code>Econia::ID</code>)


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, side: bool, id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_cancel_order">cancel_order</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    side: bool,
    id: u128
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_SC">SC</a>, <a href="User.md#0xc0deb00c_User_OC">OC</a> {
    <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(user); // Update user sequence counter
    <b>let</b> addr = s_a_o(user); // Get user <b>address</b>
    // Assert user <b>has</b> order collateral container
    <b>assert</b>!(<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr), <a href="User.md#0xc0deb00c_User_E_NO_O_C">E_NO_O_C</a>);
    // Borrow mutable reference <b>to</b> user's order collateral container
    <b>let</b> o_c = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>if</b> (side == <a href="User.md#0xc0deb00c_User_ASK">ASK</a>) { // If cancelling an ask
        // Cancel on user's open orders, storing scaled size
        <b>let</b> s_s = o_c_a&lt;B, Q, E&gt;(addr, id, &orders_cap());
        // Cancel on order book
        b_c_a&lt;B, Q, E&gt;(host, id, &c_b_f_c());
        // Increment amount of base coins available for withdraw,
        // by order scaled size times scale factor on given market
        o_c.b_a = o_c.b_a + s_s * o_s_f&lt;B, Q, E&gt;(addr);
    } <b>else</b> { // If cancelling a bid
        // Cancel on user's open orders, storing scaled size
        <b>let</b> s_s = o_c_b&lt;B, Q, E&gt;(addr, id, &orders_cap());
        // Cancel on order book
        b_c_b&lt;B, Q, E&gt;(host, id, &c_b_f_c());
        // Increment amount of quote coins available for withdraw,
        // by order scaled size times price from order <a href="ID.md#0xc0deb00c_ID">ID</a>
        o_c.q_a = o_c.q_a + s_s * id_price(id);
    }
}
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
    <b>assert</b>!(!<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(s_a_o(user)), <a href="User.md#0xc0deb00c_User_E_O_C_EXISTS">E_O_C_EXISTS</a>);
    // Assert given market <b>has</b> actually been registered
    <b>assert</b>!(r_i_r&lt;B, Q, E&gt;(), <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>);
    // Pack empty order collateral container
    <b>let</b> o_c = <a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;{b_c: c_z&lt;B&gt;(), b_a: 0, q_c: c_z&lt;Q&gt;(), q_a: 0};
    <b>move_to</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(user, o_c); // Move <b>to</b> user account
}
</code></pre>



</details>

<a name="0xc0deb00c_User_submit_limit_order"></a>

## Function `submit_limit_order`

Submit limit order for market <code>&lt;B, Q, E&gt;</code>


<a name="@Parameters_5"></a>

### Parameters

* <code>user</code>: User submitting a limit order
* <code>host</code>: The market host (See <code>Econia::Registry</code>)
* <code>side</code>: <code><a href="User.md#0xc0deb00c_User_ASK">ASK</a></code> or <code><a href="User.md#0xc0deb00c_User_BID">BID</a></code>
* <code>price</code>: Scaled integer price (see <code>Econia::ID</code>)
* <code>size</code>: Scaled order size (number of base coin parcels per
<code>Econia::Orders</code>)


<a name="@Abort_conditions_6"></a>

### Abort conditions

* If no such market exists at host address
* If user does not have order collateral container for market
* If user does not have enough collateral
* If placing an order would cross the spread (temporary)


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>&lt;B, Q, E&gt;(user: &signer, host: <b>address</b>, side: bool, price: u64, size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_submit_limit_order">submit_limit_order</a>&lt;B, Q, E&gt;(
    user: &signer,
    host: <b>address</b>,
    side: bool,
    price: u64,
    size: u64
) <b>acquires</b> <a href="User.md#0xc0deb00c_User_OC">OC</a>, <a href="User.md#0xc0deb00c_User_SC">SC</a> {
    <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(user); // Update user sequence counter
    // Assert market <b>exists</b> at given host <b>address</b>
    <b>assert</b>!(b_e_b&lt;B, Q, E&gt;(host), <a href="User.md#0xc0deb00c_User_E_NO_MARKET">E_NO_MARKET</a>);
    <b>let</b> addr = s_a_o(user); // Get user <b>address</b>
    // Assert user <b>has</b> order collateral container
    <b>assert</b>!(<b>exists</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr), <a href="User.md#0xc0deb00c_User_E_NO_O_C">E_NO_O_C</a>);
    // Borrow mutable reference <b>to</b> user's order collateral container
    <b>let</b> o_c = <b>borrow_global_mut</b>&lt;<a href="User.md#0xc0deb00c_User_OC">OC</a>&lt;B, Q, E&gt;&gt;(addr);
    <b>let</b> v_n = v_g_v_n(); // Get transaction version number
    <b>let</b> c_s: bool; // Define flag for <b>if</b> order crosses the spread
    <b>if</b> (side == <a href="User.md#0xc0deb00c_User_ASK">ASK</a>) { // If limit order is an ask
        <b>let</b> id = id_a(price, v_n); // Get corresponding order id
        // Verify and add <b>to</b> user's open orders, storing amount of
        // base coin subunits required <b>to</b> fill the trade
        <b>let</b> (b_c_subs, _) =
            o_a_a&lt;B, Q, E&gt;(addr, id, price, size, &orders_cap());
        // Assert user <b>has</b> enough base coins held <b>as</b> collateral
        <b>assert</b>!(!(b_c_subs &gt; o_c.b_a), <a href="User.md#0xc0deb00c_User_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
        // Decrement amount of base coins available for withdraw
        o_c.b_a = o_c.b_a - b_c_subs;
        // Try adding <b>to</b> order book, storing crossed spread flag
        c_s =
            b_a_a&lt;B, Q, E&gt;(host, addr, id, price, size, &c_b_f_c());
    } <b>else</b> { // If limit order is a bid
        <b>let</b> id = id_b(price, v_n); // Get corresponding order id
        // Verify and add <b>to</b> user's open orders, storing amoung of
        // quote coin subunits required <b>to</b> fill the trade
        <b>let</b> (_, q_c_subs) =
            o_a_b&lt;B, Q, E&gt;(addr, id, price, size, &orders_cap());
        // Assert user <b>has</b> enough quote coins held <b>as</b> collateral
        <b>assert</b>!(!(q_c_subs &gt; o_c.q_a), <a href="User.md#0xc0deb00c_User_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
        // Decrement amount of quote coins available for withdraw
        o_c.q_a = o_c.q_a - q_c_subs;
        // Try adding <b>to</b> order book, storing crossed spread flag
        c_s =
            b_a_b&lt;B, Q, E&gt;(host, addr, id, price, size, &c_b_f_c());
    };
    <b>assert</b>!(!c_s, <a href="User.md#0xc0deb00c_User_E_CROSSES_SPREAD">E_CROSSES_SPREAD</a>); // Assert uncrossed spread
}
</code></pre>



</details>

<a name="0xc0deb00c_User_update_s_c"></a>

## Function `update_s_c`

Update sequence counter for user <code>u</code> with the sequence number of
the current transaction, aborting if user does not have an
initialized sequence counter or if sequence number is not
greater than the number indicated by the user's <code><a href="User.md#0xc0deb00c_User_SC">SC</a></code>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(u: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0xc0deb00c_User_update_s_c">update_s_c</a>(
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
