/// Market-level book keeping functionality, with matching engine.
module econia::market {

    /// Dependency stub planning
    fun invoke_user() {user::return_0();}

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::registry::{Self, CustodianCapability};
    use econia::user;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, BC, BG, QC, QG};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// An order on the order book
    struct Order has store {
        /// Number of lots to be filled
        size: u64,
        /// Address of corresponding user
        user: address,
        /// For given user, the ID of the custodian required to approve
        /// transactions other than generic asset transfers
        general_custodian_id: u64
    }

    /// An order book for a given market
    struct OrderBook has store {
        /// Base asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to a non-coin asset
        /// indicated by the market host.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds a non-coin asset
        /// indicated by the market host.
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot
        lot_size: u64,
        /// Number of quote units exchanged per tick
        tick_size: u64,
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
        /// Number of limit orders placed on book
        counter: u64
    }

    /// Order book map for all of a user's `OrderBook`s
    struct OrderBooks has key {
        /// Map from market ID to `OrderBook`. Separated into different
        /// table entries to reduce transaction collisions across
        /// markets
        map: open_table::OpenTable<u64, OrderBook>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When an order book already exists at given address
    const E_ORDER_BOOK_EXISTS: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Register a market having at least one asset that is not a coin
    /// type, which requires the authority of custodian indicated by
    /// `generic_asset_transfer_custodian_id_ref` to verify deposits
    /// and withdrawals of non-coin assets.
    ///
    /// See wrapped function `register_market()`.
    public entry fun register_market_generic<
        BaseType,
        QuoteType
    >(
        host: &signer,
        lot_size: u64,
        tick_size: u64,
        generic_asset_transfer_custodian_id_ref: &CustodianCapability
    ) acquires OrderBooks {
        register_market<BaseType, QuoteType>(
            host,
            lot_size,
            tick_size,
            registry::custodian_id(generic_asset_transfer_custodian_id_ref)
        );
    }

    #[cmd]
    /// Register a market for both base and quote assets as coin types.
    ///
    /// See wrapped function `register_market()`.
    public entry fun register_market_pure_coin<
        BaseCoinType,
        QuoteCoinType
    >(
        host: &signer,
        lot_size: u64,
        tick_size: u64,
    ) acquires OrderBooks {
        register_market<BaseCoinType, QuoteCoinType>(
            host,
            lot_size,
            tick_size,
            PURE_COIN_PAIR
        );
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register new market under signing host
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `host`: Account where order book should be stored
    /// * `lot_size`: Number of base units exchanged per lot
    /// * `tick_size`: Number of quote units exchanged per tick
    /// * `generic_asset_transfer_custodian_id`: ID of custodian
    ///    capability required to approve deposits and withdrawals of
    ///    non-coin assets
    fun register_market<
        BaseType,
        QuoteType
    >(
        host: &signer,
        lot_size: u64,
        tick_size: u64,
        generic_asset_transfer_custodian_id: u64
    ) acquires OrderBooks {
        // Register the market in the global registry, storing market ID
        let market_id =
            registry::register_market_internal<BaseType, QuoteType>(
                address_of(host), lot_size, tick_size,
                generic_asset_transfer_custodian_id);
        // Register an under book under host's account
        register_order_book<BaseType, QuoteType>(
            host, market_id, lot_size, tick_size);
    }

    /// Register host with an `OrderBook`, initializing their
    /// `OrderBooks` if they do not already have one
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `host`: Account where order book should be stored
    /// * `market_id`: Market ID
    /// * `lot_size`: Number of base units exchanged per lot
    /// * `tick_size`: Number of quote units exchanged per tick
    fun register_order_book<
        BaseType,
        QuoteType
    >(
        host: &signer,
        market_id: u64,
        lot_size: u64,
        tick_size: u64,
    ) acquires OrderBooks {
        let host_address = address_of(host); // Get host address
        // If host does not have an order books map
        if (!exists<OrderBooks>(host_address))
            // Move one to their account
            move_to<OrderBooks>(host, OrderBooks{map: open_table::empty()});
        // Borrow mutable reference to order books map
        let order_books_map_ref_mut =
            &mut borrow_global_mut<OrderBooks>(host_address).map;
        // Assert order book does not already exist under host account
        assert!(!open_table::contains(order_books_map_ref_mut, market_id),
            E_ORDER_BOOK_EXISTS);
        open_table::add(order_books_map_ref_mut, market_id, OrderBook{
            base_type_info: type_info::type_of<BaseType>(),
            quote_type_info: type_info::type_of<QuoteType>(),
            lot_size,
            tick_size,
            asks: critbit::empty(),
            bids: critbit::empty(),
            min_ask: MIN_ASK_DEFAULT,
            max_bid: MAX_BID_DEFAULT,
            counter: 0
        });
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful registration for both pure coin and generic
    /// markets
    fun test_register_markets(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        registry::init_registry(econia); // Init registry
        assets::init_coin_types(econia); // Init coin types
        // Register custodian capability
        let generic_asset_transfer_custodian_id =
            registry::register_custodian_capability();
        // Register a purely generic market
        register_market_generic<BG, QG>(user, 4, 5,
            &generic_asset_transfer_custodian_id);
        // Register a pure coin market
        register_market_pure_coin<BC, QC>(user, 6, 7);
        // Borrow immutable reference to order books map
        let order_book_map_ref = &borrow_global<OrderBooks>(@user).map;
        // Assert order books map contains entry for each market
        assert!(open_table::contains(order_book_map_ref, 0), 0);
        assert!(open_table::contains(order_book_map_ref, 1), 0);
        // Destroy capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_id);
    }

    #[test(user = @user)]
    /// Verify successful registration of multiple books
    fun test_register_order_books(
        user: &signer
    ) acquires OrderBooks {
        // Declare order book values
        let market_id_1 = 123;
        let lot_size_1 = 456;
        let tick_size_1 = 789;
        let base_type_info_1 = type_info::type_of<BC>();
        let quote_type_info_1 = type_info::type_of<QC>();
        let market_id_2 = 321;
        let lot_size_2 = 654;
        let tick_size_2 = 987;
        let base_type_info_2 = type_info::type_of<BG>();
        let quote_type_info_2 = type_info::type_of<QG>();
        // Register order books
        register_order_book<BC, QC>(
            user, market_id_1, lot_size_1, tick_size_1);
        register_order_book<BG, QG>(
            user, market_id_2, lot_size_2, tick_size_2);
        // Borrow immutable reference to order books map
        let order_books_map_ref = &borrow_global<OrderBooks>(@user).map;
        // Borrow immutable reference to first order book
        let order_book_ref_1 = open_table::borrow(
            order_books_map_ref, market_id_1);
        // Assert fields
        assert!(order_book_ref_1.base_type_info == base_type_info_1, 0);
        assert!(order_book_ref_1.quote_type_info == quote_type_info_1, 0);
        assert!(order_book_ref_1.lot_size == lot_size_1, 0);
        assert!(order_book_ref_1.tick_size == tick_size_1, 0);
        assert!(critbit::is_empty(&order_book_ref_1.asks), 0);
        assert!(critbit::is_empty(&order_book_ref_1.bids), 0);
        assert!(order_book_ref_1.max_bid == MAX_BID_DEFAULT, 0);
        assert!(order_book_ref_1.min_ask == MIN_ASK_DEFAULT, 0);
        assert!(order_book_ref_1.counter == 0, 0);
        // Borrow immutable reference to second order book
        let order_book_ref_2 = open_table::borrow(
            order_books_map_ref, market_id_2);
        // Assert fields
        assert!(order_book_ref_2.base_type_info == base_type_info_2, 0);
        assert!(order_book_ref_2.quote_type_info == quote_type_info_2, 0);
        assert!(order_book_ref_2.lot_size == lot_size_2, 0);
        assert!(order_book_ref_2.tick_size == tick_size_2, 0);
        assert!(critbit::is_empty(&order_book_ref_2.asks), 0);
        assert!(critbit::is_empty(&order_book_ref_2.bids), 0);
        assert!(order_book_ref_2.max_bid == MAX_BID_DEFAULT, 0);
        assert!(order_book_ref_2.min_ask == MIN_ASK_DEFAULT, 0);
        assert!(order_book_ref_2.counter == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempted re-registration
    fun test_register_order_book_order_book_exists(
        user: &signer
    ) acquires OrderBooks {
        // Register order book
        register_order_book<BC, QC>(user, 1, 2, 3);
        // Attempt invalid re-registration
        register_order_book<BC, QC>(user, 1, 2, 3);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}