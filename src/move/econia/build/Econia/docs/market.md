
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market-level book keeping functionality, with matching engine.


-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Struct `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Resource `OrderBooks`](#0xc0deb00c_market_OrderBooks)
-  [Constants](#@Constants_0)
-  [Function `invoke_user`](#0xc0deb00c_market_invoke_user)
-  [Function `register_market_generic`](#0xc0deb00c_market_register_market_generic)
-  [Function `register_market_pure_coin`](#0xc0deb00c_market_register_market_pure_coin)
-  [Function `register_market`](#0xc0deb00c_market_register_market)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
-  [Function `register_order_book`](#0xc0deb00c_market_register_order_book)
    -  [Type parameters](#@Type_parameters_3)
    -  [Parameters](#@Parameters_4)
-  [Function `verify_order_book_exists`](#0xc0deb00c_market_verify_order_book_exists)
    -  [Abort conditions](#@Abort_conditions_5)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
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


<a name="0xc0deb00c_market_PURE_COIN_PAIR"></a>

When both base and quote assets are coins


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>: u64 = 0;
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



<a name="0xc0deb00c_market_MAX_BID_DEFAULT"></a>

Default value for maximum bid order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_market_MIN_ASK_DEFAULT"></a>

Default value for minimum ask order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_market_invoke_user"></a>

## Function `invoke_user`

Dependency stub planning


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_user">invoke_user</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_invoke_user">invoke_user</a>() {<a href="user.md#0xc0deb00c_user_return_0">user::return_0</a>();}
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

<a name="0xc0deb00c_market_register_market"></a>

## Function `register_market`

Register new market under signing host


<a name="@Type_parameters_1"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_2"></a>

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


<a name="@Type_parameters_3"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_4"></a>

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


<a name="@Abort_conditions_5"></a>

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
