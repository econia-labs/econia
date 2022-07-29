/// Market-side functionality
module econia::market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use econia::capability::{Self, EconiaCapability};
    use econia::critbit::{Self, CritBitTree};
    use econia::order_id;
    use econia::registry;
    use econia::user;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::coins::{Self, BC, QC};

    #[test_only]
    use econia::registry::{E1};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Stores an `EconiaCapability` for cross-module authorization
    struct EconiaCapabilityStore has key {
        econia_capability: EconiaCapability
    }

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
    /// When caller is not Econia
    const E_NOT_ECONIA: u64 = 1;
    /// When `EconiaCapabilityStore` already exists under Econia account
    const E_ECONIA_CAPABILITY_STORE_EXISTS: u64 = 2;
    /// When no `EconiaCapabilityStore` exists under Econia account
    const E_NO_ECONIA_CAPABILITY_STORE: u64 = 3;
    /// When no `OrderBook` exists under given address
    const E_NO_ORDER_BOOK: u64 = 4;

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

    /// Initializes an `EconiaCapabilityStore`, aborting if one already
    /// exists under the Econia account or if caller is not Econia
    public fun init_econia_capability_store(
        account: &signer
    ) {
        // Assert caller is Econia account
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Assert capability store not already registered
        assert!(!exists<EconiaCapabilityStore>(@econia),
            E_ECONIA_CAPABILITY_STORE_EXISTS);
        // Get new capability instance (aborts if caller is not Econia)
        let econia_capability = capability::get_econia_capability(account);
        move_to<EconiaCapabilityStore>(account, EconiaCapabilityStore{
            econia_capability}); // Move to account capability store
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register a market for the given base type, quote type,
    /// scale exponent type, and move an `OrderBook` to `host`.
    public entry fun register_market<B, Q, E>(
        host: &signer,
    ) acquires EconiaCapabilityStore {
        // Add an entry to the market registry table
        registry::register_market_internal<B, Q, E>(address_of(host),
            &get_econia_capability());
        // Initialize an order book under host account
        init_book<B, Q, E>(host, registry::scale_factor<E>());
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Increment counter for number of orders placed on an `OrderBook`,
    /// returning the original value.
    fun get_serial_id<B, Q, E>(
        order_book_ref_mut: &mut OrderBook<B, Q, E>
    ): u64 {
        // Borrow mutable reference to order book serial counter
        let counter_ref_mut = &mut order_book_ref_mut.counter;
        let count = *counter_ref_mut; // Get count
        *counter_ref_mut = count + 1; // Set new count
        count // Return original count
    }

    /// Return an `EconiaCapability`, aborting if Econia account has no
    /// `EconiaCapabilityStore`
    fun get_econia_capability():
    EconiaCapability
    acquires EconiaCapabilityStore {
        // Assert capability store has been intialized
        assert!(exists<EconiaCapabilityStore>(@econia),
            E_NO_ECONIA_CAPABILITY_STORE);
        // Return a copy of an Econia capability
        borrow_global<EconiaCapabilityStore>(@econia).econia_capability
    }

    /// Initialize `OrderBook` with given `scale_factor` under `host`
    /// account, aborting if one already exists
    fun init_book<B, Q, E>(
        host: &signer,
        scale_factor: u64,
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

    fun place_limit_order<B, Q, E>(
        user: address,
        host: address,
        custodian_id: u64,
        side: bool,
        base_parcels: u64,
        price: u64
    ) acquires EconiaCapabilityStore, OrderBook {
        // Assert host has an order book
        assert!(exists<OrderBook<B, Q, E>>(host), E_NO_ORDER_BOOK);
        // Borrow mutable reference to order book
        let order_book_ref_mut = borrow_global_mut<OrderBook<B, Q, E>>(host);
        let order_id = // Get order ID based on book serial ID and side
            order_id::order_id(price, get_serial_id(order_book_ref_mut), side);
        // Add order to user's market account
        user::add_order_internal<B, Q, E>(user, custodian_id, side, order_id,
            base_parcels, price, &get_econia_capability());
        // Insert to corresponding tree
        // Check min/max
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(host = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for re-registering an order book
    fun test_book_exists(
        host: &signer,
    ) {
        // Initialize a book
        init_book<BC, QC, E1>(host, 10);
        // Attemp invalid re-initialization
        init_book<BC, QC, E1>(host, 10);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for uninitialized capability store
    fun test_get_econia_capability_not_exists()
    acquires EconiaCapabilityStore{
        get_econia_capability(); // Attempt invalid invocation
    }

    #[test(econia = @econia)]
    /// Verify successful serial ID generation
    fun test_get_order_serial_id(
        econia: &signer
    ) acquires OrderBook {
        init_book<BC, QC, E1>(econia, 10); // Initalize order book
        // Borrow mutable reference to order book
        let order_book_ref_mut =
            borrow_global_mut<OrderBook<BC, QC, E1>>(@econia);
        // Assert serial ID returns
        assert!(get_serial_id(order_book_ref_mut) == 0, 0);
        assert!(get_serial_id(order_book_ref_mut) == 1, 0);
        assert!(get_serial_id(order_book_ref_mut) == 2, 0);
    }

    #[test(host = @user)]
    /// Verify successful initialization of order book
    fun test_init_book(
        host: &signer,
    ) acquires OrderBook {
        // Initialize a book
        init_book<BC, QC, E1>(host, 10);
        // Borrow immutable reference to new book
        let book = borrow_global<OrderBook<BC, QC, E1>>(@user);
        // Assert fields initialized correctly
        assert!(book.scale_factor == 10, 0);
        assert!(critbit::is_empty(&book.asks), 0);
        assert!(critbit::is_empty(&book.bids), 0);
        assert!(book.min_ask == MIN_ASK_DEFAULT, 0);
        assert!(book.max_bid == MAX_BID_DEFAULT, 0);
        assert!(book.counter == 0, 0);
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to init under non-Econia account
    fun test_init_econia_capability_store_not_econia(
        account: &signer
    ) {
        init_econia_capability_store(account); // Attempt invalid init
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting to re-init under Econia account
    fun test_init_econia_capability_store_exists(
        econia: &signer
    ) {
        init_econia_capability_store(econia); // Initialize store
        init_econia_capability_store(econia); // Attempt invalid re-init
    }

    #[test(econia = @econia)]
    /// Verify successful registration
    fun test_register_market(
        econia: &signer
    ) acquires EconiaCapabilityStore {
        init_econia_capability_store(econia);
        coins::init_coin_types(econia); // Init coin types
        registry::init_registry(econia); // Initialize registry
        register_market<BC, QC, E1>(econia); // Register market
        // Assert entry added to registry
        assert!(registry::is_registered_types<BC, QC, E1>(), 0);
        // Assert corresponding order book initialized under host
        assert!(exists<OrderBook<BC, QC, E1>>(@econia), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}