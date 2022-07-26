/// Order book functionality
module econia::book {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use econia::capability::{EconiaCapability};
    use econia::critbit::{Self, CritBitTree};
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// An order on the order book
    struct Order has store {
        /// Number of base parcels to be filled
        base_parcels: u64,
        /// Address of corresponding user
        user: address,
        /// For given user, custodian ID of corresponding market account
        custodian_id: u8
    }

    /// An order book for the given market
    struct OrderBook<phantom B, phantom Q, phantom E> has key {
        /// Number of base units in a base parcel
        scale_factor: u64,
        /// Asks tree
        asks: CritBitTree<Order>,
        /// Bids tree
        bids: CritBitTree<Order>,
        /// Order ID of minimum ask, per price-time priority
        min_ask: u128,
        /// Order ID of maximum bid, per price-time priority
        max_bid: u128,
        /// Serial counter for number of orders placed on book
        counter: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When an order book already exists at given address
    const E_BOOK_EXISTS: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// Left direction, denoting predecessor traversal
    const LEFT: bool = true;
    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Right direction, denoting successor traversal
    const RIGHT: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize `OrderBook` with given `scale_factor` under `host`
    /// account, aborting if one already exists
    public fun init_book<B, Q, E>(
        host: &signer,
        scale_factor: u64,
        _: &EconiaCapability
    ) {
        // Assert book does not already exist under host account
        assert!(!exists<OrderBook<B, Q, E>>(address_of(host)), E_BOOK_EXISTS);
        // Move to host a newly-packed order book
        move_to<OrderBook<B, Q, E>>(host, OrderBook{
            scale_factor,
            asks: critbit::empty(),
            bids: critbit::empty(),
            min_ask: MIN_ASK_DEFAULT,
            max_bid: MAX_BID_DEFAULT,
            counter: 0
        });
    }

    /// Return scale factor for extant order book at `host` address
    ///
    /// # Assumes
    /// * `OrderBook` exists at `host` address
    public fun scale_factor<B, Q, E>(
        host: address,
        _: &EconiaCapability
    ): u64
    acquires OrderBook {
        borrow_global<OrderBook<B, Q, E>>(host).scale_factor
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::capability::get_econia_capability_test;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Test base coin type
    struct BT{}

    #[test_only]
    /// Test quote coin type
    struct QT{}

    #[test_only]
    /// Test scale exponent type
    struct ET{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(host = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for re-registering an order book
    fun test_book_exists(
        host: &signer,
    ) {
        // Initialize a book
        init_book<BT, QT, ET>(host, 10, &get_econia_capability_test());
        // Attemp invalid re-initialization
        init_book<BT, QT, ET>(host, 10, &get_econia_capability_test());
    }

    #[test(host = @user)]
    /// Verify successful initialization of order book
    fun test_init_book(
        host: &signer,
    ) acquires OrderBook {
        // Initialize a book
        init_book<BT, QT, ET>(host, 10, &get_econia_capability_test());
        // Borrow immutable reference to new book
        let book = borrow_global<OrderBook<BT, QT, ET>>(@user);
        // Assert fields initialized correctly
        assert!(book.scale_factor == 10, 0);
        assert!(critbit::is_empty(&book.asks), 0);
        assert!(critbit::is_empty(&book.bids), 0);
        assert!(book.min_ask == MIN_ASK_DEFAULT, 0);
        assert!(book.max_bid == MAX_BID_DEFAULT, 0);
        assert!(book.counter == 0, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}