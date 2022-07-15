
<a name="0xc0deb00c_Match"></a>

# Module `0xc0deb00c::Match`

Matching engine functionality, integrating user-side and book-side
modules


-  [Constants](#@Constants_0)
-  [Function `fill_market_order`](#0xc0deb00c_Match_fill_market_order)
    -  [Parameters](#@Parameters_1)
    -  [Returns](#@Returns_2)
    -  [Assumptions](#@Assumptions_3)


<pre><code><b>use</b> <a href="Book.md#0xc0deb00c_Book">0xc0deb00c::Book</a>;
<b>use</b> <a href="User.md#0xc0deb00c_User">0xc0deb00c::User</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Match_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Match_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Match_fill_market_order"></a>

## Function `fill_market_order`

Fill a market order against the book as much as possible,
returning when there is no liquidity left or when order is
completely filled


<a name="@Parameters_1"></a>

### Parameters

* <code>host</code> Host of corresponding order book
* <code>addr</code>: Address of user placing market order
* <code>side</code>: <code><a href="Match.md#0xc0deb00c_Match_ASK">ASK</a></code> or <code><a href="Match.md#0xc0deb00c_Match_BID">BID</a></code>, denoting the side on the order book
which should be filled against. If <code><a href="Match.md#0xc0deb00c_Match_ASK">ASK</a></code>, user is submitting
a market buy, if <code><a href="Match.md#0xc0deb00c_Match_BID">BID</a></code>, user is submitting a market sell
* <code>size</code>: Base coin parcels to be filled
* <code>book_cap</code>: Immutable reference to <code>Econia::Book:FriendCap</code>


<a name="@Returns_2"></a>

### Returns

* <code>u64</code>: Amount of base coin parcels left unfilled


<a name="@Assumptions_3"></a>

### Assumptions

* Order book has been properly initialized at host address


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(host: <b>address</b>, addr: <b>address</b>, side: bool, size: u64, book_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    addr: <b>address</b>,
    side: bool,
    size: u64,
    book_cap: &BookCap
): u64 {
    // Get number of positions on corresponding order book side
    <b>let</b> n_positions = <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>) n_asks&lt;B, Q, E&gt;(host, book_cap)
        <b>else</b> n_bids&lt;B, Q, E&gt;(host, book_cap);
    // Get scale factor of corresponding order book
    <b>let</b> scale_factor = scale_factor&lt;B, Q, E&gt;(host, book_cap);
    // Return full order size <b>if</b> no positions on book
    <b>if</b> (n_positions == 0) <b>return</b> size;
    // Initialize traversal, storing <a href="ID.md#0xc0deb00c_ID">ID</a> of target position, <b>address</b>
    // of user holding it, the parent field of corresponding tree
    // node, child index of corresponding node, amount filled, and
    // <b>if</b> an exact match between incoming order and target position
    <b>let</b> (target_id, target_addr, target_p_f, target_c_i, filled, exact) =
        init_traverse_fill&lt;B, Q, E&gt;(host, addr, side, size, book_cap);
    <b>loop</b> { // Begin traversal <b>loop</b>
        // Route funds between conterparties, <b>update</b> open orders
        process_fill&lt;B, Q, E&gt;(target_addr, addr, side, target_id, filled,
                              scale_factor, exact);
        size = size - filled; // Decrement size left <b>to</b> match
        // If incoming order unfilled and can traverse
        <b>if</b> (size &gt; 0 && n_positions &gt; 1) {
            // Traverse pop fill <b>to</b> next position
            (target_id, target_addr, target_p_f, target_c_i, filled, exact)
                = traverse_pop_fill&lt;B, Q, E&gt;(
                    host, addr, side, size, n_positions, target_id,
                    target_p_f, target_c_i, book_cap);
            // Decrement count of positions on book for given side
            n_positions = n_positions - 1;
        } <b>else</b> { // If should not continute iterated traverse fill
            // Determine <b>if</b> a partial target fill was made
            <b>let</b> partial_target_fill = (size == 0 && !exact);
            // If anything other than a partial target fill made
            <b>if</b> (!partial_target_fill) {
                // Cancel target position
                cancel_position&lt;B, Q, E&gt;(host, side, target_id, book_cap);
            };
            // Refresh the max bid/<b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a> for the order book
            // refresh_extreme_order_id&lt;B, Q, E&gt;(host, side, book_cap);
            <b>break</b> // Break out of iterated traversal <b>loop</b>
        };
    };
    size // Return unfilled size on market order
}
</code></pre>



</details>
