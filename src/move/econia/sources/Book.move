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
        insert as cb_i,
        is_empty as cb_i_e,
        max_key as cb_ma_k,
        min_key as cb_mi_k,
        pop as cb_p
    };

    use Econia::ID::{
        price as id_p,
    };

    use Std::Signer::{
        address_of as s_a_o
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
        /// Scaled size (see `Econia::Orders`) of position to be filled
        s: u64,
        /// Address holding position
        a: address
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
    /// When order book does not exist at given address
    const E_NO_BOOK: u64 = 1;
    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 2;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// `u128` bitmask with all bits set
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;

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

    /// Wrapped `add_position()` call for `ASK`, requiring `FriendCap`
    public fun cancel_ask<B, Q, E>(
        host: address,
        id: u128,
        _c: &FriendCap
    ) acquires OB {
        cancel_position<B, Q, E>(host, ASK, id);
    }

    /// Wrapped `add_position()` call for `BID`, requiring `FriendCap`
    public fun cancel_bid<B, Q, E>(
        host: address,
        id: u128,
        _c: &FriendCap
    ) acquires OB {
        cancel_position<B, Q, E>(host, BID, id);
    }

    /// Return `true` if specified order book type exists at address
    public fun exists_book<B, Q, E>(a: address): bool {exists<OB<B, Q, E>>(a)}

    /// Return a `FriendCap`, aborting if not called by Econia account
    public fun get_friend_cap(
        account: &signer
    ): FriendCap {
        // Assert called by Econia
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        FriendCap{} // Return requested capability
    }

    /// Initialize order book under host account, provided `FriendCap`,
    /// with market types `B`, `Q`, `E`, and scale factor `f`
    public fun init_book<B, Q, E>(
        host: &signer,
        f: u64,
        _c: &FriendCap
    ) {
        // Assert book does not already exist under host account
        assert!(!exists_book<B, Q, E>(s_a_o(host)), E_BOOK_EXISTS);
        let m_a = MIN_ASK_DEFAULT; // Declare min ask default order ID
        let m_b = MAX_BID_DEFAULT; // Declare max bid default order ID
        let o_b = // Pack empty order book
            OB<B, Q, E>{f, a: cb_e<P>(), b: cb_e<P>(), m_a, m_b};
        move_to<OB<B, Q, E>>(host, o_b); // Move to host
    }

    /// Return scale factor of specified order book at given address
    public fun scale_factor<B, Q, E>(
        addr: address
    ): u64
    acquires OB {
        // Assert book exists at given address
        assert!(exists_book<B, Q, E>(addr), E_NO_BOOK);
        borrow_global<OB<B, Q, E>>(addr).f // Return book's scale factor
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
        let (m_a_p, m_b_p) = (id_p(o_b.m_a), id_p(o_b.m_b));
        if (side == ASK) { // If order is an ask
            if (price > m_b_p) { // If order does not cross spread
                // Add corresponding position to ask tree
                cb_i(&mut o_b.a, id, P{s: size, a: user});
                // If order is within spread, update min ask id
                if (price < m_a_p) o_b.m_a = id;
            } else return true; // Otherwise indicate crossed spread
        } else { // If order is a bid
            if (price < m_a_p) { // If order does not cross spread
                // Add corresponding position to bid tree
                cb_i(&mut o_b.b, id, P{s: size, a: user});
                // If order is within spread, update max bid id
                if (price > m_b_p) o_b.m_b = id;
            // Otherwise manage order that crosses spread
            } else return true; // Otherwise indicate crossed spread
        }; // Order is on now on book, and did not cross spread
        false // Indicate spread not crossed
    }

    /// Cancel position on book for market `<B, Q, E>`, skipping
    /// redundant error checks already covered by calling functions
    ///
    /// # Parameters
    /// * `host`: Address of market host
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    ///
    /// # Assumes
    /// * `OB` for given market exists at host address
    /// * Position has already been placed on book properly, by
    ///   preceding functions that perform their own error-checking
    fun cancel_position<B, Q, E>(
        host: address,
        side: bool,
        id: u128
    ) acquires OB {
        // Borrow mutable reference to order book at host address
        let o_b = borrow_global_mut<OB<B, Q, E>>(host);
        if (side == ASK) { // If order is an ask
            let asks = &mut o_b.a; // Get mutable reference to asks tree
            P{s: _, a: _} = cb_p<P>(asks, id); // Pop/unpack position
            if (o_b.m_a == id) { // If cancelled order was the min ask
                // If asks tree now empty, set min ask ID to default
                o_b.m_a = if (cb_i_e<P>(asks)) MIN_ASK_DEFAULT else
                    cb_mi_k<P>(asks); // Otherwise set to new min ask ID
            };
        } else { // If order is a bid
            let bids = &mut o_b.b; // Get mutable reference to bids tree
            P{s: _, a: _} = cb_p<P>(bids, id); // Pop/unpack position
            if (o_b.m_b == id) { // If cancelled order was the max bid
                // If bid tree now empty, set max bid ID to default
                o_b.m_b = if (cb_i_e<P>(bids)) MAX_BID_DEFAULT else
                    cb_ma_k<P>(bids); // Otherwise set to new max bid ID
            };
        }
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    // Return `P` fields for ask with specified ID, for specified market
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
    // Return order ID of ask having minimum price
    public fun check_ask_min<B, Q, E>(
        host: address
    ): (
        u128
    ) acquires OB {
        borrow_global<OB<B, Q, E>>(host).m_a
    }

    #[test_only]
    // Return `P` fields for bid with specified ID, on specified market
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
    // Return order ID of bid having maximum price
    public fun check_bid_max<B, Q, E>(
        host: address
    ): (
        u128
    ) acquires OB {
        borrow_global<OB<B, Q, E>>(host).m_b
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @TestUser)]
    /// Verify return when placing an ask that crosses the spread
    fun add_position_success_crossed_spread_ask(
        account: &signer,
    ) acquires OB {
        let addr = s_a_o(account); // Get account address
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
        let addr = s_a_o(account); // Get account address
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
        let addr = s_a_o(account); // Get account address
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
        let addr = s_a_o(account); // Get account address
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
        let addr = s_a_o(account); // Get account address
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
        let addr = s_a_o(account); // Get account address
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

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 2)]
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
        let host_addr = s_a_o(host); // Get host address
        // Assert book exists and has correct scale factor
        assert!(scale_factor<BT, QT, ET>(host_addr) == 1, 0);
        // Borrow mutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(host_addr);
        // Assert minimum ask id inits to max possible value, and
        // maximum bid order id inits to 0
        assert!(o_b.m_a == HI_128 && o_b.m_b == 0, 1);
        // Assert bid and ask trees init empty
        assert!(cb_i_e(&o_b.a) && cb_i_e(&o_b.b), 2);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no book
    fun scale_factor_failure()
    acquires OB {
        scale_factor<BT, QT, ET>(@TestUser); // Attempt invalid query
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}