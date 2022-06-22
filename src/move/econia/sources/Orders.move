/// Pure-Move implementation of user-side open orders functionality
module Econia::Orders {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::CritBit::{
        CB,
        empty as cb_e,
        insert as cb_i
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::CritBit::{
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
    /// When amount is not an integer multiple of scale factor
    const E_AMOUNT_NOT_MULTIPLE: u64 = 4;
    /// When amount of quote coins to fill order overflows u64
    const E_FILL_OVERFLOW: u64 = 5;
    /// When order size is 0
    const E_SIZE_0: u64 = 6;

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
    /// `<B, Q, E>`
    ///
    /// # Parameters
    /// * `addr`: User's address
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    /// * `price`: Scaled integer price (see `Econia::ID`)
    /// * `size`: Unscaled order size, in base coin subunits
    ///
    /// # Abort sceniarios
    /// * If `price` is 0
    /// * If `size` is 0
    /// * If `OO<B, Q, E>` not initialized at `addr`
    /// * If `size` is not an integer multiple of price scale factor for
    ///   given market (see `Econia::Registry`)
    /// * If amount of quote coin subunits needed to fill order does not
    ///   fit in a `u64`
    ///
    /// # Assumes
    /// * Caller has constructed `id` to incorporate `price` as
    ///   specified in `Econia::ID`, since `id` is not directly operated
    ///   on or verified (`id` is only used as a tree insertion key)
    fun add_order<B, Q, E>(
        addr: address,
        side: bool,
        id: u128,
        price: u64,
        size: u64,
    ) acquires OO {
        assert!(price > 0, E_PRICE_0); // Assert order has actual price
        assert!(size > 0, E_SIZE_0); // Assert order has actual size
        // Assert open orders container exists at given address
        assert!(exists_orders<B, Q, E>(addr), E_NO_ORDERS);
        // Borrow mutable reference to open orders at given address
        let o_o = borrow_global_mut<OO<B, Q, E>>(addr);
        let s_f = o_o.f; // Get price scale factor
        // Assert order size is integer multiple of price scale factor
        assert!(size % s_f == 0, E_AMOUNT_NOT_MULTIPLE);
        let scaled_size = size / s_f; // Get scaled order size
        // Determine amount of quote coins needed to fill order, as u128
        let fill_amount = (scaled_size as u128) * (price as u128);
        // Assert that fill amount can fit in a u64
        assert!(!(fill_amount > (HI_64 as u128)), E_FILL_OVERFLOW);
        // Add order to corresponding tree
        if (side == ASK) cb_i<u64>(&mut o_o.a, id, scaled_size)
            else cb_i<u64>(&mut o_o.b, id, scaled_size);
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
    /// Verify failure for order size not integer multiple of
    /// scale factor
    fun add_order_failure_not_multiple(
        user: &signer
    )
    acquires OO {
        // Init orders with scale factor of 10
        init_orders<BT, QT, ET>(user, 10, &FriendCap{});
        // Attempt to add invalid order
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 1, 15);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for required quote coin fill amount not fitting
    /// into a `u64`
    fun add_order_failure_overflow(
        user: &signer
    )
    acquires OO {
        // Init orders with scale factor of 1
        init_orders<BT, QT, ET>(user, 1, &FriendCap{});
        // Attempt to add invalid order
        add_order<BT, QT, ET>(@TestUser, ASK, 0, HI_64, 2);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for order of price 0
    fun add_order_failure_price_0()
    acquires OO {
        // Attempt to add invalid order
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 0, 1);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for order of size 0
    fun add_order_failure_size_0()
    acquires OO {
        // Attempt to add invalid order
        add_order<BT, QT, ET>(@TestUser, ASK, 0, 1, 0);
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