/// Market-level book keeping functionality, with matching engine.
/// Allows for self-matched trades since preventing them is practically
/// impossible in a permissionless market: all a user has to do is
/// open two wallets and trade them against each other.
module econia::market {

    /// Dependency stub planning
    fun invoke_user() {user::return_0();}

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::order_id;
    use econia::registry::{Self, CustodianCapability};
    use econia::user;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use aptos_framework::coin;
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
    /// When a host does not have an `OrderBooks`
    const E_NO_ORDER_BOOKS: u64 = 1;
    /// When indicated `OrderBook` does not exist
    const E_NO_ORDER_BOOK: u64 = 2;
    /// When a post-or-abort limit order crosses the spread
    const E_POST_OR_ABORT_CROSSED_SPREAD: u64 = 8;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
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

    /// Increment counter for number of orders placed on `OrderBook`,
    /// returning the original value.
    fun get_counter(
        order_book_ref_mut: &mut OrderBook
    ): u64 {
        // Borrow mutable reference to order book serial counter
        let counter_ref_mut = &mut order_book_ref_mut.counter;
        let count = *counter_ref_mut; // Get count
        *counter_ref_mut = count + 1; // Set new count
        count // Return original count
    }

    /// Place limit order against book and optionally register in user's
    /// market account.
    ///
    /// If `post_or_abort` is false and the order crosses the spread, it
    /// will match as a taker order against all orders it crosses, then
    /// the remaining `size` will be placed as a maker order.
    ///
    /// # Parameters
    /// * `user`: Address of user submitting order
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `market_id`: Market ID
    /// * `general_custodian_id`: General custodian ID for `user`'s
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `size`: Number of lots the order is for
    /// * `price`: Order price, in ticks per lot
    /// * `post_or_abort`:  If `true`, abort for orders that cross the
    ///   spread, otherwise fill across the spread when applicable
    ///
    /// # Abort conditions
    /// * If `post_or_abort` is `true` and order crosses the spread
    fun place_limit_order(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool
    ) acquires OrderBooks {
        // Verify order book exists
        verify_order_book_exists(host, market_id);
        // Borrow mutable reference to order books map
        let order_books_map_ref_mut =
            &mut borrow_global_mut<OrderBooks>(host).map;
        // Borrow mutable reference to order book
        let order_book_ref_mut =
            open_table::borrow_mut(order_books_map_ref_mut, market_id);
        // Determine if spread crossed
        let crossed_spread = if (side == ASK)
            (price <= order_id::price(order_book_ref_mut.max_bid)) else
            (price >= order_id::price(order_book_ref_mut.min_ask));
        // Assert spread uncrossed if a post-or-abort order
        assert!(!(post_or_abort && crossed_spread),
            E_POST_OR_ABORT_CROSSED_SPREAD);
        if (crossed_spread) {
            abort 0 // Temporary
            // Match against book until price threshold hit
            // Store return value as new size
        };
        if (size > 0) { // If still size left to fill
            // Get new order ID based on book counter/side
            let order_id = order_id::order_id(
                price, get_counter(order_book_ref_mut), side);
            // Get market account ID for given user
            let market_account_id = user::get_market_account_id(market_id,
                general_custodian_id);
            // Add order to user's market account
            user::register_order_internal(user, market_account_id, side,
                order_id, size, price, order_book_ref_mut.lot_size,
                order_book_ref_mut.tick_size);
            // Get mutable reference to orders tree for given side,
            // determine if order is new spread maker, and get mutable
            // reference to spread maker for given side
            let (tree_ref_mut, new_spread_maker, spread_maker_ref_mut) =
                if (side == ASK) (
                    &mut order_book_ref_mut.asks,
                    (order_id < order_book_ref_mut.min_ask),
                    &mut order_book_ref_mut.min_ask
                ) else ( // If order is a bid
                    &mut order_book_ref_mut.bids,
                    (order_id > order_book_ref_mut.max_bid),
                    &mut order_book_ref_mut.max_bid
                );
            // If a new spread maker, mark as such on book
            if (new_spread_maker) *spread_maker_ref_mut = order_id;
            // Insert order to corresponding tree
            critbit::insert(tree_ref_mut, order_id,
                Order{size, user, general_custodian_id});
        }
    }

    /// Register new market under signing host.
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

    /// Verify `host` has an `OrderBook` with `market_id`
    ///
    /// # Abort conditions
    /// * If user does not have an `OrderBooks`
    /// * If user does not have an `OrderBook` for given `market_id`
    fun verify_order_book_exists(
        host: address,
        market_id: u64
    ) acquires OrderBooks {
        // Assert host has an order books map
        assert!(exists<OrderBooks>(host), E_NO_ORDER_BOOKS);
        // Borrow immutable reference to order books map
        // Borrow immutable reference to market accounts map
        let order_books_map_ref = &borrow_global<OrderBooks>(host).map;
        // Assert host has an entry in map for market account ID
        assert!(open_table::contains(order_books_map_ref, market_id),
            E_NO_ORDER_BOOK);
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Market parameters
    #[test_only]
    /// Market ID for first registered market
    const MARKET_ID: u64 = 0;
    #[test_only]
    /// Lot size for test market
    const LOT_SIZE: u64 = 10;
    #[test_only]
    /// Tick size for test market
    const TICK_SIZE: u64 = 25;
    #[test_only]
    /// Generic asset transfer custodian ID for test market
    const GENERIC_ASSET_TRANSFER_CUSTODIAN_ID: u64 = 1;

    // User parameters
    #[test_only]
    /// Base asset amount `@user` starts with
    const USER_START_BASE: u64  = 100000000000;
    #[test_only]
    /// Quote asset amount `@user` starts with
    const USER_START_QUOTE: u64 = 200000000000;
    #[test_only]
    /// General custodian ID for test market user
    const GENERAL_CUSTODIAN_ID: u64 = 2;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return fields of `Order` for given `host`, `market_id`,
    /// `order_id`, and `side`.
    ///
    /// # Assumes
    /// * `OrderBook` for given `market_id` exists at `host` with
    ///   `Order` having `order_id` on given `side`
    ///
    /// # Returns
    /// * `u64`: `Order.size`
    /// * `address`: `Order.user`
    /// * `u64`: `Order.general_custodian_id`
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun get_order_fields_test(
        host: address,
        market_id: u64,
        order_id: u128,
        side: bool
    ): (
        u64,
        address,
        u64
    ) acquires OrderBooks {
        // Borrow immutable reference to order books map
        let order_books_map_ref = &borrow_global_mut<OrderBooks>(host).map;
        // Borrow immutable reference to order book
        let order_book_ref =
            open_table::borrow(order_books_map_ref, market_id);
        // Borrow immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Get immutable reference to order with given ID
        let order_ref = critbit::borrow(tree_ref, order_id);
        // Get order fields, shortened
        let (size, user, general_custodian_id) =
            (order_ref.size, order_ref.user, order_ref.general_custodian_id);
        // Return order fields
        (size, user, general_custodian_id)
    }

    #[test_only]
    /// If `side` is `ASK`, return minimum ask order ID field for
    /// `OrderBook` at `host` with `market_id`, else the maximum bid
    /// order ID field.
    ///
    /// # Assumes
    /// * `OrderBook` for given market exists at `host`
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun get_spread_maker_test(
        host: address,
        market_id: u64,
        side: bool
    ): u128
    acquires OrderBooks {
        // Borrow immutable reference to order books map
        let order_books_map_ref = &borrow_global_mut<OrderBooks>(host).map;
        // Borrow immutable reference to order book
        let order_book_ref =
            open_table::borrow(order_books_map_ref, market_id);
        // Return spread maker
        if (side == ASK) order_book_ref.min_ask else order_book_ref.max_bid
    }

    #[test_only]
    /// Return `true` if `OrderBook` at `host` for given `market_id` has
    /// `Order` with given `order_id` on given `side`.
    ///
    /// # Assumes
    /// * `host` has `OrderBook` as specified
    ///
    /// # Restrictions
    /// * Restricted to private and test-only to prevent excessive
    ///   public queries and thus transaction collisions
    fun has_order_test(
        host: address,
        market_id: u64,
        side: bool,
        order_id: u128,
    ): bool
    acquires OrderBooks {
        // Borrow immutable reference to order books map
        let order_books_map_ref = &borrow_global_mut<OrderBooks>(host).map;
        // Borrow immutable reference to order book
        let order_book_ref =
            open_table::borrow(order_books_map_ref, market_id);
        // Borrow immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Return if orders tree has given order ID
        critbit::has_key(tree_ref, order_id)
    }

    #[test_only]
    /// Register test market and market account for given parameters,
    /// then fund `user`.
    ///
    /// Inner function for `register_market_funded_user_test()`
    fun register_market_funded_user_inner_test<
        BaseType,
        QuoteType
    >(
        econia: &signer,
        user: &signer,
        generic_asset_transfer_custodian_id: u64,
        general_custodian_id: u64
    ) acquires OrderBooks {
        // Register market for given parameters
        register_market<BaseType, QuoteType>(econia, LOT_SIZE, TICK_SIZE,
            generic_asset_transfer_custodian_id);
        // Register user for corresponding marking account
        user::register_market_account<BaseType, QuoteType>(user, MARKET_ID,
            general_custodian_id);
        // Determine if base is a coin type
        let base_is_coin = coin::is_coin_initialized<BaseType>();
        // Determine if quote is a coin type
        let quote_is_coin = coin::is_coin_initialized<QuoteType>();
        // Determine if a pure coin pair
        let pure_coin = base_is_coin && quote_is_coin;
        if (!pure_coin) { // If not a pure coin market
            // Get generic asset transfer custodian capability
            let generic_asset_transfer_custodian_capability = registry::
                get_custodian_capability_test(
                    generic_asset_transfer_custodian_id);
            // If base asset is generic, deposit asset accordingly
            if (!base_is_coin) user::deposit_generic_asset<BG>(
                    address_of(user), MARKET_ID, general_custodian_id,
                    USER_START_BASE,
                    &generic_asset_transfer_custodian_capability
                );
            // If quote asset is generic, deposit asset accordingly
            if (!quote_is_coin) user::deposit_generic_asset<QG>(
                    address_of(user), MARKET_ID, general_custodian_id,
                    USER_START_QUOTE,
                    &generic_asset_transfer_custodian_capability
                );
            // Destroy custodian capability
            registry::destroy_custodian_capability_test(
                generic_asset_transfer_custodian_capability);
        };
        // If base asset is coin, deposit asset accordingly
        if (base_is_coin) user::deposit_coins<BC>(
            address_of(user), MARKET_ID, general_custodian_id,
            assets::mint<BC>(econia, USER_START_BASE)
        );
        // If quote asset is coin, deposit asset accordingly
        if (quote_is_coin) user::deposit_coins<QC>(
            address_of(user), MARKET_ID, general_custodian_id,
            assets::mint<QC>(econia, USER_START_QUOTE)
        );
    }

    #[test_only]
    /// Initialize Econia-hosted test market with registered user.
    ///
    /// See test-only constants for market parameters.
    ///
    /// Parameters
    /// * `econia`: `@econia` signature
    /// * `user`: `@user` signature
    /// * `base_is_coin`: If `true` use `BC` for base asset, else `BG`
    /// * `quote_is_coin`: If `true` use `QC` for quote asset, else `QG`
    /// * `has_general_custodian`: If `true`, register user's market to
    ///   require a general custodian ID
    fun register_market_funded_user_test(
        econia: &signer,
        user: &signer,
        base_is_coin: bool,
        quote_is_coin: bool,
        has_general_custodian: bool
    ) acquires OrderBooks {
        // Determine if market is pure coin market
        let pure_coin = base_is_coin && quote_is_coin;
        // Determine if market is pure generic market
        let pure_generic = !base_is_coin && !quote_is_coin;
        // Initialize coin types if not purely generic
        if (!pure_generic) assets::init_coin_types(econia);
        registry::init_registry(econia); // Initialize registry
        // Get generic asset transfer custodian ID if not pure coin
        let generic_asset_transfer_custodian_id = if (pure_coin)
            PURE_COIN_PAIR else GENERIC_ASSET_TRANSFER_CUSTODIAN_ID;
        // Get general custodian ID if one is indicated
        let general_custodian_id = if (has_general_custodian)
            GENERAL_CUSTODIAN_ID else NO_CUSTODIAN;
        // Set as a registered custodian ID the higher ID number
        if (general_custodian_id > generic_asset_transfer_custodian_id)
            registry::set_registered_custodian_test(general_custodian_id) else
            registry::set_registered_custodian_test(
                generic_asset_transfer_custodian_id);
        if (base_is_coin) { // If base asset is coin
            if (quote_is_coin) { // If quote asset is coin
                // Register market and market account accordingly
                register_market_funded_user_inner_test<BC, QC>(econia, user,
                    generic_asset_transfer_custodian_id, general_custodian_id);
            } else { // If quote asset is generic
                // Register market and market account accordingly
                register_market_funded_user_inner_test<BC, QG>(econia, user,
                    generic_asset_transfer_custodian_id, general_custodian_id);
            };
        } else { // If base asset is generic
            if (quote_is_coin) { // If quote asset is coin
                // Register market and market account accordingly
                register_market_funded_user_inner_test<BG, QC>(econia, user,
                    generic_asset_transfer_custodian_id, general_custodian_id);
            } else { // If quote asset is generic
                // Register market and market account accordingly
                register_market_funded_user_inner_test<BG, QG>(econia, user,
                    generic_asset_transfer_custodian_id, general_custodian_id);
            };
        };
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(user = @user)]
    fun test_get_counter(
        user: &signer
    ) acquires OrderBooks {
        // Declare order book parameters
        let (market_id, tick_size, lot_size) = (0, 1, 2);
        // Register an order book
        register_order_book<BG, QG>(user, market_id, lot_size, tick_size);
        // Borrow mutable reference to order books map
        let order_books_map_ref_mut =
            &mut borrow_global_mut<OrderBooks>(@user).map;
        // Borrow mutable reference to order book
        let order_book_ref_mut =
            open_table::borrow_mut(order_books_map_ref_mut, market_id);
        // Assert counter returns
        assert!(get_counter(order_book_ref_mut) == 0, 0);
        assert!(get_counter(order_book_ref_mut) == 1, 0);
        assert!(get_counter(order_book_ref_mut) == 2, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful ask placement
    fun test_place_limit_order_ask(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Get market account ID
        let market_account_id =
            user::get_market_account_id(MARKET_ID, general_custodian_id);
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let base_fill_1 = size_1 * LOT_SIZE;
        let quote_fill_1 = size_1 * price_1 * TICK_SIZE;
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let base_fill_2 = size_2 * LOT_SIZE;
        let quote_fill_2 = size_2 * price_1 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, MARKET_ID,
                general_custodian_id);
        let order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_1);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE - base_fill_1, 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE + quote_fill_1, 0);
        assert!(order_size      == size_1, 0);
        // Get book state
        let (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_1, side);
        let spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_1, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place order at same price, not setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_2, price_2, post_or_abort_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, MARKET_ID,
                general_custodian_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_2);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
                                   (base_fill_1 + base_fill_2), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
                                   (quote_fill_1 + quote_fill_2), 0);
        assert!(order_size      == size_2, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_2, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_2, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful bid placement
    fun test_place_limit_order_bid(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Get market account ID
        let market_account_id =
            user::get_market_account_id(MARKET_ID, general_custodian_id);
        // Declare market parameters
        let side = BID;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let base_fill_1 = size_1 * LOT_SIZE;
        let quote_fill_1 = size_1 * price_1 * TICK_SIZE;
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let base_fill_2 = size_2 * LOT_SIZE;
        let quote_fill_2 = size_2 * price_1 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, MARKET_ID,
                general_custodian_id);
        let order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_1);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE + base_fill_1, 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE - quote_fill_1, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_1, 0);
        // Get book state
        let (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_1, side);
        let spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_1, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place order at same price, not setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_2, price_2, post_or_abort_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, MARKET_ID,
                general_custodian_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_2);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
                                   (base_fill_1 + base_fill_2), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
                                   (quote_fill_1 + quote_fill_2), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_2, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_2, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_2, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for post-or-abort crossed spread
    fun test_place_limit_order_crossed_spread_ask(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Register market and user
        register_market_funded_user_test(econia, user, true, true, false);
        // Place a bid
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, BID, 10,
            5, false);
        // Place a post-or-abort limit order that crosses spread
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, ASK, 10,
            4, true);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for post-or-abort crossed spread
    fun test_place_limit_order_crossed_spread_bid(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Register market and user
        register_market_funded_user_test(econia, user, true, true, false);
        // Place a bid
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, ASK, 10,
            5, false);
        // Place a post-or-abort limit order that crosses spread
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, BID, 10,
            6, true);
    }

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

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no `OrderBook` with given market ID
    fun test_verify_order_book_exists_no_order_book(
        user: &signer
    ) acquires OrderBooks {
        // Register an order book
        register_order_book<BG, QG>(user, 0, 1, 2);
        // Attempt invalid invocation
        verify_order_book_exists(@user, 1);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no `OrderBooks`
    fun test_verify_order_book_exists_no_order_books()
    acquires OrderBooks {
        // Attempt invalid invocation
        verify_order_book_exists(@user, 0);
    }

    #[test(user = @user)]
    /// Verify run to completion without error
    fun test_verify_order_book_exists(
        user: &signer
    ) acquires OrderBooks {
        // Register an order book
        register_order_book<BG, QG>(user, 0, 1, 2);
        // Verify it was registered
        verify_order_book_exists(@user, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}