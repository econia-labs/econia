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
        custodian_id: u64
    }

    /// An order book for the given market
    struct OrderBook<phantom B, phantom Q, phantom E> has key {
        /// Number of base units in a base parcel
        scale_factor: u64,
        /// Asks tree
        asks: CritBitTree<Order>,
        /// Bids tree
        bids: CritBitTree<Order>,
        /// Order ID of minimum ask, per price-time priority. The ask
        /// side "spread maker".
        min_ask: u128,
        /// Order ID of maximum bid, per price-time priority. The bid
        /// side "spread maker".
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
    /// When corresponding order not found on book for given side
    const E_NO_SUCH_ORDER: u64 = 5;
    /// When invalid user attempts to manage an order
    const E_INVALID_USER: u64 = 6;
    /// When invalid custodian attempts to manage an order
    const E_INVALID_CUSTODIAN: u64 = 7;
    /// When a limit order crosses the spread
    const E_CROSSED_SPREAD: u64 = 8;

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
    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// Right direction, denoting successor traversal
    const RIGHT: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel a limit order on the book and in a user's market account.
    /// Invoked by a custodian, who passes an immutable reference to
    /// their `registry::CustodianCapability`. See wrapped call
    /// `cancel_limit_order`.
    public fun cancel_limit_order_custodian<B, Q, E>(
        user: address,
        host: address,
        side: bool,
        order_id: u128,
        custodian_capability_ref: &registry::CustodianCapability
    ) acquires EconiaCapabilityStore, OrderBook {
        // Get custodian ID encoded in capability
        let custodian_id = registry::custodian_id(custodian_capability_ref);
        // Cancel limit order with corresponding custodian id
        cancel_limit_order<B, Q, E>(user, host, custodian_id, side, order_id);
    }

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

    /// Place a limit order on the book and in a user's market account.
    /// Invoked by a custodian, who passes an immutable reference to
    /// their `registry::CustodianCapability`. See wrapped call
    /// `place_limit_order`.
    public fun place_limit_order_custodian<B, Q, E>(
        user: address,
        host: address,
        side: bool,
        base_parcels: u64,
        price: u64,
        custodian_capability_ref: &registry::CustodianCapability
    ) acquires EconiaCapabilityStore, OrderBook {
        // Get custodian ID encoded in capability
        let custodian_id = registry::custodian_id(custodian_capability_ref);
        // Place limit order with corresponding custodian id
        place_limit_order<B, Q, E>(
            user, host, custodian_id, side, base_parcels, price);
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel a limit order on the book and in a user's market account.
    /// Invoked by a signing user. See wrapped call `place_limit_order`.
    public entry fun cancel_limit_order_user<B, Q, E>(
        user: &signer,
        host: address,
        side: bool,
        order_id: u128,
    ) acquires EconiaCapabilityStore, OrderBook {
        // Cancel limit order with corresponding no custodian flag
        cancel_limit_order<B, Q, E>(
            address_of(user), host, NO_CUSTODIAN, side, order_id);
    }

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

    /// Place a limit order on the book and in a user's market account.
    /// Invoked by a signing user. See wrapped call `place_limit_order`.
    public entry fun place_limit_order_user<B, Q, E>(
        user: &signer,
        host: address,
        side: bool,
        base_parcels: u64,
        price: u64,
    ) acquires EconiaCapabilityStore, OrderBook {
        // Place limit order with no custodian flag
        place_limit_order<B, Q, E>(
            address_of(user), host, NO_CUSTODIAN, side, base_parcels, price);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel limit order on book and unmark in user's market account.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    ///
    /// # Abort conditions
    /// * If no such `OrderBook` under `host` account
    /// * If the specified `order_id` is not on given `side` for
    ///   corresponding `OrderBook`
    /// * If `user` is not the user who placed the order with the
    ///   corresponding `order_id`
    /// * If `custodian_id` is not the same as that indicated on order
    ///   with the corresponding `order_id`
    fun cancel_limit_order<B, Q, E>(
        user: address,
        host: address,
        custodian_id: u64,
        side: bool,
        order_id: u128
    ) acquires EconiaCapabilityStore, OrderBook {
        // Assert host has an order book
        assert!(exists<OrderBook<B, Q, E>>(host), E_NO_ORDER_BOOK);
        // Borrow mutable reference to order book
        let order_book_ref_mut = borrow_global_mut<OrderBook<B, Q, E>>(host);
        // Get mutable reference to orders tree for corresponding side
        let tree_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks else
            &mut order_book_ref_mut.bids;
        // Assert order is on book
        assert!(critbit::has_key(tree_ref_mut, order_id), E_NO_SUCH_ORDER);
        let Order{ // Pop and unpack order from book,
            base_parcels: _, // Drop base parcel count
            user: order_user, // Save indicated user for checking later
            custodian_id: order_custodian_id // Save indicated custodian
        } = critbit::pop(tree_ref_mut, order_id);
        // Assert user attempting to cancel is user on order
        assert!(user == order_user, E_INVALID_USER);
        // Assert custodian attempting to cancel is custodian on order
        assert!(custodian_id == order_custodian_id, E_INVALID_CUSTODIAN);
        // If cancelling an ask that was previously the spread maker
        if (side == ASK && order_id == order_book_ref_mut.min_ask) {
            // Update minimum ask to default value if tree is empty
            order_book_ref_mut.min_ask = if (critbit::is_empty(tree_ref_mut))
                // Else to the minimum ask on the book
                MIN_ASK_DEFAULT else critbit::min_key(tree_ref_mut);
        // Else if cancelling a bid that was previously the spread maker
        } else if (side == BID && order_id == order_book_ref_mut.max_bid) {
            // Update maximum bid to default value if tree is empty
            order_book_ref_mut.max_bid = if (critbit::is_empty(tree_ref_mut))
                // Else to the maximum bid on the book
                MAX_BID_DEFAULT else critbit::max_key(tree_ref_mut);
        };
        // Remove order from corresponding user's market account
        user::remove_order_internal<B, Q, E>(user, custodian_id, side,
            order_id, &get_econia_capability());
    }

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

    /// Place limit order on the book and in user's market account.
    ///
    /// # Parameters
    /// * `user`: Address of user submitting order
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `custodian_id`: Serial ID of delegated custodian for `user`'s
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `base_parcels`: Number of base parcels the order is for
    /// * `price`: Order price
    ///
    /// # Abort conditions
    /// * If `host` does not have corresponding `OrderBook`
    /// * If order does not pass `user::add_order_internal` error checks
    /// * If new order crosses the spread (temporary)
    ///
    /// # Assumes
    /// * Orders tree will not alread have an order with the same ID as
    ///   the new order because order IDs are generated from a
    ///   counter that increases when queried (via `get_serial_id`)
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
        let order_id = // Get order ID based on new book serial ID/side
            order_id::order_id(price, get_serial_id(order_book_ref_mut), side);
        // Add order to user's market account (performs extensive error
        // checking)
        user::add_order_internal<B, Q, E>(user, custodian_id, side, order_id,
            base_parcels, price, &get_econia_capability());
        // Get mutable reference to orders tree for corresponding side,
        // determine if new order ID is new spread maker, determine if
        // new order crosses the spread, and get mutable reference to
        // spread maker for given side
        let (tree_ref_mut, new_spread_maker, crossed_spread,
            spread_maker_ref_mut) = if (side == ASK) (
                &mut order_book_ref_mut.asks,
                (order_id < order_book_ref_mut.min_ask),
                (price <= order_id::price(order_book_ref_mut.max_bid)),
                &mut order_book_ref_mut.min_ask
            ) else ( // If order is a bid
                &mut order_book_ref_mut.bids,
                (order_id > order_book_ref_mut.max_bid),
                (price >= order_id::price(order_book_ref_mut.min_ask)),
                &mut order_book_ref_mut.max_bid
            );
        // Assert spread uncrossed
        assert!(!crossed_spread, E_CROSSED_SPREAD);
        // If a new spread maker, mark as such on book
        if (new_spread_maker) *spread_maker_ref_mut = order_id;
        // Insert order to corresponding tree
        critbit::insert(tree_ref_mut, order_id,
            Order{base_parcels, user, custodian_id});
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Scale factor for test market (`registry::F1`)
    const SCALE_FACTOR: u64 = 10;
    #[test_only]
    /// Number of base coins `@user` starts with as collateral
    const USER_BASE_COINS_START: u64 = 1000000;
    #[test_only]
    /// Number of quote coins `@user` starts with as collateral
    const USER_QUOTE_COINS_START: u64 = 2000000;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return `true` if `OrderBook` at `host` has `Order` with given
    /// `order_id` on given `side`.
    ///
    /// # Assumes
    /// * `host` has `OrderBook` as specified
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun has_order_test<B, Q, E>(
        host: address,
        side: bool,
        order_id: u128,
    ): bool
    acquires OrderBook {
        // Borrow immutable reference to order book
        let order_book_ref = borrow_global<OrderBook<B, Q, E>>(host);
        // Borrow immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Return if orders tree has given order ID
        critbit::has_key(tree_ref, order_id)
    }

    #[test_only]
    /// Return fields of `Order` having `order_id` on `side` of
    /// `OrderBook` at `host`.
    ///
    /// # Assumes
    /// * `OrderBook` for given market exists at `host` with `Order`
    ///   having `order_id` on given `side`
    ///
    /// # Returns
    /// * `u64`: `Order.base_parcels`
    /// * `address`: `Order.user`
    /// * `u64`: `Order.custodian_id`
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun order_fields_test<B, Q, E>(
        host: address,
        order_id: u128,
        side: bool
    ): (
        u64,
        address,
        u64
    ) acquires OrderBook {
        // Borrow immutable reference to order book
        let order_book_ref = borrow_global<OrderBook<B, Q, E>>(host);
        // Borrow immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Get immutable reference to order with given ID
        let order_ref = critbit::borrow(tree_ref, order_id);
        // Return order fields
        (order_ref.base_parcels, order_ref.user, order_ref.custodian_id)
    }

    #[test_only]
    /// Initialize a test market hosted by Econia, then register `user`
    /// with corresponding market account having `custodian_id`.
    fun register_market_with_user_test(
        econia: &signer,
        user: &signer,
        custodian_id: u64
    ) acquires EconiaCapabilityStore {
        coins::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initialize registry
        // Initialize Econia capability store
        init_econia_capability_store(econia);
        // Register test market with Econia as host
        register_market<BC, QC, E1>(econia);
        // Set custodian ID as in bounds
        registry::set_registered_custodian(custodian_id);
        // Register user to trade on the account
        user::register_market_account<BC, QC, E1>(user, custodian_id);
        // Get market account info
        let market_account_info =
            user::market_account_info<BC, QC, E1>(custodian_id);
        // Deposit base coin collateral
        user::deposit_collateral<BC>(address_of(user), market_account_info,
            coins::mint<BC>(econia, USER_BASE_COINS_START));
        // Deposit quote coin collateral
        user::deposit_collateral<QC>(address_of(user), market_account_info,
            coins::mint<QC>(econia, USER_QUOTE_COINS_START));
    }

    #[test_only]
    /// If `side` is `ASK`, return minimum ask order ID field for
    /// `OrderBook` at `host`, else the maximum bid order ID field.
    ///
    /// # Assumes
    /// * `OrderBook` for given market exists at `host`
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun spread_maker_test<B, Q, E>(
        host: address,
        side: bool
    ): u128
    acquires OrderBook {
        // Borrow immutable reference to order book
        let order_book_ref = borrow_global<OrderBook<B, Q, E>>(host);
        // Return spread maker
        if (side == ASK) order_book_ref.min_ask else order_book_ref.max_bid
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful cancellation for asks
    fun test_cancel_limit_order_ask(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = ASK; // Declare side
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare upcoming order parameters
        let (base_parcels_0, price_0, serial_id_0) = (10, 23, 0);
        let (base_parcels_1, price_1, serial_id_1) = (11, 22, 1);
        let (base_parcels_2, price_2, serial_id_2) = (12, 21, 2);
        // Get order IDs
        let order_id_0 = order_id::order_id(price_0, serial_id_0, side);
        let order_id_1 = order_id::order_id(price_1, serial_id_1, side);
        let order_id_2 = order_id::order_id(price_2, serial_id_2, side);
        // Place orders on book
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_0, price_0);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_1, price_1);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_2, price_2);
        // Assert all orders on book
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_0), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        // Cancel order that is not spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_0);
        // Assert user-side state updates
        let (base_coins_total, base_coins_available) = user::
            get_collateral_counts_test<BC, QC, E1, BC>(@user, NO_CUSTODIAN);
        assert!(base_coins_total == USER_BASE_COINS_START, 0);
        assert!(base_coins_available == USER_BASE_COINS_START -
            SCALE_FACTOR * (base_parcels_1 + base_parcels_2), 0);
        assert!(!user::has_order_test<BC, QC, E1>(@user, NO_CUSTODIAN,
            side, order_id_0), 0);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_0), 0);
        // Assert spread maker field unmodified
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_2, 0);
        // Cancel spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_2);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        // Assert spread maker field updates
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_1);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        // Assert spread maker field updates
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) ==
            MIN_ASK_DEFAULT, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful cancellation for bids
    fun test_cancel_limit_order_bid(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = BID; // Declare side
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare upcoming order parameters
        let (base_parcels_0, price_0, serial_id_0) = (10, 21, 0);
        let (base_parcels_1, price_1, serial_id_1) = (11, 22, 1);
        let (base_parcels_2, price_2, serial_id_2) = (12, 23, 2);
        // Get order IDs
        let order_id_0 = order_id::order_id(price_0, serial_id_0, side);
        let order_id_1 = order_id::order_id(price_1, serial_id_1, side);
        let order_id_2 = order_id::order_id(price_2, serial_id_2, side);
        // Place orders on book
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_0, price_0);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_1, price_1);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_2, price_2);
        // Assert all orders on book
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_0), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        // Cancel order that is not spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_0);
        // Assert user-side state updates
        let (quote_coins_total, quote_coins_available) = user::
            get_collateral_counts_test<BC, QC, E1, QC>(@user, NO_CUSTODIAN);
        assert!(quote_coins_total == USER_QUOTE_COINS_START, 0);
        assert!(quote_coins_available == USER_QUOTE_COINS_START -
            (base_parcels_1 * price_1 + base_parcels_2 * price_2), 0);
        assert!(!user::has_order_test<BC, QC, E1>(@user, NO_CUSTODIAN,
            side, order_id_0), 0);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_0), 0);
        // Assert spread maker field unmodified
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_2, 0);
        // Cancel spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_2);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        // Assert spread maker field updates
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_1);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        // Assert spread maker field updates
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) ==
            MAX_BID_DEFAULT, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful spread maker updates when multiple candidates
    /// for next spread maker
    fun test_cancel_limit_order_spread_maker(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = ASK; // Declare side
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare upcoming order parameters
        let (base_parcels_0, price_0, serial_id_0) = (10, 71, 0);
        let (base_parcels_1, price_1, serial_id_1) = (11, 72, 1);
        let (base_parcels_2, price_2) = (12, 73);
        let (base_parcels_3, price_3) = (13, 74);
        // Get order IDs
        let order_id_0 = order_id::order_id(price_0, serial_id_0, side);
        let order_id_1 = order_id::order_id(price_1, serial_id_1, side);
        // Place orders on book
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_0, price_0);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_1, price_1);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_2, price_2);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_3, price_3);
        // Cancel spread maker when multiple candidtates for max/min
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_0);
        // Assert spread maker updates correctly
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        let side = BID; // Declare new side
        // Declare upcoming order parameters
        let (base_parcels_4, price_4) = (10, 21);
        let (base_parcels_5, price_5) = (11, 22);
        let (base_parcels_6, price_6, serial_id_6) = (12, 23, 6);
        let (base_parcels_7, price_7, serial_id_7) = (13, 24, 7);
        // Get order IDs
        let order_id_6 = order_id::order_id(price_6, serial_id_6, side);
        let order_id_7 = order_id::order_id(price_7, serial_id_7, side);
        // Place orders on book
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_4, price_4);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_5, price_5);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_6, price_6);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels_7, price_7);
        // Cancel spread maker when multiple candidtates for max/min
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            order_id_7);
        // Assert spread maker updates correctly
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_6, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for invalid custodian
    fun test_cancel_limit_order_invalid_custodian(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = ASK; // Declare side
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare upcoming order parameters
        let (base_parcels, price, serial_id) = (11, 12, 0);
        // Get order id
        let order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place order on book
        cancel_limit_order<BC, QC, E1>( // Attempt invalid cancel
            @user, @econia, 1, side, order_id);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid user
    fun test_cancel_limit_order_invalid_user(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = ASK; // declare side
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare upcoming order parameters
        let (base_parcels, price, serial_id) = (11, 12, 0);
        // Get order ID
        let order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place order on book
        cancel_limit_order<BC, QC, E1>( // Attempt invalid cancel
            @econia, @econia, NO_CUSTODIAN, side, order_id);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for no registered order book at host
    fun test_cancel_limit_order_no_book()
    acquires EconiaCapabilityStore, OrderBook {
        // Attempt invalid invocation
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, ASK, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for no such order on book
    fun test_cancel_limit_order_no_order(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Register market with test user
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Attempt invalid invocation of order cancellation
        cancel_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, ASK, 0);
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

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify limit order placement and cancellation by custodian
    fun test_place_cancel_limit_order_custodian(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id, serial_id) =
            (ASK, 10, 12, 25, 0);
        // Get order ID
        let order_id = order_id::order_id(price, serial_id, side);
        // Register user with market account for given custodian ID
        register_market_with_user_test(econia, user, custodian_id);
        // Get custodian capability w/ corresponding ID
        let custodian_capability =
            registry::get_custodian_capability(custodian_id);
        // Have custodian place limit order
        place_limit_order_custodian<BC, QC, E1>(@user, @econia, side,
            base_parcels, price, &custodian_capability);
        // Assert base parcels for order in user's market account
        assert!(user::order_base_parcels_test<BC, QC, E1>(
            @user, custodian_id, side, order_id) == base_parcels, 0);
        // Get fields for order on book having given order ID
        let (order_base_parcels, order_user, order_custodian_id) =
            order_fields_test<BC, QC, E1>(@econia, order_id, side);
        // Assert order fields
        assert!(order_base_parcels == base_parcels, 0);
        assert!(order_user == @user, 0);
        assert!(order_custodian_id == custodian_id, 0);
        // Have custodian cancel limit order
        cancel_limit_order_custodian<BC, QC, E1>(@user, @econia, side,
            order_id, &custodian_capability);
        // Assert user no longer has order
        assert!(!user::has_order_test<BC, QC, E1>(
            @user, custodian_id, side, order_id), 0);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id), 0);
        // Destroy custodian capability
        registry::destroy_custodian_capability(custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify limit order placement and cancellation by signing user
    fun test_place_cancel_limit_order_user(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id, serial_id) =
            ( ASK,           10,    12, NO_CUSTODIAN,         0);
        // Get order ID
        let order_id = order_id::order_id(price, serial_id, side);
        // Register user with market account for given custodian ID
        register_market_with_user_test(econia, user, custodian_id);
        // Have user place limit order
        place_limit_order_user<BC, QC, E1>(user, @econia, side,
            base_parcels, price);
        // Assert base parcels for order in user's market account
        assert!(user::order_base_parcels_test<BC, QC, E1>(
            @user, custodian_id, side, order_id) == base_parcels, 0);
        // Get fields for order on book having given order ID
        let (order_base_parcels, order_user, order_custodian_id) =
            order_fields_test<BC, QC, E1>(@econia, order_id, side);
        // Assert order fields
        assert!(order_base_parcels == base_parcels, 0);
        assert!(order_user == @user, 0);
        assert!(order_custodian_id == custodian_id, 0);
        // Have user cancel limit order
        cancel_limit_order_user<BC, QC, E1>(user, @econia, side, order_id);
        // Assert user no longer has order
        assert!(!user::has_order_test<BC, QC, E1>(
            @user, custodian_id, side, order_id), 0);
        // Assert order no longer on book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful order placement
    fun test_place_limit_order_ask(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = ASK; // Declare side
        // Register market and user with a market account on it
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare order parameters
        let (base_parcels, price, serial_id) = (15, 25, 0);
        // Get order id
        let order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place limit order
        // Assert user-side state updates
        let (base_coins_total, base_coins_available) = user::
            get_collateral_counts_test<BC, QC, E1, BC>(@user, NO_CUSTODIAN);
        assert!(base_coins_total == USER_BASE_COINS_START, 0);
        assert!(base_coins_available ==
            USER_BASE_COINS_START - SCALE_FACTOR * base_parcels, 0);
        assert!(user::order_base_parcels_test<BC, QC, E1>(@user, NO_CUSTODIAN,
            side, order_id) == base_parcels, 0);
        // Get fields for order on book having given order ID
        let (order_base_parcels, order_user, order_custodian_id) =
            order_fields_test<BC, QC, E1>(@econia, order_id, side);
        assert!(order_base_parcels == base_parcels, 0);
        assert!(order_user == @user, 0);
        assert!(order_custodian_id == NO_CUSTODIAN, 0);
        // Assert spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
        // Update order parameters for new spread maker
        (base_parcels, price, serial_id) = (10, 24, 1);
        // Get new order id
        order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place limit order
        // Assert spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
        // Place limit order that does not cause new spread maker
        place_limit_order<BC, QC, E1>(
            @user, @econia, NO_CUSTODIAN, side, 1, 26);
        // Assert no spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful order placement
    fun test_place_limit_order_bid(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let side = BID; // Declare side
        // Register market and user with a market account on it
        register_market_with_user_test(econia, user, NO_CUSTODIAN);
        // Declare order parameters
        let (base_parcels, price, serial_id) = (15, 25, 0);
        // Get order id
        let order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place limit order
        // Assert user-side state updates
        let (quote_coins_total, quote_coins_available) = user::
            get_collateral_counts_test<BC, QC, E1, QC>(@user, NO_CUSTODIAN);
        assert!(quote_coins_total == USER_QUOTE_COINS_START, 0);
        assert!(quote_coins_available ==
            USER_QUOTE_COINS_START - price * base_parcels, 0);
        assert!(user::order_base_parcels_test<BC, QC, E1>(@user, NO_CUSTODIAN,
            side, order_id) == base_parcels, 0);
        // Get fields for order on book having given order ID
        let (order_base_parcels, order_user, order_custodian_id) =
            order_fields_test<BC, QC, E1>(@econia, order_id, side);
        assert!(order_base_parcels == base_parcels, 0);
        assert!(order_user == @user, 0);
        assert!(order_custodian_id == NO_CUSTODIAN, 0);
        // Assert spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
        // Update order parameters for new spread maker
        (base_parcels, price, serial_id) = (10, 26, 1);
        // Get new order id
        order_id = order_id::order_id(price, serial_id, side);
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, side,
            base_parcels, price); // Place limit order
        // Assert spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
        // Place limit order that does not cause new spread maker
        place_limit_order<BC, QC, E1>(
            @user, @econia, NO_CUSTODIAN, side, 1, 24);
        // Assert no spread maker update
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for placing limit order that crosses spread
    fun test_place_limit_order_crossed_spread_ask(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id) =
            ( BID,           10,    12, NO_CUSTODIAN);
        // Register user with market account
        register_market_with_user_test(econia, user, custodian_id);
        // Place limit order
        place_limit_order<BC, QC, E1>(@user, @econia, custodian_id, side,
            base_parcels, price);
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id) =
            ( ASK,           10,    12, NO_CUSTODIAN);
        // Attempt placing limit order
        place_limit_order<BC, QC, E1>(@user, @econia, custodian_id, side,
            base_parcels, price);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for placing limit order that crosses spread
    fun test_place_limit_order_crossed_spread_bid(
        econia: &signer,
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id) =
            ( ASK,           10,    12, NO_CUSTODIAN);
        // Register user with market account
        register_market_with_user_test(econia, user, custodian_id);
        // Place limit order
        place_limit_order<BC, QC, E1>(@user, @econia, custodian_id, side,
            base_parcels, price);
        // Define parameters for upcoming order
        let (side, base_parcels, price, custodian_id) =
            ( BID,           10,    12, NO_CUSTODIAN);
        // Attempt placing limit order
        place_limit_order<BC, QC, E1>(@user, @econia, custodian_id, side,
            base_parcels, price);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for no initialized order book
    fun test_place_limit_order_no_order_book()
    acquires EconiaCapabilityStore, OrderBook {
        place_limit_order<BC, QC, E1>(@user, @econia, NO_CUSTODIAN, ASK,
            10, 10); // Attempt invalid invocation
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