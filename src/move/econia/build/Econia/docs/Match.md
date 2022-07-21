
<a name="0xc0deb00c_Match"></a>

# Module `0xc0deb00c::Match`

Matching engine functionality, integrating user-side and book-side
modules


<a name="@Sides_0"></a>

## Sides


In the case of a market sell (which fills against bids on the book),
it is possible to verify that the submitting user has enough
collateral, in the form of base coin subunits, ahead of time,
because they pre-specify the amount of base coins they are trying to
sell. They will receive an unspecified amount of quote coins in
return, but it does not matter that this amount is unknown because
the value simply gets added to their collateral.

In the case of a market buy (which fills against asks on the book),
however, it is not possible to verify that the submitting user has
enough collateral, in the form of quote coin subunits, ahead of
time: the amount of quote coins required to complete the market buy
depends on the size and price of each ask position on the book,
hence a user must pre-specify how many quote coin subunits they are
willing to pay when submitting their order.


<a name="@Terminology_1"></a>

## Terminology

* An "incoming order" is the market order filling against positions
on the book
* A "target position" is the position on the book being filled
during one filling iteration of traversal along the tree
* A "partial fill" is one where the target position still has a
nonzero size after the fill
* An "exact fill" is one where the target position and the incoming
order require the same number of base coin parcels to fill
* A "complete fill" is one where the incoming order is completely
filled against the target position, but traversal must continue
because the incoming order still has not been filled


<a name="@Testing_2"></a>

## Testing


Test-only constants and functions are used to construct a test
market with simulated positions. During testing, the "incoming
market order" fills against the "target position" during iterated
traversal, with markets constructed so that for both ask and bid
trees, user 1's position is filled before user 2's, which is filled
before user 3's. Hence, the following tests exercise logic at
sequential milestones along the process of clearing out the book,
whether via a market buy (filling against asks) or a market sell
(filling against bids):
* <code>ask_partial_1()</code>
* <code>bid_exact_1()</code>
* <code>bid_partial_2()</code>
* <code>ask_exact_2()</code>
* <code>ask_partial_3()</code>
* <code>bid_exact_3()</code>
* <code>ask_clear_book()</code>

As described in [sides](#sides), in the case of a market buy
(filling against asks on the book), the following tests exercise
logic at sequential milestones of exhausting available quote coins
along the process of clearing out the book:
* <code>buy_exhaust_immediately()</code>
* <code>buy_exhaust_partial_1_complete_requested()</code>
* <code>buy_exhaust_exact_1_complete_requested()</code>
* <code>buy_exhaust_partial_2_exact_requested()</code>
* <code>buy_exhaust_exact_2_exact_requested()</code>
* <code>buy_exhaust_partial_3_larger_partial_requested()</code>
* <code>buy_exhaust_exact_3_complete_requested()</code>

---


-  [Sides](#@Sides_0)
-  [Terminology](#@Terminology_1)
-  [Testing](#@Testing_2)
-  [Constants](#@Constants_3)
-  [Function `submit_market_buy`](#0xc0deb00c_Match_submit_market_buy)
-  [Function `submit_market_sell`](#0xc0deb00c_Match_submit_market_sell)
-  [Function `swap`](#0xc0deb00c_Match_swap)
    -  [Parameters](#@Parameters_4)
    -  [Considerations](#@Considerations_5)
-  [Function `swap_buy`](#0xc0deb00c_Match_swap_buy)
-  [Function `swap_sell`](#0xc0deb00c_Match_swap_sell)
-  [Function `fill_market_order`](#0xc0deb00c_Match_fill_market_order)
    -  [Parameters](#@Parameters_6)
    -  [Terminology](#@Terminology_7)
    -  [Returns](#@Returns_8)
    -  [Assumptions](#@Assumptions_9)
-  [Function `submit_market_order`](#0xc0deb00c_Match_submit_market_order)
    -  [Parameters](#@Parameters_10)
    -  [Abort conditions](#@Abort_conditions_11)
    -  [Assumptions](#@Assumptions_12)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="Book.md#0xc0deb00c_Book">0xc0deb00c::Book</a>;
<b>use</b> <a href="Caps.md#0xc0deb00c_Caps">0xc0deb00c::Caps</a>;
<b>use</b> <a href="ID.md#0xc0deb00c_ID">0xc0deb00c::ID</a>;
<b>use</b> <a href="Orders.md#0xc0deb00c_Orders">0xc0deb00c::Orders</a>;
<b>use</b> <a href="User.md#0xc0deb00c_User">0xc0deb00c::User</a>;
</code></pre>



<a name="@Constants_3"></a>

## Constants


<a name="0xc0deb00c_Match_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Match_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Match_E_SIZE_0"></a>



<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_E_SIZE_0">E_SIZE_0</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_Match_E_NOT_ENOUGH_COLLATERAL"></a>

When not enough collateral for an operation


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_Match_E_NO_MARKET"></a>

When no corresponding market registered


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_E_NO_MARKET">E_NO_MARKET</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Match_E_NO_O_C"></a>

When user does not have order collateral container


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_E_NO_O_C">E_NO_O_C</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Match_BUY"></a>

Flag for submitting a market buy


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_Match_E_QUOTE_SPEND_0"></a>



<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_E_QUOTE_SPEND_0">E_QUOTE_SPEND_0</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_Match_SELL"></a>

Flag for submitting a market sell


<pre><code><b>const</b> <a href="Match.md#0xc0deb00c_Match_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_Match_submit_market_buy"></a>

## Function `submit_market_buy`

Wrapped call to <code><a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>()</code> for side <code><a href="Match.md#0xc0deb00c_Match_BUY">BUY</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_buy">submit_market_buy</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, requested_size: u64, max_quote_to_spend: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_buy">submit_market_buy</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    requested_size: u64,
    max_quote_to_spend: u64
) {
    <a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>&lt;B, Q, E&gt;(
        user, host, <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>, requested_size, max_quote_to_spend);
    // Update user sequence counter
    update_user_seq_counter(user, &orders_cap());
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_submit_market_sell"></a>

## Function `submit_market_sell`

Wrapped call to <code><a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>()</code> for side <code><a href="Match.md#0xc0deb00c_Match_SELL">SELL</a></code>,


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_sell">submit_market_sell</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, requested_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_sell">submit_market_sell</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    requested_size: u64,
) {
    <a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>&lt;B, Q, E&gt;(user, host, <a href="Match.md#0xc0deb00c_Match_SELL">SELL</a>, requested_size, 0);
    // Update user sequence counter
    update_user_seq_counter(user, &orders_cap());
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_swap"></a>

## Function `swap`

Submit either a market <code><a href="Match.md#0xc0deb00c_Match_BUY">BUY</a></code> or <code><a href="Match.md#0xc0deb00c_Match_SELL">SELL</a></code>, initializing account
resources as needed, depositing as needed, and withdrawing all
available collateral after the swap. Deposits required amounts
from <code>user</code>'s <code>AptosFramework</code> coin stores into their Econia
order collateral cointainer before the swap, executes the swap,
then withdraws all order collateral back to coin stores.


<a name="@Parameters_4"></a>

### Parameters

* <code>user</code>: User performing swap
* <code>host</code>: Market host
* <code>side</code>: <code><a href="Match.md#0xc0deb00c_Match_BUY">BUY</a></code> or <code><a href="Match.md#0xc0deb00c_Match_SELL">SELL</a></code>
* <code>requested_size</code>: Requested number of base coin parcels to be
* <code>max_quote_to_spend</code>: Maximum number of quote coins that can
be spent in the case of a market buy (unused in case of a
market sell)
* <code>orders_cap</code>: Mutable reference to <code>OrdersCap</code>


<a name="@Considerations_5"></a>

### Considerations

* Designed to be a private function, but calls public entry
functions, so has to be itself a public entry function. Hence
the <code>&OrdersCap</code> to prevent SDKs from calling this version,
ensuring they only call wrapped versions


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap">swap</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, side: bool, requested_size: u64, max_quote_to_spend: u64, orders_cap: &<a href="Orders.md#0xc0deb00c_Orders_FriendCap">Orders::FriendCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap">swap</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    side: bool,
    requested_size: u64,
    max_quote_to_spend: u64,
    orders_cap: &OrdersCap
) {
    <b>let</b> user_addr = address_of(user); // Get user <b>address</b>
    // Initialize user <b>if</b> they do not have a sequence counter
    <b>if</b> (!exists_sequence_counter(user_addr, orders_cap)) init_user(user);
    // Initialize containers for given market <b>if</b> user <b>has</b> none
    <b>if</b> (!exists_order_collateral&lt;B, Q ,E&gt;(user_addr, orders_cap))
        init_containers&lt;B, Q, E&gt;(user);
    // If user does not have base <a href="">coin</a> store, register one
    <b>if</b> (!exists_coin_store&lt;B&gt;(user_addr)) register_coin_store&lt;B&gt;(user);
    // If user does not have quote <a href="">coin</a> store, register one
    <b>if</b> (!exists_coin_store&lt;Q&gt;(user_addr)) register_coin_store&lt;Q&gt;(user);
    // If a market buy, deposit max quote coins willing <b>to</b> spend
    <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>) { // If a market buy
        // Deposit max amount of quote coins willing <b>to</b> spend
        collateral_deposit&lt;B, Q, E&gt;(
            user, 0, max_quote_to_spend, orders_cap);
    } <b>else</b> { // If a market sell
        // Calculate base <a href="">coin</a> subunits needed for order
        <b>let</b> base_coins_needed = requested_size *
            orders_scale_factor&lt;B, Q, E&gt;(user_addr, orders_cap);
        // Deposit base coins <b>as</b> collateral
        collateral_deposit&lt;B, Q, E&gt;(
            user, base_coins_needed, 0, orders_cap);
    };
    // Submit a market order <b>with</b> corresponding values
    <a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>&lt;B, Q, E&gt;(user, host, side, requested_size,
        max_quote_to_spend);
    // Determine amount of availble collateral user <b>has</b>
    <b>let</b> (base_collateral, quote_collateral) =
        get_available_collateral&lt;B, Q, E&gt;(user_addr, orders_cap);
    // Withdraw all available collateral back <b>to</b> user's <a href="">coin</a> stores
    collateral_withdraw&lt;B, Q, E&gt;(
        user, base_collateral, quote_collateral, orders_cap);
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_swap_buy"></a>

## Function `swap_buy`

Wrapped call to <code><a href="Match.md#0xc0deb00c_Match_swap">swap</a>()</code> for <code><a href="Match.md#0xc0deb00c_Match_BUY">BUY</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap_buy">swap_buy</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, requested_size: u64, max_quote_to_spend: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap_buy">swap_buy</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    requested_size: u64,
    max_quote_to_spend: u64,
) {
    <a href="Match.md#0xc0deb00c_Match_swap">swap</a>&lt;B, Q, E&gt;(user, host, <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>, requested_size, max_quote_to_spend,
        &orders_cap())
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_swap_sell"></a>

## Function `swap_sell`

Wrapped call to <code><a href="Match.md#0xc0deb00c_Match_swap">swap</a>()</code> for <code><a href="Match.md#0xc0deb00c_Match_SELL">SELL</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap_sell">swap_sell</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, requested_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="Match.md#0xc0deb00c_Match_swap_sell">swap_sell</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    requested_size: u64,
) {
    <a href="Match.md#0xc0deb00c_Match_swap">swap</a>&lt;B, Q, E&gt;(user, host, <a href="Match.md#0xc0deb00c_Match_SELL">SELL</a>, requested_size, 0, &orders_cap())
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_fill_market_order"></a>

## Function `fill_market_order`

Fill a market order against the book as much as possible,
returning when there is no liquidity left or when order is
completely filled


<a name="@Parameters_6"></a>

### Parameters

* <code>host</code> Host of corresponding order book
* <code>addr</code>: Address of user placing market order
* <code>side</code>: <code><a href="Match.md#0xc0deb00c_Match_ASK">ASK</a></code> or <code><a href="Match.md#0xc0deb00c_Match_BID">BID</a></code>, denoting the side on the order book
which should be filled against. If <code><a href="Match.md#0xc0deb00c_Match_ASK">ASK</a></code>, user is submitting
a market buy, if <code><a href="Match.md#0xc0deb00c_Match_BID">BID</a></code>, user is submitting a market sell
* <code>requested_size</code>: Base coin parcels to be filled
* <code>quote_available</code>: Quote coin parcels available for filling if
filling against asks
* <code>book_cap</code>: Immutable reference to <code>Econia::Book:FriendCap</code>


<a name="@Terminology_7"></a>

### Terminology

* "Incoming order" is the market order being matched against
the order book
* "Target position" is the position on the book for each stage
of iterated traversal


<a name="@Returns_8"></a>

### Returns

* <code>u64</code>: Amount of base coin subunits filled
* <code>u64</code>: Amount of quote coin subunits filled


<a name="@Assumptions_9"></a>

### Assumptions

* Order book has been properly initialized at host address
* <code>size</code> is nonzero


<pre><code><b>fun</b> <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(host: <b>address</b>, addr: <b>address</b>, side: bool, requested_size: u64, quote_available: u64, book_cap: &<a href="Book.md#0xc0deb00c_Book_FriendCap">Book::FriendCap</a>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(
    host: <b>address</b>,
    addr: <b>address</b>,
    side: bool,
    requested_size: u64,
    quote_available: u64,
    book_cap: &BookCap
): (
    u64,
    u64,
) {
    // Get number of positions on corresponding order book side
    <b>let</b> n_positions = <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>) n_asks&lt;B, Q, E&gt;(host, book_cap)
        <b>else</b> n_bids&lt;B, Q, E&gt;(host, book_cap);
    // Return no fills <b>if</b> no positions on book
    <b>if</b> (n_positions == 0) <b>return</b> (0, 0);
    // Get scale factor of corresponding order book
    <b>let</b> scale_factor = scale_factor&lt;B, Q, E&gt;(host, book_cap);
    // Initialize counters for base <a href="">coin</a> parcels and quote <a href="">coin</a>
    // subunits filled
    <b>let</b> (base_parcels_filled, quote_coins_filled) = (0, 0);
    // Initialize traversal, storing <a href="ID.md#0xc0deb00c_ID">ID</a> of target position, <b>address</b>
    // of user holding it, the parent field of corresponding tree
    // node, child index of corresponding node, amount filled, <b>if</b> an
    // exact match between incoming order and target position, and
    // <b>if</b> the incoming order <b>has</b> insufficient quote coins in case of
    // an ask
    <b>let</b> (target_id, target_addr, target_p_f, target_c_i, filled, exact,
         insufficient_quote) =
        traverse_init_fill&lt;B, Q, E&gt;(
            host, addr, side, requested_size, quote_available, book_cap);
    <b>loop</b> { // Begin traversal <b>loop</b>
        // Update counter for number of base parcels filled
        base_parcels_filled = base_parcels_filled + filled;
        // Calculate number of quote coins just filled
        <b>let</b> quote_coins_just_filled = id_p(target_id) * filled;
        // Update counter for number of quote coins filled
        quote_coins_filled = quote_coins_filled + quote_coins_just_filled;
        // If filling against asks, <b>update</b> counter for quote coins
        // still available for filling
        <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>) quote_available =
            quote_available - quote_coins_just_filled;
        // Decrement requested size left <b>to</b> match
        requested_size = requested_size - filled;
        // Determine <b>if</b> target position completely filled
        <b>let</b> complete = ((exact || requested_size &gt; 0) &&
                        !insufficient_quote);
        // Route funds between counterparties, <b>update</b> open orders
        process_fill&lt;B, Q, E&gt;(target_addr, addr, side, target_id, filled,
                              scale_factor, complete);
        // If incoming order unfilled and can traverse
        <b>if</b> (requested_size &gt; 0 && n_positions &gt; 1 && !insufficient_quote) {
            // Traverse pop fill <b>to</b> next position
            (target_id, target_addr, target_p_f, target_c_i, filled, exact,
                insufficient_quote)
                = traverse_pop_fill&lt;B, Q, E&gt;(
                    host, addr, side, requested_size, quote_available,
                    n_positions, target_id, target_p_f, target_c_i,
                    book_cap);
            // Decrement count of positions on book for given side
            n_positions = n_positions - 1;
        } <b>else</b> { // If should not <b>continue</b> iterated traverse fill
            // Determine <b>if</b> a partial target fill was made
            <b>let</b> partial_target_fill =
                (requested_size == 0 && !exact) || insufficient_quote;
            // If anything other than a partial target fill made
            <b>if</b> (!partial_target_fill) {
                // Cancel target position
                cancel_position&lt;B, Q, E&gt;(host, side, target_id, book_cap);
            };
            // Refresh the max bid/<b>min</b> ask <a href="ID.md#0xc0deb00c_ID">ID</a> for the order book
            refresh_extreme_order_id&lt;B, Q, E&gt;(host, side, book_cap);
            <b>break</b> // Break out of iterated traversal <b>loop</b>
        };
    };
    // Return base <a href="">coin</a> subunits and quote <a href="">coin</a> subunits filled
    (base_parcels_filled * scale_factor, quote_coins_filled)
}
</code></pre>



</details>

<a name="0xc0deb00c_Match_submit_market_order"></a>

## Function `submit_market_order`

Submit market order for market <code>&lt;B, Q, E&gt;</code>, filling as much
as possible against the book


<a name="@Parameters_10"></a>

### Parameters

* <code>user</code>: User submitting a limit order
* <code>host</code>: The market host (See <code>Econia::Registry</code>)
* <code>side</code>: <code><a href="Match.md#0xc0deb00c_Match_ASK">ASK</a></code> or <code><a href="Match.md#0xc0deb00c_Match_BID">BID</a></code>
* <code>requested_size</code>: Requested number of base coin parcels to be
* <code>max_quote_to_spend</code>: Maximum number of quote coins that can
be spent in the case of a market buy (unused in case of a
market sell)


<a name="@Abort_conditions_11"></a>

### Abort conditions

* If no such market exists at host address
* If user does not have order collateral container for market
* If user does not have enough collateral
* If <code>requested_size</code> is 0


<a name="@Assumptions_12"></a>

### Assumptions

* <code>requested_size</code> is nonzero


<pre><code><b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>&lt;B, Q, E&gt;(user: &<a href="">signer</a>, host: <b>address</b>, side: bool, requested_size: u64, max_quote_to_spend: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Match.md#0xc0deb00c_Match_submit_market_order">submit_market_order</a>&lt;B, Q, E&gt;(
    user: &<a href="">signer</a>,
    host: <b>address</b>,
    side: bool,
    requested_size: u64,
    max_quote_to_spend: u64
) {
    // Assert order <b>has</b> actual size
    <b>assert</b>!(requested_size &gt; 0, <a href="Match.md#0xc0deb00c_Match_E_SIZE_0">E_SIZE_0</a>);
    // If a market buy, <b>assert</b> willing <b>to</b> spend quote coins
    <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>) <b>assert</b>!(max_quote_to_spend &gt; 0, <a href="Match.md#0xc0deb00c_Match_E_QUOTE_SPEND_0">E_QUOTE_SPEND_0</a>);
    // Get book-side and open-orders side capabilities
    <b>let</b> (book_cap, orders_cap) = (book_cap(), orders_cap());
    // Assert market <b>exists</b> at given host <b>address</b>
    <b>assert</b>!(exists_book&lt;B, Q, E&gt;(host, &book_cap), <a href="Match.md#0xc0deb00c_Match_E_NO_MARKET">E_NO_MARKET</a>);
    <b>let</b> user_address = address_of(user); // Get user <b>address</b>
    // Assert user <b>has</b> order collateral container
    <b>assert</b>!(exists_o_c&lt;B, Q, E&gt;(user_address, &orders_cap), <a href="Match.md#0xc0deb00c_Match_E_NO_O_C">E_NO_O_C</a>);
    // Get available collateral for user on given market
    <b>let</b> (base_available, quote_available) =
        get_available_collateral&lt;B, Q, E&gt;(user_address, &orders_cap);
    // If submitting a market buy (<b>if</b> filling against ask positions
    // on the order book)
    <b>if</b> (side == <a href="Match.md#0xc0deb00c_Match_BUY">BUY</a>) {
        // Assert user <b>has</b> enough quote coins <b>to</b> spend
        <b>assert</b>!(quote_available &gt;= max_quote_to_spend,
            <a href="Match.md#0xc0deb00c_Match_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
        // Fill a market order through the matching engine, storing
        // number of quote coins spent
        <b>let</b> (_, quote_coins_spent) = <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(
            host, user_address, <a href="Match.md#0xc0deb00c_Match_ASK">ASK</a>, requested_size, max_quote_to_spend,
            &book_cap());
        // Update count of available quote coins
        dec_available_collateral&lt;B, Q, E&gt;(
            user_address, 0, quote_coins_spent, &orders_cap);
    } <b>else</b> { // If submitting a market sell (filling against bids)
        // Get number of base coins required <b>to</b> execute market sell
        <b>let</b> base_coins_required = requested_size *
            orders_scale_factor&lt;B, Q, E&gt;(user_address, &orders_cap());
        // Assert user <b>has</b> enough available base coins <b>to</b> sell
        <b>assert</b>!(base_available &gt;= base_coins_required,
            <a href="Match.md#0xc0deb00c_Match_E_NOT_ENOUGH_COLLATERAL">E_NOT_ENOUGH_COLLATERAL</a>);
        // Fill a market order through the matching engine, storing
        // number of base <a href="">coin</a> subunits sold
        <b>let</b> (base_coins_sold, _) = <a href="Match.md#0xc0deb00c_Match_fill_market_order">fill_market_order</a>&lt;B, Q, E&gt;(
            host, user_address, <a href="Match.md#0xc0deb00c_Match_BID">BID</a>, requested_size, 0, &book_cap());
        // Update count of available base coins
        dec_available_collateral&lt;B, Q, E&gt;(
            user_address, base_coins_sold, 0, &orders_cap);
    }
}
</code></pre>



</details>
