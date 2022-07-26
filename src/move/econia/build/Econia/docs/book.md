
<a name="0xc0deb00c_book"></a>

# Module `0xc0deb00c::book`

Order book functionality


-  [Struct `Order`](#0xc0deb00c_book_Order)
-  [Resource `OrderBook`](#0xc0deb00c_book_OrderBook)
-  [Constants](#@Constants_0)
-  [Function `init_book`](#0xc0deb00c_book_init_book)
-  [Function `scale_factor`](#0xc0deb00c_book_scale_factor)
    -  [Assumes](#@Assumes_1)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="capability.md#0xc0deb00c_capability">0xc0deb00c::capability</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
</code></pre>



<a name="0xc0deb00c_book_Order"></a>

## Struct `Order`

An order on the order book


<pre><code><b>struct</b> <a href="book.md#0xc0deb00c_book_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_parcels: u64</code>
</dt>
<dd>
 Number of base coin parcels to be filled
</dd>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>
 Address of corresponding user
</dd>
<dt>
<code>market_account_id: u8</code>
</dt>
<dd>
 For given user, ID of market account holding the order
</dd>
</dl>


</details>

<a name="0xc0deb00c_book_OrderBook"></a>

## Resource `OrderBook`

An order book for the given market


<pre><code><b>struct</b> <a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a>&lt;B, Q, E&gt; <b>has</b> key
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
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="book.md#0xc0deb00c_book_Order">book::Order</a>&gt;</code>
</dt>
<dd>
 Asks tree
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="book.md#0xc0deb00c_book_Order">book::Order</a>&gt;</code>
</dt>
<dd>
 Bids tree
</dd>
<dt>
<code>min_ask: u128</code>
</dt>
<dd>
 Order ID of minimum ask, per price-time priority
</dd>
<dt>
<code>max_bid: u128</code>
</dt>
<dd>
 Order ID of maximum bid, per price-time priority
</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>
 Serial counter for number of orders placed on book
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_book_LEFT"></a>

Left direction, denoting predecessor traversal


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_book_RIGHT"></a>

Right direction, denoting successor traversal


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_book_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_book_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_book_E_BOOK_EXISTS"></a>

When an order book already exists at given address


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_book_MAX_BID_DEFAULT"></a>

Default value for maximum bid order ID


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_book_MIN_ASK_DEFAULT"></a>

Default value for minimum ask order ID


<pre><code><b>const</b> <a href="book.md#0xc0deb00c_book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_book_init_book"></a>

## Function `init_book`

Initialize <code><a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a></code> with given <code>scale_factor</code> under <code>host</code>
account, aborting if one already exists


<pre><code><b>public</b> <b>fun</b> <a href="book.md#0xc0deb00c_book_init_book">init_book</a>&lt;B, Q, E&gt;(host: &<a href="">signer</a>, scale_factor: u64, _: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="book.md#0xc0deb00c_book_init_book">init_book</a>&lt;B, Q, E&gt;(
    host: &<a href="">signer</a>,
    scale_factor: u64,
    _: &EconiaCapability
) {
    // Assert <a href="book.md#0xc0deb00c_book">book</a> does not already exist under host account
    <b>assert</b>!(!<b>exists</b>&lt;<a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(address_of(host)), <a href="book.md#0xc0deb00c_book_E_BOOK_EXISTS">E_BOOK_EXISTS</a>);
    // Move <b>to</b> host a newly-packed order <a href="book.md#0xc0deb00c_book">book</a>
    <b>move_to</b>&lt;<a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host, <a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a>{
        scale_factor,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        min_ask: <a href="book.md#0xc0deb00c_book_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>,
        max_bid: <a href="book.md#0xc0deb00c_book_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>,
        counter: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_book_scale_factor"></a>

## Function `scale_factor`

Return scale factor for extant order book at <code>host</code> address


<a name="@Assumes_1"></a>

### Assumes

* <code><a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a></code> exists at <code>host</code> address


<pre><code><b>public</b> <b>fun</b> <a href="book.md#0xc0deb00c_book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(host: <b>address</b>, _: &<a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="book.md#0xc0deb00c_book_scale_factor">scale_factor</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    _: &EconiaCapability
): u64
<b>acquires</b> <a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a> {
    <b>borrow_global</b>&lt;<a href="book.md#0xc0deb00c_book_OrderBook">OrderBook</a>&lt;B, Q, E&gt;&gt;(host).scale_factor
}
</code></pre>



</details>
