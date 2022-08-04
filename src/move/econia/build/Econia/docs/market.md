
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market-side functionality. See test-only constants for end-to-end
market order fill testing mock order sizes/prices: in the case of
both bids and asks, <code>USER_1</code> has the order closest to the spread,
while <code>USER_3</code> has the order furthest from the spread. <code>USER_0</code> then
places a market order against the book.


-  [Resource `EconiaCapabilityStore`](#0xc0deb00c_market_EconiaCapabilityStore)
-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Resource `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Struct `SimpleOrder`](#0xc0deb00c_market_SimpleOrder)
-  [Struct `PriceLevel`](#0xc0deb00c_market_PriceLevel)
-  [Constants](#@Constants_0)
-  [Function `cancel_limit_order_custodian`](#0xc0deb00c_market_cancel_limit_order_custodian)
-  [Function `fill_market_order_custodian`](#0xc0deb00c_market_fill_market_order_custodian)
-  [Function `init_econia_capability_store`](#0xc0deb00c_market_init_econia_capability_store)
-  [Function `place_limit_order_custodian`](#0xc0deb00c_market_place_limit_order_custodian)
-  [Function `swap`](#0xc0deb00c_market_swap)
    -  [If a swap buy:](#@If_a_swap_buy:_1)
    -  [If a swap sell:](#@If_a_swap_sell:_2)
-  [Function `cancel_limit_order_user`](#0xc0deb00c_market_cancel_limit_order_user)
-  [Function `fill_market_order_user`](#0xc0deb00c_market_fill_market_order_user)
-  [Function `register_market`](#0xc0deb00c_market_register_market)
-  [Function `place_limit_order_user`](#0xc0deb00c_market_place_limit_order_user)
-  [Function `cancel_limit_order`](#0xc0deb00c_market_cancel_limit_order)
    -  [Parameters](#@Parameters_3)
    -  [Abort conditions](#@Abort_conditions_4)
-  [Function `fill_market_order`](#0xc0deb00c_market_fill_market_order)
    -  [Parameters](#@Parameters_5)
    -  [Assumes](#@Assumes_6)
-  [Function `fill_market_order_break_cleanup`](#0xc0deb00c_market_fill_market_order_break_cleanup)
    -  [Parameters](#@Parameters_7)
-  [Function `fill_market_order_check_base_parcels_to_fill`](#0xc0deb00c_market_fill_market_order_check_base_parcels_to_fill)
    -  [Parameters](#@Parameters_8)
-  [Function `fill_market_order_from_market_account`](#0xc0deb00c_market_fill_market_order_from_market_account)
    -  [Parameters](#@Parameters_9)
-  [Function `fill_market_order_init`](#0xc0deb00c_market_fill_market_order_init)
    -  [Parameters](#@Parameters_10)
    -  [Returns](#@Returns_11)
-  [Function `fill_market_order_loop_order_follow_up`](#0xc0deb00c_market_fill_market_order_loop_order_follow_up)
    -  [Parameters](#@Parameters_12)
    -  [Returns](#@Returns_13)
-  [Function `fill_market_order_process_loop_order`](#0xc0deb00c_market_fill_market_order_process_loop_order)
    -  [Parameters](#@Parameters_14)
    -  [Returns](#@Returns_15)
-  [Function `fill_market_order_traverse_loop`](#0xc0deb00c_market_fill_market_order_traverse_loop)
    -  [Parameters](#@Parameters_16)
-  [Function `get_serial_id`](#0xc0deb00c_market_get_serial_id)
-  [Function `get_econia_capability`](#0xc0deb00c_market_get_econia_capability)
-  [Function `init_book`](#0xc0deb00c_market_init_book)
-  [Function `place_limit_order`](#0xc0deb00c_market_place_limit_order)
    -  [Parameters](#@Parameters_17)
    -  [Abort conditions](#@Abort_conditions_18)
    -  [Assumes](#@Assumes_19)
-  [Function `book_orders_sdk`](#0xc0deb00c_market_book_orders_sdk)
    -  [Returns](#@Returns_20)
-  [Function `book_price_levels_sdk`](#0xc0deb00c_market_book_price_levels_sdk)
    -  [Returns](#@Returns_21)
-  [Function `get_orders_sdk`](#0xc0deb00c_market_get_orders_sdk)
-  [Function `get_price_levels_sdk`](#0xc0deb00c_market_get_price_levels_sdk)
-  [Function `simulate_swap_sdk`](#0xc0deb00c_market_simulate_swap_sdk)
    -  [Parameters](#@Parameters_22)
    -  [Returns](#@Returns_23)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="capability.md#0xc0deb00c_capability">0xc0deb00c::capability</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="order_id.md#0xc0deb00c_order_id">0xc0deb00c::order_id</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="0xc0deb00c_market_EconiaCapabilityStore"></a>

## Resource `EconiaCapabilityStore`

Stores an <code>EconiaCapability</code> for cross-module authorization


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>econia_capability: <a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_market_Order"></a>

## Struct `Order`

An order on the order book


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_parcels: u64</code>
</dt>
<dd>
 Number of base parcels to be filled
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of corresponding user
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 For given user, custodian ID of corresponding market account
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBook"></a>

## Resource `OrderBook`

An order book for the given market


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>scale_factor: u64</code>
</dt>
<dd>
 Number of base units in a base parcel
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
 Serial counter for number of limit orders placed on book
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_SimpleOrder"></a>

## Struct `SimpleOrder`

Simple representation of an order, for SDK generation


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Price encoded in corresponding <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>'s order ID
</dd>
<dt>
<code>base_parcels: u64</code>
</dt>
<dd>
 Number of base parcels the order is for
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_PriceLevel"></a>

## Struct `PriceLevel`

Represents a price level formed by one or more <code>OrderSimple</code>s


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Price of all orders in the price level
</dd>
<dt>
<code>base_parcels: u64</code>
</dt>
<dd>
 Net base parcels across all <code>OrderSimple</code>s in the level
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_market_E_NOT_ECONIA"></a>

When caller is not Econia


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_market_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_market_LEFT"></a>

Left direction, denoting predecessor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_RIGHT"></a>

Right direction, denoting successor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_BUY"></a>

Market buy flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_E_BOOK_EXISTS"></a>

When an order book already exists at given address


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_BOOK_EXISTS">E_BOOK_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_E_CROSSED_SPREAD"></a>

When a limit order crosses the spread


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_CROSSED_SPREAD">E_CROSSED_SPREAD</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_market_E_ECONIA_CAPABILITY_STORE_EXISTS"></a>

When <code><a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a></code> already exists under Econia account


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_ECONIA_CAPABILITY_STORE_EXISTS">E_ECONIA_CAPABILITY_STORE_EXISTS</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_CUSTODIAN"></a>

When invalid custodian attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_USER"></a>

When invalid user attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ECONIA_CAPABILITY_STORE"></a>

When no <code><a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a></code> exists under Econia account


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ECONIA_CAPABILITY_STORE">E_NO_ECONIA_CAPABILITY_STORE</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER_BOOK"></a>

When no <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> exists under given address


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_market_E_NO_SUCH_ORDER"></a>

When corresponding order not found on book for given side


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_SUCH_ORDER">E_NO_SUCH_ORDER</a>: u64 = 5;
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

Market sell flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_cancel_limit_order_custodian"></a>

## Function `cancel_limit_order_custodian`

Cancel a limit order on the book and in a user's market account.
Invoked by a custodian, who passes an immutable reference to
their <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code>. See wrapped call
<code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Get custodian ID encoded in <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability_ref);
    // Cancel limit order <b>with</b> corresponding custodian id
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>, host, custodian_id, side, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_custodian"></a>

## Function `fill_market_order_custodian`

Fill a market order on behalf of a user. Invoked by a custodian,
who passes an immutable reference to their
<code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code>. See wrapped call
<code><a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_custodian">fill_market_order_custodian</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, style: bool, max_base_parcels: u64, max_quote_units: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_custodian">fill_market_order_custodian</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    style: bool,
    max_base_parcels: u64,
    max_quote_units: u64,
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Get custodian ID encoded in <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability_ref);
    // Fill the <a href="market.md#0xc0deb00c_market">market</a> order, using custodian ID
    <a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>&lt;B, Q, E&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, host, custodian_id, style, max_base_parcels,
        max_quote_units);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_init_econia_capability_store"></a>

## Function `init_econia_capability_store`

Initializes an <code><a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a></code>, aborting if one already
exists under the Econia account or if caller is not Econia


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_init_econia_capability_store">init_econia_capability_store</a>(account: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_init_econia_capability_store">init_econia_capability_store</a>(
    account: &<a href="">signer</a>
) {
    // Assert caller is Econia account
    <b>assert</b>!(address_of(account) == @econia, <a href="market.md#0xc0deb00c_market_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Assert <a href="capability.md#0xc0deb00c_capability">capability</a> store not already registered
    <b>assert</b>!(!<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>&gt;(@econia),
        <a href="market.md#0xc0deb00c_market_E_ECONIA_CAPABILITY_STORE_EXISTS">E_ECONIA_CAPABILITY_STORE_EXISTS</a>);
    // Get new <a href="capability.md#0xc0deb00c_capability">capability</a> instance (aborts <b>if</b> caller is not Econia)
    <b>let</b> econia_capability = <a href="capability.md#0xc0deb00c_capability_get_econia_capability">capability::get_econia_capability</a>(account);
    <b>move_to</b>&lt;<a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>&gt;(account, <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>{
        econia_capability}); // Move <b>to</b> account <a href="capability.md#0xc0deb00c_capability">capability</a> store
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_custodian"></a>

## Function `place_limit_order_custodian`

Place a limit order on the book and in a user's market account.
Invoked by a custodian, who passes an immutable reference to
their <code><a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a></code>. See wrapped call
<code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, side: bool, base_parcels: u64, price: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    side: bool,
    base_parcels: u64,
    price: u64,
    custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Get custodian ID encoded in <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(custodian_capability_ref);
    // Place limit order <b>with</b> corresponding custodian id
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;B, Q, E&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, host, custodian_id, side, base_parcels, price);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_swap"></a>

## Function `swap`

For given market and <code>host</code>, execute specified <code>style</code> of swap,
either <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.


<a name="@If_a_swap_buy:_1"></a>

### If a swap buy:

* Quote coins at <code>quote_coins_ref_mut</code> are traded against the
order book until either there are no more trades on the book
or max possible quote coins have been spent on base coins
* Purchased base coins are deposited to <code>base_coin_ref_mut</code>
* <code>base_coins_ref_mut</code> does not need to have coins before swap,
but <code>quote_coins_ref_mut</code> does (amount of quote coins to
spend)


<a name="@If_a_swap_sell:_2"></a>

### If a swap sell:

* Base coins at <code>base_coins_ref_mut</code> are traded against the
order book until either there are no more trades on the book
or max possible base coins have been sold in exchange for
quote coins
* Received quote coins are deposited to <code>quote_coins_ref_mut</code>
* <code>quote_coins_ref_mut</code> does not need to have coins before swap,
but <code>base_coins_ref_mut</code> does (amount of base coins to sell)


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;B, Q, E&gt;(style: bool, host: <b>address</b>, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;B, Q, E&gt;(
    style: bool,
    host: <b>address</b>,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Assert host <b>has</b> an order book
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut = <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host);
    // Get scale factor for book
    <b>let</b> scale_factor = order_book_ref_mut.scale_factor;
    // Get an Econia <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> econia_capability = <a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>();
    // Compute max number of base <a href="">coin</a> parcels/quote <a href="">coin</a> units <b>to</b>
    // fill, based on side
    <b>let</b> (max_base_parcels, max_quote_units) = <b>if</b> (style == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // If <a href="market.md#0xc0deb00c_market">market</a> buy, limiting factor is quote <a href="coins.md#0xc0deb00c_coins">coins</a>, so set
        // max base parcels <b>to</b> biggest value that can fit in u64
        (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a>, <a href="_value">coin::value</a>(quote_coins_ref_mut)) <b>else</b>
        // If a <a href="market.md#0xc0deb00c_market">market</a> sell, max base parcels that can be filled is
        // number of base <a href="coins.md#0xc0deb00c_coins">coins</a> divided by scale factor (truncating
        // division) and quote <a href="">coin</a> argument <b>has</b> no impact on
        // matching engine
        (<a href="_value">coin::value</a>(base_coins_ref_mut) / scale_factor, 0);
    // Fill <a href="market.md#0xc0deb00c_market">market</a> order against the book
    <a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(order_book_ref_mut, scale_factor, style,
        max_base_parcels, max_quote_units, base_coins_ref_mut,
        quote_coins_ref_mut, &econia_capability);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order_user"></a>

## Function `cancel_limit_order_user`

Cancel a limit order on the book and in a user's market account.
Invoked by a signing user. See wrapped call
<code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Cancel limit order, <b>with</b> no custodian flag
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>&lt;B, Q, E&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), host, <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>, side, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_user"></a>

## Function `fill_market_order_user`

Fill a market order. Invoked by a signing user. See wrapped
call <code><a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_user">fill_market_order_user</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, style: bool, max_base_parcels: u64, max_quote_units: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_user">fill_market_order_user</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    style: bool,
    max_base_parcels: u64,
    max_quote_units: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Fill the <a href="market.md#0xc0deb00c_market">market</a> order, <b>with</b> no custodian flag
    <a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>&lt;B, Q, E&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), host, <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>, style, max_base_parcels,
        max_quote_units);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market"></a>

## Function `register_market`

Register a market for the given base type, quote type,
scale exponent type, and move an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> to <code>host</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;B, Q, E&gt;(host: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;B, Q, E&gt;(
    host: &<a href="">signer</a>,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a> {
    // Add an entry <b>to</b> the <a href="market.md#0xc0deb00c_market">market</a> <a href="registry.md#0xc0deb00c_registry">registry</a> <a href="">table</a>
    <a href="registry.md#0xc0deb00c_registry_register_market_internal">registry::register_market_internal</a>&lt;B, Q, E&gt;(address_of(host),
        &<a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>());
    // Initialize an order book under host account
    <a href="market.md#0xc0deb00c_market_init_book">init_book</a>&lt;B, Q, E&gt;(host, <a href="registry.md#0xc0deb00c_registry_scale_factor">registry::scale_factor</a>&lt;E&gt;());
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_user"></a>

## Function `place_limit_order_user`

Place a limit order on the book and in a user's market account.
Invoked by a signing user. See wrapped call
<code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, side: bool, base_parcels: u64, price: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    side: bool,
    base_parcels: u64,
    price: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Place limit order, <b>with</b> no custodian flag
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;B, Q, E&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>), host, <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>, side, base_parcels, price);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order"></a>

## Function `cancel_limit_order`

Cancel limit order on book, remove from user's market account.


<a name="@Parameters_3"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>custodian_id</code>: Serial ID of delegated custodian for given
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>: Order ID for given order


<a name="@Abort_conditions_4"></a>

### Abort conditions

* If no such <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> under <code>host</code> account
* If the specified <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code> is not on given <code>side</code> for
corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> is not the user who placed the order with the
corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>
* If <code>custodian_id</code> is not the same as that indicated on order
with the corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Assert host <b>has</b> an order book
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut = <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host);
    // Get mutable reference <b>to</b> orders tree for corresponding side
    <b>let</b> tree_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks <b>else</b>
        &<b>mut</b> order_book_ref_mut.bids;
    // Assert order is on book
    <b>assert</b>!(<a href="critbit.md#0xc0deb00c_critbit_has_key">critbit::has_key</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>), <a href="market.md#0xc0deb00c_market_E_NO_SUCH_ORDER">E_NO_SUCH_ORDER</a>);
    <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{ // Pop and unpack order from book,
        base_parcels: _, // Drop base parcel count
        <a href="user.md#0xc0deb00c_user">user</a>: order_user, // Save indicated <a href="user.md#0xc0deb00c_user">user</a> for checking later
        custodian_id: order_custodian_id // Save indicated custodian
    } = <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> attempting <b>to</b> cancel is <a href="user.md#0xc0deb00c_user">user</a> on order
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user">user</a> == order_user, <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>);
    // Assert custodian attempting <b>to</b> cancel is custodian on order
    <b>assert</b>!(custodian_id == order_custodian_id, <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
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
    // Remove order from corresponding <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> account
    <a href="user.md#0xc0deb00c_user_remove_order_internal">user::remove_order_internal</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>, custodian_id, side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, &<a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>());
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order"></a>

## Function `fill_market_order`

For an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> accessed by <code>order_book_ref_mut</code>, fill a
market order for given <code>style</code> and <code>max_base_parcels</code>,
optionally accounting for <code>max_quote_units</code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>.

Prepares a crit-bit tree for iterated traversal, then loops over
nodes until the order is filled or another break condition is
met. During iterated traversal, the "incoming user" (who places
the market order or who has the order placed on their behalf by
a custodian) has their order filled against the "target user"
who has a "target position" on the order book.


<a name="@Parameters_5"></a>

### Parameters

* <code>order_book_ref_mut</code>: Mutable reference to order book to fill
against
* <code>scale_factor</code>: Scale factor for corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>max_base_parcels</code>: The maximum number of base parcels to fill
* <code>max_quote_units</code>: The maximum number of quote units to
exchange during a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, which may become a limiting factor
if the incoming user cannot afford to buy <code>max_base_parcels</code>
at market prices.
* <code>base_coins_ref_mut</code>: Mutable reference to incoming user's
base coins, essentially a container to route to/from
* <code>quote_coins_ref_mut</code>: Mutable reference to incoming user's
quote coins, essentially a container to route to/from
* <code>econia_capability_ref</code>: Immutable reference to an
<code>EconiaCapability</code>


<a name="@Assumes_6"></a>

### Assumes

* Caller has provided sufficient collateral in <code>Coin</code> at
<code>quote_coins_ref_mut</code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, or to
<code>base_coins_ref_mut</code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* Caller has derived <code>scale_factor</code> from <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> accessed by
<code>order_book_ref_mut</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;, scale_factor: u64, style: bool, max_base_parcels: u64, max_quote_units: u64, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;, econia_capability_ref: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;,
    scale_factor: u64,
    style: bool,
    max_base_parcels: u64,
    max_quote_units: u64,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    econia_capability_ref: &EconiaCapability
) {
    <b>if</b> (max_base_parcels == 0 || style == <a href="market.md#0xc0deb00c_market_BUY">BUY</a> && max_quote_units == 0)
        <b>return</b>; // Return <b>if</b> nothing <b>to</b> fill
    // Initialize <b>local</b> variables, get <a href="user.md#0xc0deb00c_user">user</a>'s base/quote collateral
    <b>let</b> (base_parcels_to_fill, side, tree_ref_mut, spread_maker_ref_mut,
         n_orders, traversal_direction) = <a href="market.md#0xc0deb00c_market_fill_market_order_init">fill_market_order_init</a>&lt;B, Q, E&gt;(
            order_book_ref_mut, style, max_base_parcels);
    <b>if</b> (n_orders != 0) { // If orders tree <b>has</b> orders <b>to</b> fill
        // Fill them in an iterated <b>loop</b> traversal
        <a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>&lt;B, Q, E&gt;(style, side, scale_factor,
            tree_ref_mut, traversal_direction, n_orders,
            spread_maker_ref_mut, base_parcels_to_fill, base_coins_ref_mut,
            quote_coins_ref_mut, econia_capability_ref);
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_break_cleanup"></a>

## Function `fill_market_order_break_cleanup`

Clean up before breaking during iterated market order filling.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>()</code>.


<a name="@Parameters_7"></a>

### Parameters

* <code>null_order</code>: A null order used for mutable reference passing
* <code>spread_maker_ref_mut</code>: Mutable reference to the spread maker
for order tree just filled against
* <code>new_spread_maker</code>: New spread maker value to assign
* <code>should_pop</code>: If ended traversal by completely filling against
the last order on the book
* <code>tree_ref_mut</code>: Mutable reference to orders tree filled
against
* <code>target_order_id</code>: If <code>should_pop</code> is <code><b>true</b></code>, the order ID of
the final order in the book that should be popped


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_break_cleanup">fill_market_order_break_cleanup</a>(null_order: <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, spread_maker_ref_mut: &<b>mut</b> u128, new_spread_maker: u128, should_pop: bool, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, target_order_id: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_break_cleanup">fill_market_order_break_cleanup</a>(
    null_order: <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    spread_maker_ref_mut: &<b>mut</b> u128,
    new_spread_maker: u128,
    should_pop: bool,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    target_order_id: u128
) {
    // Unpack null order
    <a href="market.md#0xc0deb00c_market_Order">Order</a>{custodian_id: _, <a href="user.md#0xc0deb00c_user">user</a>: _, base_parcels: _} = null_order;
    // Update spread maker field
    *spread_maker_ref_mut = new_spread_maker;
    // If pop flagged, pop and unpack final order on tree
    <b>if</b> (should_pop) <a href="market.md#0xc0deb00c_market_Order">Order</a>{base_parcels: _, <a href="user.md#0xc0deb00c_user">user</a>: _, custodian_id: _} =
        <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, target_order_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_check_base_parcels_to_fill"></a>

## Function `fill_market_order_check_base_parcels_to_fill`

If <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, check indicated amount of base parcels
to buy, updating as needed.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order_process_loop_order">fill_market_order_process_loop_order</a>()</code>. In
the case of a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, if the "target order" on the book (against
which the "incoming user's" order fills against) has a high
enough price, then the incoming user may not be able to afford
as many base parcels as otherwise indicated by
<code>base_parcels_to_fill_ref_mut</code>. If this is the case, the counter
is updated with the amount the incoming can afford.


<a name="@Parameters_8"></a>

### Parameters

* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>target_price</code>: Target order price
* <code>quote_coins_ref</code>: Immutable reference to incoming user's
quote coins
* <code>target_order_ref_mut</code>: Mutable reference to target order
* <code>base_parcels_to_fill_ref_mut</code>: Mutable reference to counter
for number of base parcels still left to fill


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_check_base_parcels_to_fill">fill_market_order_check_base_parcels_to_fill</a>&lt;Q&gt;(style: bool, target_price: u64, quote_coins_ref: &<a href="_Coin">coin::Coin</a>&lt;Q&gt;, target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, base_parcels_to_fill_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_check_base_parcels_to_fill">fill_market_order_check_base_parcels_to_fill</a>&lt;Q&gt;(
    style: bool,
    target_price: u64,
    quote_coins_ref: &<a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    base_parcels_to_fill_ref_mut: &<b>mut</b> u64
) {
    <b>if</b> (style == <a href="market.md#0xc0deb00c_market_SELL">SELL</a>) <b>return</b>; // No need <b>to</b> check when <a href="market.md#0xc0deb00c_market">market</a> sell
    // Calculate max base parcels that incoming <a href="user.md#0xc0deb00c_user">user</a> could buy at
    // target order price
    <b>let</b> base_parcels_can_afford = <a href="_value">coin::value</a>(quote_coins_ref) /
        target_price;
    // If <a href="user.md#0xc0deb00c_user">user</a> cannot afford <b>to</b> buy all base parcels in target order
    <b>if</b> (base_parcels_can_afford &lt; target_order_ref_mut.base_parcels) {
        // If number of base parcels that <a href="user.md#0xc0deb00c_user">user</a> can afford is less
        // than the number they would otherwise buy
        <b>if</b> (base_parcels_can_afford &lt; *base_parcels_to_fill_ref_mut) {
            // Set the remaining number of base parcels <b>to</b> fill <b>as</b>
            // the number they can actually afford
            *base_parcels_to_fill_ref_mut = base_parcels_can_afford;
        };
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_from_market_account"></a>

## Function `fill_market_order_from_market_account`

Verifies that <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> exists at <code>host</code> for given market,
then withdraws collateral from <code><a href="user.md#0xc0deb00c_user">user</a></code>'s market account as needed
to cover a market order. Deposits assets back to <code><a href="user.md#0xc0deb00c_user">user</a></code> after.
See wrapped function <code><a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>()</code>.


<a name="@Parameters_9"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of corresponding user
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>custodian_id</code>: Serial ID of delegated custodian for given
market account
* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>max_base_parcels</code>: The maximum number of base parcels to fill
* <code>max_quote_units</code>: The maximum number of quote units to
exchange during a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, which may become a limiting factor
if the incoming user cannot afford to buy <code>max_base_parcels</code>
at market prices.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, custodian_id: u64, style: bool, max_base_parcels: u64, max_quote_units: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_from_market_account">fill_market_order_from_market_account</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    custodian_id: u64,
    style: bool,
    max_base_parcels: u64,
    max_quote_units: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Assert host <b>has</b> an order book
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut = <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host);
    // Get scale factor for book
    <b>let</b> scale_factor = order_book_ref_mut.scale_factor;
    <b>let</b> market_account_info = // Get <a href="market.md#0xc0deb00c_market">market</a> account info for order
        <a href="user.md#0xc0deb00c_user_market_account_info">user::market_account_info</a>&lt;B, Q, E&gt;(custodian_id);
    // Get an Econia <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>let</b> econia_capability = <a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>();
    // Get base and quote <a href="">coin</a> instances for collateral routing
    <b>let</b> (base_coins, quote_coins) = <b>if</b> (style == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) ( // If a buy
        <a href="_zero">coin::zero</a>&lt;B&gt;(), // Does not require base, but needs quote
        <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">user::withdraw_collateral_internal</a>&lt;Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info,
            max_quote_units, &econia_capability),
    ) <b>else</b> ( // If a <a href="market.md#0xc0deb00c_market">market</a> sell
        // Requires base <a href="coins.md#0xc0deb00c_coins">coins</a> from <a href="user.md#0xc0deb00c_user">user</a>
        <a href="user.md#0xc0deb00c_user_withdraw_collateral_internal">user::withdraw_collateral_internal</a>&lt;B&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info,
            max_base_parcels * scale_factor, &econia_capability),
        <a href="_zero">coin::zero</a>&lt;Q&gt;(), // Does not require quote <a href="coins.md#0xc0deb00c_coins">coins</a> from <a href="user.md#0xc0deb00c_user">user</a>
    );
    // Fill <a href="market.md#0xc0deb00c_market">market</a> order against the book
    <a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(order_book_ref_mut, scale_factor, style,
        max_base_parcels, max_quote_units, &<b>mut</b> base_coins,
        &<b>mut</b> quote_coins, &econia_capability);
    // Deposit base <a href="coins.md#0xc0deb00c_coins">coins</a> <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral
    <a href="user.md#0xc0deb00c_user_deposit_collateral">user::deposit_collateral</a>&lt;B&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, base_coins);
    // Deposit quote <a href="coins.md#0xc0deb00c_coins">coins</a> <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s collateral
    <a href="user.md#0xc0deb00c_user_deposit_collateral">user::deposit_collateral</a>&lt;Q&gt;(<a href="user.md#0xc0deb00c_user">user</a>, market_account_info, quote_coins);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_init"></a>

## Function `fill_market_order_init`

Initialize local variables required for filling market orders.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>()</code>.


<a name="@Parameters_10"></a>

### Parameters

* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>max_base_parcels</code>: The maximum number of base parcels to fill


<a name="@Returns_11"></a>

### Returns

* <code>u64</code>: A counter for the number of base parcels left to fill
* <code>bool</code>: Either <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>&<b>mut</b> CritBitTree</code>: Mutable reference to orders tree to fill
against
* <code>&<b>mut</b> u128</code>: Mutable reference to spread maker field for given
<code>side</code>
* <code>u64</code>: Number of orders in corresponding tree
* <code>bool</code>: <code><a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code><a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code> (traversal direction)


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_init">fill_market_order_init</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;, style: bool, max_base_parcels: u64): (u64, bool, &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, &<b>mut</b> u128, u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_init">fill_market_order_init</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;,
    style: bool,
    max_base_parcels: u64,
): (
    u64,
    bool,
    &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    &<b>mut</b> u128,
    u64,
    bool
) {
    // Declare counter for number of base parcels left <b>to</b> fill
    <b>let</b> base_parcels_to_fill = max_base_parcels;
    // Get side that order fills against, mutable reference <b>to</b>
    // orders tree <b>to</b> fill against, mutable reference <b>to</b> the spread
    // maker for given side, and traversal direction
    <b>let</b> (side, tree_ref_mut, spread_maker_ref_mut, traversal_direction) =
        <b>if</b> (style == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (
        <a href="market.md#0xc0deb00c_market_ASK">ASK</a>, // If a <a href="market.md#0xc0deb00c_market">market</a> buy, fills against asks
        &<b>mut</b> order_book_ref_mut.asks, // Fill against asks tree
        &<b>mut</b> order_book_ref_mut.min_ask, // Asks spread maker
        <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a> // Successor iteration
    ) <b>else</b> ( // If a <a href="market.md#0xc0deb00c_market">market</a> sell
        <a href="market.md#0xc0deb00c_market_BID">BID</a>, // Fills against bids, <b>requires</b> base <a href="coins.md#0xc0deb00c_coins">coins</a>
        &<b>mut</b> order_book_ref_mut.bids, // Fill against bids tree
        &<b>mut</b> order_book_ref_mut.max_bid, // Bids spread maker
        <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a> // Predecessor iteration
    );
    // Get number of orders on book for given side
    <b>let</b> n_orders = <a href="critbit.md#0xc0deb00c_critbit_length">critbit::length</a>(tree_ref_mut);
    // Return initialized variables
    (base_parcels_to_fill, side, tree_ref_mut, spread_maker_ref_mut,
     n_orders, traversal_direction)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_loop_order_follow_up"></a>

## Function `fill_market_order_loop_order_follow_up`

Follow up after processing a fill against an order on the book.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>()</code>. Checks
if traversal is still possible, computes new spread maker values
as needed, and determines if loop has hit break condition.


<a name="@Parameters_12"></a>

### Parameters

* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, side of order on book just processed
* <code>base_parcels_to_fill</code>: Counter for base parcels left to fill
* <code>complete_fill</code>: <code><b>true</b></code> if the processed order was completely
filled
* <code>traversal_direction</code>: <code><a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code><a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>tree_ref_mut</code>: Mutable reference to orders tree
* <code>n_orders</code>: Counter for number of orders in tree, including
the order that was just processed
* <code>target_order_id</code>: The order ID of the target order just
processed
* <code>target_order_ref_mut</code>: Mutable reference to an <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>.
Reassigned only when traversal should proceed to the next
order on the book, otherwise left unmodified. Intended to
accept as an input a mutable reference to a bogus <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>.
* <code>target_parent_index</code>: Loop variable for iterated traversal
along outer nodes of a <code>CritBitTree</code>
* <code>target_child_index</code>: Loop variable for iterated traversal
along outer nodes of a <code>CritBitTree</code>


<a name="@Returns_13"></a>

### Returns

* <code>bool</code>: <code><b>true</b></code> if should break out of loop after follow up
* <code>bool</code>: <code><b>true</b></code> if just processed a complete fill against
the last order on the book and it should be popped without
attempting to traverse
* <code>u128</code>: The order ID of the new spread maker for the given
<code>side</code>, if one should be set
* <code>u64</code>: Updated count for <code>n_orders</code>
* <code>u128</code>: Target order ID, updated if traversal proceeds to the
next order on the book
* <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code>: Mutable reference to next order on the book to
process, only reassigned when iterated traversal proceeds
* <code>u64</code>: Loop variable for iterated traversal along outer nodes
of a <code>CritBitTree</code>, only updated when iterated traversal
proceeds
* <code>u64</code>: Loop variable for iterated traversal along outer nodes
of a <code>CritBitTree</code>, only updated when iterated traversal
proceeds


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_loop_order_follow_up">fill_market_order_loop_order_follow_up</a>(side: bool, base_parcels_to_fill: u64, complete_fill: bool, traversal_direction: bool, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, n_orders: u64, target_order_id: u128, target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, target_parent_index: u64, target_child_index: u64): (bool, bool, u128, u64, u128, &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_loop_order_follow_up">fill_market_order_loop_order_follow_up</a>(
    side: bool,
    base_parcels_to_fill: u64,
    complete_fill: bool,
    traversal_direction: bool,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    n_orders: u64,
    target_order_id: u128,
    target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    target_parent_index: u64,
    target_child_index: u64,
): (
    bool,
    bool,
    u128,
    u64,
    u128,
    &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    u64,
    u64
) {
    // Assume should set new spread maker field <b>to</b> target order ID,
    // that should <b>break</b> out of <b>loop</b> after follow up, and that
    // should not pop an order off the book after followup
    <b>let</b> (new_spread_maker, should_break, should_pop) =
        ( target_order_id,         <b>true</b>,      <b>false</b>);
    <b>if</b> (n_orders == 1) { // If no orders left on book
        <b>if</b> (complete_fill) { // If had a complete fill
            should_pop = <b>true</b>; // Mark that should pop final order
            // Set new spread maker value <b>to</b> default value for side
            new_spread_maker = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b>
                <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>
        }; // If incomplete fill, <b>use</b> default flags
    } <b>else</b> { // If orders still left on book
        <b>if</b> (complete_fill) { // If target order completely filled
            // Traverse pop <b>to</b> next order on book
            (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index,
             <a href="market.md#0xc0deb00c_market_Order">Order</a>{base_parcels: _, <a href="user.md#0xc0deb00c_user">user</a>: _, custodian_id: _}) =
                <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">critbit::traverse_pop_mut</a>(tree_ref_mut, target_order_id,
                    target_parent_index, target_child_index, n_orders,
                    traversal_direction);
            <b>if</b> (base_parcels_to_fill == 0) {
                // The order ID of the order that was just traversed
                // <b>to</b> becomes the new spread maker
                new_spread_maker = target_order_id;
            } <b>else</b> { // If still base parcels left <b>to</b> fill
                should_break = <b>false</b>; // Should <b>continue</b> looping
                // Decrement count of orders on book for given side
                n_orders = n_orders - 1;
            };
        }; // If incomplete fill, <b>use</b> default flags
    };
    // Return updated variables
    (should_break, should_pop, new_spread_maker, n_orders, target_order_id,
     target_order_ref_mut, target_parent_index, target_child_index)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_process_loop_order"></a>

## Function `fill_market_order_process_loop_order`

Fill a target order on the book during iterated traversal.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>()</code>, where
the "incoming user" (who the market order is for) fills against
a "target order" on the order book.


<a name="@Parameters_14"></a>

### Parameters

* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>:
the target order side
* <code>scale_factor</code>: Scale factor for given market
* <code>base_parcels_to_fill_ref_mut</code>: Mutable reference to ongoing
counter for base parcels left to fill
* <code>target_order_id</code>: Order ID of target order on book
* <code>target_order_ref_mut</code>: Mutable reference to target order
* <code>base_coins_ref_mut</code>: Mutable reference to incoming user's
base coins
* <code>quote_coins_ref_mut</code>: Mutable reference to incoming user's
quote coins
* <code>econia_capability_ref</code>: Immutable reference to an
<code>EconiaCapability</code> required for internal cross-module calls


<a name="@Returns_15"></a>

### Returns

* <code>bool</code>: <code><b>true</b></code> if target order is completely filled, else
<code><b>false</b></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_process_loop_order">fill_market_order_process_loop_order</a>&lt;B, Q, E&gt;(style: bool, side: bool, scale_factor: u64, base_parcels_to_fill_ref_mut: &<b>mut</b> u64, target_order_id: u128, target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;, econia_capability_ref: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_process_loop_order">fill_market_order_process_loop_order</a>&lt;B, Q, E&gt;(
    style: bool,
    side: bool,
    scale_factor: u64,
    base_parcels_to_fill_ref_mut: &<b>mut</b> u64,
    target_order_id: u128,
    target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    econia_capability_ref: &EconiaCapability,
): (
    bool
) {
    // Calculate price of target order
    <b>let</b> target_price = <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(target_order_id);
    // Check, and maybe <b>update</b>, tracker for base parcels <b>to</b> fill
    <a href="market.md#0xc0deb00c_market_fill_market_order_check_base_parcels_to_fill">fill_market_order_check_base_parcels_to_fill</a>(style, target_price,
        quote_coins_ref_mut, target_order_ref_mut,
        base_parcels_to_fill_ref_mut);
    // Target price may be too high for <a href="user.md#0xc0deb00c_user">user</a> <b>to</b> afford even one
    // base parcel in the case of a buy, and <b>return</b> incomplete fill
    // <b>if</b> so
    <b>if</b> (*base_parcels_to_fill_ref_mut == 0) <b>return</b> <b>false</b>;
    // Otherwise check <b>if</b> target order will be completely filled
    <b>let</b> complete_fill = (*base_parcels_to_fill_ref_mut &gt;=
        target_order_ref_mut.base_parcels);
    // Calculate number of base parcels filled
    <b>let</b> base_parcels_filled = <b>if</b> (complete_fill)
        // If complete fill, number of base parcels order was for
        target_order_ref_mut.base_parcels <b>else</b>
        // Else, remaining base parcels left <b>to</b> fill
        *base_parcels_to_fill_ref_mut;
    // Decrement counter for number of base parcels <b>to</b> fill
    *base_parcels_to_fill_ref_mut = *base_parcels_to_fill_ref_mut -
        base_parcels_filled;
    // Calculate base and quote <a href="coins.md#0xc0deb00c_coins">coins</a> routed for the fill
    <b>let</b> base_to_route = base_parcels_filled * scale_factor;
    <b>let</b> quote_to_route = base_parcels_filled * target_price;
    // Fill the target <a href="user.md#0xc0deb00c_user">user</a>'s order
    <a href="user.md#0xc0deb00c_user_fill_order_internal">user::fill_order_internal</a>&lt;B, Q, E&gt;(target_order_ref_mut.<a href="user.md#0xc0deb00c_user">user</a>,
        target_order_ref_mut.custodian_id, side, target_order_id,
        complete_fill, base_parcels_filled, base_coins_ref_mut,
        quote_coins_ref_mut, base_to_route, quote_to_route,
        econia_capability_ref);
    // If did not completely fill target order, decrement the number
    // of base parcels it is for by the fill amount (<b>if</b> it was
    // completely filled, it should be popped later)
    <b>if</b> (!complete_fill) target_order_ref_mut.base_parcels =
        target_order_ref_mut.base_parcels - base_parcels_filled;
    complete_fill // Return <b>if</b> target order was completely filled
}
</code></pre>



</details>

<a name="0xc0deb00c_market_fill_market_order_traverse_loop"></a>

## Function `fill_market_order_traverse_loop`

Fill a market order by traversing along the orders tree.

Inner function for <code><a href="market.md#0xc0deb00c_market_fill_market_order">fill_market_order</a>()</code>. During iterated
traversal, the "incoming user" (who places the market order or
who has the order placed on their behalf by a custodian) has
their order filled against the "target user" who has a "target
position" on the order book.


<a name="@Parameters_16"></a>

### Parameters

* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code> if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>:
the target order side
* <code>scale_factor</code>: Scale factor for given market
* <code>tree_ref_mut</code>: Mutable reference to orders tree for given
<code>side</code>
* <code>traversal_direction</code>: <code><a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code><a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>n_orders</code>: Counter for number of orders in tree
* <code>spread_maker_ref_mut</code>: Mutable reference to field tracking
spread maker on given <code>side</code>
* <code>base_parcels_to_fill</code>: Initialized counter for base parcels
left to fill
* <code>base_coins_ref_mut</code>: Mutable reference to incoming user's
base coins
* <code>quote_coins_ref_mut</code>: Mutable reference to incoming user's
quote coins
* <code>econia_capability_ref</code>: Immutable reference to an
<code>EconiaCapability</code> required for internal cross-module calls


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>&lt;B, Q, E&gt;(style: bool, side: bool, scale_factor: u64, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, traversal_direction: bool, n_orders: u64, spread_maker_ref_mut: &<b>mut</b> u128, base_parcels_to_fill: u64, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;, econia_capability_ref: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_fill_market_order_traverse_loop">fill_market_order_traverse_loop</a>&lt;B, Q, E&gt;(
    style: bool,
    side: bool,
    scale_factor: u64,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    traversal_direction: bool,
    n_orders: u64,
    spread_maker_ref_mut: &<b>mut</b> u128,
    base_parcels_to_fill: u64,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;B&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;Q&gt;,
    econia_capability_ref: &EconiaCapability
) {
    // Initialize iterated traversal, storing order ID of target
    // order, mutable reference <b>to</b> target order, the parent field
    // of the target node, and child field index of target node
    <b>let</b> (target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index) = <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">critbit::traverse_init_mut</a>(
            tree_ref_mut, traversal_direction);
    // Declare a null order for generating default mutable reference
    <b>let</b> null_order = <a href="market.md#0xc0deb00c_market_Order">Order</a>{<a href="user.md#0xc0deb00c_user">user</a>: @0x0, custodian_id: 0, base_parcels: 0};
    <b>loop</b> { // Begin traversal <b>loop</b>
        // Process the order for current iteration, storing flag for
        // <b>if</b> the target order was completely filled
        <b>let</b> complete_fill = <a href="market.md#0xc0deb00c_market_fill_market_order_process_loop_order">fill_market_order_process_loop_order</a>&lt;B, Q, E&gt;(
            style, side, scale_factor, &<b>mut</b> base_parcels_to_fill,
            target_order_id, target_order_ref_mut, base_coins_ref_mut,
            quote_coins_ref_mut, econia_capability_ref);
        // Declare variables for <b>if</b> should <b>break</b> out of <b>loop</b>, <b>if</b>
        // should pop the last order in the tree, and the value for
        // a new spread maker <b>if</b> one is generated
        <b>let</b> (should_break, should_pop, new_spread_maker);
        // Follow up on order processing
        (should_break, should_pop, new_spread_maker, n_orders,
         target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index) = <a href="market.md#0xc0deb00c_market_fill_market_order_loop_order_follow_up">fill_market_order_loop_order_follow_up</a>(
            side, base_parcels_to_fill, complete_fill, traversal_direction,
            tree_ref_mut, n_orders, target_order_id, &<b>mut</b> null_order,
            target_parent_index, target_child_index);
        <b>if</b> (should_break) { // If should <b>break</b> out of <b>loop</b>
            // Clean up <b>as</b> needed before breaking out of <b>loop</b>
            <a href="market.md#0xc0deb00c_market_fill_market_order_break_cleanup">fill_market_order_break_cleanup</a>(null_order,
                spread_maker_ref_mut, new_spread_maker, should_pop,
                tree_ref_mut, target_order_id);
            <b>break</b> // Break out of <b>loop</b>
        };
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_serial_id"></a>

## Function `get_serial_id`

Increment counter for number of orders placed on an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>,
returning the original value.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_serial_id">get_serial_id</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_serial_id">get_serial_id</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;
): u64 {
    // Borrow mutable reference <b>to</b> order book serial counter
    <b>let</b> counter_ref_mut = &<b>mut</b> order_book_ref_mut.counter;
    <b>let</b> count = *counter_ref_mut; // Get count
    *counter_ref_mut = count + 1; // Set new count
    count // Return original count
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_econia_capability"></a>

## Function `get_econia_capability`

Return an <code>EconiaCapability</code>, aborting if Econia account has no
<code><a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>(): <a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>():
EconiaCapability
<b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a> {
    // Assert <a href="capability.md#0xc0deb00c_capability">capability</a> store <b>has</b> been initialized
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>&gt;(@econia),
        <a href="market.md#0xc0deb00c_market_E_NO_ECONIA_CAPABILITY_STORE">E_NO_ECONIA_CAPABILITY_STORE</a>);
    // Return a <b>copy</b> of an Econia <a href="capability.md#0xc0deb00c_capability">capability</a>
    <b>borrow_global</b>&lt;<a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>&gt;(@econia).econia_capability
}
</code></pre>



</details>

<a name="0xc0deb00c_market_init_book"></a>

## Function `init_book`

Initialize <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> with given <code>scale_factor</code> under <code>host</code>
account, aborting if one already exists


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_init_book">init_book</a>&lt;B, Q, E&gt;(host: &<a href="">signer</a>, scale_factor: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_init_book">init_book</a>&lt;B, Q, E&gt;(
    host: &<a href="">signer</a>,
    scale_factor: u64,
) {
    // Assert book does not already exist under host account
    <b>assert</b>!(!<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(address_of(host)), <a href="market.md#0xc0deb00c_market_E_BOOK_EXISTS">E_BOOK_EXISTS</a>);
    // Move <b>to</b> host a newly-packed order book
    <b>move_to</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>{
        scale_factor,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        min_ask: <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>,
        max_bid: <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>,
        counter: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order"></a>

## Function `place_limit_order`

Place limit order on the book and in user's market account.


<a name="@Parameters_17"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user submitting order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>custodian_id</code>: Serial ID of delegated custodian for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>base_parcels</code>: Number of base parcels the order is for
* <code>price</code>: Order price


<a name="@Abort_conditions_18"></a>

### Abort conditions

* If <code>host</code> does not have corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* If order does not pass <code><a href="user.md#0xc0deb00c_user_add_order_internal">user::add_order_internal</a></code> error checks
* If new order crosses the spread (temporary)


<a name="@Assumes_19"></a>

### Assumes

* Orders tree will not already have an order with the same ID as
the new order because order IDs are generated from a
counter that increases when queried (via <code>get_serial_id</code>)


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, custodian_id: u64, side: bool, base_parcels: u64, price: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;B, Q, E&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    custodian_id: u64,
    side: bool,
    base_parcels: u64,
    price: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_EconiaCapabilityStore">EconiaCapabilityStore</a>, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> {
    // Assert host <b>has</b> an order book
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut = <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host);
    <b>let</b> <a href="order_id.md#0xc0deb00c_order_id">order_id</a> = // Get order ID based on new book serial ID/side
        <a href="order_id.md#0xc0deb00c_order_id_order_id">order_id::order_id</a>(price, <a href="market.md#0xc0deb00c_market_get_serial_id">get_serial_id</a>(order_book_ref_mut), side);
    // Add order <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> account (performs extensive <a href="">error</a>
    // checking)
    <a href="user.md#0xc0deb00c_user_add_order_internal">user::add_order_internal</a>&lt;B, Q, E&gt;(<a href="user.md#0xc0deb00c_user">user</a>, custodian_id, side, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>,
        base_parcels, price, &<a href="market.md#0xc0deb00c_market_get_econia_capability">get_econia_capability</a>());
    // Get mutable reference <b>to</b> orders tree for corresponding side,
    // determine <b>if</b> new order ID is new spread maker, determine <b>if</b>
    // new order crosses the spread, and get mutable reference <b>to</b>
    // spread maker for given side
    <b>let</b> (tree_ref_mut, new_spread_maker, crossed_spread,
        spread_maker_ref_mut) = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) (
            &<b>mut</b> order_book_ref_mut.asks,
            (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &lt; order_book_ref_mut.min_ask),
            (price &lt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref_mut.max_bid)),
            &<b>mut</b> order_book_ref_mut.min_ask
        ) <b>else</b> ( // If order is a bid
            &<b>mut</b> order_book_ref_mut.bids,
            (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &gt; order_book_ref_mut.max_bid),
            (price &gt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref_mut.min_ask)),
            &<b>mut</b> order_book_ref_mut.max_bid
        );
    // Assert spread uncrossed
    <b>assert</b>!(!crossed_spread, <a href="market.md#0xc0deb00c_market_E_CROSSED_SPREAD">E_CROSSED_SPREAD</a>);
    // If a new spread maker, mark <b>as</b> such on book
    <b>if</b> (new_spread_maker) *spread_maker_ref_mut = <a href="order_id.md#0xc0deb00c_order_id">order_id</a>;
    // Insert order <b>to</b> corresponding tree
    <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>,
        <a href="market.md#0xc0deb00c_market_Order">Order</a>{base_parcels, <a href="user.md#0xc0deb00c_user">user</a>, custodian_id});
}
</code></pre>



</details>

<a name="0xc0deb00c_market_book_orders_sdk"></a>

## Function `book_orders_sdk`

Index <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>s from <code>order_book_ref_mut</code> into vector of
<code><a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a></code>s, sorted by price-time priority per
<code>get_orders_sdk</code>, for each side.


<a name="@Returns_20"></a>

### Returns

* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;</code>: Price-time sorted asks
* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;</code>: Price-time sorted bids


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_book_orders_sdk">book_orders_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;): (<a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">market::SimpleOrder</a>&gt;, <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">market::SimpleOrder</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_book_orders_sdk">book_orders_sdk</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;
): (
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;,
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;
) {
    (<a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut, <a href="market.md#0xc0deb00c_market_ASK">ASK</a>),
     <a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut, <a href="market.md#0xc0deb00c_market_BID">BID</a>))
}
</code></pre>



</details>

<a name="0xc0deb00c_market_book_price_levels_sdk"></a>

## Function `book_price_levels_sdk`

Index <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> from <code>order_book_ref_mut</code> into vector of
<code>PriceLevels</code> for each side.


<a name="@Returns_21"></a>

### Returns

* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt;</code>: Ask price levels
* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt;</code>: Bid price levels


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_book_price_levels_sdk">book_price_levels_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;): (<a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">market::PriceLevel</a>&gt;, <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">market::PriceLevel</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_book_price_levels_sdk">book_price_levels_sdk</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;
): (
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt;,
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt;
) {
    (<a href="market.md#0xc0deb00c_market_get_price_levels_sdk">get_price_levels_sdk</a>(<a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>(order_book_ref_mut, <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)),
     <a href="market.md#0xc0deb00c_market_get_price_levels_sdk">get_price_levels_sdk</a>(<a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>(order_book_ref_mut, <a href="market.md#0xc0deb00c_market_BID">BID</a>)))
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_orders_sdk"></a>

## Function `get_orders_sdk`

Index <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>s in <code>order_book_ref_mut</code> into a <code><a href="">vector</a></code> of
<code>OrderSimple</code>s sorted by price-time priority, beginning with the
spread maker: if <code>side</code> is <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>, first element in vector is the
oldest ask at the minimum ask price, and if <code>side</code> is <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>,
first element in vector is the oldest bid at the maximum bid
price. Requires mutable reference to <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> because
<code>CritBitTree</code> traversal is not implemented immutably (at least
as of the time of this writing). Only for SDK generation.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;, side: bool): <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">market::SimpleOrder</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;,
    side: bool
): <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt; {
    // Initialize empty <a href="">vector</a>
    <b>let</b> simple_orders = <a href="_empty">vector::empty</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;();
    // Define orders tree and traversal direction base on side
    <b>let</b> (tree_ref_mut, traversal_direction) = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
        // If asks, <b>use</b> asks tree <b>with</b> successor iteration
        (&<b>mut</b> order_book_ref_mut.asks, <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a>) <b>else</b>
        // If bids, <b>use</b> bids tree <b>with</b> predecessor iteration
        (&<b>mut</b> order_book_ref_mut.bids, <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a>);
    // If no positions in tree, <b>return</b> empty <a href="">vector</a>
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut)) <b>return</b> simple_orders;
    // Calculate number of traversals possible
    <b>let</b> remaining_traversals = <a href="critbit.md#0xc0deb00c_critbit_length">critbit::length</a>(tree_ref_mut) - 1;
    // Initialize traversal: get target order ID, mutable reference
    // <b>to</b> target order, and the index of the target node's parent
    <b>let</b> (target_id, target_order_ref_mut, target_parent_index, _) =
        <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">critbit::traverse_init_mut</a>(tree_ref_mut, traversal_direction);
    <b>loop</b> { // Loop over all orders in tree
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> simple_orders, <a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>{
            price: <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(target_id),
            base_parcels: target_order_ref_mut.base_parcels
        }); // Push back corresponding simple order onto <a href="">vector</a>
        // Return simple orders <a href="">vector</a> <b>if</b> unable <b>to</b> traverse
        <b>if</b> (remaining_traversals == 0) <b>return</b> simple_orders;
        // Otherwise traverse <b>to</b> next order in the tree
        (target_id, target_order_ref_mut, target_parent_index, _) =
            <a href="critbit.md#0xc0deb00c_critbit_traverse_mut">critbit::traverse_mut</a>(tree_ref_mut, target_id,
                target_parent_index, traversal_direction);
        // Decrement number of remaining traversals
        remaining_traversals = remaining_traversals - 1;
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_price_levels_sdk"></a>

## Function `get_price_levels_sdk`

Index output of <code><a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>()</code> into a vector of <code><a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_price_levels_sdk">get_price_levels_sdk</a>(simple_orders: <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">market::SimpleOrder</a>&gt;): <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">market::PriceLevel</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_price_levels_sdk">get_price_levels_sdk</a>(
    simple_orders: <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_SimpleOrder">SimpleOrder</a>&gt;
): <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt; {
    // Initialize empty <a href="">vector</a> of price levels
    <b>let</b> price_levels = <a href="_empty">vector::empty</a>&lt;<a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>&gt;();
    // Return empty <a href="">vector</a> <b>if</b> no simple orders <b>to</b> index
    <b>if</b> (<a href="_is_empty">vector::is_empty</a>(&simple_orders)) <b>return</b> price_levels;
    // Get immutable reference <b>to</b> first simple order in <a href="">vector</a>
    <b>let</b> simple_order_ref = <a href="_borrow">vector::borrow</a>(&simple_orders, 0);
    // Set level price <b>to</b> that from first simple order
    <b>let</b> level_price = simple_order_ref.price;
    // Set level base parcels counter <b>to</b> that of first simple order
    <b>let</b> level_base_parcels = simple_order_ref.base_parcels;
    // Get number of simple orders <b>to</b> index
    <b>let</b> n_simple_orders = <a href="_length">vector::length</a>(&simple_orders);
    <b>let</b> simple_order_index = 1; // Start <b>loop</b> at the next order
    // While there are simple orders left <b>to</b> index
    <b>while</b> (simple_order_index &lt; n_simple_orders) {
        // Borrow immutable reference <b>to</b> order for current iteration
        simple_order_ref =
            <a href="_borrow">vector::borrow</a>(&simple_orders, simple_order_index);
        // If on new level
        <b>if</b> (simple_order_ref.price != level_price) {
            // Store last price level in <a href="">vector</a>
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> price_levels, <a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>{
                price: level_price, base_parcels: level_base_parcels});
            // Start tracking new price level <b>with</b> given order
            (level_price, level_base_parcels) = (
                simple_order_ref.price, simple_order_ref.base_parcels)
        } <b>else</b> { // If same price <b>as</b> last checked
            // Increment count of base parcels for current level
            level_base_parcels =
                level_base_parcels + simple_order_ref.base_parcels;
        };
        // Iterate again, on next simple order in <a href="">vector</a>
        simple_order_index = simple_order_index + 1;
    }; // No more simple orders left <b>to</b> index
    // Store final price level in <a href="">vector</a>
    <a href="_push_back">vector::push_back</a>(&<b>mut</b> price_levels, <a href="market.md#0xc0deb00c_market_PriceLevel">PriceLevel</a>{
        price: level_price, base_parcels: level_base_parcels});
    price_levels // Return sorted <a href="">vector</a> of price levels
}
</code></pre>



</details>

<a name="0xc0deb00c_market_simulate_swap_sdk"></a>

## Function `simulate_swap_sdk`

Calculate expected result of swap against an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>.


<a name="@Parameters_22"></a>

### Parameters

* <code>order_book_ref_mut</code>: Mutable reference to an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>style</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>coins_in</code>: Quote coins to spend if style is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and base
coins to sell if style is <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>


<a name="@Returns_23"></a>

### Returns

* <code>u64</code>: Max base coins that can be purchased with <code>coins_in</code>
quote coins if <code>style</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, else max quote coins that can
be received in exchange for selling <code>coins_in</code> base coins.
* <code>u64</code>: Leftover <code>coins_in</code>, if not enough depth on book for a
complete fill


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_simulate_swap_sdk">simulate_swap_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&lt;B, Q, E&gt;, style: bool, coins_in: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_simulate_swap_sdk">simulate_swap_sdk</a>&lt;B, Q, E&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>&lt;B, Q, E&gt;,
    style: bool,
    coins_in: u64
): (
    u64,
    u64
) {
    // If a swap buy, fills against asks, <b>else</b> bids
    <b>let</b> (side) = <b>if</b> (style == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) <a href="market.md#0xc0deb00c_market_ASK">ASK</a> <b>else</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>;
    // Get orders sorted by price-time priority
    <b>let</b> simple_orders = <a href="market.md#0xc0deb00c_market_get_orders_sdk">get_orders_sdk</a>&lt;B, Q, E&gt;(order_book_ref_mut, side);
    // If no orders on book, <b>return</b> that 0 swaps made
    <b>if</b> (<a href="_is_empty">vector::is_empty</a>(&simple_orders)) <b>return</b> (0, coins_in);
    // Get order book scale factor
    <b>let</b> scale_factor = order_book_ref_mut.scale_factor;
    // Initialize counter for in <a href="coins.md#0xc0deb00c_coins">coins</a> left, out <a href="coins.md#0xc0deb00c_coins">coins</a> received,
    // counter for <a href="">vector</a> <b>loop</b> index, and number of orders
    <b>let</b> (coins_in_left, coins_out, simple_order_index, n_orders) =
        (coins_in, 0, 0, <a href="_length">vector::length</a>(&simple_orders));
    <b>loop</b> { // Loop over all orders
        // Borrow immutable reference <b>to</b> order for current iteration
        <b>let</b> simple_order =
            <a href="_borrow">vector::borrow</a>(&simple_orders, simple_order_index);
        // Declare variables for base parcels filled, and <b>if</b> should
        // <b>return</b> after current iteration
        <b>let</b> (base_parcels_filled, should_return);
        // Set base parcels filled multipliers based on style
        <b>let</b> (coins_in_multiplier, coins_out_multiplier) =
            // If sell, get base <a href="coins.md#0xc0deb00c_coins">coins</a> and expend quote <a href="coins.md#0xc0deb00c_coins">coins</a>
            <b>if</b> (style == <a href="market.md#0xc0deb00c_market_SELL">SELL</a>) (scale_factor, simple_order.price) <b>else</b>
                // If buy, get quote <a href="coins.md#0xc0deb00c_coins">coins</a> and expend base <a href="coins.md#0xc0deb00c_coins">coins</a>
                (simple_order.price, scale_factor);
        <b>if</b> (style == <a href="market.md#0xc0deb00c_market_SELL">SELL</a>) { // If selling base <a href="coins.md#0xc0deb00c_coins">coins</a>
            // Calculate base parcels swap seller <b>has</b>
            <b>let</b> base_parcels_on_hand = coins_in_left / scale_factor;
            // Caculate base parcels filled against order and <b>if</b>
            // should <b>return</b> after current <b>loop</b> iteration
            (base_parcels_filled, should_return) =
                // If more than enough base parcels on hand for a
                // complete fill against the target bid
                <b>if</b> (base_parcels_on_hand &gt; simple_order.base_parcels)
                // Complete fill, so <b>continue</b>
                (simple_order.base_parcels, <b>false</b>) <b>else</b>
                // Fills all parcels on hand, so <b>return</b>
                (base_parcels_on_hand, <b>true</b>);
        } <b>else</b> { // If buying base <a href="coins.md#0xc0deb00c_coins">coins</a>
            // Calculate number of base parcels <a href="user.md#0xc0deb00c_user">user</a> can afford at
            // order price
            <b>let</b> base_parcels_can_afford =
                coins_in_left / simple_order.price;
            // Caculate base parcels filled against order and <b>if</b>
            // should <b>return</b> after current <b>loop</b> iteration
            (base_parcels_filled, should_return) =
                // If cannot afford <b>to</b> buy all base parcels in order
                <b>if</b> (simple_order.base_parcels &gt; base_parcels_can_afford)
                // Only fills base parcels can afford, so <b>return</b>
                (base_parcels_can_afford, <b>true</b>) <b>else</b>
                // Fills all base parcels in order, so <b>continue</b>
                (simple_order.base_parcels, <b>false</b>);
        };
        // Decrement <a href="coins.md#0xc0deb00c_coins">coins</a> in by base parcels times multiplier
        coins_in_left = coins_in_left -
            base_parcels_filled * coins_in_multiplier;
        // Increment <a href="coins.md#0xc0deb00c_coins">coins</a> out by base parcels times multiplier
        coins_out = coins_out + base_parcels_filled * coins_out_multiplier;
        // Increment <b>loop</b> counter
        simple_order_index = simple_order_index + 1;
        // If done looping, <b>return</b> <a href="coins.md#0xc0deb00c_coins">coins</a> out and <a href="coins.md#0xc0deb00c_coins">coins</a> in left
        <b>if</b> (should_return || simple_order_index == n_orders)
            <b>return</b> (coins_out, coins_in_left)
    }
}
</code></pre>



</details>
