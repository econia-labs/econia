/// Market-level book keeping functionality, with matching engine.
/// Allows for self-matched trades since preventing them is practically
/// impossible in a permissionless market: all a user has to do is
/// open two wallets and trade them against each other.
module econia::market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::order_id;
    use econia::registry::{Self, CustodianCapability};
    use econia::user;
    use std::signer::address_of;
    use std::option;

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
    /// When a host does not have an `OrderBooks`
    const E_NO_ORDER_BOOKS: u64 = 1;
    /// When indicated `OrderBook` does not exist
    const E_NO_ORDER_BOOK: u64 = 2;
   /// When order not found in book
    const E_NO_ORDER: u64 = 5;
    /// When invalid user attempts to manage an order
    const E_INVALID_USER: u64 = 6;
    /// When invalid custodian attempts to manage an order
    const E_INVALID_CUSTODIAN: u64 = 7;
    /// When a post-or-abort limit order crosses the spread
    const E_POST_OR_ABORT_CROSSED_SPREAD: u64 = 8;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;
    /// Buy direction flag
    const BUY: bool = true;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Left traversal direction, denoting predecessor traversal
    const LEFT: bool = true;
    /// Default value for maximum bid order ID
    const MAX_BID_DEFAULT: u128 = 0;
    /// Default value for minimum ask order ID
    const MIN_ASK_DEFAULT: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// Quasi-null `address` value assigned to a variable when it will
    /// be reassigned via pass-by-reference, since declaration without
    /// assignment before use is invalid
    const NULL_ADDRESS: address = @0x0;
    /// Quasi-null `bool` value assigned to a variable when it will be
    /// reassigned via pass-by-reference, since declaration without
    /// assignment before use is invalid
    const NULL_BOOL: bool = false;
    /// Quasi-null `u64` value assigned to a variable when it will be
    /// reassigned via pass-by-reference, since declaration without
    /// assignment before use is invalid
    const NULL_U64: u64 = 0;
    /// Quasi-null `u128` value assigned to a variable when it will be
    /// reassigned via pass-by-reference, since declaration without
    /// assignment before use is invalid
    const NULL_U128: u128 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;
    /// Right traversal direction, denoting successor traversal
    const RIGHT: bool = false;
    /// Sell direction flag
    const SELL: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel all limit order on behalf of user, via
    /// `general_custodian_capability_ref`.
    ///
    /// See wrapped function `cancel_all_limit_orders()`.
    public fun cancel_all_limit_orders_custodian(
        user: address,
        host: address,
        market_id: u64,
        side: bool,
        general_custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        cancel_all_limit_orders(
            user,
            host,
            market_id,
            registry::custodian_id(general_custodian_capability_ref),
            side
        );
    }

    /// Cancel a limit order on behalf of user, via
    /// `general_custodian_capability_ref`.
    ///
    /// See wrapped function `cancel_limit_order()`.
    public fun cancel_limit_order_custodian(
        user: address,
        host: address,
        market_id: u64,
        side: bool,
        order_id: u128,
        general_custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        cancel_limit_order(
            user,
            host,
            market_id,
            registry::custodian_id(general_custodian_capability_ref),
            side,
            order_id
        );
    }

    /// Place a limit order on behalf of user, via
    /// `general_custodian_capability_ref`.
    ///
    /// See wrapped function `place_limit_order()`.
    public fun place_limit_order_custodian(
        user: address,
        host: address,
        market_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool,
        general_custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        place_limit_order(
            user,
            host,
            market_id,
            registry::custodian_id(general_custodian_capability_ref),
            side,
            size,
            price,
            post_or_abort
        );
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Cancel all limit orders as a signing user.
    ///
    /// See wrapped function `cancel_all_limit_orders()`.
    public entry fun cancel_all_limit_orders_user(
        user: &signer,
        host: address,
        market_id: u64,
        side: bool,
    ) acquires OrderBooks {
        cancel_all_limit_orders(
            address_of(user),
            host,
            market_id,
            NO_CUSTODIAN,
            side,
        );
    }

    #[cmd]
    /// Cancel a limit order as a signing user.
    ///
    /// See wrapped function `cancel_limit_order()`.
    public entry fun cancel_limit_order_user(
        user: &signer,
        host: address,
        market_id: u64,
        side: bool,
        order_id: u128
    ) acquires OrderBooks {
        cancel_limit_order(
            address_of(user),
            host,
            market_id,
            NO_CUSTODIAN,
            side,
            order_id
        );
    }

    #[cmd]
    /// Place a limit order as a signing user.
    ///
    /// See wrapped function `place_limit_order()`.
    public entry fun place_limit_order_user(
        user: &signer,
        host: address,
        market_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool
    ) acquires OrderBooks {
        place_limit_order(
            address_of(user),
            host,
            market_id,
            NO_CUSTODIAN,
            side,
            size,
            price,
            post_or_abort
        );
    }

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

    /// Cancel all of a user's limit orders on the book, and remove from
    /// their market account, silently returning if they have no open
    /// orders.
    ///
    /// See wrapped function `cancel_limit_order()`.
    ///
    /// # Parameters
    /// * `user`: Address of user cancelling order
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `market_id`: Market ID
    /// * `general_custodian_id`: General custodian ID for `user`'s
    ///   market account
    /// * `side`: `ASK` or `BID`
    ///
    /// # Assumes
    /// * That `get_n_orders_internal()` aborts if no corresponding user
    ///   orders tree available to cancel from
    fun cancel_all_limit_orders(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        side: bool,
    ) acquires OrderBooks {
        let market_account_id = user::get_market_account_id(market_id,
            general_custodian_id); // Get user's market account ID
        let n_orders = // Get number of orders on given side
            user::get_n_orders_internal(user, market_account_id, side);
        while (n_orders > 0) { // While user has open orders
            // Get order ID of order nearest the spread
            let order_id_nearest_spread =
                user::get_order_id_nearest_spread_internal(
                    user, market_account_id, side);
            // Cancel the order
            cancel_limit_order(user, host, market_id, general_custodian_id,
                side, order_id_nearest_spread);
            n_orders = n_orders - 1; // Decrement order count
        }
    }

    /// Cancel limit order on book, remove from user's market account.
    ///
    /// # Parameters
    /// * `user`: Address of user cancelling order
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `market_id`: Market ID
    /// * `general_custodian_id`: General custodian ID for `user`'s
    ///   market account
    /// * `side`: `ASK` or `BID`
    ///
    /// # Abort conditions
    /// * If the specified `order_id` is not on given `side` for
    ///   corresponding `OrderBook`
    /// * If `user` is not the user who placed the order with the
    ///   corresponding `order_id`
    /// * If `custodian_id` is not the same as that indicated on order
    ///   with the corresponding `order_id`
    fun cancel_limit_order(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        side: bool,
        order_id: u128
    ) acquires OrderBooks {
        // Verify order book exists
        verify_order_book_exists(host, market_id);
        // Borrow mutable reference to order books map
        let order_books_map_ref_mut =
            &mut borrow_global_mut<OrderBooks>(host).map;
        // Borrow mutable reference to order book
        let order_book_ref_mut =
            open_table::borrow_mut(order_books_map_ref_mut, market_id);
        // Get mutable reference to orders tree for corresponding side
        let tree_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks else
            &mut order_book_ref_mut.bids;
        // Assert order is on book
        assert!(critbit::has_key(tree_ref_mut, order_id), E_NO_ORDER);
        let Order{ // Pop and unpack order from book,
            size: _, // Drop size count
            user: order_user, // Save indicated user for checking later
            // Save indicated general custodian ID for checking later
            general_custodian_id: order_general_custodian_id
        } = critbit::pop(tree_ref_mut, order_id);
        // Assert user attempting to cancel is user on order
        assert!(user == order_user, E_INVALID_USER);
        // Assert custodian attempting to cancel is custodian on order
        assert!(general_custodian_id == order_general_custodian_id,
            E_INVALID_CUSTODIAN);
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
        // Get market account ID, lot size, and tick size for order
        let (market_account_id, lot_size, tick_size) = (
            user::get_market_account_id(market_id, general_custodian_id),
            order_book_ref_mut.lot_size,
            order_book_ref_mut.tick_size);
        // Remove order from corresponding user's market account
        user::remove_order_internal(user, market_account_id, lot_size,
            tick_size, side, order_id);
    }

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

    /// Match an incoming order against indicated order book.
    ///
    /// Initialize local variables, verify that loopwise matching can
    /// proceed, then verify fill amounts afterwards. Institutes
    /// pass-by-reference for enhanced efficiency.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `market_id_ref`: Immutable reference to market ID
    /// * `order_book_ref_mut`: Mutable reference to corresponding
    ///   `OrderBook`
    /// * `lot_size_ref`: Immutable reference to lot size for market
    /// * `tick_size_ref`: Immutable reference to tick size for market
    /// * `direction_ref`: `&BUY` or `&SELL`
    /// * `min_lots_ref`: Immutable reference to minimum number of lots
    ///   to fill
    /// * `max_lots_ref`: Immutable reference to maximum number of lots
    ///   to fill
    /// * `min_ticks_ref`: Immutable reference to minimum number of
    ///   ticks to fill
    /// * `max_ticks_ref`: Immutable reference to maximum number of
    ///   ticks to fill
    /// * `limit_price_ref`: Immutable reference to maximum price to
    ///   match against if `direction_ref` is `&BUY`, and minimum price
    ///   to match against if `direction_ref` is `&SELL`
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine, gradually
    ///   incremented in the case of `BUY`, and gradually decremented
    ///   in the case of `SELL`
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine, gradually
    ///   decremented in the case of `BUY`, and gradually incremented
    ///   in the case of `SELL`
    fun match<
        BaseType,
        QuoteType
    >(
        market_id_ref: &u64,
        order_book_ref_mut: &mut OrderBook,
        lot_size_ref: &u64,
        tick_size_ref: &u64,
        direction_ref: &bool,
        min_lots_ref: &u64,
        max_lots_ref: &u64,
        min_ticks_ref: &u64,
        max_ticks_ref: &u64,
        limit_price_ref: &u64,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>
    ) {
        // Initialize max counters and side-wise matching variables
        let (lots_until_max, ticks_until_max, side, tree_ref_mut,
             spread_maker_ref_mut, n_orders, traversal_direction) =
                match_init(order_book_ref_mut, direction_ref, max_lots_ref,
                    max_ticks_ref);
        if (n_orders != 0) { // If orders tree has orders to match
            // Match them in an iterated loop traversal
            match_loop<BaseType, QuoteType>(market_id_ref, tree_ref_mut,
                &side, lot_size_ref, tick_size_ref, &mut lots_until_max,
                &mut ticks_until_max, limit_price_ref, &mut n_orders,
                spread_maker_ref_mut, &traversal_direction,
                optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
        };
        min_lots_ref; min_ticks_ref;
    }

    /// Initialize variables required for matching.
    ///
    /// Inner function for `match()`.
    ///
    /// Must determine orders tree based on a conditional check on
    /// `direction_ref` in order for `match()` to check that there are
    /// even orders to fill against, hence evaluates other side-wise
    /// variables in ternary operator (even though some of these could
    /// be evaluated later on in `match_loop_init()`) such that matching
    /// initialization only requires one side-wise conditional check.
    ///
    /// Additionally, lots and ticks until max counters are additionally
    /// initialized here rather than in `match_loop_init()` so they can
    /// be passed by reference and then verified within the local scope
    /// of `match()`, via `match_verify_fills()`.
    ///
    /// # Parameters
    /// * `order_book_ref_mut`: Mutable reference to corresponding
    ///   `OrderBook`
    /// * `direction_ref`: `&BUY` or `&SELL`
    /// * `max_lots_ref`: Immutable reference to maximum number of lots
    ///   to fill
    /// * `min_lots_ref`: Immutable reference to maximum number of ticks
    ///   to fill
    ///
    /// # Returns
    /// * `u64`: Counter for remaining lots that can be filled before
    ///   exceeding maximum allowed
    /// * `u64`: Counter for remaining ticks that can be filled before
    ///   exceeding maximum allowed
    /// * `bool`: `ASK` or `BID` corresponding to `direction_ref`
    /// * `&mut CritBitTree<Order>`: Mutable reference to orders tree to
    ///   fill against
    /// * `&mut u128`: Mutable reference to spread maker field for given
    ///   side
    /// * `u64`: Number of orders in corresponding tree
    /// * `bool`: `LEFT` or `RIGHT` (traversal direction) corresponding
    ///   to `direction_ref`
    fun match_init(
        order_book_ref_mut: &mut OrderBook,
        direction_ref: &bool,
        max_lots_ref: &u64,
        max_ticks_ref: &u64,
    ): (
        u64,
        u64,
        bool,
        &mut CritBitTree<Order>,
        &mut u128,
        u64,
        bool,
    ) {
        // Get side that order fills against, mutable reference to
        // orders tree to fill against, mutable reference to the spread
        // maker for given side, and traversal direction
        let (side, tree_ref_mut, spread_maker_ref_mut, traversal_direction) =
            if (*direction_ref == BUY) (
            ASK, // If a buy, fills against asks
            &mut order_book_ref_mut.asks, // Fill against asks tree
            &mut order_book_ref_mut.min_ask, // Asks spread maker
            RIGHT // Successor iteration
        ) else ( // If a sell
            BID, // Fills against bids, requires base coins
            &mut order_book_ref_mut.bids, // Fill against bids tree
            &mut order_book_ref_mut.max_bid, // Bids spread maker
            LEFT // Predecessor iteration
        );
        // Get number of orders in corresponding tree
        let n_orders = critbit::length(tree_ref_mut);
        (
            *max_lots_ref,
            *max_ticks_ref,
            side,
            tree_ref_mut,
            spread_maker_ref_mut,
            n_orders,
            traversal_direction,
        )
    }

    /// Match an order against the book via loopwise tree traversal.
    ///
    /// Inner function for `match()`.
    ///
    /// During interated traversal, the "incoming user" matches against
    /// a "target order" on the book at each iteration.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `market_id_ref`: Immutable reference to market ID
    /// * `tree_ref_mut`: Mutable reference to orders tree
    /// * `side_ref`: `&ASK` or `&BID`
    /// * `lot_size_ref`: Immutable reference to lot size for market
    /// * `tick_size_ref`: Immutable reference to tick size for market
    /// * `lots_until_max_ref_mut`: Mutable reference to counter for
    ///   number of lots that can be filled before exceeding max
    ///   allowed for incoming user
    /// * `ticks_until_max_ref_mut`: Mutable reference to counter
    ///   for number of ticks that can be filled before exceeding max
    ///   allowed for incoming user
    /// * `limit_price_ref`: Immutable reference to max price to match
    ///   against if `side_ref` indicates `ASK`, and min price to match
    ///   against if `side_ref` indicates `BID`
    /// * `n_orders_ref_mut`: Mutable reference to counter for number of
    ///   orders in tree
    /// * `spread_maker_ref_mut`: Mutable reference to the spread maker
    ///   field for corresponding side
    /// * `traversal_direction_ref`: `&LEFT`, or `&RIGHT`
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    ///
    /// # Passing considerations
    /// * Pass-by-reference instituted for improved efficiency
    /// * See `match_loop_order_follow_up()` for a discussion on its
    ///   return schema
    fun match_loop<
        BaseType,
        QuoteType
    >(
        market_id_ref: &u64,
        tree_ref_mut: &mut CritBitTree<Order>,
        side_ref: &bool,
        lot_size_ref: &u64,
        tick_size_ref: &u64,
        lots_until_max_ref_mut: &mut u64,
        ticks_until_max_ref_mut: &mut u64,
        limit_price_ref: &u64,
        n_orders_ref_mut: &mut u64,
        spread_maker_ref_mut: &mut u128,
        traversal_direction_ref: &bool,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>
    ) {
        // Initialize local variables
        let (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index, null_order, complete_target_fill,
             should_pop_last, new_spread_maker) = match_loop_init(
                tree_ref_mut, traversal_direction_ref);
        // Declare locally-scoped return variable for below loop, which
        // can not be declared without a value in the above function,
        // and which raises a warning if it is assigned a value within
        // the present scope. It could be declared within the loop
        // scope, but this would involve a redeclaration for each
        // iteration. Hence it is declared here, such that the statement
        // in which it is assigned does not locally re-bind the other
        // variables in the function return tuple, which would occur if
        // they were to be assigned via a `let` expression.
        let should_break;
        loop { // Begin loopwise matching
            // Process the order for current iteration, storing flag for
            // if the target order was completely filled
            match_loop_order<BaseType, QuoteType>(market_id_ref, side_ref,
                lot_size_ref, tick_size_ref, lots_until_max_ref_mut,
                ticks_until_max_ref_mut, limit_price_ref, &target_order_id,
                target_order_ref_mut, &mut complete_target_fill,
                optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
            // Follow up on order processing, assigning variable returns
            // that cannot be reassigned via pass-by-reference
            (target_order_id, target_order_ref_mut, should_break) =
                match_loop_order_follow_up(tree_ref_mut, side_ref,
                traversal_direction_ref, n_orders_ref_mut,
                &complete_target_fill, &mut should_pop_last, target_order_id,
                &mut null_order, &mut target_parent_index,
                &mut target_child_index, &mut new_spread_maker);
            if (should_break) { // If should break out of loop
                // Clean up as needed before breaking out of loop
                match_loop_break(null_order, spread_maker_ref_mut,
                    &new_spread_maker, &should_pop_last, tree_ref_mut,
                    &target_order_id);
                break // Break out of loop
            }
        }
    }

    /// Execute break cleanup after loopwise matching.
    ///
    /// Inner function for `match_loop()`.
    ///
    /// # Parameters
    /// * `null_order`: A null order used for mutable reference passing
    /// * `spread_maker_ref_mut`: Mutable reference to the spread maker
    ///   field for order tree just filled against
    /// * `new_spread_maker_ref`: Immutable reference to new spread
    ///   maker value to assign
    /// * `should_pop_last_ref`: `&true` if loopwise matching ends on a
    ///   complete fill against the last order on the book, which should
    ///   be popped off
    /// * `tree_ref_mut`: Mutable reference to orders tree just matched
    ///   against
    /// * `final_order_id_ref`: If `should_pop_last_ref` indicates
    ///   `true`, an immutable reference to the order ID of the last
    ///   order in the book, which should be popped
    fun match_loop_break(
        null_order: Order,
        spread_maker_ref_mut: &mut u128,
        new_spread_maker_ref: &u128,
        should_pop_last_ref: &bool,
        tree_ref_mut: &mut CritBitTree<Order>,
        final_order_id_ref: &u128
    ) {
        // Unpack null order
        Order{size: _, user: _, general_custodian_id: _} = null_order;
        // Update spread maker field
        *spread_maker_ref_mut = *new_spread_maker_ref;
        // Pop and unpack last order on book if flagged to do so
        if (*should_pop_last_ref)
            Order{size: _, user: _, general_custodian_id: _} =
                critbit::pop(tree_ref_mut, *final_order_id_ref);
    }

    /// Initialize variables for loopwise matching.
    ///
    /// Inner function for `match_loop()`.
    ///
    /// # Parameters
    /// * `tree_ref_mut`: Mutable reference to orders tree to start
    ///   match against
    /// * `traversal_direction_ref`: `&LEFT`, or `&RIGHT`
    ///
    /// # Returns
    /// * `u128`: Order ID of first target order to process
    /// * `&mut Order`: Mutable reference to first target order
    /// * `u64`: Parent index loop variable for iterated traversal along
    ///    outer nodes of a `CritBitTree`
    /// * `u64`: Child index loop variable for iterated traversal along
    ///    outer nodes of a `CritBitTree`
    /// * `Order`: A quasi-null order used for mutable reference
    ///   reassignment as described in `match_loop_order_follow_up()`
    /// * `bool`: Flag for if target order is completely filled
    /// * `bool`: Flag for if loopwise matching ends on a complete fill
    ///   against the last order on the book, which should be popped
    /// * `u128`: Tracker for new spread maker value to assign
    ///
    /// # Passing considerations
    /// * Initialized variables are passed by reference within
    ///   `match_loop()`, and as such must be assigned before use
    /// * Variables that are only assigned meaningful values after
    ///   pass-by-reference are effectively initialized to null values
    fun match_loop_init(
        tree_ref_mut: &mut CritBitTree<Order>,
        traversal_direction_ref: &bool,
    ): (
        u128,
        &mut Order,
        u64,
        u64,
        Order,
        bool,
        bool,
        u128
    ) {
        // Initialize iterated traversal, storing order ID of target
        // order, mutable reference to target order, the parent field
        // of the target node, and child field index of target node
        let (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index) = critbit::traverse_init_mut(
                tree_ref_mut, *traversal_direction_ref);
        ( // Return initialized variables
            target_order_id,
            target_order_ref_mut,
            target_parent_index,
            target_child_index,
            Order{size: NULL_U64,
                user: NULL_ADDRESS, general_custodian_id: NULL_U64},
            NULL_BOOL,
            NULL_BOOL,
            NULL_U128,
        )
    }

    /// Fill order from "incoming user" against "target order" on the
    /// book.
    ///
    /// Inner function for `match_loop()`.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `market_id_ref`: Immutable reference to market ID
    /// * `side_ref`: `&ASK` or `&BID`
    /// * `lot_size_ref`: Immutable reference to lot size for market
    /// * `tick_size_ref`: Immutable reference to tick size for market
    /// * `lots_until_max_ref_mut`: Mutable reference to counter for
    ///   number of lots that can be filled before exceeding max
    ///   allowed for incoming user
    /// * `ticks_until_max_ref_mut`: Mutable reference to counter
    ///   for number of ticks that can be filled before exceeding max
    ///   allowed for incoming user
    /// * `limit_price_ref`: Immutable reference to max price to match
    ///   against if `side_ref` indicates `ASK`, and min price to match
    ///   against if `side_ref` indicates `BID`
    /// * `target_order_id_ref`: Immutable reference to target order ID
    /// * `target_order_ref_mut`: Mutable reference to target order
    /// * `complete_target_fill_ref_mut`: Mutable reference to flag for
    ///   if target order is completely filled
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    fun match_loop_order<
        BaseType,
        QuoteType
    >(
        market_id_ref: &u64,
        side_ref: &bool,
        lot_size_ref: &u64,
        tick_size_ref: &u64,
        lots_until_max_ref_mut: &mut u64,
        ticks_until_max_ref_mut: &mut u64,
        limit_price_ref: &u64,
        target_order_id_ref: &u128,
        target_order_ref_mut: &mut Order,
        complete_target_fill_ref_mut: &mut bool,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>
    ) {
        // Calculate target order price
        let target_order_price = order_id::price(*target_order_id_ref);
        // If ask price is higher than limit price
        if ((*side_ref == ASK && target_order_price > *limit_price_ref) ||
            // Or if bid price is lower than limit price
            (*side_ref == BID && target_order_price < *limit_price_ref)) {
                // Flag that there was not a complete target fill
                *complete_target_fill_ref_mut = false;
                return // Do not attempt to fill
            };
        // Declare fill size for pass-by-reference
        let fill_size = NULL_U64;
        // Calculate size filled and determine if a complete fill
        // against target order
        match_loop_order_fill_size(lots_until_max_ref_mut,
            ticks_until_max_ref_mut, &target_order_price, target_order_ref_mut,
            &mut fill_size, complete_target_fill_ref_mut);
        if (fill_size == 0) { // If no lots to fill
            // Flag that there was not a complete target fill
            *complete_target_fill_ref_mut = false;
            return // Do not attempt to fill
        };
        // Calculate number of ticks filled
        let ticks_filled = fill_size * target_order_price;
        // Decrement counter for lots until max
        *lots_until_max_ref_mut = *lots_until_max_ref_mut - fill_size;
        // Decrement counter for ticks until max
        *ticks_until_max_ref_mut = *ticks_until_max_ref_mut - ticks_filled;
        // Calculate base and quote units to route
        let (base_to_route, quote_to_route) = (
            fill_size * *lot_size_ref, ticks_filled * *tick_size_ref);
        // Get the target order user's market account ID
        let target_order_market_account_id = user::get_market_account_id(
            *market_id_ref, target_order_ref_mut.general_custodian_id);
        // Fill the target order user-side
        user::fill_order_internal<BaseType, QuoteType>(
            target_order_ref_mut.user, target_order_market_account_id,
            *side_ref, *target_order_id_ref, *complete_target_fill_ref_mut,
            fill_size, optional_base_coins_ref_mut,
            optional_quote_coins_ref_mut, base_to_route, quote_to_route);
        // Decrement target order size by size filled (should be popped
        // later if completely filled, and so this step is redundant in
        // the case of a complete fill, but adding an extra if statement
        // to check whether or not to decrement would add computational
        // overhead in the case of an incomplete fill)
        target_order_ref_mut.size = target_order_ref_mut.size - fill_size;
    }

    /// Calculate fill size and whether an order on the book is
    /// completely filled during a match. The "incoming user" fills
    /// against the "target order" on the book.
    ///
    /// Inner function for `match_loop_order()`.
    ///
    /// # Parameters
    /// * `lots_until_max_ref`: Immutable reference to counter for
    ///   number of lots that can be filled before exceeding max allowed
    ///   for incoming user
    /// * `ticks_until_max_ref`: Immutable reference to counter for
    ///   number of ticks that can be filled before exceeding max
    ///   allowed for incoming user
    /// * `target_order_price_ref`: Immutable reference to target order
    ///   price
    /// * `target_order_ref`: Immutable reference to target order
    /// * `fill_size_ref_mut`: Mutable reference to fill size, in lots
    /// * `complete_target_fill_ref_mut`: Mutable reference to flag
    ///   marked `true` if target order is completely filled
    fun match_loop_order_fill_size(
        lots_until_max_ref: &u64,
        ticks_until_max_ref: &u64,
        target_order_price_ref: &u64,
        target_order_ref: &Order,
        fill_size_ref_mut: &mut u64,
        complete_target_fill_ref_mut: &mut bool
    ) {
        // Calculate max number of lots that could be filled without
        // exceeding the maximum number of filled ticks: number of lots
        // that incoming user can afford to buy at target price in the
        // case of a buy, else number of lots that user could sell at
        // target order price without receiving too many ticks
        let fill_size_tick_limited =
            *ticks_until_max_ref / *target_order_price_ref;
        // Max-limited fill size is the lesser of tick-limited fill size
        // and lot-limited fill size
        let fill_size_max_limited =
            if (fill_size_tick_limited < *lots_until_max_ref)
                fill_size_tick_limited else *lots_until_max_ref;
        // Get fill size and if target order is completely filled
        let (fill_size, complete_target_fill) =
            // If max-limited fill size is less than target order size
            if (fill_size_max_limited < target_order_ref.size)
                // Fill size is max-limited fill size, target order is
                // not completely filled
                (fill_size_max_limited, false) else
                // Otherwise fill size is target order size, and target
                // order is completely filled
                (target_order_ref.size, true);
        // Reassign to passed in references, since cannot reassign
        // to references within ternary operation result tuple above
        *fill_size_ref_mut = fill_size;
        *complete_target_fill_ref_mut = complete_target_fill;
    }

    /// Follow up after processing a fill against an order on the book.
    ///
    /// Checks if traversal is still possible, computes new spread maker
    /// value as needed, and determines if loop has hit break condition,
    /// following up on an "incoming user" filling against a "target
    /// order" on the book.
    ///
    /// Inner function for `match_loop()`.
    ///
    /// # Parameters
    /// * `tree_ref_mut`: Mutable reference to orders tree
    /// * `side_ref`: `&ASK` or `&BID`
    /// * `traversal_direction_ref`: `&LEFT` or `&RIGHT`
    /// * `n_orders_ref_mut`: Mutable reference to counter for number of
    ///   orders in tree, including the target order that was just
    ///   processed
    /// * `complete_target_fill_ref`: `&true` if the target order was
    ///   completely filled
    /// * `should_pop_last_ref_mut`: Reassigned to `&true` if just
    ///   processed a complete fill against the last order on the book,
    ///   which should be popped
    /// * `target_order_id`: Order ID of target order just processed
    /// * `target_order_ref_mut`: Mutable reference to an `Order`.
    ///   Effectively reassigned only when traversal should proceed to
    ///   the next order on the book, otherwise left unmodified.
    ///   Intended to accept as an input a mutable reference to a
    ///   quasi-null `Order`.
    /// * `target_parent_index_ref_mut`: Mutable reference to parent
    ///   loop variable for iterated traversal along outer nodes of a
    ///   `CritBitTree`
    /// * `target_child_index_ref_mut`: Mutable reference to child loop
    ///   variable for iterated traversal along outer nodes of a
    ///   `CritBitTree`
    /// * `new_spread_maker_ref_mut`: Mutable reference to the value
    ///   that should be assigned to the spread maker field for the
    ///   side indicated by `side_ref`, if one should be set
    ///
    /// # Returns
    /// * `u128`: Target order ID, updated from `target_order_id` if
    ///   traversal proceeds to the next order on the book
    /// * `&mut Order`: Mutable reference to next order on the book to
    ///   process, only reassigned when iterated traversal proceeds
    /// * `bool`: `true` if should break out of loop after follow up
    ///
    /// # Passing considerations
    /// * Returns a mutable reference to an `Order` rather than
    ///   reassigning to the underlying value because doing so would
    ///   require `Order` to have the `drop` ability, which it does not
    /// * Returns local `target_order_id` and `should_break` variables
    ///   as values rather than reassigning to passed in references,
    ///   because the calling function `match_loop_order()` accesses
    ///   these variables elsewhere in a loop, such that passing
    ///   references to them consitutes an invalid borrow within the
    ///   loop context
    /// * Accepts `target_order_id` as pass-by-value even though
    ///   pass-by-reference would be valid, because if it were to be
    ///   passed by reference, the underlying value would still have to
    ///   be copied into a local variable anyways in order to return
    ///   by value as described above
    fun match_loop_order_follow_up(
        tree_ref_mut: &mut CritBitTree<Order>,
        side_ref: &bool,
        traversal_direction_ref: &bool,
        n_orders_ref_mut: &mut u64,
        complete_target_fill_ref: &bool,
        should_pop_last_ref_mut: &mut bool,
        target_order_id: u128,
        target_order_ref_mut: &mut Order,
        target_parent_index_ref_mut: &mut u64,
        target_child_index_ref_mut: &mut u64,
        new_spread_maker_ref_mut: &mut u128
    ):  (
        u128,
        &mut Order,
        bool
    ) {
        // Assume should set new spread maker field to target order ID
        *new_spread_maker_ref_mut = target_order_id;
        // Assume should not pop last order off book after followup
        *should_pop_last_ref_mut = false;
        // Assume should break out of loop after follow up
        let should_break = true;
        if (*n_orders_ref_mut == 1) { // If no orders left on book
            // If target order completely filled
            if (*complete_target_fill_ref) {
                // Market that should pop last order on book
                *should_pop_last_ref_mut = true;
                // Set new spread maker value to default value for side
                *new_spread_maker_ref_mut = if (*side_ref == ASK)
                    MIN_ASK_DEFAULT else MAX_BID_DEFAULT;
            }; // If not complete target order fill, use default flags
        } else { // If orders still left on book
            // If target order completely filled
            if (*complete_target_fill_ref) {
                // Declare locally-scoped temporary return variables
                let (target_parent_index, target_child_index, empty_order);
                // Traverse pop to next order on book, reassigning to
                // temporary variables and those from calling scope
                (target_order_id, target_order_ref_mut, target_parent_index,
                 target_child_index, empty_order) = critbit::traverse_pop_mut(
                    tree_ref_mut, target_order_id,
                    *target_parent_index_ref_mut, *target_child_index_ref_mut,
                    *n_orders_ref_mut, *traversal_direction_ref);
                // Reassign temporary traverse returns to variables from
                // calling scope, since dereferencing is not permitted
                // inside of the above function return tuple
                *target_parent_index_ref_mut = target_parent_index;
                *target_child_index_ref_mut  = target_child_index;
                // Unpack popped empty order and discard
                Order{size: _, user: _, general_custodian_id: _} = empty_order;
                should_break = false; // Flag not to break out of loop
                // Decrement count of orders on book for given side
                *n_orders_ref_mut = *n_orders_ref_mut - 1;
            }; // If not complete target order fill, use default flags
        };
        (target_order_id, target_order_ref_mut, should_break)
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
    ///
    /// # Assumes
    /// * That user-side order registration will abort for invalid
    ///   arguments
    /// * That matching against the book will abort for invalid
    ///   arguments
    /// * That if `size` is as 0 and price does not cross spread, will
    ///   simply return silently
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

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for invalid custodian cancelling order
    fun test_cancel_limit_order_invalid_custodian(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Declare invalid custodian ID
        let invalid_custodian_id = general_custodian_id + 1;
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Declare order parameters
        let size = 123;
        let price = 456;
        let post_or_abort = false;
        let order_id = order_id::order_id(price, 0, side);
        // Place order
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size, price, post_or_abort);
        // Attempt invalid cancellation
        cancel_limit_order(@user, @econia, MARKET_ID, invalid_custodian_id,
            side, order_id);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid user cancelling order
    fun test_cancel_limit_order_invalid_user(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Declare order parameters
        let size = 123;
        let price = 456;
        let post_or_abort = false;
        let order_id = order_id::order_id(price, 0, side);
        // Place order
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size, price, post_or_abort);
        // Attempt invalid cancellation
        cancel_limit_order(@econia, @econia, MARKET_ID, general_custodian_id,
            side, order_id);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for no such order on book
    fun test_cancel_limit_order_no_order(
        econia: &signer
    ) acquires OrderBooks {
        // Register order book
        register_order_book<BG, QG>(econia, MARKET_ID, LOT_SIZE, TICK_SIZE);
        // Attempt invalid invocation
        cancel_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, ASK, 0);
    }

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

    #[test]
    /// Verify successful returns
    fun test_match_loop_order_fill_size() {
        // Declare target order parameters
        let target_order_price = 123;
        let target_order =
            Order{size: 456, user: @user, general_custodian_id: NO_CUSTODIAN};
        // Declare variables for pass-by-reference
        let fill_size = NULL_U64;
        let complete_target_fill = NULL_BOOL;
        // Declare parameters for a tick-limited fill
        let size_filled_tick_limited = target_order.size - 1;
        let complete_target_fill_tick_limited = false;
        let lots_until_max_tick_limited = HI_64;
        let ticks_until_max_tick_limited =
            size_filled_tick_limited * target_order_price + 1;
        // Calculate fill size and if complete fill
        match_loop_order_fill_size(
            &lots_until_max_tick_limited, &ticks_until_max_tick_limited,
            &target_order_price, &target_order, &mut fill_size,
            &mut complete_target_fill);
        // Assert correct returns
        assert!(fill_size == size_filled_tick_limited, 0);
        assert!(complete_target_fill == complete_target_fill_tick_limited, 0);
        // Declare parameters for a lot-limited fill
        let size_filled_lot_limited = target_order.size - 1;
        let complete_target_fill_lot_limited = false;
        let lots_until_max_lot_limited = size_filled_lot_limited;
        let ticks_until_max_lot_limited = HI_64;
        // Calculate fill size and if complete fill
        match_loop_order_fill_size(
            &lots_until_max_lot_limited, &ticks_until_max_lot_limited,
            &target_order_price, &target_order, &mut fill_size,
            &mut complete_target_fill);
        // Assert correct returns
        assert!(fill_size == size_filled_lot_limited, 0);
        assert!(complete_target_fill == complete_target_fill_lot_limited, 0);
        // Declare parameters for a target order-limited fill
        let size_filled_target_limited = target_order.size;
        let complete_target_fill_target_limited = true;
        let lots_until_max_target_limited = HI_64;
        let ticks_until_max_target_limited = HI_64;
        // Calculate fill size and if complete fill
        match_loop_order_fill_size(
            &lots_until_max_target_limited, &ticks_until_max_target_limited,
            &target_order_price, &target_order, &mut fill_size,
            &mut complete_target_fill);
        // Assert correct returns
        assert!(fill_size == size_filled_target_limited, 0);
        assert!(complete_target_fill ==
            complete_target_fill_target_limited, 0);
        // Declare parameters for a fill equally limited by all inputs
        let size_filled_all_limited = target_order.size;
        let complete_target_fill_all_limited = true;
        let lots_until_max_all_limited = target_order.size;
        let ticks_until_max_all_limited =
            target_order.size * target_order_price;
        // Calculate fill size and if complete fill
        match_loop_order_fill_size(
            &lots_until_max_all_limited, &ticks_until_max_all_limited,
            &target_order_price, &target_order, &mut fill_size,
            &mut complete_target_fill);
        // Assert correct returns
        assert!(fill_size == size_filled_all_limited, 0);
        assert!(complete_target_fill == complete_target_fill_all_limited, 0);
        // Declare parameters for no fill, limited by quote
        let size_filled_no_limited = 0;
        let complete_target_fill_no_limited = false;
        let lots_until_max_no_limited = HI_64;
        let ticks_until_max_no_limited = target_order_price - 1;
        // Calculate fill size and if complete fill
        match_loop_order_fill_size(
            &lots_until_max_no_limited, &ticks_until_max_no_limited,
            &target_order_price, &target_order, &mut fill_size,
            &mut complete_target_fill);
        // Assert correct returns
        assert!(fill_size == size_filled_no_limited, 0);
        assert!(complete_target_fill == complete_target_fill_no_limited, 0);
        // Unpack target order
        Order{size: _, user: _, general_custodian_id: _} = target_order;
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful placement and cancellation for multiple orders
    ///
    /// 1. Place order
    /// 2. Place order with same price as first order
    /// 3. Place order with price further away from spread
    /// 4. Cancel order from (1)
    /// 5. Cancel order from (3)
    /// 6. Cancel order from (2)
    fun test_place_cancel_limit_orders_ask(
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
        let quote_fill_2 = size_2 * price_2 * TICK_SIZE;
        let size_3 = 987;
        let price_3 = price_1 + 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        let base_fill_3 = size_3 * LOT_SIZE;
        let quote_fill_3 = size_3 * price_3 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
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
            user::get_asset_counts_test(@user, market_account_id);
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
        // Place new order further away from spread
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_3, price_3, post_or_abort_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_3);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
            (base_fill_1 + base_fill_2 + base_fill_3), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
            (quote_fill_1 + quote_fill_2 + quote_fill_3), 0);
        assert!(order_size      == size_3, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_3, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_3, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_1);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
                                   (base_fill_2 + base_fill_3), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
                                   (quote_fill_2 + quote_fill_3), 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_1), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        // Cancel order that is not spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE - base_fill_2, 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE + quote_fill_2, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_3), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel only remaining order
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_2), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == MIN_ASK_DEFAULT, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful placement and cancellation for multiple orders
    ///
    /// 1. Place order
    /// 2. Place order with same price as first order
    /// 3. Place order with price further away from spread
    /// 4. Cancel order from (1)
    /// 5. Cancel order from (3)
    /// 6. Cancel order from (2)
    fun test_place_cancel_limit_orders_bid(
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
        let quote_fill_2 = size_2 * price_2 * TICK_SIZE;
        let size_3 = 987;
        let price_3 = price_1 - 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        let base_fill_3 = size_3 * LOT_SIZE;
        let quote_fill_3 = size_3 * price_3 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
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
            user::get_asset_counts_test(@user, market_account_id);
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
        // Place new order further away from spread
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_3, price_3, post_or_abort_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_3);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
            (base_fill_1 + base_fill_2 + base_fill_3), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
            (quote_fill_1 + quote_fill_2 + quote_fill_3), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_3, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_3, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_3, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_1);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
                                   (base_fill_2 + base_fill_3), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
                                   (quote_fill_2 + quote_fill_3), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_1), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        // Cancel order that is not spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE + base_fill_2, 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE - quote_fill_2, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_3), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel only remaining order
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_2), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == MAX_BID_DEFAULT, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Test order placement and cancellation as a general custodian
    fun test_place_cancel_limit_orders_custodian(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = true;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let size_3 = 987;
        let price_3 = price_1 + 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        // Get general custodian capability
        let general_custodian_capability =
            registry::get_custodian_capability_test(GENERAL_CUSTODIAN_ID);
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place limit orders
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_1,
            price_1, post_or_abort_1, &general_custodian_capability);
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_2,
            price_2, post_or_abort_2, &general_custodian_capability);
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_3,
            price_3, post_or_abort_3, &general_custodian_capability);
        // Assert orders on book
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel single order
        cancel_limit_order_custodian(@user, @econia, MARKET_ID, side,
            order_id_2, &general_custodian_capability);
        // Assert order off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        // Cancel all orders
        cancel_all_limit_orders_custodian(@user, @econia, MARKET_ID, side,
            &general_custodian_capability);
        // Assert orders off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Attempt to cancel all orders, silently returning since none
        cancel_all_limit_orders_custodian(@user, @econia, MARKET_ID, side,
            &general_custodian_capability);
        // Destroy general custodian capability
        registry::destroy_custodian_capability_test(
            general_custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Test order placement and cancellation as signing user
    fun test_place_cancel_limit_orders_user(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare market parameters
        let side = BID;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = false;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let size_3 = 987;
        let price_3 = price_1 - 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place limit orders
        place_limit_order_user(user, @econia, MARKET_ID, side, size_1,
            price_1, post_or_abort_1);
        place_limit_order_user(user, @econia, MARKET_ID, side, size_2,
            price_2, post_or_abort_2);
        place_limit_order_user(user, @econia, MARKET_ID, side, size_3,
            price_3, post_or_abort_3);
        // Assert orders on book
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel single order
        cancel_limit_order_user(user, @econia, MARKET_ID, side, order_id_2);
        // Assert order off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        // Cancel all orders
        cancel_all_limit_orders_user(user, @econia, MARKET_ID, side);
        // Assert orders off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Attempt to cancel all orders, silently returning since none
        cancel_all_limit_orders_user(user, @econia, MARKET_ID, side);
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