/// # Test oriented implementation
///
/// The present module is implemented purely in Move, to enable coverage
/// testing as described in `Econia::Caps`. Hence the use of `FriendCap`
/// in public functions.
///
/// # Order structure
///
/// For a market specified by `<B, Q, E>` (see `Econia::Registry`), a
/// user's open orders are stored in an `OO`, which has a
/// `Econia::CritBit::CB` for both asks and bids. In each tree,
/// key-value pairs have a key formatted per `Econia::ID`, and a value
/// indicating the order's "scaled size" remaining to be filled, where
/// scaled size is defined as the "unscaled size" of an order divided by
/// the market scale factor (See `Econia::Registry`):
///
/// $size_{scaled} = size_{unscaled} / SF$
///
/// ## Order placement
///
/// For example, if a user wants to place a bid for `1400` indivisible
/// subunits of protocol coin `PRO` in a `USDC`-denominated market with
/// with a scale factor of `100`, and is willing to pay `28014`
/// indivisible subunits of `USDC`, then their bid has an unscaled size
/// of `1400`, a scaled size of `14`, and a scaled price of `2001`. Thus
/// when this bid is added to the user's open orders per `add_bid()`,
/// into the `b` field of their `OO<PRO, USDC, E2>` will be inserted a
/// key-value pair of the form $\{id, 14\}$, where $id$ denotes an order
/// ID (per `Econia::ID`) indicating a scaled price of `2001`. In other
/// words, the scaled size is the number of base coin "parcels" in an
/// order, where a parcel contains $SF$ subunits.
///
/// ---
///
module Econia::Orders {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::CritBit::{
        CB,
        empty as cb_e,
        has_key as cb_h_k,
        insert as cb_i,
        pop as cb_p
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::CritBit::{
        borrow as cb_b,
        is_empty as cb_i_e
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Friend-like capability, administered instead of declaring as a
    /// friend a module containing Aptos native functions, which would
    /// inhibit coverage testing via the Move CLI. See `Econia::Caps`
    struct FriendCap has copy, drop, store {}

    /// Open orders, for the given market, on a user's account
    struct OO<phantom B, phantom Q, phantom E> has key {
        /// Scale factor
        f: u64,
        /// Asks
        a: CB<u64>,
        /// Bids
        b: CB<u64>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base coin type
    struct BT{}

    #[test_only]
    /// Quote coin type
    struct QT{}

    #[test_only]
    /// Scale exponent type
    struct ET{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When open orders already exists at given address
    const E_ORDERS_EXISTS: u64 = 0;
    /// When order book does not exist at given address
    const E_NO_ORDERS: u64 = 1;
    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 2;
    /// When indicated price indicated 0
    const E_PRICE_0: u64 = 3;
    /// When base coin subunits required to fill order overflows a u64
    const E_BASE_OVERFLOW: u64 = 4;
    /// When quote coin subunits required to fill order overflows a u64
    const E_QUOTE_OVERFLOW: u64 = 5;
    /// When order size is 0
    const E_SIZE_0: u64 = 6;
    /// When user does not have open order with specified ID
    const E_NO_SUCH_ORDER: u64 = 7;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Wrapped `add_order()` call for `ASK`, requiring `FriendCap`
    public fun add_ask<B, Q, E>(
        addr: address,
        id: u128,
        price: u64,
        size: u64,
        _c: &FriendCap
    ): (
        u64,
        u64
    ) acquires OO {
        add_order<B, Q, E>(addr, ASK, id, price, size)
    }

    /// Wrapped `add_order()` call for `BID`, requiring `FriendCap`
    public fun add_bid<B, Q, E>(
        addr: address,
        id: u128,
        price: u64,
        size: u64,
        _c: &FriendCap
    ): (
        u64,
        u64
    ) acquires OO {
        add_order<B, Q, E>(addr, BID, id, price, size)
    }

    /// Wrapped `cancel_order()` call for `ASK`, requiring `FriendCap`
    public fun cancel_ask<B, Q, E>(
        addr: address,
        id: u128,
        _c: &FriendCap
    ): u64
    acquires OO {
        cancel_order<B, Q, E>(addr, ASK, id)
    }

    /// Wrapped `cancel_order()` call for `BID`, requiring `FriendCap`
    public fun cancel_bid<B, Q, E>(
        addr: address,
        id: u128,
        _c: &FriendCap
    ): u64
    acquires OO {
        cancel_order<B, Q, E>(addr, BID, id)
    }

    /// Return `true` if specified open orders type exists at address
    public fun exists_orders<B, Q, E>(
        a: address
    ): bool {
        exists<OO<B, Q, E>>(a)
    }

    /// Return a `FriendCap`, aborting if not called by Econia
    public fun get_friend_cap(
        account: &signer
    ): FriendCap {
        // Assert called by Econia
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        FriendCap{} // Return requested capability
    }

    /// Initialize open orders under host account, provided `FriendCap`,
    /// with market types `B`, `Q`, `E`, and scale factor `f`
    public fun init_orders<B, Q, E>(
        user: &signer,
        f: u64,
        _c: &FriendCap
    ) {
        // Assert open orders does not already exist under user account
        assert!(!exists_orders<B, Q, E>(s_a_o(user)), E_ORDERS_EXISTS);
        // Pack empty open orders container
        let o_o = OO<B, Q, E>{f, a: cb_e<u64>(), b: cb_e<u64>()};
        move_to<OO<B, Q, E>>(user, o_o); // Move to user
    }

    /// Return scale factor of specified open orders at given address
    public fun scale_factor<B, Q, E>(
        addr: address
    ): u64
    acquires OO {
        // Assert open orders container exists at given address
        assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
        // Return open order container's scale factor
        borrow_global<OO<B, Q, E>>(addr).f
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Add new order to users's open orders container for market
    /// `<B, Q, E>`, returning base coin subunits and quote coin
    /// subunits required to fill the order
    ///
    /// # Parameters
    /// * `addr`: User's address
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    /// * `price`: Scaled integer price (see `Econia::ID`)
    /// * `size`: Scaled order size, (number of base coin parcels)
    ///
    /// # Returns
    /// * `u64`: Base coin subunits required to fill order
    /// * `u64`: Quote coin subunits required to fill order
    ///
    /// # Abort scenarios
    /// * If `price` is 0
    /// * If `size` is 0
    /// * If `OO<B, Q, E>` not initialized at `addr`
    /// * If the number of base coin subunits required to fill the order
    ///   does not fit in a `u64`
    /// * If the number of quote coin subunits required to fill the
    ///   order does not fit in a `u64`
    ///
    /// # Assumes
    /// * Caller has constructed `id` to indicate `price` as specified
    ///   in `Econia::ID`, since `id` is not directly operated on or
    ///   verified (`id` is only used as a tree insertion key)
    fun add_order<B, Q, E>(
        addr: address,
        side: bool,
        id: u128,
        price: u64,
        size: u64,
    ): (
    u64,
    u64
    ) acquires OO {
        assert!(price > 0, E_PRICE_0); // Assert order has actual price
        assert!(size > 0, E_SIZE_0); // Assert order has actual size
        // Assert open orders container exists at given address
        assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
        // Borrow mutable reference to open orders at given address
        let o_o = borrow_global_mut<OO<B, Q, E>>(addr);
        let s_f = o_o.f; // Get price scale factor
        // Determine amount of base coins needed to fill order, as u128
        let base_subunits = (size as u128) * (s_f as u128);
        // Assert that amount can fit in a u64
        assert!(!(base_subunits > (HI_64 as u128)), E_BASE_OVERFLOW);
        // Determine amount of quote coins needed to fill order, as u128
        let quote_subunits = (size as u128) * (price as u128);
        // Assert that amount can fit in a u64
        assert!(!(quote_subunits > (HI_64 as u128)), E_QUOTE_OVERFLOW);
        // Add order to corresponding tree
        if (side == ASK) cb_i<u64>(&mut o_o.a, id, size)
            else cb_i<u64>(&mut o_o.b, id, size);
        ((base_subunits as u64), (quote_subunits as u64))
    }

    /// Cancel position in open orders for market `<B, Q, E>`
    ///
    /// # Parameters
    /// * `addr`: User's address
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    ///
    /// # Returns
    /// * `u64`: Scaled size of order
    ///
    /// # Abort scenarios
    /// * If `OO<B, Q, E>` not initialized at `addr`
    /// * If user does not have an open order with given ID
    fun cancel_order<B, Q, E>(
        addr: address,
        side: bool,
        id: u128
    ): u64
    acquires OO {
        // Assert open orders container exists at given address
        assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
        // Borrow mutable reference to open orders at given address
        let o_o = borrow_global_mut<OO<B, Q, E>>(addr);
        if (side == ASK) { // If cancelling an ask
            // Assert user has an open ask with corresponding ID
            assert!(cb_h_k<u64>(&o_o.a, id), E_NO_SUCH_ORDER);
            // Pop ask with corresponding ID, returning its scaled size
            return cb_p<u64>(&mut o_o.a, id)
        } else { // If cancelling a bid
            // Assert user has an open bid with corresponding ID
            assert!(cb_h_k<u64>(&o_o.b, id), E_NO_SUCH_ORDER);
            // Pop bid with corresponding ID, returning its scaled size
            return cb_p<u64>(&mut o_o.b, id)
        }
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    // Return scaled size of ask for given market, user, order ID
    public fun check_ask<B, Q, E>(
        user: address,
        id: u128
    ): (
        u64
    ) acquires OO {
        *cb_b<u64>(&borrow_global<OO<B, Q, E>>(user).a, id)
    }

    #[test_only]
    // Return scaled size of bid for given market, user, order ID
    public fun check_bid<B, Q, E>(
        user: address,
        id: u128
    ): (
        u64
    ) acquires OO {
        *cb_b<u64>(&borrow_global<OO<B, Q, E>>(user).b, id)
    }

    #[test_only]
    /// Return `true` if extant open orders container at given address
    /// has an ask with the given ID
    public fun has_ask<B, Q, E>(
        user: address,
        id: u128
    ): bool
    acquires OO {
        cb_h_k<u64>(&borrow_global<OO<B, Q, E>>(user).a, id)
    }

    #[test_only]
    /// Return `true` if extant open orders container at given address
    /// has a bid with the given ID
    public fun has_bid<B, Q, E>(
        user: address,
        id: u128
    ): bool
    acquires OO {
        cb_h_k<u64>(&borrow_global<OO<B, Q, E>>(user).b, id)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no open orders container initialized
    fun add_order_failure_no_orders()
    acquires OO {
        // Attempt invalid add
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 1, 1);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for base subunit fill amount overflow
    fun add_order_failure_overflow_base(
        user: &signer
    ) acquires OO {
        // Init orders with scale factor of 10
        init_orders<BT, QT, ET>(user, 10, &FriendCap{});
        // Attempt invalid add
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 2, HI_64 / 9);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for quote subunit fill amount overflow
    fun add_order_failure_overflow_quote(
        user: &signer
    ) acquires OO {
        // Init orders with scale factor of 10
        init_orders<BT, QT, ET>(user, 10, &FriendCap{});
        // Attempt invalid add
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 11, HI_64 / 10);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for order of price 0
    fun add_order_failure_price_0()
    acquires OO {
        // Attempt invalid add
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 0, 1);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for order of size 0
    fun add_order_failure_size_0()
    acquires OO {
        // Attempt invalid add
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 1, 0);
    }

    #[test(user = @TestUser)]
    /// Verify successful adding of orders
    fun add_orders_success(
        user: &signer
    ) acquires OO {
        let f_c = FriendCap{}; // Initialize friend-like capability
        // Init orders with scale factor of 100
        init_orders<BT, QT, ET>(user, 100, &f_c);
        // Add ask, storing base/quote coin subunit fill amounts
        let (ask_b_s, ask_q_s) =
            add_ask<BT, QT, ET>(@TestUser, 123, 2, 4, &f_c);
        // Assert correct
        assert!(ask_b_s == 400 && ask_q_s == 8, 0);
        // Add bid, storing base/quote coin subunit fill amounts
        let (bid_b_s, bid_q_s) =
            add_bid<BT, QT, ET>(@TestUser, 234, 3, 14, &f_c);
        // Assert correct scaled size and fill amount returns
        assert!(bid_b_s == 1400 && bid_q_s == 42, 1);
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(@TestUser);
        // Assert ask added correctly
        assert!(*cb_b<u64>(&o_o.a, 123) == 4, 2);
        // Assert bid added correctly
        assert!(*cb_b<u64>(&o_o.b, 234) == 14, 3);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no such order
    fun cancel_order_failure_no_such_ask(
        user: &signer
    ) acquires OO {
        let f_c = FriendCap{}; // Initialize friend-like capability
        // Init orders with scale factor of 1
        init_orders<BT, QT, ET>(user, 1, &f_c);
        // Attempt invalid cancellation
        cancel_ask<BT, QT, ET>(@TestUser, 0, &f_c);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no such order
    fun cancel_order_failure_no_such_bid(
        user: &signer
    ) acquires OO {
        let f_c = FriendCap{}; // Initialize friend-like capability
        // Init orders with scale factor of 1
        init_orders<BT, QT, ET>(user, 1, &f_c);
        // Attempt invalid cancellation
        cancel_bid<BT, QT, ET>(@TestUser, 0, &f_c);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no open orders container initialized
    fun cancel_order_failure_no_orders()
    acquires OO {
        // Attempt invalid cancellation
        cancel_ask<BT, QT, ET>(@TestUser, 0, &FriendCap{});
    }

    #[test(user = @TestUser)]
    /// Verify successful cancellation of both ask and bid
    fun cancel_orders_success(
        user: &signer
    ) acquires OO {
        let f_c = FriendCap{}; // Initialize friend-like capability
        // Init orders with scale factor of 1
        init_orders<BT, QT, ET>(user, 1, &f_c);
        // Declare dummy id, price, size fields
        let (id, price, size) = (1, 2, 3);
        // Add ask to open orders
        add_ask<BT, QT, ET>(@TestUser, id, price, size, &f_c);
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(@TestUser);
        // Assert ask registered in open orders
        assert!(cb_h_k<u64>(&o_o.a, id), 0);
        // Cancel ask, storing scaled size of order
        let s_s = cancel_ask<BT, QT, ET>(@TestUser, id, &FriendCap{});
        assert!(s_s == size, 1); // Assert correct scaled size return
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(@TestUser);
        // Assert ask no longer registered in open orders
        assert!(!cb_h_k<u64>(&o_o.a, id), 2);
        // Add bid to open orders
        add_bid<BT, QT, ET>(@TestUser, id, price, size, &f_c);
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(@TestUser);
        // Assert bid registered in open orders
        assert!(cb_h_k<u64>(&o_o.b, id), 3);
        // Cancel bid, storing scaled size of order
        let s_s = cancel_bid<BT, QT, ET>(@TestUser, id, &FriendCap{});
        assert!(s_s == size, 4); // Assert correct scaled size return
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(@TestUser);
        // Assert bid no longer registered in open orders
        assert!(!cb_h_k<u64>(&o_o.b, id), 5);
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for non-Econia account
    fun get_friend_cap_failure(
        account: &signer
    ) {
        get_friend_cap(account); // Attempt invalid invocation
    }

    #[test(econia = @Econia)]
    /// Verify success for Econia account
    fun get_friend_cap_success(
        econia: &signer
    ) {
        // Unpack result of valid invocation
        let FriendCap{} = get_friend_cap(econia);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failed re-initialization of open orders container
    fun init_orders_failure_exists(
        user: &signer,
    ) {
        // Initialize open orders with scale factor 1
        init_orders<BT, QT, ET>(user, 1, &FriendCap{});
        // Attempt invalid re-initialization
        init_orders<BT, QT, ET>(user, 1, &FriendCap{});
    }

    #[test(user = @TestUser)]
    /// Verify successful initialization of open orders container
    fun init_orders_success(
        user: &signer,
    ) acquires OO {
        // Initialize open orders with scale factor 1
        init_orders<BT, QT, ET>(user, 1, &FriendCap{});
        let user_addr = s_a_o(user); // Get user address
        // Assert open orders exists and has correct scale factor
        assert!(scale_factor<BT, QT, ET>(user_addr) == 1, 0);
        // Borrow immutable reference to open orders
        let o_o = borrow_global<OO<BT, QT, ET>>(user_addr);
        // Assert bid and ask trees init empty
        assert!(cb_i_e(&o_o.a) && cb_i_e(&o_o.b), 2);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no orders
    fun scale_factor_failure()
    acquires OO {
        scale_factor<BT, QT, ET>(@TestUser); // Attempt invalid query
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}