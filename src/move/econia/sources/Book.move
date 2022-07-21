/// # Test oriented implementation
///
/// The present module is implemented purely in Move, to enable coverage
/// testing as described in `Econia::Caps`. Hence the use of `FriendCap`
/// in public functions.
///
/// # Order structure
///
/// For a market specified by `<B, Q, E>` (see `Econia::Registry`), an
/// order book is stored in an `OB`, which has a `Econia::CritBit::CB`
/// for both asks and bids. In each tree, key-value pairs have a key
/// formatted per `Econia::ID`, and a value `P`, which indicates the
/// user holding the corresponding position in the order book, as well
/// as the scaled size (see `Econia::Orders`) of the position remaining
/// to be filled.
///
/// ## Order placement
///
/// ---
///
module Econia::Book {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::CritBit::{
        CB,
        empty as cb_e,
        insert,
        is_empty,
        length as length,
        max_key,
        min_key,
        pop,
        traverse_init_mut,
        traverse_mut,
        traverse_pop_mut
    };

    use Econia::ID::{
        price as id_price,
    };

    use std::signer::{
        address_of
    };

    use std::vector::{
        borrow as vector_borrow,
        empty as empty_vector,
        length as vector_length,
        push_back as vector_push_back
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::CritBit::{
        borrow as cb_b,
        has_key as cb_h_k
    };

    #[test_only]
    use Econia::ID::{
        id_a,
        id_b
    };

    #[test_only]
    use std::vector::{
        is_empty as vector_is_empty,
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Friend-like capability, administered instead of declaring as a
    /// friend a module containing Aptos native functions, which would
    /// inhibit coverage testing via the Move CLI. See `Econia::Caps`
    struct FriendCap has copy, drop, store {}

    /// Order book with base coin type `B`, quote coin type `Q`, and
    /// scale exponent type `E`
    struct OB<phantom B, phantom Q, phantom E> has key {
        /// Scale factor
        f: u64,
        /// Asks
        a: CB<P>,
        /// Bids
        b: CB<P>,
        /// Order ID (see `Econia::ID`) of minimum ask
        m_a: u128,
        /// Order ID (see `Econia::ID`) of maximum bid
        m_b: u128
    }

    /// Position in an order book
    struct P has store {
        /// Scaled size (see `Econia::Orders`) of position to be filled,
        /// in base coin parcels
        s: u64,
        /// Address holding position
        a: address
    }

    /// Anonymized position, used only for SDK-generative functions like
    /// `get_orders()`
    struct Order has drop {
        /// Price from position's order ID
        price: u64,
        /// Number of base coin parcels in order
        size: u64,
    }

    /// Price level, used only for SDK-generative functions like
    /// `get_price_levels()`
    struct PriceLevel has drop {
        /// Price from position order IDs
        price: u64,
        /// Net position size for given price, in base coin parcels
        size: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base coin type
    struct BT{}

    #[test_only]
    /// Scale exponent type
    struct ET{}

    #[test_only]
    /// Quote coin type
    struct QT{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When order book already exists at given address
    const E_BOOK_EXISTS: u64 = 0;
    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 1;
    /// When both sides of a trade have same address
    const E_SELF_MATCH: u64 = 2;
    /// When book does not exist at given address
    const E_NO_BOOK: u64 = 3;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// `u128` bitmask with all bits set
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Left direction, denoting predecessor traversal
    const L: bool = true;
    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Right direction, denoting successor traversal
    const R: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Wrapped `add_position()` call for `ASK`, requiring `FriendCap`
    public fun add_ask<B, Q, E>(
        host: address,
        user: address,
        id: u128,
        price: u64,
        size: u64,
        _c: &FriendCap
    ): bool
    acquires OB {
        add_position<B, Q, E>(host, user, ASK, id, price, size)
    }

    /// Wrapped `add_position()` call for `BID`, requiring `FriendCap`
    public fun add_bid<B, Q, E>(
        host: address,
        user: address,
        id: u128,
        price: u64,
        size: u64,
        _c: &FriendCap
    ): bool
    acquires OB {
        add_position<B, Q, E>(host, user, BID, id, price, size)
    }

    /// Wrapped `cancel_position()` call for `ASK`
    public fun cancel_ask<B, Q, E>(
        host: address,
        id: u128,
        friend_cap: &FriendCap
    ) acquires OB {
        cancel_position<B, Q, E>(host, ASK, id, friend_cap);
    }

    /// Wrapped `cancel_position()` call for `BID`
    public fun cancel_bid<B, Q, E>(
        host: address,
        id: u128,
        friend_cap: &FriendCap
    ) acquires OB {
        cancel_position<B, Q, E>(host, BID, id, friend_cap);
    }

    /// Cancel position on book for market `<B, Q, E>`, skipping
    /// redundant error checks already covered by calling functions
    ///
    /// # Parameters
    /// * `host`: Address of market host
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    /// * `_c`: Immutable reference to `FriendCap`
    ///
    /// # Assumes
    /// * `OB` for given market exists at host address
    /// * Position has already been placed on book properly, by
    ///   preceding functions that perform their own error-checking
    public fun cancel_position<B, Q, E>(
        host: address,
        side: bool,
        id: u128,
        _c: &FriendCap
    ) acquires OB {
        // Borrow mutable reference to order book at host address
        let o_b = borrow_global_mut<OB<B, Q, E>>(host);
        if (side == ASK) { // If order is an ask
            let asks = &mut o_b.a; // Get mutable reference to asks tree
            P{s: _, a: _} = pop<P>(asks, id); // Pop/unpack position
            if (o_b.m_a == id) { // If cancelled order was the min ask
                // If asks tree now empty, set min ask ID to default
                o_b.m_a = if (is_empty<P>(asks)) MIN_ASK_DEFAULT else
                    min_key<P>(asks); // Otherwise set to new min ask ID
            };
        } else { // If order is a bid
            let bids = &mut o_b.b; // Get mutable reference to bids tree
            P{s: _, a: _} = pop<P>(bids, id); // Pop/unpack position
            if (o_b.m_b == id) { // If cancelled order was the max bid
                // If bid tree now empty, set max bid ID to default
                o_b.m_b = if (is_empty<P>(bids)) MAX_BID_DEFAULT else
                    max_key<P>(bids); // Otherwise set to new max bid ID
            };
        }
    }

    /// Return `true` if specified order book type exists at address
    public fun exists_book<B, Q, E>(
        a: address,
        _c: &FriendCap
    ): bool {
        exists<OB<B, Q, E>>(a)
    }

    /// Return a `FriendCap`, aborting if not called by Econia account
    public fun get_friend_cap(
        account: &signer
    ): FriendCap {
        // Assert called by Econia
        assert!(address_of(account) == @Econia, E_NOT_ECONIA);
        FriendCap{} // Return requested capability
    }

    /// Initialize order book under host account, provided `FriendCap`,
    /// for market `<B, Q, E>` and corresponding scale factor `f`
    public fun init_book<B, Q, E>(
        host: &signer,
        f: u64,
        _c: &FriendCap
    ) {
        // Assert book does not already exist under host account
        assert!(!exists_book<B, Q, E>(address_of(host), &FriendCap{}),
            E_BOOK_EXISTS);
        let m_a = MIN_ASK_DEFAULT; // Declare min ask default order ID
        let m_b = MAX_BID_DEFAULT; // Declare max bid default order ID
        let o_b = // Pack empty order book
            OB<B, Q, E>{f, a: cb_e<P>(), b: cb_e<P>(), m_a, m_b};
        move_to<OB<B, Q, E>>(host, o_b); // Move to host
    }

    /// Return number of asks on order book, assuming order book exists
    /// at host address
    public fun n_asks<B, Q, E>(
        addr: address,
        _c: &FriendCap
    ): u64
    acquires OB {
        // Return length of asks tree
        length<P>(&borrow_global<OB<B, Q, E>>(addr).a)
    }

    /// Return number of bids on order book, assuming order book exists
    /// at host address
    public fun n_bids<B, Q, E>(
        addr: address,
        _c: &FriendCap
    ): u64
    acquires OB {
        // Return length of bids tree
        length<P>(&borrow_global<OB<B, Q, E>>(addr).b)
    }

    /// If `side` is `ASK`, refresh the minimum ask ID to that of the
    /// minimum ask in the asks tree in `OB` at `addr`, and if `side`,
    /// is `BID`, the maximum bid ID, assuming `OB` already exists at
    /// `addr`. If no positions, use default values.
    public fun refresh_extreme_order_id<B, Q, E>(
        addr: address,
        side: bool,
        _c: &FriendCap
    ) acquires OB {
        // Borrow mutable reference to order book at address
        let order_book = borrow_global_mut<OB<B, Q, E>>(addr);
        if (side == ASK) { // If refreshing for asks
            // Set min ask ID to default value if empty tree
            order_book.m_a = if (is_empty(&order_book.a)) MIN_ASK_DEFAULT else
                min_key(&order_book.a); // Otherwise set to min ask ID
        } else { // If refreshing for bids
            // Set max bid ID to default value if empty tree
            order_book.m_b = if (is_empty(&order_book.b)) MAX_BID_DEFAULT else
                max_key(&order_book.b); // Otherwise set to max ask ID
        }
    }

    /// Return scale factor of specified order book, assuming order
    /// book exists at host address
    public fun scale_factor<B, Q, E>(
        addr: address,
        _c: &FriendCap
    ): u64
    acquires OB {
        borrow_global<OB<B, Q, E>>(addr).f // Return book's scale factor
    }

    /// Wrapped call to `traverse_fill()` for `init` parameter `true`,
    /// requiring `FriendCap`.
    public fun traverse_init_fill<B, Q, E>(
        host: address,
        incoming_address: address,
        side: bool,
        size_left: u64,
        quote_available: u64,
        _c: &FriendCap
    ): (
        u128,
        address,
        u64,
        u64,
        u64,
        bool,
        bool
    ) acquires OB {
        traverse_fill<B, Q, E>(host, incoming_address, side, size_left,
            quote_available, true, 0, 0, 0, 0)
    }

    /// Wrapped call to `traverse_fill()` for `init` parameter `false`,
    /// requiring `FriendCap`.
    public fun traverse_pop_fill<B, Q, E>(
        host: address,
        incoming_address: address,
        side: bool,
        size_left: u64,
        quote_available: u64,
        n_positions: u64,
        start_id: u128,
        start_parent_field: u64,
        start_child_index: u64,
        _c: &FriendCap,
    ): (
        u128,
        address,
        u64,
        u64,
        u64,
        bool,
        bool
    ) acquires OB {
        traverse_fill<B, Q, E>(host, incoming_address, side, size_left,
            quote_available, false, n_positions, start_id, start_parent_field,
            start_child_index)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Add new position to book for market `<B, Q, E>`, as long as
    /// order does not cross the spread, skipping redundant error checks
    /// already covered by calling functions
    ///
    /// # Parameters
    /// * `host`: Address of market host
    /// * `user`: Address of user submitting position
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    /// * `price`: Scaled integer price (see `Econia::ID`)
    /// * `size`: Scaled order size (see `Econia::Orders`)
    ///
    /// # Returns
    /// * `true` if the new position crosses the spread, `false`
    ///   otherwise
    ///
    /// # Assumes
    /// * Correspondent order has already passed validation checks per
    ///   `Econia::Orders::add_order()`
    /// * `OB` for given market exists at host address
    ///
    /// # Spread terminology
    /// * An order that "encroaches" on the spread may either lie
    ///   "within" the spread, or may "cross" the spread. For example,
    ///   if the max bid price is 10 and the min ask price is 15, a bid
    ///   price of 11 is within the spread, a bid price of 16 crosses
    ///   the spread, and both such orders encroach on the spread. A bid
    ///   price of 9, however, does not encroach on the spread
    fun add_position<B, Q, E>(
        host: address,
        user: address,
        side: bool,
        id: u128,
        price: u64,
        size: u64
    ): bool
    acquires OB {
        // Borrow mutable reference to order book at host address
        let o_b = borrow_global_mut<OB<B, Q, E>>(host);
        // Get minimum ask price and maximum bid price on book
        let (m_a_p, m_b_p) = (id_price(o_b.m_a), id_price(o_b.m_b));
        if (side == ASK) { // If order is an ask
            if (price > m_b_p) { // If order does not cross spread
                // Add corresponding position to ask tree
                insert(&mut o_b.a, id, P{s: size, a: user});
                // If order is within spread, update min ask id
                if (price < m_a_p) o_b.m_a = id;
            } else return true; // Otherwise indicate crossed spread
        } else { // If order is a bid
            if (price < m_a_p) { // If order does not cross spread
                // Add corresponding position to bid tree
                insert(&mut o_b.b, id, P{s: size, a: user});
                // If order is within spread, update max bid id
                if (price > m_b_p) o_b.m_b = id;
            // Otherwise manage order that crosses spread
            } else return true; // Otherwise indicate crossed spread
        }; // Order is on now on book, and did not cross spread
        false // Indicate spread not crossed
    }

    /// Return immediately if `side` is `BID`, otherwise verify that the
    /// user with the incoming order has enough quote coins to fill
    /// against the target ask on the book, either completely or
    /// partially
    ///
    /// # Terminology
    /// * "Incoming order" has `requested_size` base coin parcels to be
    ///  filled
    /// * "Target position" is the corresponding `P` on the book
    ///
    /// # Parameters
    /// * `side`: `ASK` or `BID`
    /// * `target_id`: The target `P`
    /// * `size_left`: Total base coin parcels left to be filled on
    ///   incoming order
    /// * `quote_available`: The number of quote coin subunits that the
    ///   user with the incoming order has available for the trade
    ///
    /// # Returns
    /// * `bool`: `true` if incoming user has insufficient quote coins
    ///   in the case of a filling against an ask, otherwise `false`
    /// * `u64`: `size_left` if `side` is `BID` or if `side` is `ASK`
    ///   and user has enough quote coins available to match against a
    ///   target ask, otherwise the max number of base coin parcels that
    ///   can be filled against the target ask
    fun check_size(
        side: bool,
        target_id: u128,
        target_size: u64,
        size_left: u64,
        quote_available: u64,
    ): (
        bool,
        u64
    ) {
        // Do not flag insufficient quote coins, and confirm filling
        // size left
        if (side == BID) return (false, size_left);
        // Otherwise incoming order fills against a target ask, so
        // calculate number of quote coins required for a complete fill
        let target_price = id_price(target_id); // Get target price
        // Get quote coins required to fill against target ask
        let quote_to_fill =
            // If size left on incoming order greater than or equal to
            // target size, then quote coins needed are for a complete
            // target fill
            if (size_left >= target_size) target_price * target_size else
            // Otherwise quote coins needed for partial target fill
            target_price * size_left;
        // If quote coins needed for fill exceed available quote coins
        if (quote_to_fill > quote_available) return
            // Flag insufficient quote coins, and return max fill size
            // possible
            (true, quote_available / target_price) else
            // Otherwise do not flag insufficient quote coins, and
            // confirm filling size left
            return (false, size_left)
    }

    /// Private indexing function for SDK generation: Return a vector
    /// of `Order` sorted by price-time priority: if `side` is `ASK`,
    /// first element in vector is the oldest ask at the minimum price,
    /// and if `side` is `BID`, first element in vector is the oldest
    /// ask at the maximum price
    fun get_orders<B, Q, E>(
        host_address: address,
        side: bool
    ): vector<Order>
    acquires OB {
        // Assert an order book exists at the given address
        assert!(exists<OB<B, Q, E>>(host_address), E_NO_BOOK);
        // Initialize empty vector of orders
        let orders = empty_vector<Order>();
        let (tree, traversal_dir) = if (side == ASK) // If an ask
            // Define traversal tree as asks tree, successor iteration
            (&mut borrow_global_mut<OB<B, Q, E>>(host_address).a, R) else
            // Otherwise define tree as bids tree, predecessor iteration
            (&mut borrow_global_mut<OB<B, Q, E>>(host_address).b, L);
        // Get number of positions in tree
        let n_positions = length(tree);
        // If no positions in tree, return empty vector of orders
        if (n_positions == 0) return orders;
        // Calculate number of traversals still remaining
        let remaining_traversals = n_positions - 1;
        // Declare target position order ID, mutable reference to
        // target position, target position tree node parent field,
        // target position tree node child field index
        let (target_id, target_position_ref_mut, target_parent_field, _) =
            traverse_init_mut<P>(tree, traversal_dir);
        loop { // Loop over all positions in tree
            let price = id_price(target_id); // Get position price
            let size = target_position_ref_mut.s; // Get position size
            // Push corresponding order onto back of orders vector
            vector_push_back<Order>(&mut orders, Order{price, size});
            // Return orders vector if unable to traverse further
            if (remaining_traversals == 0) return orders;
            // Otherwise traverse to the next position in the tree
            (target_id, target_position_ref_mut, target_parent_field, _) =
                traverse_mut<P>(tree, target_id, target_parent_field,
                    traversal_dir);
            // Decrement number of remaining traversals
            remaining_traversals = remaining_traversals - 1;
        }
    }

    /// Private indexing function for SDK generation: aggregates result
    /// of `get_orders()` into a vector of `PriceLevel`
    fun get_price_levels(
        orders: &vector<Order>
    ): vector<PriceLevel> {
        // Initialize empty vector of price levels
        let price_levels = empty_vector<PriceLevel>();
        // Get number of orders to process
        let n_orders = vector_length<Order>(orders);
        // If no orders, return empty vector of price levels
        if (n_orders == 0) return price_levels;
        // Initialize loop counter, price level price and size
        let (order_index, level_price, level_size) = (0, 0, 0);
        loop { // Loop over all orders
            // Borrow immutable reference to order for current iteration
            let order = vector_borrow<Order>(orders, order_index);
            if (order.price != level_price) { // If on new price level
                if (order_index > 0) { // If not on first order
                    // Store the last price level in vector
                    vector_push_back<PriceLevel>(&mut price_levels,
                        PriceLevel{price: level_price, size: level_size});
                };
                // Start tracking a new price level at given order
                (level_price, level_size) = (order.price, order.size)
            } else { // If order has same price level as last checked
                // Increment size of price level by order size
                level_size = level_size + order.size;
            };
            order_index = order_index + 1; // Increment order index
            // If have looped over all in  0-indexed vector
            if (order_index == n_orders) { // If no more iterations left
                // Store final price level in vector
                vector_push_back<PriceLevel>(&mut price_levels,
                    PriceLevel{price: level_price, size: level_size});
                break // Break out of loop
            };
        }; // Now done looping over orders
        price_levels // Return sorted vector of price levels
    }

    /// Compare incoming order `size` and address `i_addr` against
    /// fields in target position `t_p_r`, returning fill amount and if
    /// incoming size is equal to target size. Abort if both have same
    /// address, and decrement target position size (`P.s`) by `size` if
    /// target position only gets partially filled.
    ///
    /// # Abort conditions
    /// * If `i_addr` (incoming address) is same as target address
    fun process_fill_scenarios(
        i_addr: address,
        t_p_r: &mut P,
        size: u64
    ): (
        u64,
        bool
    ) {
        // Assume not a perfect match between incoming/target size
        let perfect_match = false;
        // Assert incoming address is not same as target address
        assert!(i_addr != t_p_r.a, E_SELF_MATCH);
        let filled: u64; // Declare fill amount
        // If incoming order size is less than target position size
        if (size < t_p_r.s) { // If partial target fill
            filled = size; // Flag complete fill on incoming order
            // Decrement target position size by incoming order size
            t_p_r.s = t_p_r.s - size;
        } else if (size > t_p_r.s) { // If partial incoming fill
            // Flag incoming order filled by amount in target position
            filled = t_p_r.s;
        } else { // If incoming order and target position have same size
            filled = size; // Flag complete fill on incoming order
            perfect_match = true; // Flag equal size for both sides
        };
        (filled, perfect_match) // Return fill amount & if perfect match
    }

    /// Either initialize traversal and fill against order book at
    /// `host` if `init` is `true`, or execute a traversal pop and then
    /// fill if `init` is `false`. If `side` is `ASK`, perform successor
    /// traversal starting at the ask with the minimum order ID, and if
    /// `side` is `BID`, perform predecessor traversal starting at the
    /// bid with the maximum order ID. Decrement target position by
    /// `size` if matching results in a partial fill against it, leave
    /// it unmodified if matching results in an exact fill on both sides
    /// of the trade, and leave it unmodified if matching only results
    /// in a partial fill against the incoming order (in both of the
    /// latter cases so that the target position may be popped later).
    /// If `side` is `ASK`, check the fill size per `check_size()`,
    /// reducing it as needed based on available incoming quote coins.
    ///
    /// # Terminology
    /// * "Incoming order" has `size_left` base coin parcels to be
    ///   filled
    /// * "Target position" is the first `P` on the book to fill against
    ///   if `init` is `true`, and next position on the book to fill
    ///   against if `init` is `false`
    ///   against
    /// * "Start position" is the position to traverse from if `init`
    ///   is `false`
    ///
    /// # Parameters
    /// * `host`: Host of `OB`
    /// * `incoming_address`: Address of incoming order to match against
    /// * `side`: `ASK` or `BID`
    /// * `size_left`: Total base coin parcels left to be filled on
    ///   incoming order
    /// * `quote_available`: Quote coin parcels available for filling if
    ///   filling against asks
    /// * `init`: If `true`, ignore remaining parameters and initialize
    ///   traversal before filling. If `false`, use remaining parameters
    ///   to traverse from start node to target node then pop start node
    ///   before filling
    /// * `n_position`: Number of positions in `OB` for corresponding
    ///   `side`
    /// * `start_id`: Order ID of start position. If `side` is `ASK`,
    ///   cannot be maximum ask in order book, and if `side` is `BID`,
    ///   cannot be minimum bid in order book (since no traversal is
    ///   possible for these cases).
    /// * `start_parent_field`: Start position tree node parent field
    /// * `start_child_index`: Child field index of start position tree
    ///   node
    ///
    /// # Returns
    /// * `u128`: Target position order ID
    /// * `address`: User address holding target position (`P.a`)
    /// * `u64`: Parent field of node corresponding to target position
    /// * `u64`: Child field index of node corresponding to target
    ///   position
    /// * `u64`: Amount filled, in base coin parcels
    /// * `bool`: `true` if an exact match between incoming order and
    ///   target position size
    /// * `bool`: `true` if `quote_available` was insufficient for
    ///   completely filling the target position in the case of an ask
    ///
    /// # Considerations
    /// * Publicly exposes internal tree node indices per canonical
    ///   traversal paradigm described at `Econia::CritBit`
    ///
    /// # Assumes
    /// * Order book has been properly initialized at host address and
    ///   has at least one position in corresponding tree in case of
    ///   `init` true
    /// * Caller has tracked `n_positions` correctly if `init` is
    ///   `false`
    fun traverse_fill<B, Q, E>(
        host: address,
        incoming_address: address,
        side: bool,
        size_left: u64,
        quote_available: u64,
        init: bool,
        n_positions: u64,
        start_id: u128,
        start_parent_field: u64,
        start_child_index: u64,
    ): (
        u128,
        address,
        u64,
        u64,
        u64,
        bool,
        bool
    ) acquires OB {
        let (tree, traversal_dir) = if (side == ASK) // If an ask
            // Define traversal tree as asks tree, successor iteration
            (&mut borrow_global_mut<OB<B, Q, E>>(host).a, R) else
            // Otherwise define tree as bids tree, predecessor iteration
            (&mut borrow_global_mut<OB<B, Q, E>>(host).b, L);
        // Declare target position order ID, mutable reference to
        // target position, target position tree node parent field,
        // target position tree node child field index
        let (target_id, target_position_ref_mut, target_parent_field,
             target_child_index): (u128, &mut P, u64, u64);
        if (init) { // If initializing traversal
            // Store relevant values from tree traversal initialization
            (target_id, target_position_ref_mut, target_parent_field,
                target_child_index) = traverse_init_mut(tree, traversal_dir);
        } else { // If continuing traversal
            // Store from iterated tree traversal popping, unpacking
            // start position struct
            (target_id, target_position_ref_mut, target_parent_field,
                target_child_index, P{s: _, a: _}) = traverse_pop_mut(
                    tree, start_id, start_parent_field, start_child_index,
                    n_positions, traversal_dir);
        };
        // Store target position user address
        let target_address = target_position_ref_mut.a;
        // Flag if insufficient quote coins in case of ask, check size
        // left to be filled
        let (insufficient_quote, size) = check_size(side, target_id,
            target_position_ref_mut.s, size_left, quote_available);
        // Process fill scenarios, storing amount filled and if perfect
        // match between incoming and target order
        let (filled, perfect) = process_fill_scenarios(
            incoming_address, target_position_ref_mut, size);
        // Return target position ID, target position user address,
        // corresponding node's parent field, corresponding node's child
        // field index, the number of base coin parcels filled, and if
        // insufficient quote coins in the case of target ask position
        (target_id, target_address, target_parent_field, target_child_index,
         filled, perfect, insufficient_quote)
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return `P` fields for ask with specified ID, for specified market
    public fun check_ask<B, Q, E>(
        host: address,
        id: u128,
    ): (
        u64,
        address
    ) acquires OB {
        // Borrow immutable reference to order book at host account
        let o_b = borrow_global<OB<B, Q, E>>(host);
        // Borrow immutable reference to ask with given id
        let ask = cb_b<P>(&o_b.a, id);
        (ask.s, ask.a) // Return size and address of position
    }

    #[test_only]
    /// Return order ID of ask having minimum price
    public fun check_ask_min<B, Q, E>(
        host: address
    ): u128
    acquires OB {
        borrow_global<OB<B, Q, E>>(host).m_a
    }

    #[test_only]
    /// Return `P` fields for bid with specified ID, on specified market
    public fun check_bid<B, Q, E>(
        host: address,
        id: u128,
    ): (
        u64,
        address
    ) acquires OB {
        // Borrow immutable reference to order book at host account
        let o_b = borrow_global<OB<B, Q, E>>(host);
        // Borrow immutable reference to bid with given id
        let bid = cb_b<P>(&o_b.b, id);
        (bid.s, bid.a) // Return size and address of position
    }

    #[test_only]
    /// Return order ID of bid having maximum price
    public fun check_bid_max<B, Q, E>(
        host: address
    ): u128
    acquires OB {
        borrow_global<OB<B, Q, E>>(host).m_b
    }

    #[test_only]
    /// If `side` is ASK, return minimum ask order ID on book, else the
    /// maximum bid order ID on the book
    public fun check_extreme_order_id<B, Q, E>(
        host: address,
        side: bool
    ): u128
    acquires OB {
        if (side == ASK) check_ask_min<B, Q, E>(host) else
            check_bid_max<B, Q, E>(host)
    }

    #[test_only]
    /// Return `P` fields for position with specified ID, on specified
    /// market and side
    public fun check_position<B, Q, E>(
        host: address,
        side: bool,
        id: u128,
    ): (
        u64,
        address
    ) acquires OB {
        if (side == ASK) check_ask<B, Q, E>(host, id) else
            check_bid<B, Q, E>(host, id)
    }

    #[test_only]
    /// Return `true` if order book has an ask with the given ID
    public fun has_ask<B, Q, E>(
        host: address,
        id: u128
    ): bool
    acquires OB {
        cb_h_k<P>(&borrow_global<OB<B, Q, E>>(host).a, id)
    }

    #[test_only]
    /// Return `true` if order book has a bid with the given ID
    public fun has_bid<B, Q, E>(
        host: address,
        id: u128
    ): bool
    acquires OB {
        cb_h_k<P>(&borrow_global<OB<B, Q, E>>(host).b, id)
    }

    #[test_only]
    /// Return `true` if extant order book at `host` has position with
    /// given `id` on corresponding `side`
    public fun has_position<B, Q, E>(
        host: address,
        side: bool,
        id: u128
    ): bool
    acquires OB {
        if (side == ASK) has_ask<B, Q, E>(host, id) else
            has_bid<B, Q, E>(host, id)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @TestUser)]
    /// Verify return when placing an ask that crosses the spread
    fun add_position_success_crossed_spread_ask(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define ask with price 8, version number 1, size 1
        let (price, version, size) = (8, 1, 1);
        let id = id_a(price, version); // Get corresponding order id
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Define new bid with price 2, version number 2, size 1
        let (price, version, size) = (2, 2, 1);
        let id = id_b(price, version); // Get corresponding order id
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Define ask with price 1, version number 3, size 1
        let (price, version, size) = (1, 3, 1);
        let id = id_a(price, version); // Get corresponding order id
        // Add position to book an ask that crosses the spread
        let crossed =
            add_ask<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        assert!(crossed, 0); // Assert indication of crossed spread
    }

    #[test(account = @TestUser)]
    /// Verify return when placing a bid that crosses the spread
    fun add_position_success_crossed_spread_bid(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define ask with price 8, version number 1, size 1
        let (price, version, size) = (8, 1, 1);
        let id = id_a(price, version); // Get corresponding order id
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Define new bid with price 2, version number 2, size 1
        let (price, version, size) = (2, 2, 1);
        let id = id_b(price, version); // Get corresponding order id
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Define bid with price 9, version number 3, size 1
        let (price, version, size) = (9, 3, 1);
        let id = id_b(price, version); // Get corresponding order id
        // Add position to book a bid that crosses the spread
        let crossed =
            add_bid<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        assert!(crossed, 0); // Assert indication of crossed spread
    }

    #[test(account = @TestUser)]
    /// Verify positions correctly added for first ask on book, then for
    /// another ask that does not encroach on the spread
    fun add_position_success_simple_ask(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define ask with price 8, version number 1, size 1
        let (price, version, size) = (8, 1, 1);
        let id = id_a(price, version); // Get corresponding order id
        let crossed = // Add position to book, store crossed spread flag
            add_position<BT, QT, ET>(addr, addr, ASK, id, price, size);
        // Borrow immutable reference to order book
        assert!(!crossed, 0); // Assert no indication of crossed spread
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        assert!(o_b.m_a == id, 1); // Assert minimum ask id updates
        // Borrow immutable reference to new position on book
        let p = cb_b<P>(&o_b.a, id);
        // Assert position size and address stored correctly
        assert!(p.s == size && p.a == addr, 2);
        let m_a = id; // Store minimum ask id
        // Define new ask with price 9, version number 2, size 1
        let (price, version, size) = (9, 2, 1);
        let id = id_a(price, version); // Get corresponding order id
        let crossed = // Add position to book, store crossed spread flag
            add_position<BT, QT, ET>(addr, addr, ASK, id, price, size);
        assert!(!crossed, 3); // Assert no indication of crossed spread
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        assert!(o_b.m_a == m_a, 4); // Assert minimum ask id unchanged
        // Borrow immutable reference to new position on book
        let p = cb_b<P>(&o_b.a, id);
        // Assert position size and address stored correctly
        assert!(p.s == size && p.a == addr, 5);
    }

    #[test(account = @TestUser)]
    /// Verify positions correctly added for first bid on book, then for
    /// another bid that does not encroach on the spread
    fun add_position_success_simple_bid(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define bid with price 3, version number 1, size 1
        let (price, version, size) = (3, 1, 1);
        let id = id_b(price, version); // Get corresponding order id
        let crossed = // Add position to book, store crossed spread flag
            add_position<BT, QT, ET>(addr, addr, BID, id, price, size);
        assert!(!crossed, 0); // Assert no indication of crossed spread
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        assert!(o_b.m_b == id, 1); // Assert maximum bid id updates
        // Borrow immutable reference to new position on book
        let p = cb_b<P>(&o_b.b, id);
        // Assert position size and address stored correctly
        assert!(p.s == size && p.a == addr, 2);
        let m_b = id; // Store maximum bid id
        // Define new bid with price 2, version number 2, size 1
        let (price, version, size) = (2, 2, 1);
        let id = id_b(price, version); // Get corresponding order id
        let crossed = // Add position to book, store crossed spread flag
            add_position<BT, QT, ET>(addr, addr, BID, id, price, size);
        assert!(!crossed, 3); // Assert no indication of crossed spread
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        assert!(o_b.m_b == m_b, 4); // Assert maximum bid id unchanged
        // Borrow immutable reference to new position on book
        let p = cb_b<P>(&o_b.b, id);
        // Assert position size and address stored correctly
        assert!(p.s == size && p.a == addr, 5);
    }

    #[test(account = @TestUser)]
    /// Verify successful order cancellation and min ask ID updates
    fun cancel_ask_success(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define ask with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_a(p_1, v_1); // Get corresponding order ID
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id_1, p_1, s_1, &FriendCap{});
        // Define ask with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_a(p_2, v_2); // Get corresponding order ID
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id_2, p_2, s_2, &FriendCap{});
        // Define ask with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_a(p_3, v_3); // Get corresponding order ID
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id_3, p_3, s_3, &FriendCap{});
        // Cancel order having minimum ask ID
        cancel_ask<BT, QT, ET>(addr, id_1, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in asks tree, and correct min ask ID
        assert!(!cb_h_k<P>(&o_b.a, id_1) && o_b.m_a == id_2, 0);
        // Cancel order not having minimum ask ID
        cancel_ask<BT, QT, ET>(addr, id_3, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in asks tree, and correct min ask ID
        assert!(!cb_h_k<P>(&o_b.a, id_3) && o_b.m_a == id_2, 1);
        // Cancel only ask on book
        cancel_ask<BT, QT, ET>(addr, id_2, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in asks tree, and correct min ask ID
        assert!(!cb_h_k<P>(&o_b.a, id_2) && o_b.m_a == MIN_ASK_DEFAULT, 2);
    }

    #[test(account = @TestUser)]
    /// Verify successful order cancellation and max bid ID updates
    fun cancel_bid_success(
        account: &signer,
    ) acquires OB {
        let addr = address_of(account); // Get account address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(account, 1, &FriendCap{});
        // Define bid with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_b(p_1, v_1); // Get corresponding order ID
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id_1, p_1, s_1, &FriendCap{});
        // Define bid with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_b(p_2, v_2); // Get corresponding order ID
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id_2, p_2, s_2, &FriendCap{});
        // Define bid with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_b(p_3, v_3); // Get corresponding order ID
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id_3, p_3, s_3, &FriendCap{});
        // Cancel order having maximum bid ID
        cancel_bid<BT, QT, ET>(addr, id_3, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in bids tree, and correct max bid ID
        assert!(!cb_h_k<P>(&o_b.b, id_3) && o_b.m_b == id_2, 0);
        // Cancel order not having maximum bid ID
        cancel_bid<BT, QT, ET>(addr, id_1, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in bids tree, and correct max bid ID
        assert!(!cb_h_k<P>(&o_b.b, id_1) && o_b.m_b == id_2, 1);
        // Cancel only bid on book
        cancel_bid<BT, QT, ET>(addr, id_2, &FriendCap{});
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(addr);
        // Assert order ID not in bids tree, and correct max bid ID
        assert!(!cb_h_k<P>(&o_b.b, id_2) && o_b.m_b == MAX_BID_DEFAULT, 2);
    }

    #[test]
    /// Verify returns for assorted conditions
    fun check_size_success() {
        // Check size for matching against a bid
        let (insufficient_quote, size_left) =
            check_size(BID, 0, 0, 123, 0);
        // Assert returns
        assert!(!insufficient_quote && size_left == 123, 0);
        // Define target ask ID with price 15
        let target_id = id_a(15, 1);
        // Check size for matching against an ask when enough quote
        // coins available for a complete target fill
        (insufficient_quote, size_left) =
            check_size(ASK, target_id, 3, 50, 60);
        // Assert returns
        assert!(!insufficient_quote && size_left == 50, 0);
        // Check size for matching against an ask when enough quote
        // coins available for a partial target fill
        (insufficient_quote, size_left) =
            check_size(ASK, target_id, 3, 2, 30);
        // Assert returns
        assert!(!insufficient_quote && size_left == 2, 0);
        // Check size for matching against an ask when not enough quote
        // coins available for a complete target fill
        (insufficient_quote, size_left) =
            check_size(ASK, target_id, 3, 50, 44);
        // Assert returns
        assert!(insufficient_quote && size_left == 2, 0);
        // Check size for matching against an ask when not enough quote
        // coins available for a partial target fill
        (insufficient_quote, size_left) =
            check_size(ASK, target_id, 3, 2, 29);
        // Assert returns
        assert!(insufficient_quote && size_left == 1, 0);
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for non-Econia account
    fun get_friend_cap_failure(
        account: &signer
    ) {
        // Attempt invalid getter invocation
        get_friend_cap(account);
    }

    #[test(econia = @Econia)]
    /// Verify success for Econia account
    fun get_friend_cap_success(
        econia: &signer
    ) {
        // Unpack result of valid getter invocation
        let FriendCap{} = get_friend_cap(econia);
    }

    #[test(host = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failed re-initialization of order book
    fun init_book_failure_exists(
        host: &signer,
    ) {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Attempt invalid re-initialization
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
    }

    #[test(host = @TestUser)]
    /// Verify successful initialization of order book
    fun init_book_success(
        host: &signer,
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        let host_addr = address_of(host); // Get host address
        // Assert book exists and has correct scale factor
        assert!(scale_factor<BT, QT, ET>(host_addr, &FriendCap{}) == 1, 0);
        // Borrow immutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(host_addr);
        // Assert minimum ask id inits to max possible value, and
        // maximum bid order id inits to 0
        assert!(o_b.m_a == HI_128 && o_b.m_b == 0, 1);
        // Assert bid and ask trees init empty
        assert!(is_empty(&o_b.a) && is_empty(&o_b.b), 2);
    }

    #[test(host = @TestUser)]
    /// Verify successful lookup
    fun n_asks_success(
        host: &signer
    ) acquires OB {
        let addr = address_of(host); // Get host address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Assert 0 asks indicated
        assert!(n_asks<BT, QT, ET>(addr, &FriendCap{}) == 0, 0);
        // Define ask with price 8, version number 1, size 1
        let (price, version, size) = (8, 1, 1);
        let id = id_a(price, version); // Get corresponding order id
        // Add position to book
        add_ask<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Assert 1 ask indicated
        assert!(n_asks<BT, QT, ET>(addr, &FriendCap{}) == 1, 1);
    }

    #[test(host = @TestUser)]
    /// Verify successful lookup
    fun n_bids_success(
        host: &signer
    ) acquires OB {
        let addr = address_of(host); // Get host address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Assert 0 bids indicated
        assert!(n_bids<BT, QT, ET>(addr, &FriendCap{}) == 0, 0);
        // Define bid with price 8, version number 1, size 1
        let (price, version, size) = (8, 1, 1);
        let id = id_b(price, version); // Get corresponding order id
        // Add position to book
        add_bid<BT, QT, ET>(addr, addr, id, price, size, &FriendCap{});
        // Assert 1 bid indicated
        assert!(n_bids<BT, QT, ET>(addr, &FriendCap{}) == 1, 1);
    }

    #[test(host = @TestUser)]
    // Verify successful refresh of min ask/max bid ID
    fun refresh_extreme_order_id_success(
        host: &signer
    ) acquires OB {
        let addr = address_of(host); // Get host address
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Borrow mutable reference to order book
        let book = borrow_global_mut<OB<BT, QT, ET>>(addr);
        // Insert asks with mock order IDs straight to tree
        insert(&mut book.a, 123, P{s: 1, a: @TestUser});
        insert(&mut book.a, 456, P{s: 1, a: @TestUser});
        // Assert min ask default value
        assert!(book.m_a == MIN_ASK_DEFAULT, 0);
        // Refresh min ask ID
        refresh_extreme_order_id<BT, QT, ET>(addr, ASK, &FriendCap{});
        // Borrow mutable reference to order book
        let book = borrow_global_mut<OB<BT, QT, ET>>(addr);
        assert!(book.m_a == 123, 1); // Assert min ask ID update
        // Pop asks straight from tree
        let P{s: _, a:_} = pop(&mut book.a, 123);
        let P{s: _, a:_} = pop(&mut book.a, 456);
        // Refresh min ask ID
        refresh_extreme_order_id<BT, QT, ET>(addr, ASK, &FriendCap{});
        // Borrow mutable reference to order book
        let book = borrow_global_mut<OB<BT, QT, ET>>(addr);
        // Assert min ask default value
        assert!(book.m_a == MIN_ASK_DEFAULT, 2);
        // Insert bids with mock order IDs straight to tree
        insert(&mut book.b, 789, P{s: 1, a: @TestUser});
        insert(&mut book.b, 321, P{s: 1, a: @TestUser});
        // Assert max bid default value
        assert!(book.m_b == MAX_BID_DEFAULT, 3);
        // Refresh max ask ID
        refresh_extreme_order_id<BT, QT, ET>(addr, BID, &FriendCap{});
        // Borrow mutable reference to order book
        let book = borrow_global_mut<OB<BT, QT, ET>>(addr);
        assert!(book.m_b == 789, 4); // Assert max bid ID update
        // Pop bids straight from tree
        let P{s: _, a:_} = pop(&mut book.b, 789);
        let P{s: _, a:_} = pop(&mut book.b, 321);
        // Refresh min ask ID
        refresh_extreme_order_id<BT, QT, ET>(addr, BID, &FriendCap{});
        // Borrow mutable reference to order book
        let book = borrow_global_mut<OB<BT, QT, ET>>(addr);
        // Assert min ask default value
        assert!(book.m_b == MAX_BID_DEFAULT, 5);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    fun test_get_orders_no_book():
    vector<Order>
    acquires OB {
        get_orders<BT, QT, ET>(@Econia, ASK)
    }

    #[test(host = @Econia)]
    /// Verify price level and order indexing functions
    fun test_price_levels(
        host: &signer
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Get orders from empty tree
        let orders = get_orders<BT, QT, ET>(@Econia, ASK);
        // Assert empty orders vector returned
        assert!(vector_is_empty<Order>(&orders), 0);
        // Get price levels from empty orders vector
        let price_levels = get_price_levels(&orders);
        // Assert empty price levels vector returned
        assert!(vector_is_empty<PriceLevel>(&price_levels), 0);
        // Define a series of asks and add them to the book
        let (ask_0_price, ask_0_size) = (10, 10);
        let (ask_1_price, ask_1_size) = (10, 18);
        let (ask_2_price, ask_2_size) = (12, 5);
        let (ask_3_price, ask_3_size) = (14, 3);
        let (ask_4_price, ask_4_size) = (14, 4);
        add_ask<BT, QT, ET>(@Econia, @Econia, id_a(ask_0_price, 0),
            ask_0_price, ask_0_size, &FriendCap{});
        add_ask<BT, QT, ET>(@Econia, @Econia, id_a(ask_1_price, 1),
            ask_1_price, ask_1_size, &FriendCap{});
        add_ask<BT, QT, ET>(@Econia, @Econia, id_a(ask_2_price, 2),
            ask_2_price, ask_2_size, &FriendCap{});
        add_ask<BT, QT, ET>(@Econia, @Econia, id_a(ask_3_price, 3),
            ask_3_price, ask_3_size, &FriendCap{});
        add_ask<BT, QT, ET>(@Econia, @Econia, id_a(ask_4_price, 4),
            ask_4_price, ask_4_size, &FriendCap{});
        // Get vector of orders sorted by price-time priority
        orders = get_orders<BT, QT, ET>(@Econia, ASK);
        // Borrow all orders in vector and verify price, size
        let order = vector_borrow<Order>(&orders, 0);
        let (assert_price, assert_size) = (ask_0_price, ask_0_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        order = vector_borrow<Order>(&orders, 1);
        (assert_price, assert_size) = (ask_1_price, ask_1_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        order = vector_borrow<Order>(&orders, 2);
        (assert_price, assert_size) = (ask_2_price, ask_2_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        order = vector_borrow<Order>(&orders, 3);
        (assert_price, assert_size) = (ask_3_price, ask_3_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        order = vector_borrow<Order>(&orders, 4);
        (assert_price, assert_size) = (ask_4_price, ask_4_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        // Generate price levels vector from orders
        price_levels = get_price_levels(&orders);
        // Assert price levels and sizes based on original values
        let (level_price, level_size) = (ask_0_price, ask_0_size + ask_1_size);
        let level = vector_borrow<PriceLevel>(&price_levels, 0);
        assert!(level.price == level_price && level.size == level_size, 0);
        (level_price, level_size) = (ask_2_price, ask_2_size);
        level = vector_borrow<PriceLevel>(&price_levels, 1);
        assert!(level.price == level_price && level.size == level_size, 0);
        (level_price, level_size) = (ask_3_price, ask_3_size + ask_4_size);
        level = vector_borrow<PriceLevel>(&price_levels, 2);
        assert!(level.price == level_price && level.size == level_size, 0);
        // Define a series of bids and add them to the book
        let (bid_0_price, bid_0_size) = (9, 20);
        let (bid_1_price, bid_1_size) = (8, 25);
        add_bid<BT, QT, ET>(@Econia, @Econia, id_b(bid_0_price, 0),
            bid_0_price, bid_0_size, &FriendCap{});
        add_bid<BT, QT, ET>(@Econia, @Econia, id_b(bid_1_price, 1),
            bid_1_price, bid_1_size, &FriendCap{});
        // Get vector of orders sorted by price-time priority
        orders = get_orders<BT, QT, ET>(@Econia, BID);
        order = vector_borrow<Order>(&orders, 0);
        (assert_price, assert_size) = (bid_0_price, bid_0_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        order = vector_borrow<Order>(&orders, 1);
        (assert_price, assert_size) = (bid_1_price, bid_1_size);
        assert!(order.price == assert_price && order.size == assert_size, 0);
        // Generate price levels vector from orders
        price_levels = get_price_levels(&orders);
        // Assert price levels and sizes based on original values
        (level_price, level_size) = (bid_0_price, bid_0_size);
        level = vector_borrow<PriceLevel>(&price_levels, 0);
        assert!(level.price == level_price && level.size == level_size, 0);
        (level_price, level_size) = (bid_1_price, bid_1_size);
        level = vector_borrow<PriceLevel>(&price_levels, 1);
        assert!(level.price == level_price && level.size == level_size, 0);
    }

    #[test(host = @Econia)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempted self matching trade
    fun traverse_init_fill_failure_self_match(
        host: &signer,
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Define ask with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_a(p_1, v_1); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_1, p_1, s_1, &FriendCap{});
        // Attempt invalid fill traversal init
        traverse_init_fill<BT, QT, ET>(
            @Econia, @Econia, ASK, 2, 3, &FriendCap{});
    }

    #[test(host = @Econia)]
    /// Verify successful traversal initialization for ask
    fun traverse_init_fill_success_ask(
        host: &signer,
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Define ask with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_a(p_1, v_1); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_1, p_1, s_1, &FriendCap{});
        // Define ask with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_a(p_2, v_2); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_2, p_2, s_2, &FriendCap{});
        // Define ask with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_a(p_3, v_3); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_3, p_3, s_3, &FriendCap{});
        // Init ask fill traversal for user w/ incoming order of size 1
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(@Econia, @TestUser, ASK, 1, 500,
            &FriendCap{});
        // Assert correct returns for partial target fill
        assert!(t_id == id_1 && t_addr == @Econia && filled == 1 && !exact, 0);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_ask<BT, QT, ET>(@Econia, t_id);
        // Assert target position size decremented accordingly
        assert!(t_s == 2 && t_a == @Econia, 1);
        // Init ask fill traversal for user w/ incoming order of size 2
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(@Econia, @TestUser, ASK, 2, 500,
            &FriendCap{});
        // Assert correct returns for complete fill both sides
        assert!(t_id == id_1 && t_addr == @Econia && filled == 2 && exact, 2);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_ask<BT, QT, ET>(@Econia, t_id);
        // Assert target position size left unmodified
        assert!(t_s == 2 && t_a == @Econia, 3);
        // Init ask fill traversal for user w/ incoming order of size 10
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(@Econia, @TestUser, ASK, 10, 500,
            &FriendCap{});
        // Assert correct returns for partial incoming fill
        assert!(t_id == id_1 && t_addr == @Econia && filled == 2 && !exact, 0);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_ask<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchanged
        assert!(t_s == 2 && t_a == @Econia, 1);
    }

    #[test(host = @Econia)]
    /// Verify successful traversal initialization for bid
    fun traverse_init_fill_success_bid(
        host: &signer,
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Define bid with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_b(p_1, v_1); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_1, p_1, s_1, &FriendCap{});
        // Define bid with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_b(p_2, v_2); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_2, p_2, s_2, &FriendCap{});
        // Define bid with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_b(p_3, v_3); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_3, p_3, s_3, &FriendCap{});
        // Init bid fill traversal for user w/ incoming order of size 1
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(
                @Econia, @TestUser, BID, 1, 500, &FriendCap{});
        // Assert correct returns for partial target fill
        assert!(t_id == id_3 && t_addr == @Econia && filled == 1 && !exact, 0);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_bid<BT, QT, ET>(@Econia, t_id);
        // Assert target position size decremented accordingly
        assert!(t_s == 4 && t_a == @Econia, 1);
        // Init bid fill traversal for user w/ incoming order of size 4
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(
                @Econia, @TestUser, BID, 4, 500, &FriendCap{});
        // Assert correct returns for complete fill both sides
        assert!(t_id == id_3 && t_addr == @Econia && filled == 4 && exact, 2);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_bid<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchaged
        assert!(t_s == 4 && t_a == @Econia, 3);
        // Init bid fill traversal for user w/ incoming order of size 10
        let (t_id, t_addr, _, _, filled, exact, _) =
            traverse_init_fill<BT, QT, ET>(
                @Econia, @TestUser, BID, 10, 500, &FriendCap{});
        // Assert correct returns for partial incoming fill
        assert!(t_id == id_3 && t_addr == @Econia && filled == 4 && !exact, 4);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_bid<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchanged
        assert!(t_s == 4 && t_a == @Econia, 5);
    }

    #[test(host = @Econia)]
    /// Verify successful iterated traversal filling of orders
    fun traverse_pop_fill_success_ask(
        host: &signer
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Define ask with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_a(p_1, v_1); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_1, p_1, s_1, &FriendCap{});
        // Define ask with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_a(p_2, v_2); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_2, p_2, s_2, &FriendCap{});
        // Define ask with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_a(p_3, v_3); // Get corresponding order ID
        // Add host-held position to book
        add_ask<BT, QT, ET>(@Econia, @Econia, id_3, p_3, s_3, &FriendCap{});
        // Init ask fill traversal for user w/ incoming order of size 12
        let (t_id, _, t_p_f, t_c_i, _, _, _) = traverse_init_fill<BT, QT, ET>(
            @Econia, @TestUser, ASK, 12, 500, &FriendCap{});
        // Traverse pop to next order and fill against incoming amount
        let (t_id, t_addr, t_p_f, t_c_i, filled, exact, _) =
            traverse_pop_fill<BT, QT, ET>(@Econia, @TestUser, ASK, 9, 500, 3,
                t_id, t_p_f, t_c_i, &FriendCap{});
        // Assert correct returns for partial incoming fill
        assert!(t_id == id_2 && t_addr == @Econia && filled == 4 && !exact, 0);
        // Assert start position popped off book
        assert!(!has_ask<BT, QT, ET>(@Econia, id_1), 1);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_ask<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchanged
        assert!(t_s == 4 && t_a == @Econia, 2);
        // Traverse pop to next order and fill against incoming amount
        (t_id, t_addr, _, _, filled, exact, _) =
            traverse_pop_fill<BT, QT, ET>(@Econia, @TestUser, ASK, 5, 500, 2,
                t_id, t_p_f, t_c_i, &FriendCap{});
        // Assert start position popped off book
        assert!(!has_ask<BT, QT, ET>(@Econia, id_2), 3);
        // Assert correct returns for complete fill both sides
        assert!(t_id == id_3 && t_addr == @Econia && filled == 5 && exact, 4);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_ask<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchanged
        assert!(t_s == 5 && t_a == @Econia, 2);
    }

    #[test(host = @Econia)]
    /// Verify successful iterated traversal filling of orders
    fun traverse_pop_fill_success_bid(
        host: &signer
    ) acquires OB {
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &FriendCap{});
        // Define bid with price 1, version number 2, size 3
        let (p_1, v_1, s_1) = (1, 2, 3);
        let id_1 = id_b(p_1, v_1); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_1, p_1, s_1, &FriendCap{});
        // Define bid with price 2, version number 3, size 4
        let (p_2, v_2, s_2) = (2, 3, 4);
        let id_2 = id_b(p_2, v_2); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_2, p_2, s_2, &FriendCap{});
        // Define bid with price 3, version number 4, size 5
        let (p_3, v_3, s_3) = (3, 4, 5);
        let id_3 = id_b(p_3, v_3); // Get corresponding order ID
        // Add host-held position to book
        add_bid<BT, QT, ET>(@Econia, @Econia, id_3, p_3, s_3, &FriendCap{});
        // Init bid fill traversal for user w/ incoming order of size 12
        let (t_id, _, t_p_f, t_c_i, _, _, _) =
            traverse_init_fill<BT, QT, ET>(
                @Econia, @TestUser, BID, 12, 500, &FriendCap{});
        // Traverse pop to next order and fill against incoming amount
        let (t_id, t_addr, t_p_f, t_c_i, filled, exact, _) =
            traverse_pop_fill<BT, QT, ET>(@Econia, @TestUser, BID, 7, 500, 3,
                t_id, t_p_f, t_c_i, &FriendCap{});
        // Assert correct returns for partial incoming fill
        assert!(t_id == id_2 && t_addr == @Econia && filled == 4 && !exact, 0);
        // Assert start position popped off book
        assert!(!has_bid<BT, QT, ET>(@Econia, id_3), 1);
        // Get size and address for target position order ID
        let (t_s, t_a) = check_bid<BT, QT, ET>(@Econia, t_id);
        // Assert target position size unchanged
        assert!(t_s == 4 && t_a == @Econia, 2);
        // Traverse pop to next order and fill against incoming amount
        (t_id, t_addr, _, _, filled, exact, _) =
            traverse_pop_fill<BT, QT, ET>(@Econia, @TestUser, BID, 3, 500, 2,
                t_id, t_p_f, t_c_i, &FriendCap{});
        // Assert start position popped off book
        assert!(!has_ask<BT, QT, ET>(@Econia, id_2), 3);
        // Assert correct returns for complete fill both sides
        assert!(t_id == id_1 && t_addr == @Econia && filled == 3 && exact, 4);
        // Assert target position popped off book
        assert!(!has_ask<BT, QT, ET>(@Econia, t_id), 5);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}