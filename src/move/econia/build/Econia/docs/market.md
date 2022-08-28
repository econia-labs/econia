
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market-level book keeping functionality, with matching engine.
Allows for self-matched trades since preventing them is practically
impossible in a permissionless market: all a user has to do is
open two wallets and trade them against each other.


-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Struct `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Resource `OrderBooks`](#0xc0deb00c_market_OrderBooks)
-  [Constants](#@Constants_0)
-  [Function `cancel_all_limit_orders_custodian`](#0xc0deb00c_market_cancel_all_limit_orders_custodian)
-  [Function `cancel_limit_order_custodian`](#0xc0deb00c_market_cancel_limit_order_custodian)
-  [Function `place_limit_order_custodian`](#0xc0deb00c_market_place_limit_order_custodian)
-  [Function `cancel_all_limit_orders_user`](#0xc0deb00c_market_cancel_all_limit_orders_user)
-  [Function `cancel_limit_order_user`](#0xc0deb00c_market_cancel_limit_order_user)
-  [Function `place_limit_order_user`](#0xc0deb00c_market_place_limit_order_user)
-  [Function `register_market_generic`](#0xc0deb00c_market_register_market_generic)
-  [Function `register_market_pure_coin`](#0xc0deb00c_market_register_market_pure_coin)
-  [Function `cancel_all_limit_orders`](#0xc0deb00c_market_cancel_all_limit_orders)
    -  [Parameters](#@Parameters_1)
    -  [Assumes](#@Assumes_2)
-  [Function `cancel_limit_order`](#0xc0deb00c_market_cancel_limit_order)
    -  [Parameters](#@Parameters_3)
    -  [Abort conditions](#@Abort_conditions_4)
-  [Function `get_counter`](#0xc0deb00c_market_get_counter)
-  [Function `match`](#0xc0deb00c_market_match)
    -  [Type parameters](#@Type_parameters_5)
    -  [Parameters](#@Parameters_6)
    -  [Assumes](#@Assumes_7)
-  [Function `match_init`](#0xc0deb00c_market_match_init)
    -  [Parameters](#@Parameters_8)
    -  [Returns](#@Returns_9)
-  [Function `match_loop`](#0xc0deb00c_market_match_loop)
    -  [Type parameters](#@Type_parameters_10)
    -  [Parameters](#@Parameters_11)
    -  [Passing considerations](#@Passing_considerations_12)
-  [Function `match_loop_break`](#0xc0deb00c_market_match_loop_break)
    -  [Parameters](#@Parameters_13)
-  [Function `match_loop_init`](#0xc0deb00c_market_match_loop_init)
    -  [Parameters](#@Parameters_14)
    -  [Returns](#@Returns_15)
    -  [Passing considerations](#@Passing_considerations_16)
-  [Function `match_loop_order`](#0xc0deb00c_market_match_loop_order)
    -  [Type parameters](#@Type_parameters_17)
    -  [Parameters](#@Parameters_18)
-  [Function `match_loop_order_fill_size`](#0xc0deb00c_market_match_loop_order_fill_size)
    -  [Parameters](#@Parameters_19)
-  [Function `match_loop_order_follow_up`](#0xc0deb00c_market_match_loop_order_follow_up)
    -  [Parameters](#@Parameters_20)
    -  [Returns](#@Returns_21)
    -  [Passing considerations](#@Passing_considerations_22)
    -  [Target order reference rationale](#@Target_order_reference_rationale_23)
-  [Function `match_range_check_inputs`](#0xc0deb00c_market_match_range_check_inputs)
    -  [Abort conditions](#@Abort_conditions_24)
-  [Function `match_verify_fills`](#0xc0deb00c_market_match_verify_fills)
    -  [Parameters](#@Parameters_25)
    -  [Abort conditions](#@Abort_conditions_26)
-  [Function `place_limit_order`](#0xc0deb00c_market_place_limit_order)
    -  [Parameters](#@Parameters_27)
    -  [Abort conditions](#@Abort_conditions_28)
    -  [Assumes](#@Assumes_29)
-  [Function `register_market`](#0xc0deb00c_market_register_market)
    -  [Type parameters](#@Type_parameters_30)
    -  [Parameters](#@Parameters_31)
-  [Function `register_order_book`](#0xc0deb00c_market_register_order_book)
    -  [Type parameters](#@Type_parameters_32)
    -  [Parameters](#@Parameters_33)
-  [Function `verify_order_book_exists`](#0xc0deb00c_market_verify_order_book_exists)
    -  [Abort conditions](#@Abort_conditions_34)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
<b>use</b> <a href="order_id.md#0xc0deb00c_order_id">0xc0deb00c::order_id</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="0xc0deb00c_market_Order"></a>

## Struct `Order`

An order on the order book


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Number of lots to be filled
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of corresponding user
</dd>
<dt>
<code>general_custodian_id: u64</code>
</dt>
<dd>
 For given user, the ID of the custodian required to approve
 transactions other than generic asset transfers
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBook"></a>

## Struct `OrderBook`

An order book for a given market


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to a non-coin asset
 indicated by the market host.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds a non-coin asset
 indicated by the market host.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per tick
</dd>
<dt>
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Asks tree
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Bids tree
</dd>
<dt>
<code>min_ask: u128</code>
</dt>
<dd>
 Order ID of minimum ask, per price-time priority. The ask
 side "spread maker".
</dd>
<dt>
<code>max_bid: u128</code>
</dt>
<dd>
 Order ID of maximum bid, per price-time priority. The bid
 side "spread maker".
</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>
 Number of limit orders placed on book
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBooks"></a>

## Resource `OrderBooks`

Order book map for all of a user's <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>s


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u64, <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&gt;</code>
</dt>
<dd>
 Map from market ID to <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>. Separated into different
 table entries to reduce transaction collisions across
 markets
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_market_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_market_LEFT"></a>

Left traversal direction, denoting predecessor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_RIGHT"></a>

Right traversal direction, denoting successor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_CUSTODIAN"></a>

When invalid custodian attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_market_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_PURE_COIN_PAIR"></a>

When both base and quote assets are coins


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_BUY"></a>

Buy direction flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_E_BASE_MAX_OVERFLOW"></a>

When filling max lots overflows base asset units


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_BASE_MAX_OVERFLOW">E_BASE_MAX_OVERFLOW</a>: u64 = 14;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_USER"></a>

When invalid user attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_market_E_LIMIT_PRICE_0"></a>

When indicated limit price is 0


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_LIMIT_PRICE_0">E_LIMIT_PRICE_0</a>: u64 = 13;
</code></pre>



<a name="0xc0deb00c_market_E_MAX_LOTS_0"></a>

When maximum indicated lots to match is 0


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MAX_LOTS_0">E_MAX_LOTS_0</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_market_E_MAX_TICKS_0"></a>

When maximum indicated ticks to match is 0


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MAX_TICKS_0">E_MAX_TICKS_0</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_LOTS_EXCEEDS_MAX"></a>

When minimum indicated lots to match exceeds maximum


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_EXCEEDS_MAX">E_MIN_LOTS_EXCEEDS_MAX</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED"></a>

When minimum number of lots are not filled by matching engine


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED">E_MIN_LOTS_NOT_FILLED</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_TICKS_EXCEEDS_MAX"></a>

When minimum indicated ticks to match exceeds maximum


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_EXCEEDS_MAX">E_MIN_TICKS_EXCEEDS_MAX</a>: u64 = 12;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED"></a>

When minimum number of ticks are not filled by matching engine


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED">E_MIN_TICKS_NOT_FILLED</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER"></a>

When order not found in book


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER">E_NO_ORDER</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER_BOOK"></a>

When indicated <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> does not exist


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER_BOOKS"></a>

When a host does not have an <code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code>


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOKS">E_NO_ORDER_BOOKS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_market_E_ORDER_BOOK_EXISTS"></a>

When an order book already exists at given address


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_ORDER_BOOK_EXISTS">E_ORDER_BOOK_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD"></a>

When a post-or-abort limit order crosses the spread


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD">E_POST_OR_ABORT_CROSSED_SPREAD</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_market_E_QUOTE_MAX_OVERFLOW"></a>

When filling max ticks overflows quote asset units


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_QUOTE_MAX_OVERFLOW">E_QUOTE_MAX_OVERFLOW</a>: u64 = 15;
</code></pre>



<a name="0xc0deb00c_market_MAX_BID_DEFAULT"></a>

Default value for maximum bid order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_market_MIN_ASK_DEFAULT"></a>

Default value for minimum ask order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_market_SELL"></a>

Sell direction flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_cancel_all_limit_orders_custodian"></a>

## Function `cancel_all_limit_orders_custodian`

Cancel all limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_custodian">cancel_all_limit_orders_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_custodian">cancel_all_limit_orders_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
        <a href="user.md#0xc0deb00c_user">user</a>,
        host,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        side
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order_custodian"></a>

## Function `cancel_limit_order_custodian`

Cancel a limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
        <a href="user.md#0xc0deb00c_user">user</a>,
        host,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_custodian"></a>

## Function `place_limit_order_custodian`

Place a limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, size: u64, price: u64, post_or_abort: bool, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    size: u64,
    price: u64,
    post_or_abort: bool,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>(
        <a href="user.md#0xc0deb00c_user">user</a>,
        host,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        side,
        size,
        price,
        post_or_abort
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_all_limit_orders_user"></a>

## Function `cancel_all_limit_orders_user`

Cancel all limit orders as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_user">cancel_all_limit_orders_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_user">cancel_all_limit_orders_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        host,
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order_user"></a>

## Function `cancel_limit_order_user`

Cancel a limit order as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        host,
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_user"></a>

## Function `place_limit_order_user`

Place a limit order as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool, size: u64, price: u64, post_or_abort: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    size: u64,
    price: u64,
    post_or_abort: bool
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        host,
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
        size,
        price,
        post_or_abort
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market_generic"></a>

## Function `register_market_generic`

Register a market having at least one asset that is not a coin
type, which requires the authority of custodian indicated by
<code>generic_asset_transfer_custodian_id_ref</code> to verify deposits
and withdrawals of non-coin assets.

See wrapped function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_generic">register_market_generic</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64, generic_asset_transfer_custodian_id_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_generic">register_market_generic</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
    generic_asset_transfer_custodian_id_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(
        host,
        lot_size,
        tick_size,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(generic_asset_transfer_custodian_id_ref)
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market_pure_coin"></a>

## Function `register_market_pure_coin`

Register a market for both base and quote assets as coin types.

See wrapped function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_pure_coin">register_market_pure_coin</a>&lt;BaseCoinType, QuoteCoinType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_pure_coin">register_market_pure_coin</a>&lt;
    BaseCoinType,
    QuoteCoinType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseCoinType, QuoteCoinType&gt;(
        host,
        lot_size,
        tick_size,
        <a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_all_limit_orders"></a>

## Function `cancel_all_limit_orders`

Cancel all of a user's limit orders on the book, and remove from
their market account, silently returning if they have no open
orders.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<a name="@Parameters_1"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user cancelling order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>market_id</code>: Market ID
* <code>general_custodian_id</code>: General custodian ID for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>


<a name="@Assumes_2"></a>

### Assumes

* That <code>get_n_orders_internal()</code> aborts if no corresponding user
orders tree available to cancel from


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, general_custodian_id: u64, side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    side: bool,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(market_id,
        general_custodian_id); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> n_orders = // Get number of orders on given side
        <a href="user.md#0xc0deb00c_user_get_n_orders_internal">user::get_n_orders_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side);
    <b>while</b> (n_orders &gt; 0) { // While <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> open orders
        // Get order ID of order nearest the spread
        <b>let</b> order_id_nearest_spread =
            <a href="user.md#0xc0deb00c_user_get_order_id_nearest_spread_internal">user::get_order_id_nearest_spread_internal</a>(
                <a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side);
        // Cancel the order
        <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(<a href="user.md#0xc0deb00c_user">user</a>, host, market_id, general_custodian_id,
            side, order_id_nearest_spread);
        n_orders = n_orders - 1; // Decrement order count
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order"></a>

## Function `cancel_limit_order`

Cancel limit order on book, remove from user's market account.


<a name="@Parameters_3"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user cancelling order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>market_id</code>: Market ID
* <code>general_custodian_id</code>: General custodian ID for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>


<a name="@Abort_conditions_4"></a>

### Abort conditions

* If the specified <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code> is not on given <code>side</code> for
corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> is not the user who placed the order with the
corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>
* If <code>custodian_id</code> is not the same as that indicated on order
with the corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, general_custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(host, market_id);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Get mutable reference <b>to</b> orders tree for corresponding side
    <b>let</b> tree_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks <b>else</b>
        &<b>mut</b> order_book_ref_mut.bids;
    // Assert order is on book
    <b>assert</b>!(<a href="critbit.md#0xc0deb00c_critbit_has_key">critbit::has_key</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>), <a href="market.md#0xc0deb00c_market_E_NO_ORDER">E_NO_ORDER</a>);
    <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{ // Pop and unpack order from book,
        size: _, // Drop size count
        <a href="user.md#0xc0deb00c_user">user</a>: order_user, // Save indicated <a href="user.md#0xc0deb00c_user">user</a> for checking later
        // Save indicated general custodian ID for checking later
        general_custodian_id: order_general_custodian_id
    } = <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> attempting <b>to</b> cancel is <a href="user.md#0xc0deb00c_user">user</a> on order
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user">user</a> == order_user, <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>);
    // Assert custodian attempting <b>to</b> cancel is custodian on order
    <b>assert</b>!(general_custodian_id == order_general_custodian_id,
        <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    // If cancelling an ask that was previously the spread maker
    <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a> && <a href="order_id.md#0xc0deb00c_order_id">order_id</a> == order_book_ref_mut.min_ask) {
        // Update minimum ask <b>to</b> default value <b>if</b> tree is empty
        order_book_ref_mut.min_ask = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut))
            // Else <b>to</b> the minimum ask on the book
            <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b> <a href="critbit.md#0xc0deb00c_critbit_min_key">critbit::min_key</a>(tree_ref_mut);
    // Else <b>if</b> cancelling a bid that was previously the spread maker
    } <b>else</b> <b>if</b> (side == <a href="market.md#0xc0deb00c_market_BID">BID</a> && <a href="order_id.md#0xc0deb00c_order_id">order_id</a> == order_book_ref_mut.max_bid) {
        // Update maximum bid <b>to</b> default value <b>if</b> tree is empty
        order_book_ref_mut.max_bid = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut))
            // Else <b>to</b> the maximum bid on the book
            <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a> <b>else</b> <a href="critbit.md#0xc0deb00c_critbit_max_key">critbit::max_key</a>(tree_ref_mut);
    };
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID, lot size, and tick size for order
    <b>let</b> (market_account_id, lot_size, tick_size) = (
        <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(market_id, general_custodian_id),
        order_book_ref_mut.lot_size,
        order_book_ref_mut.tick_size);
    // Remove order from corresponding <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_remove_order_internal">user::remove_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, lot_size,
        tick_size, side, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_counter"></a>

## Function `get_counter`

Increment counter for number of orders placed on <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>,
returning the original value.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>
): u64 {
    // Borrow mutable reference <b>to</b> order book serial counter
    <b>let</b> counter_ref_mut = &<b>mut</b> order_book_ref_mut.counter;
    <b>let</b> count = *counter_ref_mut; // Get count
    *counter_ref_mut = count + 1; // Set new count
    count // Return original count
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match"></a>

## Function `match`

Match an incoming order against the order book.

Range check arguments, initialize local variables, verify that
loopwise matching can proceed, then match against the orders
tree in a loopwise traversal. Verify fill amounts afterwards.

Institutes pass-by-reference for enhanced efficiency.


<a name="@Type_parameters_5"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_6"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_lots_ref</code>: Immutable reference to minimum number of lots
to fill
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to fill
* <code>min_ticks_ref</code>: Immutable reference to minimum number of
ticks to fill
* <code>max_ticks_ref</code>: Immutable reference to maximum number of
ticks to fill
* <code>limit_price_ref</code>: Immutable reference to maximum price to
match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price
to match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine, gradually
incremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually decremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine, gradually
decremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually incremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>lots_until_max_final_ref_mut</code>: Mutable reference to counter
for number of lots that can be filled before exceeding maximum
threshold, after matching engine executes
* <code>ticks_until_max_final_ref</code>: Mutable reference to counter for
number of ticks that can be filled before exceeding maximum
maximum, after matching engine executes


<a name="@Assumes_7"></a>

### Assumes

* That if optional coins are passed, they contain sufficient
amounts for matching in accordance with other specifed values


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, lot_size_ref: &u64, tick_size_ref: &u64, direction_ref: &bool, min_lots_ref: &u64, max_lots_ref: &u64, min_ticks_ref: &u64, max_ticks_ref: &u64, limit_price_ref: &u64, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, lots_until_max_final_ref_mut: &<b>mut</b> u64, ticks_until_max_final_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    direction_ref: &bool,
    min_lots_ref: &u64,
    max_lots_ref: &u64,
    min_ticks_ref: &u64,
    max_ticks_ref: &u64,
    limit_price_ref: &u64,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    lots_until_max_final_ref_mut: &<b>mut</b> u64,
    ticks_until_max_final_ref_mut: &<b>mut</b> u64
) {
    // Range check inputs
    <a href="market.md#0xc0deb00c_market_match_range_check_inputs">match_range_check_inputs</a>(lot_size_ref, tick_size_ref, min_lots_ref,
        max_lots_ref, min_ticks_ref, max_ticks_ref, limit_price_ref);
    // Initialize max counters and side-wise matching variables
    <b>let</b> (lots_until_max, ticks_until_max, side, tree_ref_mut,
         spread_maker_ref_mut, n_orders, traversal_direction) =
            <a href="market.md#0xc0deb00c_market_match_init">match_init</a>(order_book_ref_mut, direction_ref, max_lots_ref,
                max_ticks_ref);
    <b>if</b> (n_orders != 0) { // If orders tree <b>has</b> orders <b>to</b> match
        // Match them via loopwise iterated traversal
        <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;BaseType, QuoteType&gt;(market_id_ref, tree_ref_mut,
            &side, lot_size_ref, tick_size_ref, &<b>mut</b> lots_until_max,
            &<b>mut</b> ticks_until_max, limit_price_ref, &<b>mut</b> n_orders,
            spread_maker_ref_mut, &traversal_direction,
            optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
    };
    // Verify fill amounts, compute final threshold allowance counts
    <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(min_lots_ref, max_lots_ref, min_ticks_ref,
        max_ticks_ref, &lots_until_max, &ticks_until_max,
        lots_until_max_final_ref_mut, ticks_until_max_final_ref_mut);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_init"></a>

## Function `match_init`

Initialize variables required for matching.

Inner function for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

Must determine orders tree based on a conditional check on
<code>direction_ref</code> in order for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code> to check that there are
even orders to fill against, hence evaluates other side-wise
variables in ternary operator (even though some of these could
be evaluated later on in <code><a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>()</code>) such that matching
initialization only requires one side-wise conditional check.

Additionally, lots and ticks until max counters are additionally
initialized here rather than in <code><a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>()</code> so they can
be passed by reference and then verified within the local scope
of <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, via <code><a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>()</code>.


<a name="@Parameters_8"></a>

### Parameters

* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to fill
* <code>min_lots_ref</code>: Immutable reference to maximum number of ticks
to fill


<a name="@Returns_9"></a>

### Returns

* <code>u64</code>: Counter for remaining lots that can be filled before
exceeding maximum allowed
* <code>u64</code>: Counter for remaining ticks that can be filled before
exceeding maximum allowed
* <code>bool</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code> corresponding to <code>direction_ref</code>
* <code>&<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>: Mutable reference to orders tree to
fill against
* <code>&<b>mut</b> u128</code>: Mutable reference to spread maker field for given
side
* <code>u64</code>: Number of orders in corresponding tree
* <code>bool</code>: <code><a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code><a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code> (traversal direction) corresponding
to <code>direction_ref</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_init">match_init</a>(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, direction_ref: &bool, max_lots_ref: &u64, max_ticks_ref: &u64): (u64, u64, bool, &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, &<b>mut</b> u128, u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_init">match_init</a>(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    direction_ref: &bool,
    max_lots_ref: &u64,
    max_ticks_ref: &u64,
): (
    u64,
    u64,
    bool,
    &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    &<b>mut</b> u128,
    u64,
    bool,
) {
    // Get side that order fills against, mutable reference <b>to</b>
    // orders tree <b>to</b> fill against, mutable reference <b>to</b> the spread
    // maker for given side, and traversal direction
    <b>let</b> (side, tree_ref_mut, spread_maker_ref_mut, traversal_direction) =
        <b>if</b> (*direction_ref == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (
        <a href="market.md#0xc0deb00c_market_ASK">ASK</a>, // If a buy, fills against asks
        &<b>mut</b> order_book_ref_mut.asks, // Fill against asks tree
        &<b>mut</b> order_book_ref_mut.min_ask, // Asks spread maker
        <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a> // Successor iteration
    ) <b>else</b> ( // If a sell
        <a href="market.md#0xc0deb00c_market_BID">BID</a>, // Fills against bids, <b>requires</b> base coins
        &<b>mut</b> order_book_ref_mut.bids, // Fill against bids tree
        &<b>mut</b> order_book_ref_mut.max_bid, // Bids spread maker
        <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a> // Predecessor iteration
    );
    // Get number of orders in corresponding tree
    <b>let</b> n_orders = <a href="critbit.md#0xc0deb00c_critbit_length">critbit::length</a>(tree_ref_mut);
    (
        *max_lots_ref,
        *max_ticks_ref,
        side,
        tree_ref_mut,
        spread_maker_ref_mut,
        n_orders,
        traversal_direction,
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop"></a>

## Function `match_loop`

Match an order against the book via loopwise tree traversal.

Inner function for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

During interated traversal, the "incoming user" matches against
a "target order" on the book at each iteration.


<a name="@Type_parameters_10"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_11"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>tree_ref_mut</code>: Mutable reference to orders tree
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>lots_until_max_ref_mut</code>: Mutable reference to counter for
number of lots that can be filled before exceeding max
allowed for incoming user
* <code>ticks_until_max_ref_mut</code>: Mutable reference to counter
for number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>limit_price_ref</code>: Immutable reference to max price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>, and min price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>n_orders_ref_mut</code>: Mutable reference to counter for number of
orders in tree
* <code>spread_maker_ref_mut</code>: Mutable reference to the spread maker
field for corresponding side
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code>, or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine


<a name="@Passing_considerations_12"></a>

### Passing considerations

* Pass-by-reference instituted for improved efficiency
* See <code><a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>()</code> for a discussion on its
return schema


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, side_ref: &bool, lot_size_ref: &u64, tick_size_ref: &u64, lots_until_max_ref_mut: &<b>mut</b> u64, ticks_until_max_ref_mut: &<b>mut</b> u64, limit_price_ref: &u64, n_orders_ref_mut: &<b>mut</b> u64, spread_maker_ref_mut: &<b>mut</b> u128, traversal_direction_ref: &bool, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    side_ref: &bool,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    lots_until_max_ref_mut: &<b>mut</b> u64,
    ticks_until_max_ref_mut: &<b>mut</b> u64,
    limit_price_ref: &u64,
    n_orders_ref_mut: &<b>mut</b> u64,
    spread_maker_ref_mut: &<b>mut</b> u128,
    traversal_direction_ref: &bool,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;
) {
    // Initialize <b>local</b> variables
    <b>let</b> (target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index, complete_target_fill, should_pop_last,
         new_spread_maker) = <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(
            tree_ref_mut, traversal_direction_ref);
    // Declare locally-scoped <b>return</b> variable for below <b>loop</b>, which
    // can not be declared without a value in the above function,
    // and which raises a warning <b>if</b> it is assigned a value within
    // the present scope. It could be declared within the <b>loop</b>
    // scope, but this would involve a redeclaration for each
    // iteration. Hence it is declared here, such that the statement
    // in which it is assigned does not locally re-bind the other
    // variables in the function <b>return</b> tuple, which would occur <b>if</b>
    // they were <b>to</b> be assigned via a `<b>let</b>` expression.
    <b>let</b> should_break;
    <b>loop</b> { // Begin loopwise matching
        // Process the order for current iteration, storing flag for
        // <b>if</b> the target order was completely filled
        <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;BaseType, QuoteType&gt;(market_id_ref, side_ref,
            lot_size_ref, tick_size_ref, lots_until_max_ref_mut,
            ticks_until_max_ref_mut, limit_price_ref, &target_order_id,
            target_order_ref_mut, &<b>mut</b> complete_target_fill,
            optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
        // Follow up on order processing, assigning variable returns
        // that cannot be reassigned via pass-by-reference
        (target_order_id, target_order_ref_mut, should_break) =
            <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(tree_ref_mut, side_ref,
            traversal_direction_ref, n_orders_ref_mut,
            &complete_target_fill, &<b>mut</b> should_pop_last, target_order_id,
            &<b>mut</b> target_parent_index, &<b>mut</b> target_child_index,
            &<b>mut</b> new_spread_maker);
        <b>if</b> (should_break) { // If should <b>break</b> out of <b>loop</b>
            // Clean up <b>as</b> needed before breaking out of <b>loop</b>
            <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(spread_maker_ref_mut, &new_spread_maker,
                &should_pop_last, tree_ref_mut, &target_order_id);
            <b>break</b> // Break out of <b>loop</b>
        }
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_break"></a>

## Function `match_loop_break`

Execute break cleanup after loopwise matching.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_13"></a>

### Parameters

* <code>spread_maker_ref_mut</code>: Mutable reference to the spread maker
field for order tree just filled against
* <code>new_spread_maker_ref</code>: Immutable reference to new spread
maker value to assign
* <code>should_pop_last_ref</code>: <code>&<b>true</b></code> if loopwise matching ends on a
complete fill against the last order on the book, which should
be popped off
* <code>tree_ref_mut</code>: Mutable reference to orders tree just matched
against
* <code>final_order_id_ref</code>: If <code>should_pop_last_ref</code> indicates
<code><b>true</b></code>, an immutable reference to the order ID of the last
order in the book, which should be popped


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(spread_maker_ref_mut: &<b>mut</b> u128, new_spread_maker_ref: &u128, should_pop_last_ref: &bool, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, final_order_id_ref: &u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(
    spread_maker_ref_mut: &<b>mut</b> u128,
    new_spread_maker_ref: &u128,
    should_pop_last_ref: &bool,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    final_order_id_ref: &u128
) {
    // Update spread maker field
    *spread_maker_ref_mut = *new_spread_maker_ref;
    // Pop and unpack last order on book <b>if</b> flagged <b>to</b> do so
    <b>if</b> (*should_pop_last_ref)
        <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: _, <a href="user.md#0xc0deb00c_user">user</a>: _, general_custodian_id: _} =
            <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, *final_order_id_ref);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_init"></a>

## Function `match_loop_init`

Initialize variables for loopwise matching.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_14"></a>

### Parameters

* <code>tree_ref_mut</code>: Mutable reference to orders tree to start
match against
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code>, or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>


<a name="@Returns_15"></a>

### Returns

* <code>u128</code>: Order ID of first target order to process
* <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code>: Mutable reference to first target order
* <code>u64</code>: Parent index loop variable for iterated traversal along
outer nodes of a <code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>u64</code>: Child index loop variable for iterated traversal along
outer nodes of a <code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>bool</code>: Flag for if target order is completely filled
* <code>bool</code>: Flag for if loopwise matching ends on a complete fill
against the last order on the book, which should be popped
* <code>u128</code>: Tracker for new spread maker value to assign


<a name="@Passing_considerations_16"></a>

### Passing considerations

* Initialized variables are passed by reference within
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>, and as such must be assigned before use
* Variables that are only assigned meaningful values after
pass-by-reference are effectively initialized to null values


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, traversal_direction_ref: &bool): (u128, &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, u64, u64, bool, bool, u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    traversal_direction_ref: &bool,
): (
    u128,
    &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    u64,
    u64,
    bool,
    bool,
    u128
) {
    // Initialize iterated traversal, storing order ID of target
    // order, mutable reference <b>to</b> target order, the parent field
    // of the target node, and child field index of target node
    <b>let</b> (target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index) = <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">critbit::traverse_init_mut</a>(
            tree_ref_mut, *traversal_direction_ref);
    // Return initialized traversal variables, and flags/tracker
    // that are reassigned later
    (target_order_id, target_order_ref_mut, target_parent_index,
     target_child_index, <b>false</b>, <b>false</b>, 0)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order"></a>

## Function `match_loop_order`

Fill order from "incoming user" against "target order" on the
book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Type_parameters_17"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_18"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>lots_until_max_ref_mut</code>: Mutable reference to counter for
number of lots that can be filled before exceeding max
allowed for incoming user
* <code>ticks_until_max_ref_mut</code>: Mutable reference to counter
for number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>limit_price_ref</code>: Immutable reference to max price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>, and min price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>target_order_id_ref</code>: Immutable reference to target order ID
* <code>target_order_ref_mut</code>: Mutable reference to target order
* <code>complete_target_fill_ref_mut</code>: Mutable reference to flag for
if target order is completely filled
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, side_ref: &bool, lot_size_ref: &u64, tick_size_ref: &u64, lots_until_max_ref_mut: &<b>mut</b> u64, ticks_until_max_ref_mut: &<b>mut</b> u64, limit_price_ref: &u64, target_order_id_ref: &u128, target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, complete_target_fill_ref_mut: &<b>mut</b> bool, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    side_ref: &bool,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    lots_until_max_ref_mut: &<b>mut</b> u64,
    ticks_until_max_ref_mut: &<b>mut</b> u64,
    limit_price_ref: &u64,
    target_order_id_ref: &u128,
    target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    complete_target_fill_ref_mut: &<b>mut</b> bool,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;
) {
    // Calculate target order price
    <b>let</b> target_order_price = <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(*target_order_id_ref);
    // If ask price is higher than limit price
    <b>if</b> ((*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a> && target_order_price &gt; *limit_price_ref) ||
        // Or <b>if</b> bid price is lower than limit price
        (*side_ref == <a href="market.md#0xc0deb00c_market_BID">BID</a> && target_order_price &lt; *limit_price_ref)) {
            // Flag that there was not a complete target fill
            *complete_target_fill_ref_mut = <b>false</b>;
            <b>return</b> // Do not attempt <b>to</b> fill
        };
    // Declare null fill size for pass-by-reference reassignment
    <b>let</b> fill_size = 0;
    // Calculate size filled and determine <b>if</b> a complete fill
    // against target order
    <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(lots_until_max_ref_mut,
        ticks_until_max_ref_mut, &target_order_price, target_order_ref_mut,
        &<b>mut</b> fill_size, complete_target_fill_ref_mut);
    <b>if</b> (fill_size == 0) { // If no lots <b>to</b> fill
        // Flag that there was not a complete target fill
        *complete_target_fill_ref_mut = <b>false</b>;
        <b>return</b> // Do not attempt <b>to</b> fill
    };
    // Calculate number of ticks filled
    <b>let</b> ticks_filled = fill_size * target_order_price;
    // Decrement counter for lots until max
    *lots_until_max_ref_mut = *lots_until_max_ref_mut - fill_size;
    // Decrement counter for ticks until max
    *ticks_until_max_ref_mut = *ticks_until_max_ref_mut - ticks_filled;
    // Calculate base and quote units <b>to</b> route
    <b>let</b> (base_to_route, quote_to_route) = (
        fill_size * *lot_size_ref, ticks_filled * *tick_size_ref);
    // Get the target order <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> target_order_market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(
        *market_id_ref, target_order_ref_mut.general_custodian_id);
    // Fill the target order <a href="user.md#0xc0deb00c_user">user</a>-side
    <a href="user.md#0xc0deb00c_user_fill_order_internal">user::fill_order_internal</a>&lt;BaseType, QuoteType&gt;(
        target_order_ref_mut.<a href="user.md#0xc0deb00c_user">user</a>, target_order_market_account_id,
        *side_ref, *target_order_id_ref, *complete_target_fill_ref_mut,
        fill_size, optional_base_coins_ref_mut,
        optional_quote_coins_ref_mut, base_to_route, quote_to_route);
    // Decrement target order size by size filled (should be popped
    // later <b>if</b> completely filled, and so this step is redundant in
    // the case of a complete fill, but adding an extra <b>if</b> statement
    // <b>to</b> check whether or not <b>to</b> decrement would add computational
    // overhead in the case of an incomplete fill)
    target_order_ref_mut.size = target_order_ref_mut.size - fill_size;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order_fill_size"></a>

## Function `match_loop_order_fill_size`

Calculate fill size and whether an order on the book is
completely filled during a match. The "incoming user" fills
against the "target order" on the book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code>.


<a name="@Parameters_19"></a>

### Parameters

* <code>lots_until_max_ref</code>: Immutable reference to counter for
number of lots that can be filled before exceeding max allowed
for incoming user
* <code>ticks_until_max_ref</code>: Immutable reference to counter for
number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>target_order_price_ref</code>: Immutable reference to target order
price
* <code>target_order_ref</code>: Immutable reference to target order
* <code>fill_size_ref_mut</code>: Mutable reference to fill size, in lots
* <code>complete_target_fill_ref_mut</code>: Mutable reference to flag
marked <code><b>true</b></code> if target order is completely filled


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(lots_until_max_ref: &u64, ticks_until_max_ref: &u64, target_order_price_ref: &u64, target_order_ref: &<a href="market.md#0xc0deb00c_market_Order">market::Order</a>, fill_size_ref_mut: &<b>mut</b> u64, complete_target_fill_ref_mut: &<b>mut</b> bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(
    lots_until_max_ref: &u64,
    ticks_until_max_ref: &u64,
    target_order_price_ref: &u64,
    target_order_ref: &<a href="market.md#0xc0deb00c_market_Order">Order</a>,
    fill_size_ref_mut: &<b>mut</b> u64,
    complete_target_fill_ref_mut: &<b>mut</b> bool
) {
    // Calculate max number of lots that could be filled without
    // exceeding the maximum number of filled ticks: number of lots
    // that incoming <a href="user.md#0xc0deb00c_user">user</a> can afford <b>to</b> buy at target price in the
    // case of a buy, <b>else</b> number of lots that <a href="user.md#0xc0deb00c_user">user</a> could sell at
    // target order price without receiving too many ticks
    <b>let</b> fill_size_tick_limited =
        *ticks_until_max_ref / *target_order_price_ref;
    // Max-limited fill size is the lesser of tick-limited fill size
    // and lot-limited fill size
    <b>let</b> fill_size_max_limited =
        <b>if</b> (fill_size_tick_limited &lt; *lots_until_max_ref)
            fill_size_tick_limited <b>else</b> *lots_until_max_ref;
    // Get fill size and <b>if</b> target order is completely filled
    <b>let</b> (fill_size, complete_target_fill) =
        // If max-limited fill size is less than target order size
        <b>if</b> (fill_size_max_limited &lt; target_order_ref.size)
            // Fill size is max-limited fill size, target order is
            // not completely filled
            (fill_size_max_limited, <b>false</b>) <b>else</b>
            // Otherwise fill size is target order size, and target
            // order is completely filled
            (target_order_ref.size, <b>true</b>);
    // Reassign <b>to</b> passed in references, since cannot reassign
    // <b>to</b> references within ternary operation result tuple above
    *fill_size_ref_mut = fill_size;
    *complete_target_fill_ref_mut = complete_target_fill;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order_follow_up"></a>

## Function `match_loop_order_follow_up`

Follow up after processing a fill against an order on the book.

Checks if traversal is still possible, computes new spread maker
value as needed, and determines if loop has hit break condition,
following up on an "incoming user" filling against a "target
order" on the book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_20"></a>

### Parameters

* <code>tree_ref_mut</code>: Mutable reference to orders tree
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>n_orders_ref_mut</code>: Mutable reference to counter for number of
orders in tree, including the target order that was just
processed
* <code>complete_target_fill_ref</code>: <code>&<b>true</b></code> if the target order was
completely filled
* <code>should_pop_last_ref_mut</code>: Reassigned to <code>&<b>true</b></code> if just
processed a complete fill against the last order on the book,
which should be popped
* <code>target_order_id</code>: Order ID of target order just processed
* <code>target_parent_index_ref_mut</code>: Mutable reference to parent
loop variable for iterated traversal along outer nodes of a
<code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>target_child_index_ref_mut</code>: Mutable reference to child loop
variable for iterated traversal along outer nodes of a
<code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>new_spread_maker_ref_mut</code>: Mutable reference to the value
that should be assigned to the spread maker field for the
side indicated by <code>side_ref</code>, if one should be set


<a name="@Returns_21"></a>

### Returns

* <code>u128</code>: Target order ID, updated from <code>target_order_id</code> if
traversal proceeds to the next order on the book
* <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code>: Mutable reference to next order on the book to
process, only reassigned when iterated traversal proceeds
* <code>bool</code>: <code><b>true</b></code> if should break out of loop after follow up


<a name="@Passing_considerations_22"></a>

### Passing considerations

* Returns local <code>target_order_id</code> and <code>should_break</code> variables
as values rather than reassigning to passed in references,
because the calling function <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> accesses
these variables elsewhere in a loop, such that passing
references to them consitutes an invalid borrow within the
loop context
* Accepts <code>target_order_id</code> as pass-by-value even though
pass-by-reference would be valid, because if it were to be
passed by reference, the underlying value would still have to
be copied into a local variable anyways in order to return
by value as described above


<a name="@Target_order_reference_rationale_23"></a>

### Target order reference rationale


In the case where there are still orders left on the book and
the target order is completely filled, the calling function
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> requires a mutable reference to the next target
order to fill against, which is operated on during the next
loopwise iteration. Ideally, <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> would pass in a
mutable reference to an <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>, which would be reassigned to
the next target order to fill against, only in the case where
there are still orders on the book and the order just processed
in <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> was completely filled.

But this would be invalid, because a reassignment to a mutable
reference requires that the underlying value have the <code>drop</code>
capability, which <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code> does not.  Hence a mutable reference
to the next target order must be optionally returned in the case
where traversal proceeds, and ideally this would entail
returning an <code><a href="_Option">option::Option</a>&lt;&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>. But mutable
references can not be stored in structs, at least as of the time
of this writing, including structs that have the <code>drop</code> ability,
which an <code><a href="_Option">option::Option</a>&lt;&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code> would have, since mutable
references have the <code>drop</code> ability.

Thus a <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code> must be returned in all cases, even though
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> only meaningfully operates on this return in the
case where traversal proceeds to the next target order on the
book. Hence for the base case where traversal halts, a mutable
reference to the target order just processed in
<code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> is returned, even though there are no
future iterations where it is operated on.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, side_ref: &bool, traversal_direction_ref: &bool, n_orders_ref_mut: &<b>mut</b> u64, complete_target_fill_ref: &bool, should_pop_last_ref_mut: &<b>mut</b> bool, target_order_id: u128, target_parent_index_ref_mut: &<b>mut</b> u64, target_child_index_ref_mut: &<b>mut</b> u64, new_spread_maker_ref_mut: &<b>mut</b> u128): (u128, &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    side_ref: &bool,
    traversal_direction_ref: &bool,
    n_orders_ref_mut: &<b>mut</b> u64,
    complete_target_fill_ref: &bool,
    should_pop_last_ref_mut: &<b>mut</b> bool,
    target_order_id: u128,
    target_parent_index_ref_mut: &<b>mut</b> u64,
    target_child_index_ref_mut: &<b>mut</b> u64,
    new_spread_maker_ref_mut: &<b>mut</b> u128
):  (
    u128,
    &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    bool
) {
    // Assume traversal halts, so <b>return</b> mutable reference <b>to</b>
    // target order just processed, which will not be operated on
    <b>let</b> target_order_ref_mut =
        <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">critbit::borrow_mut</a>(tree_ref_mut, target_order_id);
    // Assume should set new spread maker field <b>to</b> target order ID
    *new_spread_maker_ref_mut = target_order_id;
    // Assume should not pop last order off book after followup
    *should_pop_last_ref_mut = <b>false</b>;
    // Assume should <b>break</b> out of <b>loop</b> after follow up
    <b>let</b> should_break = <b>true</b>;
    <b>if</b> (*n_orders_ref_mut == 1) { // If no orders left on book
        // If target order completely filled
        <b>if</b> (*complete_target_fill_ref) {
            // Market that should pop last order on book
            *should_pop_last_ref_mut = <b>true</b>;
            // Set new spread maker value <b>to</b> default value for side
            *new_spread_maker_ref_mut = <b>if</b> (*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
                <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b> <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>;
        }; // If not complete target order fill, <b>use</b> defaults
    } <b>else</b> { // If orders still left on book
        // If target order completely filled
        <b>if</b> (*complete_target_fill_ref) {
            // Declare locally-scoped temporary <b>return</b> variables
            <b>let</b> (target_parent_index, target_child_index, empty_order);
            // Traverse pop <b>to</b> next order on book, reassigning <b>to</b>
            // temporary variables and those from calling scope
            (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index, empty_order) = <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">critbit::traverse_pop_mut</a>(
                tree_ref_mut, target_order_id,
                *target_parent_index_ref_mut, *target_child_index_ref_mut,
                *n_orders_ref_mut, *traversal_direction_ref);
            // Reassign temporary traverse returns <b>to</b> variables from
            // calling scope, since reassignment is not permitted
            // inside of the above function <b>return</b> tuple
            *target_parent_index_ref_mut = target_parent_index;
            *target_child_index_ref_mut  = target_child_index;
            // Unpack popped empty order and discard
            <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: _, <a href="user.md#0xc0deb00c_user">user</a>: _, general_custodian_id: _} = empty_order;
            should_break = <b>false</b>; // Flag not <b>to</b> <b>break</b> out of <b>loop</b>
            // Decrement count of orders on book for given side
            *n_orders_ref_mut = *n_orders_ref_mut - 1;
        }; // If not complete target order fill, <b>use</b> defaults
    };
    (target_order_id, target_order_ref_mut, should_break)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_range_check_inputs"></a>

## Function `match_range_check_inputs`

Range check inputs for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Abort_conditions_24"></a>

### Abort conditions

* If maximum lots to match is indicated as 0
* If maximum ticks to match is indicated as 0
* If minimum lots to match is indicated as greater than max
* If minimum ticks to match is indicated as greater than max
* If limit price is 0
* If filling max lots overflows base asset units
* If filling max ticks overflows quote asset units


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_range_check_inputs">match_range_check_inputs</a>(lot_size_ref: &u64, tick_size_ref: &u64, min_lots_ref: &u64, max_lots_ref: &u64, min_ticks_ref: &u64, max_ticks_ref: &u64, limit_price_ref: &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_range_check_inputs">match_range_check_inputs</a>(
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    min_lots_ref: &u64,
    max_lots_ref: &u64,
    min_ticks_ref: &u64,
    max_ticks_ref: &u64,
    limit_price_ref: &u64
) {
    // Assert maximum lot allowance is not 0
    <b>assert</b>!(*max_lots_ref != 0, <a href="market.md#0xc0deb00c_market_E_MAX_LOTS_0">E_MAX_LOTS_0</a>);
    // Assert maximum tick allowance is not 0
    <b>assert</b>!(*max_ticks_ref != 0, <a href="market.md#0xc0deb00c_market_E_MAX_TICKS_0">E_MAX_TICKS_0</a>);
    // Assert minimum lot allowance does not exceed maximum
    <b>assert</b>!(!(*min_lots_ref &gt; *max_lots_ref), <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_EXCEEDS_MAX">E_MIN_LOTS_EXCEEDS_MAX</a>);
    // Assert minimum tick allowance does not exceed maximum
    <b>assert</b>!(!(*min_ticks_ref &gt; *max_ticks_ref), <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_EXCEEDS_MAX">E_MIN_TICKS_EXCEEDS_MAX</a>);
    // Assert limit price is not 0
    <b>assert</b>!(*limit_price_ref != 0, <a href="market.md#0xc0deb00c_market_E_LIMIT_PRICE_0">E_LIMIT_PRICE_0</a>);
    // Calculate max base units filled
    <b>let</b> max_fill_base = (*max_lots_ref <b>as</b> u128) * (*lot_size_ref <b>as</b> u128);
    // Assert max base fill does not overflow a u64
    <b>assert</b>!(!(max_fill_base &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_BASE_MAX_OVERFLOW">E_BASE_MAX_OVERFLOW</a>);
    <b>let</b> max_fill_quote = // Calculate max quote units filled
        (*max_ticks_ref <b>as</b> u128) * (*tick_size_ref <b>as</b> u128);
    // Assert max quote fill does not overflow a u64
    <b>assert</b>!(!(max_fill_quote &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_QUOTE_MAX_OVERFLOW">E_QUOTE_MAX_OVERFLOW</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_verify_fills"></a>

## Function `match_verify_fills`

Calculate number of lots and ticks filled, verify minimum
thresholds met.

Inner function for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

Called by matching engine after <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> executes, which
will not match in excess of values indicated by <code>max_lots_ref</code>
and <code>max_ticks_ref</code>, but which may terminate before filling at
least the corresponding minimum value thresholds.


<a name="@Parameters_25"></a>

### Parameters

* <code>min_lots_ref</code>: Immutable reference to minimum number of lots
to have been filled by matching engine
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to have been filled by matching engine
* <code>min_ticks_ref</code>: Immutable reference to minimum number of
ticks to have been filled by matching engine
* <code>max_ticks_ref</code>: Immutable reference to maximum number of
ticks to have been filled by matching engine
* <code>lots_until_max_ref</code>: Immutable reference to counter for
number of lots that matching engine could have filled before
exceeding maximum threshold
* <code>ticks_until_max_ref</code>: Immutable reference to counter for
number of ticks that matching engine could have filled before
exceeding maximum threshold
* <code>lots_until_max_final_ref_mut</code>: Mutable reference to counter
for number of lots that can be filled before exceeding maximum
threshold, after matching engine executes
* <code>ticks_until_max_final_ref</code>: Mutable reference to counter for
number of ticks that can be filled before exceeding maximum
threshold, after matching engine executes


<a name="@Abort_conditions_26"></a>

### Abort conditions

* If minimum lot fill threshold not met
* If minimum tick fill threshold not met


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(min_lots_ref: &u64, max_lots_ref: &u64, min_ticks_ref: &u64, max_ticks_ref: &u64, lots_until_max_ref: &u64, ticks_until_max_ref: &u64, lots_until_max_final_ref_mut: &<b>mut</b> u64, ticks_until_max_final_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(
    min_lots_ref: &u64,
    max_lots_ref: &u64,
    min_ticks_ref: &u64,
    max_ticks_ref: &u64,
    lots_until_max_ref: &u64,
    ticks_until_max_ref: &u64,
    lots_until_max_final_ref_mut: &<b>mut</b> u64,
    ticks_until_max_final_ref_mut: &<b>mut</b> u64
) {
    // Calculate number of lots filled
    <b>let</b> lots_filled = *max_lots_ref - *lots_until_max_ref;
    // Calculate number of ticks filled
    <b>let</b> ticks_filled = *max_ticks_ref - *ticks_until_max_ref;
    // Assert minimum lots fill requirement met
    <b>assert</b>!(!(lots_filled &lt; *min_lots_ref), <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED">E_MIN_LOTS_NOT_FILLED</a>);
    // Assert minimum ticks fill requirement met
    <b>assert</b>!(!(ticks_filled &lt; *min_ticks_ref), <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED">E_MIN_TICKS_NOT_FILLED</a>);
    // Store final count for lots until max threshold
    *lots_until_max_final_ref_mut = *lots_until_max_ref;
    // Store final count for ticks until max threshold
    *ticks_until_max_final_ref_mut = *ticks_until_max_ref;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order"></a>

## Function `place_limit_order`

Place limit order against book and optionally register in user's
market account.

If <code>post_or_abort</code> is false and the order crosses the spread, it
will match as a taker order against all orders it crosses, then
the remaining <code>size</code> will be placed as a maker order.


<a name="@Parameters_27"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user submitting order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>market_id</code>: Market ID
* <code>general_custodian_id</code>: General custodian ID for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>size</code>: Number of lots the order is for
* <code>price</code>: Order price, in ticks per lot
* <code>post_or_abort</code>:  If <code><b>true</b></code>, abort for orders that cross the
spread, otherwise fill across the spread when applicable


<a name="@Abort_conditions_28"></a>

### Abort conditions

* If <code>post_or_abort</code> is <code><b>true</b></code> and order crosses the spread


<a name="@Assumes_29"></a>

### Assumes

* That user-side order registration will abort for invalid
arguments
* That matching against the book will abort for invalid
arguments
* That if <code>size</code> is as 0 and price does not cross spread, will
simply return silently


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, general_custodian_id: u64, side: bool, size: u64, price: u64, post_or_abort: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    side: bool,
    size: u64,
    price: u64,
    post_or_abort: bool
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(host, market_id);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Determine <b>if</b> spread crossed
    <b>let</b> crossed_spread = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
        (price &lt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref_mut.max_bid)) <b>else</b>
        (price &gt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref_mut.min_ask));
    // Assert spread uncrossed <b>if</b> a <b>post</b>-or-<b>abort</b> order
    <b>assert</b>!(!(post_or_abort && crossed_spread),
        <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD">E_POST_OR_ABORT_CROSSED_SPREAD</a>);
    <b>if</b> (crossed_spread) {
        <b>abort</b> 0 // Temporary
        // Match against book until price threshold hit
        // Store <b>return</b> value <b>as</b> new size
    };
    <b>if</b> (size &gt; 0) { // If still size left <b>to</b> fill
        // Get new order ID based on book counter/side
        <b>let</b> <a href="order_id.md#0xc0deb00c_order_id">order_id</a> = <a href="order_id.md#0xc0deb00c_order_id_order_id">order_id::order_id</a>(
            price, <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(order_book_ref_mut), side);
        // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID for given <a href="user.md#0xc0deb00c_user">user</a>
        <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(market_id,
            general_custodian_id);
        // Add order <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
        <a href="user.md#0xc0deb00c_user_register_order_internal">user::register_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side,
            <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, size, price, order_book_ref_mut.lot_size,
            order_book_ref_mut.tick_size);
        // Get mutable reference <b>to</b> orders tree for given side,
        // determine <b>if</b> order is new spread maker, and get mutable
        // reference <b>to</b> spread maker for given side
        <b>let</b> (tree_ref_mut, new_spread_maker, spread_maker_ref_mut) =
            <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) (
                &<b>mut</b> order_book_ref_mut.asks,
                (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &lt; order_book_ref_mut.min_ask),
                &<b>mut</b> order_book_ref_mut.min_ask
            ) <b>else</b> ( // If order is a bid
                &<b>mut</b> order_book_ref_mut.bids,
                (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &gt; order_book_ref_mut.max_bid),
                &<b>mut</b> order_book_ref_mut.max_bid
            );
        // If a new spread maker, mark <b>as</b> such on book
        <b>if</b> (new_spread_maker) *spread_maker_ref_mut = <a href="order_id.md#0xc0deb00c_order_id">order_id</a>;
        // Insert order <b>to</b> corresponding tree
        <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>,
            <a href="market.md#0xc0deb00c_market_Order">Order</a>{size, <a href="user.md#0xc0deb00c_user">user</a>, general_custodian_id});
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market"></a>

## Function `register_market`

Register new market under signing host.


<a name="@Type_parameters_30"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_31"></a>

### Parameters

* <code>host</code>: Account where order book should be stored
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per tick
* <code>generic_asset_transfer_custodian_id</code>: ID of custodian
capability required to approve deposits and withdrawals of
non-coin assets


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64, generic_asset_transfer_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
    generic_asset_transfer_custodian_id: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Register the <a href="market.md#0xc0deb00c_market">market</a> in the <b>global</b> <a href="registry.md#0xc0deb00c_registry">registry</a>, storing <a href="market.md#0xc0deb00c_market">market</a> ID
    <b>let</b> market_id =
        <a href="registry.md#0xc0deb00c_registry_register_market_internal">registry::register_market_internal</a>&lt;BaseType, QuoteType&gt;(
            address_of(host), lot_size, tick_size,
            generic_asset_transfer_custodian_id);
    // Register an under book under host's <a href="">account</a>
    <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;BaseType, QuoteType&gt;(
        host, market_id, lot_size, tick_size);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_order_book"></a>

## Function `register_order_book`

Register host with an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>, initializing their
<code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code> if they do not already have one


<a name="@Type_parameters_32"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_33"></a>

### Parameters

* <code>host</code>: Account where order book should be stored
* <code>market_id</code>: Market ID
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per tick


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, market_id: u64, lot_size: u64, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    market_id: u64,
    lot_size: u64,
    tick_size: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> host_address = address_of(host); // Get host <b>address</b>
    // If host does not have an order books map
    <b>if</b> (!<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host_address))
        // Move one <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host, <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()});
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host_address).map;
    // Assert order book does not already exist under host <a href="">account</a>
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(order_books_map_ref_mut, market_id),
        <a href="market.md#0xc0deb00c_market_E_ORDER_BOOK_EXISTS">E_ORDER_BOOK_EXISTS</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(order_books_map_ref_mut, market_id, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>{
        base_type_info: <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(),
        quote_type_info: <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(),
        lot_size,
        tick_size,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        min_ask: <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>,
        max_bid: <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>,
        counter: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_market_verify_order_book_exists"></a>

## Function `verify_order_book_exists`

Verify <code>host</code> has an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> with <code>market_id</code>


<a name="@Abort_conditions_34"></a>

### Abort conditions

* If user does not have an <code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code>
* If user does not have an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> for given <code>market_id</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(host: <b>address</b>, market_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(
    host: <b>address</b>,
    market_id: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Assert host <b>has</b> an order books map
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOKS">E_NO_ORDER_BOOKS</a>);
    // Borrow immutable reference <b>to</b> order books map
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> order_books_map_ref = &<b>borrow_global</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host).map;
    // Assert host <b>has</b> an entry in map for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(order_books_map_ref, market_id),
        <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
}
</code></pre>



</details>
