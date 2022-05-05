
<a name="0x1d157846c6d7ac69cbbc60590c325683_User"></a>

# Module `0x1d157846c6d7ac69cbbc60590c325683::User`

User account and order functionality


-  [Resource `Collateral`](#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral)
-  [Struct `Order`](#0x1d157846c6d7ac69cbbc60590c325683_User_Order)
-  [Resource `Orders`](#0x1d157846c6d7ac69cbbc60590c325683_User_Orders)
-  [Constants](#@Constants_0)
-  [Function `collateral_balances`](#0x1d157846c6d7ac69cbbc60590c325683_User_collateral_balances)
-  [Function `deposit`](#0x1d157846c6d7ac69cbbc60590c325683_User_deposit)
-  [Function `deposit_coins`](#0x1d157846c6d7ac69cbbc60590c325683_User_deposit_coins)
-  [Function `match_order`](#0x1d157846c6d7ac69cbbc60590c325683_User_match_order)
-  [Function `num_orders`](#0x1d157846c6d7ac69cbbc60590c325683_User_num_orders)
-  [Function `init_account`](#0x1d157846c6d7ac69cbbc60590c325683_User_init_account)
-  [Function `publish_collateral`](#0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral)
-  [Function `publish_orders`](#0x1d157846c6d7ac69cbbc60590c325683_User_publish_orders)
-  [Function `record_order`](#0x1d157846c6d7ac69cbbc60590c325683_User_record_order)
-  [Function `record_mock_order`](#0x1d157846c6d7ac69cbbc60590c325683_User_record_mock_order)
-  [Function `trigger_match_order`](#0x1d157846c6d7ac69cbbc60590c325683_User_trigger_match_order)
-  [Function `withdraw`](#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw)
-  [Function `withdraw_coins`](#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw_coins)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">0x1d157846c6d7ac69cbbc60590c325683::Coin</a>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_Collateral"></a>

## Resource `Collateral`

Collateral cointainer


<pre><code><b>struct</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>holdings: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>available: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_Order"></a>

## Struct `Order`

A single limit order, always USD-denominated APT (APT/USDC).
Colloquially, "one APT costs $120"


<pre><code><b>struct</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>side: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>unfilled: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_Orders"></a>

## Resource `Orders`

Resource container for open limit orders


<pre><code><b>struct</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>open: vector&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">User::Order</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1d157846c6d7ac69cbbc60590c325683_User_BUY"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_COLLATERAL"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_COLLATERAL">E_ALREADY_HAS_COLLATERAL</a>: u64 = 0;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_ORDERS"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_ORDERS">E_ALREADY_HAS_ORDERS</a>: u64 = 2;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_COLLATERAL_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_COLLATERAL_NOT_EMPTY">E_COLLATERAL_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_DEPOSIT_FAILURE"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_DEPOSIT_FAILURE">E_DEPOSIT_FAILURE</a>: u64 = 4;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_INSUFFICIENT_COLLATERAL"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INSUFFICIENT_COLLATERAL">E_INSUFFICIENT_COLLATERAL</a>: u64 = 5;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_RECORDER"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_RECORDER">E_INVALID_RECORDER</a>: u64 = 7;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_TRIGGER"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_TRIGGER">E_INVALID_TRIGGER</a>: u64 = 10;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_MATCH_ERROR"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_MATCH_ERROR">E_MATCH_ERROR</a>: u64 = 9;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_NO_ORDERS"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_NO_ORDERS">E_NO_ORDERS</a>: u64 = 8;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_ORDERS_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_ORDERS_NOT_EMPTY">E_ORDERS_NOT_EMPTY</a>: u64 = 3;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_E_RECORD_ORDER_INVALID"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_RECORD_ORDER_INVALID">E_RECORD_ORDER_INVALID</a>: u64 = 6;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_SELL"></a>



<pre><code><b>const</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_User_collateral_balances"></a>

## Function `collateral_balances`

Get holdings and available amount for given coin type


<pre><code><b>public</b> <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_collateral_balances">collateral_balances</a>&lt;CoinType&gt;(addr: <b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_collateral_balances">collateral_balances</a>&lt;CoinType&gt;(
    addr: <b>address</b>
): (
    u64, // Holdings in subunits
    u64 // Available <b>to</b> withdraw
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a> {
    (
        report_subunits&lt;CoinType&gt;(
            &<b>borrow_global</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).holdings
        ),
        <b>borrow_global</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).available
    )
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_deposit"></a>

## Function `deposit`

Deposit given coin to collateral container


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;CoinType&gt;(addr: <b>address</b>, coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;CoinType&gt;(
    addr: <b>address</b>,
    coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a> {
    <b>let</b> target =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).holdings;
    <b>let</b> (added, _, _) = merge_coin_to_target(coin, target);
    <b>let</b> available_ref =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).available;
    *available_ref = *available_ref + added;
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_deposit_coins"></a>

## Function `deposit_coins`

Deposit specified amounts to corresponding collateral
containers, withdrawing from Coin::Balance


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit_coins">deposit_coins</a>(account: &signer, apt_subunits: u64, usd_subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit_coins">deposit_coins</a>(
    account: &signer,
    apt_subunits: u64,
    usd_subunits: u64
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a> {
    <b>let</b> (apt, usd) =
        <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw_coins">Coin::withdraw_coins</a>(account, apt_subunits, usd_subunits);
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;APT&gt;(addr, apt);
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;USD&gt;(addr, usd);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_match_order"></a>

## Function `match_order`

Match order for given address and order id. Should pass only APT
or USD depending on the order side. If passed APT returns USD,
and if passed USD returns APT


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_match_order">match_order</a>(addr: <b>address</b>, id: u64, apt: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">Coin::APT</a>&gt;, usd: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">Coin::USD</a>&gt;): (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">Coin::APT</a>&gt;, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">Coin::USD</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_match_order">match_order</a>(
    addr: <b>address</b>,
    id: u64,
    apt: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;APT&gt;, // Can have 0 subunits
    usd: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;USD&gt; // Can have 0 subunits
): (
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;APT&gt;, // Can have 0 subunits
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;USD&gt; // Can have 0 subunits
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> {
    <b>let</b> open_orders = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a>&gt;(addr).open;
    // Since <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt; will <b>abort</b> for invalid
    // indices, skip checks on length of vector/<b>loop</b> count
    // Similarly ignore integer underflow range checks
    <b>let</b> i = 0;
    <b>loop</b> {
        <b>let</b> order = <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt;(open_orders, i);
        <b>if</b> (order.id == id) { // Found the order <b>to</b> match
            // Empty placeholders <b>to</b> <b>return</b> later
            <b>let</b> apt_final = get_empty_coin&lt;APT&gt;();
            <b>let</b> usd_final = get_empty_coin&lt;USD&gt;();
            <b>if</b> (order.side == <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_BUY">BUY</a>) {
                // Calculate amounts <b>to</b> disperse <b>to</b> user and book
                <b>let</b> apt_for_user = report_subunits&lt;APT&gt;(&apt);
                <b>let</b> usd_for_book = order.price * apt_for_user;
                // Update order fill amount
                order.unfilled = order.unfilled - apt_for_user;
                // Split inbound APT, deposit <b>to</b> user
                <b>let</b> (apt_to_deposit, apt_to_return) =
                    split_coin&lt;APT&gt;(apt, apt_for_user);
                <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;APT&gt;(addr, apt_to_deposit);
                // Withdraw USD from user collateral for book
                <b>let</b> withdrawn_usd = <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;USD&gt;(addr, usd_for_book);
                <b>let</b> usd_to_return = merge_coins(usd, withdrawn_usd);
                // Merge final APT and USD into placeholders
                merge_coin_to_target(apt_to_return, &<b>mut</b> apt_final);
                merge_coin_to_target(usd_to_return, &<b>mut</b> usd_final);
            } <b>else</b> { // If a <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_SELL">SELL</a>
                // Calculate amounts <b>to</b> disperse <b>to</b> user and book
                <b>let</b> usd_for_user = report_subunits&lt;USD&gt;(&usd);
                <b>let</b> apt_for_book = usd_for_user / order.price;
                // Update order fill amount
                order.unfilled = order.unfilled - apt_for_book;
                // Split inbound USD, deposit <b>to</b> user
                <b>let</b> (usd_to_deposit, usd_to_return) =
                    split_coin&lt;USD&gt;(usd, usd_for_user);
                <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_deposit">deposit</a>&lt;USD&gt;(addr, usd_to_deposit);
                // Withdraw APT from user collateral for book
                <b>let</b> withdrawn_apt = <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;APT&gt;(addr, apt_for_book);
                <b>let</b> apt_to_return = merge_coins(apt, withdrawn_apt);
                // Merge final APT and USD into placeholders
                merge_coin_to_target(apt_to_return, &<b>mut</b> apt_final);
                merge_coin_to_target(usd_to_return, &<b>mut</b> usd_final);
            };
            // If order fully matched, remove from orders resource
            <b>if</b> (order.unfilled == 0) {
                <b>let</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>{id: _, side: _, price: _, unfilled: _} =
                    <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt;(open_orders, i);
            };
            <b>return</b>(apt_final, usd_final)
        };
        i = i + 1;
    }
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_num_orders"></a>

## Function `num_orders`

Return number of open orders for given address


<pre><code><b>public</b> <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_num_orders">num_orders</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_num_orders">num_orders</a>(
    addr: <b>address</b>
): u64
 <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> {
    <b>let</b> open = & <b>borrow_global</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a>&gt;(addr).open;
    <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt;(open)
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_init_account"></a>

## Function `init_account`

Initialize user collateral containers and open orders resource


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_init_account">init_account</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_init_account">init_account</a>(
    account: &signer,
) {
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral">publish_collateral</a>&lt;APT&gt;(account);
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral">publish_collateral</a>&lt;USD&gt;(account);
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_orders">publish_orders</a>(account);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral"></a>

## Function `publish_collateral`

Publish empty collateral container for given CoinType at account


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral">publish_collateral</a>&lt;CoinType&gt;(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_collateral">publish_collateral</a>&lt;CoinType&gt;(
    account: &signer
) {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>assert</b>!(!<b>exists</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr), <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_COLLATERAL">E_ALREADY_HAS_COLLATERAL</a>);
    <b>let</b> empty = get_empty_coin&lt;CoinType&gt;();
    <b>move_to</b>(account, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;{holdings: empty, available: 0});
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_publish_orders"></a>

## Function `publish_orders`

Publish empty open orders resource at account


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_orders">publish_orders</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_publish_orders">publish_orders</a>(
    account: &signer
) {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>assert</b>!(!<b>exists</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a>&gt;(addr), <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_ALREADY_HAS_ORDERS">E_ALREADY_HAS_ORDERS</a>);
    <b>move_to</b>(account, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a>{open: <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt;()});
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_record_order"></a>

## Function `record_order`

Append an order to a user's open orders resource


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_record_order">record_order</a>(addr: <b>address</b>, order: <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">User::Order</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_record_order">record_order</a>(
    addr: <b>address</b>,
    order: <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> {
    <b>let</b> open = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a>&gt;(addr).open;
    <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>&gt;(open, order);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_record_mock_order"></a>

## Function `record_mock_order`

Record a mock order to a user's open orders resource. Designed
for testing, can only be called by Ultima account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_record_mock_order">record_mock_order</a>(account: &signer, addr: <b>address</b>, id: u64, side: bool, price: u64, unfilled: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_record_mock_order">record_mock_order</a>(
    account: &signer,
    addr: <b>address</b>,
    id: u64,
    side: bool,
    price: u64,
    unfilled: u64,
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @Ultima, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_RECORDER">E_INVALID_RECORDER</a>);
    <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_record_order">record_order</a>(addr, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Order">Order</a>{id, side, price, unfilled});
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_trigger_match_order"></a>

## Function `trigger_match_order`

Directly match an order against a user's open orders. Designed
for testing, can only be called by Ultima account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_trigger_match_order">trigger_match_order</a>(account: &signer, addr: <b>address</b>, id: u64, apt_subunits: u64, usd_subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_trigger_match_order">trigger_match_order</a>(
    account: &signer,
    addr: <b>address</b>,
    id: u64,
    apt_subunits: u64,
    usd_subunits: u64,
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Orders">Orders</a> {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @Ultima, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INVALID_TRIGGER">E_INVALID_TRIGGER</a>);
    <b>let</b> apt_yielded = yield_coin&lt;APT&gt;(account, apt_subunits);
    <b>let</b> usd_yielded = yield_coin&lt;USD&gt;(account, usd_subunits);
    <b>let</b> (apt_match, usd_match) =
        <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_match_order">match_order</a>(addr, id, apt_yielded, usd_yielded);
    burn&lt;APT&gt;(account, apt_match);
    burn&lt;USD&gt;(account, usd_match);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_withdraw"></a>

## Function `withdraw`

Withdraw requested amount from collateral container at address


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;CoinType&gt;(addr: <b>address</b>, amount: u64): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;CoinType&gt;(
    addr: <b>address</b>,
    amount: u64 // Number of subunits <b>to</b> withdraw
): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a> {
    // Verify amount available, decrement marker accordingly
    <b>let</b> available_ref =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).available;
    <b>let</b> available = *available_ref;
    <b>assert</b>!(amount &lt;= available, <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_E_INSUFFICIENT_COLLATERAL">E_INSUFFICIENT_COLLATERAL</a>);
    *available_ref = *available_ref - amount;

    // Split off <b>return</b> coin from holdings
    <b>let</b> target =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a>&lt;CoinType&gt;&gt;(addr).holdings;
    <b>let</b> (result, _, _) =
        split_coin_from_target&lt;CoinType&gt;(amount, target);
    result
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_User_withdraw_coins"></a>

## Function `withdraw_coins`

Withdraw specified amounts from collateral into Coin::Balance


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw_coins">withdraw_coins</a>(account: &signer, apt_subunits: u64, usd_subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw_coins">withdraw_coins</a>(
    account: &signer,
    apt_subunits: u64,
    usd_subunits: u64
) <b>acquires</b> <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_Collateral">Collateral</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> apt = <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;APT&gt;(addr, apt_subunits);
    <b>let</b> usd = <a href="User.md#0x1d157846c6d7ac69cbbc60590c325683_User_withdraw">withdraw</a>&lt;USD&gt;(addr, usd_subunits);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit_coins">Coin::deposit_coins</a>(addr, apt, usd);
}
</code></pre>



</details>
