/// Market-side functionality. See test-only constants for end-to-end
/// market order fill testing mock order sizes/prices: in the case of
/// both bids and asks, `USER_1` has the order closest to the spread,
/// while `USER_3` has the order furthest from the spread. `USER_0` then
/// places a market order against the book.
module econia::market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
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
        /// Serial counter for number of limit orders placed on book
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
    /// Market buy flag
    const BUY: bool = true;
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
    /// Market sell flag
    const SELL: bool = false;

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

    /// Fill a market order on behalf of a user. Invoked by a custodian,
    /// who passes an immutable reference to their
    /// `registry::CustodianCapability`. See wrapped call
    /// `fill_market_order`.
    public fun fill_market_order_custodian<B, Q, E>(
        user: address,
        host: address,
        style: bool,
        max_base_parcels: u64,
        max_quote_units: u64,
        custodian_capability_ref: &registry::CustodianCapability
    ) acquires EconiaCapabilityStore, OrderBook {
        // Get custodian ID encoded in capability
        let custodian_id = registry::custodian_id(custodian_capability_ref);
        // Fill the market order, using custodian ID
        fill_market_order<B, Q, E>(user, host, custodian_id, style,
            max_base_parcels, max_quote_units);
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
        // Cancel limit order, with no custodian flag
        cancel_limit_order<B, Q, E>(
            address_of(user), host, NO_CUSTODIAN, side, order_id);
    }

    /// Fill a market order. Invoked by a signing user. See wrapped
    /// call `fill_market_order`.
    public entry fun fill_market_order_user<B, Q, E>(
        user: &signer,
        host: address,
        style: bool,
        max_base_parcels: u64,
        max_quote_units: u64,
    ) acquires EconiaCapabilityStore, OrderBook {
        // Fill the market order, with no custodian flag
        fill_market_order<B, Q, E>(address_of(user), host, NO_CUSTODIAN, style,
            max_base_parcels, max_quote_units);
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
        // Place limit order, with no custodian flag
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

    /// For an `OrderBook` at `host`, fill a market order for given
    /// `user`, `custodian_id`, `style`, and `max_base_parcels`,
    /// optionally accounting for `max_quote_units` if `style` is `BUY`.
    ///
    /// Prepares a crit-bit tree for iterated traversal, then loops over
    /// nodes until the order is filled or another break condition is
    /// met. During iterated traversal, the "incoming user" (who places
    /// the market order or who has the order placed on their behalf by
    /// a custodain) has their order filled against the "target user"
    /// who has a "target position" on the order book.
    ///
    /// During initialization, withdraws collateral from the incoming
    /// user. Then routes assets accordingly, then deposits assets back
    /// to the incoming user.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `host`: Where corresponding `OrderBook` is hosted
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `style`: `BUY` or `SELL`
    /// * `max_base_parcels`: The maximum number of base parcels to fill
    /// * `max_quote_units`: The maximum number of quote units to
    ///   exchange during a `BUY`, which may become a limiting factor
    ///   if the incoming user cannot afford to buy `max_base_parcels`
    ///   at market prices.
    fun fill_market_order<B, Q, E>(
        user: address,
        host: address,
        custodian_id: u64,
        style: bool,
        max_base_parcels: u64,
        max_quote_units: u64,
    ) acquires EconiaCapabilityStore, OrderBook {
        if (max_base_parcels == 0 || style == BUY && max_quote_units == 0)
            return; // Return if nothing to fill
        // Assert host has an order book
        assert!(exists<OrderBook<B, Q, E>>(host), E_NO_ORDER_BOOK);
        // Borrow mutable reference to order book
        let order_book_ref_mut = borrow_global_mut<OrderBook<B, Q, E>>(host);
        // Initialize local variables, get user's base/quote collateral
        let (econia_capability, scale_factor, market_account_info,
             base_parcels_to_fill, side, base_coins, quote_coins, tree_ref_mut,
             spread_maker_ref_mut, n_orders, traversal_direction) =
                fill_market_order_init<B, Q, E>(user, custodian_id, style,
                    max_base_parcels, max_quote_units, order_book_ref_mut);
        if (n_orders != 0) { // If orders tree has orders to fill
            // Fill them in an interated loop traversal
            fill_market_order_traverse_loop<B, Q, E>(style, side, scale_factor,
                tree_ref_mut, traversal_direction, n_orders,
                spread_maker_ref_mut, base_parcels_to_fill, &mut base_coins,
                &mut quote_coins, &econia_capability);
        };
        // Deposit base coins to incoming user's collateral
        user::deposit_collateral<B>(user, market_account_info, base_coins);
        // Deposit quote coins to incoming user's collateral
        user::deposit_collateral<Q>(user, market_account_info, quote_coins);
    }

    /// Clean up before breaking during iterated market order filling.
    ///
    /// Inner function for `fill_market_order_traverse_loop`.
    ///
    /// # Parameters
    /// * `null_order`: A null order used for mutable reference passing
    /// * `spread_maker_ref_mut`: Mutable reference to the spread maker
    ///   for order tree just filled against
    /// * `new_spread_maker`: New spread maker value to assign
    /// * `should_pop`: If ended traversal by completely filling against
    ///   the last order on the book
    /// * `tree_ref_mut`: Mutable reference to orders tree filled
    ///   against
    /// * `target_order_id`: If `should_pop` is `true`, the order ID of
    ///   the final order in the book that should be popped
    fun fill_market_order_break_cleanup(
        null_order: Order,
        spread_maker_ref_mut: &mut u128,
        new_spread_maker: u128,
        should_pop: bool,
        tree_ref_mut: &mut CritBitTree<Order>,
        target_order_id: u128
    ) {
        // Unpack null order
        Order{custodian_id: _, user: _, base_parcels: _} = null_order;
        // Update spread maker field
        *spread_maker_ref_mut = new_spread_maker;
        // If pop flagged, pop and unpack final order on tree
        if (should_pop) Order{base_parcels: _, user: _, custodian_id: _} =
            critbit::pop(tree_ref_mut, target_order_id);
    }

    /// If `style` is `BUY`, check indicated amount of base parcels
    /// to buy, updating as needed.
    ///
    /// Inner function for `fill_market_order_process_loop_order`. In
    /// the case of a `BUY`, if the "target order" on the book (against
    /// which the "incoming user's" order fills against) has a high
    /// enough price, then the incoming user may not be able to afford
    /// as many base parcels as otherwise indicated by
    /// `base_parcels_to_fill_ref_mut`. If this is the case, the counter
    /// is updated with the amount the incoming can afford.
    ///
    /// # Parameters
    /// * `style`: `BUY` or `SELL`
    /// * `target_price`: Target order price
    /// * `quote_coins_ref`: Immutable reference to incoming user's
    ///    quote coins
    /// * `target_order_ref_mut`: Mutable reference to target order
    /// * `base_parcels_to_fill_ref_mut`: Mutable reference to counter
    ///   for number of base parcels still left to fill
    fun fill_market_order_check_base_parcels_to_fill<Q>(
        style: bool,
        target_price: u64,
        quote_coins_ref: &coin::Coin<Q>,
        target_order_ref_mut: &mut Order,
        base_parcels_to_fill_ref_mut: &mut u64
    ) {
        if (style == SELL) return; // No need to check when market sell
        // Calculate max base parcels that incoming user could buy at
        // target order price
        let base_parcels_can_afford = coin::value(quote_coins_ref) /
            target_price;
        // If user cannot afford to buy all base parcels in target order
        if (base_parcels_can_afford < target_order_ref_mut.base_parcels) {
            // If number of base parcels that user can afford is less
            // than the number they would otherwise buy
            if (base_parcels_can_afford < *base_parcels_to_fill_ref_mut) {
                // Set the remaining number of base parcels to fill as
                // the number they can actually afford
                *base_parcels_to_fill_ref_mut = base_parcels_can_afford;
            };
        };
    }

    /// Initialize local variables required for filling market orders.
    ///
    /// Inner function for `fill_market_order`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `style`: `BUY` or `SELL`
    /// * `max_base_parcels`: The maximum number of base parcels to fill
    /// * `max_quote_units`: The maximum number of quote units to
    ///   exchange during a `BUY`, which may become a limiting factor
    ///   if the incoming user cannot afford to buy `max_base_parcels`
    ///   at market prices.
    /// * `order_book_ref_mut`: Mutable reference to corresponding
    ///   `OrderBook`
    ///
    /// # Returns
    /// * `EconiaCapability`: An `EconiaCapability` needed for internal
    ///   cross-module calls
    /// * `u64`: The scale factor for the given market
    /// * `user::MarketAccountInfo`: Info on `user`'s market account
    /// * `u64`: A counter for the number of base parcels left to fill
    /// * `bool`: Either `ASK` or `BID`
    /// * `coin::Coin<B>`: Base coins to route
    /// * `coin::Coin<Q>`: Quote coins to route
    /// * `&mut CritBitTree`: Mutable reference to orders tree to fill
    ///   against
    /// * `&mut u128`: Mutable reference to spread maker field for given
    ///   `side`
    /// * `u64`: Number of orders in corresponding tree
    /// * `bool`: `LEFT` or `RIGHT` (traversal direction)
    fun fill_market_order_init<B, Q, E>(
        user: address,
        custodian_id: u64,
        style: bool,
        max_base_parcels: u64,
        max_quote_units: u64,
        order_book_ref_mut: &mut OrderBook<B, Q, E>,
    ): (
        EconiaCapability,
        u64,
        user::MarketAccountInfo,
        u64,
        bool,
        coin::Coin<B>,
        coin::Coin<Q>,
        &mut CritBitTree<Order>,
        &mut u128,
        u64,
        bool
    ) acquires EconiaCapabilityStore {
        // Get an Econia capability
        let econia_capability = get_econia_capability();
        // Get scale factor for market
        let scale_factor = order_book_ref_mut.scale_factor;
        let market_account_info = // Get market account info for order
            user::market_account_info<B, Q, E>(custodian_id);
        // Declare counter for number of base parcels left to fill
        let base_parcels_to_fill = max_base_parcels;
        // Get side that order fills against, base coins and quote coins
        // required for the fill, mutable reference to orders tree
        // to fill against, mutable reference to the spread maker for
        // given side, and traversal direction
        let (side, base_coins, quote_coins, tree_ref_mut, spread_maker_ref_mut,
            traversal_direction) = if (style == BUY) (
            ASK, // If a market buy, fills against asks
            coin::zero<B>(), // Does not require base, but needs quote
            user::withdraw_collateral_internal<Q>(user, market_account_info,
                max_quote_units, &econia_capability),
            &mut order_book_ref_mut.asks, // Fill against asks tree
            &mut order_book_ref_mut.min_ask, // Asks spread maker
            RIGHT // Successor iteration
        ) else ( // If a market sell
            BID, // Fills against bids, requires base coins
            user::withdraw_collateral_internal<B>(user, market_account_info,
                max_base_parcels * scale_factor, &econia_capability),
            coin::zero<Q>(), // Does not require quote coins from user
            &mut order_book_ref_mut.bids, // Fill against bids tree
            &mut order_book_ref_mut.max_bid, // Bids spread maker
            LEFT // Predecessor iteration
        );
        // Get number of orders on book for given side
        let n_orders = critbit::length(tree_ref_mut);
        // Return initialized variables
        (econia_capability, scale_factor, market_account_info,
         base_parcels_to_fill, side, base_coins, quote_coins, tree_ref_mut,
         spread_maker_ref_mut, n_orders, traversal_direction)
    }

    /// Follow up after processing a fill against an order on the book.
    ///
    /// Inner function for `fill_market_order_traverse_loop`. Checks
    /// if traversal is still possible, computes new spread maker values
    /// as needed, and determines if loop has hit break condition.
    ///
    /// # Parameters
    /// * `side`: `ASK` or `BID`, side of order on book just processed
    /// * `base_parcels_to_fill`: Counter for base parcels left to fill
    /// * `complete_fill`: `true` if the processeed order was completely
    ///   filled
    /// * `traversal_direction`: `LEFT` or `RIGHT`
    /// * `tree_ref_mut`: Mutable reference to orders tree
    /// * `n_orders`: Counter for number of orders in tree, including
    ///   the order that was just processed
    /// * `target_order_id`: The order ID of the target order just
    ///   processed
    /// * `target_order_ref_mut`: Mutable reference to an `Order`.
    ///   Reassigned only when traversal should proceed to the next
    ///   order on the book, otherwise left unmodified. Intended to
    ///   accept as an input a mutable reference to a bogus `Order`.
    /// * `target_parent_index`: Loop variable for iterated traversal
    ///   along outer nodes of a `CritBitTree`
    /// * `target_child_index`: Loop variable for iterated traversal
    ///   along outer nodes of a `CritBitTree`
    ///
    /// # Returns
    /// * `bool`: `true` if should break out of loop after follow up
    /// * `bool`: `true` if just processed a complete fill against
    ///   the last order on the book and it should be popped without
    ///   attempting to traverse
    /// * `u128`: The order ID of the new spread maker for the given
    ///   `side`, if one should be set
    /// * `u64`: Updated count for `n_orders`
    /// * `u128`: Target order ID, updated if traversal proceeds to the
    ///   next order on the book
    /// * `&mut Order`: Mutable reference to next order on the book to
    ///   process, only reassigned when iterated traversal proceeds
    /// * `u64`: Loop variable for iterated traversal along outer nodes
    ///   of a `CritBitTree`, only updated when iterated traversal
    ///   proceeds
    /// * `u64`: Loop variable for iterated traversal along outer nodes
    ///   of a `CritBitTree`, only updated when iterated traversal
    ///   proceeds
    fun fill_market_order_loop_order_follow_up(
        side: bool,
        base_parcels_to_fill: u64,
        complete_fill: bool,
        traversal_direction: bool,
        tree_ref_mut: &mut CritBitTree<Order>,
        n_orders: u64,
        target_order_id: u128,
        target_order_ref_mut: &mut Order,
        target_parent_index: u64,
        target_child_index: u64,
    ): (
        bool,
        bool,
        u128,
        u64,
        u128,
        &mut Order,
        u64,
        u64
    ) {
        // Assume should set new spread maker field to target order ID,
        // that should break out of loop after follow up, and that
        // should not pop an order off the book after followup
        let (new_spread_maker, should_break, should_pop) =
            ( target_order_id,         true,      false);
        if (n_orders == 1) { // If no orders left on book
            if (complete_fill) { // If had a complete fill
                should_pop = true; // Mark that should pop final order
                // Set new spread maker value to default value for side
                new_spread_maker = if (side == ASK) MIN_ASK_DEFAULT else
                    MAX_BID_DEFAULT
            }; // If incomplete fill, use default flags
        } else { // If orders still left on book
            if (complete_fill) { // If target order completely filled
                // Traverse pop to next order on book
                (target_order_id, target_order_ref_mut, target_parent_index,
                 target_child_index,
                 Order{base_parcels: _, user: _, custodian_id: _}) =
                    critbit::traverse_pop_mut(tree_ref_mut, target_order_id,
                        target_parent_index, target_child_index, n_orders,
                        traversal_direction);
                if (base_parcels_to_fill == 0) {
                    // The order ID of the order that was just traversed
                    // to becomes the new spread maker
                    new_spread_maker = target_order_id;
                } else { // If still base parcels left to fill
                    should_break = false; // Should continue looping
                    // Decrement count of orders on book for given side
                    n_orders = n_orders - 1;
                };
            }; // If incomplete fill, use default flags
        };
        // Return updated variables
        (should_break, should_pop, new_spread_maker, n_orders, target_order_id,
         target_order_ref_mut, target_parent_index, target_child_index)
    }

    /// Fill a target order on the book during iterated traversal.
    ///
    /// Inner function for `fill_market_order_traverse_loop`, where the
    /// "incoming user" (who the market order is for) fills against a
    /// "target order" on the order book.
    ///
    /// # Parameters
    /// * `style`: `BUY` or `SELL`
    /// * `side`: `ASK` if `style` is `BUY`, `BID` if `style` is `ASK`:
    ///   the target order side
    /// * `scale_factor`: Scale factor for given market
    /// * `base_parcels_to_fill_ref_mut`: Mutable reference to ongoing
    ///    counter for base parcels left to fill
    /// * `target_order_id`: Order ID of target order on book
    /// * `target_order_ref_mut`: Mutable reference to target order
    /// * `base_coins_ref_mut`: Mutable reference to incoming user's
    ///   base coins
    /// * `quote_coins_ref_mut`: Mutable reference to incoming user's
    ///   quote coins
    /// * `econia_capability_ref`: Immutable reference to an
    ///   `EconiaCapability` required for internal cross-module calls
    ///
    /// # Returns
    /// * `bool`: `true` if target order is completely filled, else
    ///   `false`
    fun fill_market_order_process_loop_order<B, Q, E>(
        style: bool,
        side: bool,
        scale_factor: u64,
        base_parcels_to_fill_ref_mut: &mut u64,
        target_order_id: u128,
        target_order_ref_mut: &mut Order,
        base_coins_ref_mut: &mut coin::Coin<B>,
        quote_coins_ref_mut: &mut coin::Coin<Q>,
        econia_capability_ref: &EconiaCapability,
    ): (
        bool
    ) {
        // Calculate price of target order
        let target_price = order_id::price(target_order_id);
        // Check, and maybe update, tracker for base parcels to fill
        fill_market_order_check_base_parcels_to_fill(style, target_price,
            quote_coins_ref_mut, target_order_ref_mut,
            base_parcels_to_fill_ref_mut);
        // Target price may be too high for user to afford even one
        // base parcel in the case of a buy, and return incomplete fill
        // if so
        if (*base_parcels_to_fill_ref_mut == 0) return false;
        // Otherwise check if target order will be completely filled
        let complete_fill = (*base_parcels_to_fill_ref_mut >=
            target_order_ref_mut.base_parcels);
        // Calculate number of base parcels filled
        let base_parcels_filled = if (complete_fill)
            // If complete fill, number of base parcels order was for
            target_order_ref_mut.base_parcels else
            // Else, remaining base parcels left to fill
            *base_parcels_to_fill_ref_mut;
        // Decrement counter for number of base parcels to fill
        *base_parcels_to_fill_ref_mut = *base_parcels_to_fill_ref_mut -
            base_parcels_filled;
        // Calculate base and quote coins routed for the fill
        let base_to_route = base_parcels_filled * scale_factor;
        let quote_to_route = base_parcels_filled * target_price;
        // Fill the target user's order
        user::fill_order_internal<B, Q, E>(target_order_ref_mut.user,
            target_order_ref_mut.custodian_id, side, target_order_id,
            complete_fill, base_parcels_filled, base_coins_ref_mut,
            quote_coins_ref_mut, base_to_route, quote_to_route,
            econia_capability_ref);
        // If did not completely fill target order, decrement the number
        // of base parcels it is for by the fill amount (if it was
        // completely filled, it should be popped later)
        if (!complete_fill) target_order_ref_mut.base_parcels =
            target_order_ref_mut.base_parcels - base_parcels_filled;
        complete_fill // Return if target order was completely filled
    }

    /// Fill a market order by traversing along the orders tree.
    ///
    /// Inner function for `fill_market_order`. During iterated
    /// traversal, the "incoming user" (who places the market order or
    /// who has the order placed on their behalf by a custodain) has
    /// their order filled against the "target user" who has a "target
    /// position" on the order book.
    ///
    /// # Parameters
    /// * `style`: `BUY` or `SELL`
    /// * `side`: `ASK` if `style` is `BUY`, `BID` if `style` is `ASK`:
    ///   the target order side
    /// * `scale_factor`: Scale factor for given market
    /// * `tree_ref_mut`: Mutable reference to orders tree for given
    ///   `side`
    /// * `traversal_direction`: `LEFT` or `RIGHT`
    /// * `n_orders`: Counter for number of orders in tree
    /// * `spread_maker_ref_mut`: Mutable reference to field tracking
    ///   spread maker on given `side`
    /// * `base_parcels_to_fill`: Initialized counter for base parcels
    ///    left to fill
    /// * `base_coins_ref_mut`: Mutable reference to incoming user's
    ///   base coins
    /// * `quote_coins_ref_mut`: Mutable reference to incoming user's
    ///   quote coins
    /// * `econia_capability_ref`: Immutable reference to an
    ///   `EconiaCapability` required for internal cross-module calls
    fun fill_market_order_traverse_loop<B, Q, E>(
        style: bool,
        side: bool,
        scale_factor: u64,
        tree_ref_mut: &mut CritBitTree<Order>,
        traversal_direction: bool,
        n_orders: u64,
        spread_maker_ref_mut: &mut u128,
        base_parcels_to_fill: u64,
        base_coins_ref_mut: &mut coin::Coin<B>,
        quote_coins_ref_mut: &mut coin::Coin<Q>,
        econia_capability_ref: &EconiaCapability
    ) {
        // Initialize iterated traversal, storing order ID of target
        // order, mutable reference to target order, the parent field
        // of the target node, and child field index of target node
        let (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index) = critbit::traverse_init_mut(
                tree_ref_mut, traversal_direction);
        // Declare a null order for generating default mutable reference
        let null_order = Order{user: @0x0, custodian_id: 0, base_parcels: 0};
        loop { // Begin traversal loop
            // Process the order for current iteration, storing flag for
            // if the target order was completely filled
            let complete_fill = fill_market_order_process_loop_order<B, Q, E>(
                style, side, scale_factor, &mut base_parcels_to_fill,
                target_order_id, target_order_ref_mut, base_coins_ref_mut,
                quote_coins_ref_mut, econia_capability_ref);
            // Declare variables for if should break out of loop, if
            // should pop the last order in the tree, and the value for
            // a new spread maker if one is generated
            let (should_break, should_pop, new_spread_maker);
            // Follow up on order processing
            (should_break, should_pop, new_spread_maker, n_orders,
             target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index) = fill_market_order_loop_order_follow_up(
                side, base_parcels_to_fill, complete_fill, traversal_direction,
                tree_ref_mut, n_orders, target_order_id, &mut null_order,
                target_parent_index, target_child_index);
            if (should_break) { // If should break out of loop
                // Clean up as needed before breaking out of loop
                fill_market_order_break_cleanup(null_order,
                    spread_maker_ref_mut, new_spread_maker, should_pop,
                    tree_ref_mut, target_order_id);
                break // Break out of loop
            };
        };
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

    // Below constants for end-to-end market order fill testing
    #[test_only]
    const USER_0_CUSTODIAN_ID: u64 = 0; // No custodian flag
    #[test_only]
    const USER_1_CUSTODIAN_ID: u64 = 1;
    #[test_only]
    const USER_2_CUSTODIAN_ID: u64 = 2;
    #[test_only]
    const USER_3_CUSTODIAN_ID: u64 = 3;
    #[test_only]
    const USER_0_START_BASE: u64 = 1000;
    #[test_only]
    const USER_1_START_BASE: u64 = 2000;
    #[test_only]
    const USER_2_START_BASE: u64 = 3000;
    #[test_only]
    const USER_3_START_BASE: u64 = 4000;
    #[test_only]
    const USER_0_START_QUOTE: u64 = 1500;
    #[test_only]
    const USER_1_START_QUOTE: u64 = 2500;
    #[test_only]
    const USER_2_START_QUOTE: u64 = 3500;
    #[test_only]
    const USER_3_START_QUOTE: u64 = 4500;
    #[test_only]
    const USER_1_ASK_PRICE: u64 = 10;
    #[test_only]
    const USER_2_ASK_PRICE: u64 = 11;
    #[test_only]
    const USER_3_ASK_PRICE: u64 = 12;
    #[test_only]
    const USER_1_ASK_SIZE: u64 = 9;
    #[test_only]
    const USER_2_ASK_SIZE: u64 = 8;
    #[test_only]
    const USER_3_ASK_SIZE: u64 = 7;
    #[test_only]
    const USER_1_BID_SIZE: u64 = 3;
    #[test_only]
    const USER_2_BID_SIZE: u64 = 4;
    #[test_only]
    const USER_3_BID_SIZE: u64 = 5;
    #[test_only]
    const USER_1_BID_PRICE: u64 = 5;
    #[test_only]
    const USER_2_BID_PRICE: u64 = 4;
    #[test_only]
    const USER_3_BID_PRICE: u64 = 3;
    #[test_only]
    const USER_1_SERIAL_ID: u64 = 0;
    #[test_only]
    const USER_2_SERIAL_ID: u64 = 1;
    #[test_only]
    const USER_3_SERIAL_ID: u64 = 2;

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
    /// Initialize a `user` to trade on `<BC, QC, E1>`, hosted by
    /// `econia`, with market account having `custodian_id`, and fund
    /// with `base_coins` and `quote_coins`
    fun init_funded_user(
        econia: &signer,
        user: &signer,
        custodian_id: u64,
        base_coins: u64,
        quote_coins: u64
    ) {
        // Set custodian ID as in bounds
        registry::set_registered_custodian(custodian_id);
        // Reguster user to trade on the market
        user::register_market_account<BC, QC, E1>(user, custodian_id);
        // Get market account info
        let market_account_info =
            user::market_account_info<BC, QC, E1>(custodian_id);
        // Deposit base coin collateral
        user::deposit_collateral<BC>(address_of(user), market_account_info,
            coins::mint<BC>(econia, base_coins));
        // Deposit quote coin collateral
        user::deposit_collateral<QC>(address_of(user), market_account_info,
            coins::mint<QC>(econia, quote_coins));
    }

    #[test_only]
    /// Initialize all users for trading on the test market
    /// `<BC, QC, E1>` hosted by `econia`, then place limit orders
    /// for `user_1`, `user_2`, `user_3`, on `side`, returning the order
    /// ID for each respective position
    fun init_market_test(
        side: bool,
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer,
    ): (
        u128,
        u128,
        u128
    ) acquires EconiaCapabilityStore, OrderBook {
        coins::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initialize registry
        // Initialize Econia capability store
        init_econia_capability_store(econia);
        // Register test market with Econia as host
        register_market<BC, QC, E1>(econia);
        // Initialize funded users
        init_funded_user(econia, user_0, USER_0_CUSTODIAN_ID,
            USER_0_START_BASE, USER_0_START_QUOTE);
        init_funded_user(econia, user_1, USER_1_CUSTODIAN_ID,
            USER_1_START_BASE, USER_1_START_QUOTE);
        init_funded_user(econia, user_2, USER_2_CUSTODIAN_ID,
            USER_2_START_BASE, USER_2_START_QUOTE);
        init_funded_user(econia, user_3, USER_3_CUSTODIAN_ID,
            USER_3_START_BASE, USER_3_START_QUOTE);
        // Define user order prices and sizes based on market side
        let user_1_order_price = if (side == ASK)
            USER_1_ASK_PRICE else USER_1_BID_PRICE;
        let user_2_order_price = if (side == ASK)
            USER_2_ASK_PRICE else USER_2_BID_PRICE;
        let user_3_order_price = if (side == ASK)
            USER_3_ASK_PRICE else USER_3_BID_PRICE;
        let user_1_order_size = if (side == ASK)
            USER_1_ASK_SIZE else USER_1_BID_SIZE;
        let user_2_order_size = if (side == ASK)
            USER_2_ASK_SIZE else USER_2_BID_SIZE;
        let user_3_order_size = if (side == ASK)
            USER_3_ASK_SIZE else USER_3_BID_SIZE;
        // Define order ID for each user's upcoming order
        let order_id_1 = order_id::order_id(user_1_order_price,
            USER_1_SERIAL_ID, side);
        let order_id_2 = order_id::order_id(user_2_order_price,
            USER_2_SERIAL_ID, side);
        let order_id_3 = order_id::order_id(user_3_order_price,
            USER_3_SERIAL_ID, side);
        // Get custodian capabilities
        let custodian_capability_1 =
            registry::get_custodian_capability(USER_1_CUSTODIAN_ID);
        let custodian_capability_2 =
            registry::get_custodian_capability(USER_2_CUSTODIAN_ID);
        let custodian_capability_3 =
            registry::get_custodian_capability(USER_3_CUSTODIAN_ID);
        // Place limit orders for given side
        place_limit_order_custodian<BC, QC, E1>(@user_1, @econia, side,
            user_1_order_size, user_1_order_price, &custodian_capability_1);
        place_limit_order_custodian<BC, QC, E1>(@user_2, @econia, side,
            user_2_order_size, user_2_order_price, &custodian_capability_2);
        place_limit_order_custodian<BC, QC, E1>(@user_3, @econia, side,
            user_3_order_size, user_3_order_price, &custodian_capability_3);
        // Destroy custodian capabilities
        registry::destroy_custodian_capability(custodian_capability_1);
        registry::destroy_custodian_capability(custodian_capability_2);
        registry::destroy_custodian_capability(custodian_capability_3);
        (order_id_1, order_id_2, order_id_3) // Return order IDs
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
        // Register user to trade on the market
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
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify post-fill state for user submitting market buy where the
    /// specified `max_quote_units` limits them to a complete fill on
    /// first order
    fun test_fill_market_order_complete_fill_quote_limiting(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = BUY; // define market order style
        let side =  ASK; // define side of book orders fill against
        let max_base_parcels = 1000; // define max base parcels to fill
        // define max quote units if buy
        let max_quote_units = USER_1_ASK_PRICE * USER_1_ASK_SIZE;
        // Calculate number of base parcels filled
        let base_parcels_filled = USER_1_ASK_SIZE;
        // Calculate number of base coins routed
        let base_routed = base_parcels_filled * SCALE_FACTOR;
        // Calculate number of quote coins routed
        let quote_routed = base_parcels_filled * USER_1_ASK_PRICE;
        assert!( // assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order id of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        let custodian_capability = // Get mock custodian capability
            registry::get_custodian_capability(USER_0_CUSTODIAN_ID);
        // Attempt market order fill, generating mock custodian
        // capability that cannot make in practice but which can use to
        // check invocation of custodian placement function
        fill_market_order_custodian<BC, QC, E1>(@user_0, @econia, style,
            max_base_parcels, max_quote_units, &custodian_capability);
        // Destroy capability
        registry::destroy_custodian_capability(custodian_capability);
        // Assert order book state
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_2 ==  USER_2_ASK_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_ASK_SIZE, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_2, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE + base_routed, 0);
        assert!(      base_total_0 == USER_0_START_BASE + base_routed, 0);
        assert!(  base_available_0 == USER_0_START_BASE + base_routed, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!( base_collateral_1 == USER_1_START_BASE - base_routed, 0);
        assert!(      base_total_1 == USER_1_START_BASE - base_routed, 0);
        assert!(  base_available_1 == USER_1_START_BASE - base_routed, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE -
            USER_2_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE -
            USER_3_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE, 0);
        // Assert user order sizes (or that they have been popped)
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_2_order_base_parcels == USER_2_ASK_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_ASK_SIZE, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for no such order book
    fun test_fill_market_order_no_book(
        user: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        // Attempt invalid market order fill
        fill_market_order_user<QC, BC, E1>(user, @econia, BUY, 100, 200);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify unmodified user state for nothing to fill
    fun test_fill_market_order_no_fill_base_parcels(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = SELL; // Define market order style
        let side =  BID; // Define side of book orders fill against
        let max_base_parcels = 0; // Define max base parcels to fill
        let max_quote_units = 100; // Define max quote units if buy
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert order book state
        let (order_base_parcels_1, order_user_1, order_custodian_id_1) =
            order_fields_test<BC, QC, E1>(@econia, order_id_1, side);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_1 ==  USER_1_BID_SIZE, 0);
        assert!(order_base_parcels_2 ==  USER_2_BID_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_BID_SIZE, 0);
        assert!(        order_user_1 == @user_1, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_1 ==  USER_1_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE, 0);
        assert!(      base_total_0 == USER_0_START_BASE, 0);
        assert!(  base_available_0 == USER_0_START_BASE, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE, 0);
        assert!( base_collateral_1 == USER_1_START_BASE, 0);
        assert!(      base_total_1 == USER_1_START_BASE, 0);
        assert!(  base_available_1 == USER_1_START_BASE, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE
            - USER_1_BID_SIZE * USER_1_BID_PRICE, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE
            - USER_2_BID_SIZE * USER_2_BID_PRICE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE
            - USER_3_BID_SIZE * USER_3_BID_PRICE, 0);
        // Assert user order sizes
        let user_1_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_1,
                USER_1_CUSTODIAN_ID, side, order_id_1);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_1_order_base_parcels == USER_1_BID_SIZE, 0);
        assert!(user_2_order_base_parcels == USER_2_BID_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_BID_SIZE, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify unmodified user state for user submitting market buy but
    /// not allowing enough quote coins to fill even one base parcel
    fun test_fill_market_order_no_fill_cant_afford(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = BUY; // define market order style
        let side =  ASK; // define side of book orders fill against
        let max_base_parcels = 100; // define max base parcels to fill
        let max_quote_units = 1; // define max quote units if buy
        assert!( // assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert order book state
        let (order_base_parcels_1, order_user_1, order_custodian_id_1) =
            order_fields_test<BC, QC, E1>(@econia, order_id_1, side);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_1 ==  USER_1_ASK_SIZE, 0);
        assert!(order_base_parcels_2 ==  USER_2_ASK_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_ASK_SIZE, 0);
        assert!(        order_user_1 == @user_1, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_1 ==  USER_1_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE, 0);
        assert!(      base_total_0 == USER_0_START_BASE, 0);
        assert!(  base_available_0 == USER_0_START_BASE, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE, 0);
        assert!( base_collateral_1 == USER_1_START_BASE, 0);
        assert!(      base_total_1 == USER_1_START_BASE, 0);
        assert!(  base_available_1 == USER_1_START_BASE -
            USER_1_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE -
            USER_2_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE -
            USER_3_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE, 0);
        // Assert user order sizes
        let user_1_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_1,
                USER_1_CUSTODIAN_ID, side, order_id_1);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_1_order_base_parcels == USER_1_ASK_SIZE, 0);
        assert!(user_2_order_base_parcels == USER_2_ASK_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_ASK_SIZE, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify unmodified user state for nothing to fill (trying to
    /// fill side without orders)
    fun test_fill_market_order_no_fill_empty_tree(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = SELL; // Define market order style
        let side =  BID; // Define side of book orders fill against
        let max_base_parcels = 50; // Define max base parcels to fill
        let max_quote_units = 100; // Define max quote units if buy
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Attempt market order fill on opposite side of book (empty)
        fill_market_order_user<BC, QC, E1>(user_0, @econia, !style,
            max_base_parcels, max_quote_units);
        // Assert order book state
        let (order_base_parcels_1, order_user_1, order_custodian_id_1) =
            order_fields_test<BC, QC, E1>(@econia, order_id_1, side);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_1 ==  USER_1_BID_SIZE, 0);
        assert!(order_base_parcels_2 ==  USER_2_BID_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_BID_SIZE, 0);
        assert!(        order_user_1 == @user_1, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_1 ==  USER_1_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE, 0);
        assert!(      base_total_0 == USER_0_START_BASE, 0);
        assert!(  base_available_0 == USER_0_START_BASE, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE, 0);
        assert!( base_collateral_1 == USER_1_START_BASE, 0);
        assert!(      base_total_1 == USER_1_START_BASE, 0);
        assert!(  base_available_1 == USER_1_START_BASE, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE
            - USER_1_BID_SIZE * USER_1_BID_PRICE, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE
            - USER_2_BID_SIZE * USER_2_BID_PRICE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE
            - USER_3_BID_SIZE * USER_3_BID_PRICE, 0);
        // Assert user order sizes
        let user_1_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_1,
                USER_1_CUSTODIAN_ID, side, order_id_1);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_1_order_base_parcels == USER_1_BID_SIZE, 0);
        assert!(user_2_order_base_parcels == USER_2_BID_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_BID_SIZE, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify unmodified user state for nothing to fill
    fun test_fill_market_order_no_fill_quote_units(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = BUY; // Define market order style
        let side =  ASK; // Define side of book orders fill against
        let max_base_parcels = 20; // Define max base parcels to fill
        let max_quote_units = 0; // Define max quote units if buy
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert order book state
        let (order_base_parcels_1, order_user_1, order_custodian_id_1) =
            order_fields_test<BC, QC, E1>(@econia, order_id_1, side);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_1 ==  USER_1_ASK_SIZE, 0);
        assert!(order_base_parcels_2 ==  USER_2_ASK_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_ASK_SIZE, 0);
        assert!(        order_user_1 == @user_1, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_1 ==  USER_1_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE, 0);
        assert!(      base_total_0 == USER_0_START_BASE, 0);
        assert!(  base_available_0 == USER_0_START_BASE, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE, 0);
        assert!( base_collateral_1 == USER_1_START_BASE, 0);
        assert!(      base_total_1 == USER_1_START_BASE, 0);
        assert!(  base_available_1 == USER_1_START_BASE -
            USER_1_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE -
            USER_2_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE -
            USER_3_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE, 0);
        // Assert user order sizes
        let user_1_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_1,
                USER_1_CUSTODIAN_ID, side, order_id_1);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_1_order_base_parcels == USER_1_ASK_SIZE, 0);
        assert!(user_2_order_base_parcels == USER_2_ASK_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_ASK_SIZE, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify post-trade state for filling through all price levels
    /// except the final order, for filling against bids
    fun test_fill_market_order_partial_fill_final_bid(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = SELL; // Define market order style
        let side =  BID; // Define side of book orders fill against
        // Define partial fill against user 3
        let user_3_fill_size = USER_3_BID_SIZE - 1;
        let max_base_parcels = USER_1_BID_SIZE + USER_2_BID_SIZE +
            (user_3_fill_size); // Define max base parcels to fill
        let max_quote_units = 0; // Define max quote units if buy
        // Define base/quoute coins routed for each order on book
        let user_1_base_routed  = USER_1_BID_SIZE * SCALE_FACTOR;
        let user_1_quote_routed = USER_1_BID_SIZE * USER_1_BID_PRICE;
        let user_2_base_routed  = USER_2_BID_SIZE * SCALE_FACTOR;
        let user_2_quote_routed = USER_2_BID_SIZE * USER_2_BID_PRICE;
        let user_3_base_routed  = user_3_fill_size * SCALE_FACTOR;
        let user_3_quote_routed = user_3_fill_size * USER_3_BID_PRICE;
        // Calculate end coin amounts for each user
        let user_0_end_base = USER_0_START_BASE - (user_1_base_routed +
            user_2_base_routed + user_3_base_routed);
        let user_0_end_quote = USER_0_START_QUOTE + (user_1_quote_routed +
            user_2_quote_routed + user_3_quote_routed);
        let user_1_end_base  = USER_1_START_BASE  + user_1_base_routed;
        let user_1_end_quote = USER_1_START_QUOTE - user_1_quote_routed;
        let user_2_end_base  = USER_2_START_BASE  + user_2_base_routed;
        let user_2_end_quote = USER_2_START_QUOTE - user_2_quote_routed;
        let user_3_end_base  = USER_3_START_BASE  + user_3_base_routed;
        let user_3_end_quote = USER_3_START_QUOTE - user_3_quote_routed;
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Assert all orders on book
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_3), 0);
        // Assert users have orders registered
        assert!(user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID, side, order_id_3), 0);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert all orders taken off book except final one
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_3 ==
            USER_3_BID_SIZE - user_3_fill_size, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        // Assert spread maker updated
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) ==
            order_id_3, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == user_0_end_base, 0);
        assert!(      base_total_0 == user_0_end_base, 0);
        assert!(  base_available_0 == user_0_end_base, 0);
        assert!(quote_collateral_0 == user_0_end_quote, 0);
        assert!(     quote_total_0 == user_0_end_quote, 0);
        assert!( quote_available_0 == user_0_end_quote, 0);
        assert!( base_collateral_1 == user_1_end_base, 0);
        assert!(      base_total_1 == user_1_end_base, 0);
        assert!(  base_available_1 == user_1_end_base, 0);
        assert!(quote_collateral_1 == user_1_end_quote, 0);
        assert!(     quote_total_1 == user_1_end_quote, 0);
        assert!( quote_available_1 == user_1_end_quote, 0);
        assert!( base_collateral_2 == user_2_end_base, 0);
        assert!(      base_total_2 == user_2_end_base, 0);
        assert!(  base_available_2 == user_2_end_base, 0);
        assert!(quote_collateral_2 == user_2_end_quote, 0);
        assert!(     quote_total_2 == user_2_end_quote, 0);
        assert!( quote_available_2 == user_2_end_quote, 0);
        assert!( base_collateral_3 == user_3_end_base, 0);
        assert!(      base_total_3 == user_3_end_base, 0);
        assert!(  base_available_3 == user_3_end_base, 0);
        assert!(quote_collateral_3 == user_3_end_quote, 0);
        assert!(     quote_total_3 == user_3_end_quote, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE -
            USER_3_BID_SIZE * USER_3_BID_PRICE, 0);
        // Assert user orders popped except for final user
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_3_order_base_parcels == USER_3_BID_SIZE -
            user_3_fill_size, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify post-fill state for user submitting market buy where the
    /// specified `max_quote_units` limits them to a partial fill.
    fun test_fill_market_order_partial_fill_quote_limiting(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = BUY; // define market order style
        let side =  ASK; // define side of book orders fill against
        let max_base_parcels = 1000; // define max base parcels to fill
        let max_quote_units = 11; // define max quote units if buy
        // Calculate number of base parcels filled
        let base_parcels_filled = max_quote_units / USER_1_ASK_PRICE;
        // Calculate number of base coins routed
        let base_routed = base_parcels_filled * SCALE_FACTOR;
        // Calculate number of quote coins routed
        let quote_routed = base_parcels_filled * USER_1_ASK_PRICE;
        assert!( // assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order id of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert order book state
        let (order_base_parcels_1, order_user_1, order_custodian_id_1) =
            order_fields_test<BC, QC, E1>(@econia, order_id_1, side);
        let (order_base_parcels_2, order_user_2, order_custodian_id_2) =
            order_fields_test<BC, QC, E1>(@econia, order_id_2, side);
        let (order_base_parcels_3, order_user_3, order_custodian_id_3) =
            order_fields_test<BC, QC, E1>(@econia, order_id_3, side);
        assert!(order_base_parcels_1 ==
            USER_1_ASK_SIZE - base_parcels_filled, 0);
        assert!(order_base_parcels_2 ==  USER_2_ASK_SIZE, 0);
        assert!(order_base_parcels_3 ==  USER_3_ASK_SIZE, 0);
        assert!(        order_user_1 == @user_1, 0);
        assert!(        order_user_2 == @user_2, 0);
        assert!(        order_user_3 == @user_3, 0);
        assert!(order_custodian_id_1 ==  USER_1_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_2 ==  USER_2_CUSTODIAN_ID, 0);
        assert!(order_custodian_id_3 ==  USER_3_CUSTODIAN_ID, 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) == order_id_1, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == USER_0_START_BASE + base_routed, 0);
        assert!(      base_total_0 == USER_0_START_BASE + base_routed, 0);
        assert!(  base_available_0 == USER_0_START_BASE + base_routed, 0);
        assert!(quote_collateral_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!(     quote_total_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!( quote_available_0 == USER_0_START_QUOTE - quote_routed, 0);
        assert!( base_collateral_1 == USER_1_START_BASE - base_routed, 0);
        assert!(      base_total_1 == USER_1_START_BASE - base_routed, 0);
        assert!(  base_available_1 == USER_1_START_BASE -
            USER_1_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!(     quote_total_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!( quote_available_1 == USER_1_START_QUOTE + quote_routed, 0);
        assert!( base_collateral_2 == USER_2_START_BASE, 0);
        assert!(      base_total_2 == USER_2_START_BASE, 0);
        assert!(  base_available_2 == USER_2_START_BASE -
            USER_2_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_2 == USER_2_START_QUOTE, 0);
        assert!(     quote_total_2 == USER_2_START_QUOTE, 0);
        assert!( quote_available_2 == USER_2_START_QUOTE, 0);
        assert!( base_collateral_3 == USER_3_START_BASE, 0);
        assert!(      base_total_3 == USER_3_START_BASE, 0);
        assert!(  base_available_3 == USER_3_START_BASE -
            USER_3_ASK_SIZE * SCALE_FACTOR, 0);
        assert!(quote_collateral_3 == USER_3_START_QUOTE, 0);
        assert!(     quote_total_3 == USER_3_START_QUOTE, 0);
        assert!( quote_available_3 == USER_3_START_QUOTE, 0);
        // Assert user order sizes
        let user_1_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_1,
                USER_1_CUSTODIAN_ID, side, order_id_1);
        let user_2_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_2,
                USER_2_CUSTODIAN_ID, side, order_id_2);
        let user_3_order_base_parcels =
            user::order_base_parcels_test<BC, QC, E1>(@user_3,
                USER_3_CUSTODIAN_ID, side, order_id_3);
        assert!(user_1_order_base_parcels ==
            USER_1_ASK_SIZE - base_parcels_filled, 0);
        assert!(user_2_order_base_parcels == USER_2_ASK_SIZE, 0);
        assert!(user_3_order_base_parcels == USER_3_ASK_SIZE, 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify post-trade state for filling through all price levels and
    /// popping the final trade on the book, for filling against asks
    fun test_fill_market_order_pop_final_ask(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = BUY; // Define market order style
        let side =  ASK; // Define side of book orders fill against
        let max_base_parcels = (USER_1_ASK_SIZE + USER_2_ASK_SIZE +
            USER_3_ASK_SIZE) + 1; // Calculate max base parcels
        // Define max quote units if buy (limiting factor here)
        let max_quote_units =
            (USER_1_ASK_SIZE * USER_1_ASK_PRICE) +
            (USER_2_ASK_SIZE * USER_2_ASK_PRICE) +
            (USER_3_ASK_SIZE * USER_3_ASK_PRICE);
        // Define base/quoute coins routed for each order on book
        let user_1_base_routed  = USER_1_ASK_SIZE * SCALE_FACTOR;
        let user_1_quote_routed = USER_1_ASK_SIZE * USER_1_ASK_PRICE;
        let user_2_base_routed  = USER_2_ASK_SIZE * SCALE_FACTOR;
        let user_2_quote_routed = USER_2_ASK_SIZE * USER_2_ASK_PRICE;
        let user_3_base_routed  = USER_3_ASK_SIZE * SCALE_FACTOR;
        let user_3_quote_routed = USER_3_ASK_SIZE * USER_3_ASK_PRICE;
        // Calculate end coin amounts for each user
        let user_0_end_base = USER_0_START_BASE + (user_1_base_routed +
            user_2_base_routed + user_3_base_routed);
        let user_0_end_quote = USER_0_START_QUOTE - (user_1_quote_routed +
            user_2_quote_routed + user_3_quote_routed);
        let user_1_end_base  = USER_1_START_BASE  - user_1_base_routed;
        let user_1_end_quote = USER_1_START_QUOTE + user_1_quote_routed;
        let user_2_end_base  = USER_2_START_BASE  - user_2_base_routed;
        let user_2_end_quote = USER_2_START_QUOTE + user_2_quote_routed;
        let user_3_end_base  = USER_3_START_BASE  - user_3_base_routed;
        let user_3_end_quote = USER_3_START_QUOTE + user_3_quote_routed;
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Assert all orders on book
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_3), 0);
        // Assert users have orders registered
        assert!(user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID, side, order_id_3), 0);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert all orders taken off book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_3), 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) ==
            MIN_ASK_DEFAULT, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == user_0_end_base, 0);
        assert!(      base_total_0 == user_0_end_base, 0);
        assert!(  base_available_0 == user_0_end_base, 0);
        assert!(quote_collateral_0 == user_0_end_quote, 0);
        assert!(     quote_total_0 == user_0_end_quote, 0);
        assert!( quote_available_0 == user_0_end_quote, 0);
        assert!( base_collateral_1 == user_1_end_base, 0);
        assert!(      base_total_1 == user_1_end_base, 0);
        assert!(  base_available_1 == user_1_end_base, 0);
        assert!(quote_collateral_1 == user_1_end_quote, 0);
        assert!(     quote_total_1 == user_1_end_quote, 0);
        assert!( quote_available_1 == user_1_end_quote, 0);
        assert!( base_collateral_2 == user_2_end_base, 0);
        assert!(      base_total_2 == user_2_end_base, 0);
        assert!(  base_available_2 == user_2_end_base, 0);
        assert!(quote_collateral_2 == user_2_end_quote, 0);
        assert!(     quote_total_2 == user_2_end_quote, 0);
        assert!( quote_available_2 == user_2_end_quote, 0);
        assert!( base_collateral_3 == user_3_end_base, 0);
        assert!(      base_total_3 == user_3_end_base, 0);
        assert!(  base_available_3 == user_3_end_base, 0);
        assert!(quote_collateral_3 == user_3_end_quote, 0);
        assert!(     quote_total_3 == user_3_end_quote, 0);
        assert!( quote_available_3 == user_3_end_quote, 0);
        // Assert user orders popped
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID, side, order_id_3), 0);
    }

    #[test(
        econia = @econia,
        user_0 = @user_0,
        user_1 = @user_1,
        user_2 = @user_2,
        user_3 = @user_3
    )]
    /// Verify post-trade state for filling through all price levels and
    /// popping the final trade on the book, for filling against bids
    fun test_fill_market_order_pop_final_bid(
        econia: &signer,
        user_0: &signer,
        user_1: &signer,
        user_2: &signer,
        user_3: &signer
    ) acquires EconiaCapabilityStore, OrderBook {
        let style = SELL; // Define market order style
        let side =  BID; // Define side of book orders fill against
        let max_base_parcels = USER_1_BID_SIZE + USER_2_BID_SIZE +
            USER_3_BID_SIZE + 1; // Define max base parcels to fill
        let max_quote_units = 0; // Define max quote units if buy
        // Define base/quoute coins routed for each order on book
        let user_1_base_routed  = USER_1_BID_SIZE * SCALE_FACTOR;
        let user_1_quote_routed = USER_1_BID_SIZE * USER_1_BID_PRICE;
        let user_2_base_routed  = USER_2_BID_SIZE * SCALE_FACTOR;
        let user_2_quote_routed = USER_2_BID_SIZE * USER_2_BID_PRICE;
        let user_3_base_routed  = USER_3_BID_SIZE * SCALE_FACTOR;
        let user_3_quote_routed = USER_3_BID_SIZE * USER_3_BID_PRICE;
        // Calculate end coin amounts for each user
        let user_0_end_base = USER_0_START_BASE - (user_1_base_routed +
            user_2_base_routed + user_3_base_routed);
        let user_0_end_quote = USER_0_START_QUOTE + (user_1_quote_routed +
            user_2_quote_routed + user_3_quote_routed);
        let user_1_end_base  = USER_1_START_BASE  + user_1_base_routed;
        let user_1_end_quote = USER_1_START_QUOTE - user_1_quote_routed;
        let user_2_end_base  = USER_2_START_BASE  + user_2_base_routed;
        let user_2_end_quote = USER_2_START_QUOTE - user_2_quote_routed;
        let user_3_end_base  = USER_3_START_BASE  + user_3_base_routed;
        let user_3_end_quote = USER_3_START_QUOTE - user_3_quote_routed;
        assert!( // Assert style and side match
            style == SELL && side == BID || style == BUY && side == ASK, 0);
        // Initialize test market, storing order ID of limit orders
        let (order_id_1, order_id_2, order_id_3) = init_market_test(side,
            econia, user_0, user_1, user_2, user_3);
        // Assert all orders on book
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        assert!(has_order_test<BC, QC, E1>(@econia, side, order_id_3), 0);
        // Assert users have orders registered
        assert!(user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        assert!(user::has_order_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID, side, order_id_3), 0);
        // Attempt market order fill
        fill_market_order_user<BC, QC, E1>(user_0, @econia, style,
            max_base_parcels, max_quote_units);
        // Assert all orders taken off book
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_1), 0);
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_2), 0);
        assert!(!has_order_test<BC, QC, E1>(@econia, side, order_id_3), 0);
        assert!(spread_maker_test<BC, QC, E1>(@econia, side) ==
            MAX_BID_DEFAULT, 0);
        // Assert user collateral amounts
        let ( base_collateral_0,  base_total_0,  base_available_0,
             quote_collateral_0, quote_total_0, quote_available_0) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_0, USER_0_CUSTODIAN_ID);
        let ( base_collateral_1,  base_total_1,  base_available_1,
             quote_collateral_1, quote_total_1, quote_available_1) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID);
        let ( base_collateral_2,  base_total_2,  base_available_2,
             quote_collateral_2, quote_total_2, quote_available_2) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID);
        let ( base_collateral_3,  base_total_3,  base_available_3,
             quote_collateral_3, quote_total_3, quote_available_3) =
            user::get_collateral_state_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID);
        assert!( base_collateral_0 == user_0_end_base, 0);
        assert!(      base_total_0 == user_0_end_base, 0);
        assert!(  base_available_0 == user_0_end_base, 0);
        assert!(quote_collateral_0 == user_0_end_quote, 0);
        assert!(     quote_total_0 == user_0_end_quote, 0);
        assert!( quote_available_0 == user_0_end_quote, 0);
        assert!( base_collateral_1 == user_1_end_base, 0);
        assert!(      base_total_1 == user_1_end_base, 0);
        assert!(  base_available_1 == user_1_end_base, 0);
        assert!(quote_collateral_1 == user_1_end_quote, 0);
        assert!(     quote_total_1 == user_1_end_quote, 0);
        assert!( quote_available_1 == user_1_end_quote, 0);
        assert!( base_collateral_2 == user_2_end_base, 0);
        assert!(      base_total_2 == user_2_end_base, 0);
        assert!(  base_available_2 == user_2_end_base, 0);
        assert!(quote_collateral_2 == user_2_end_quote, 0);
        assert!(     quote_total_2 == user_2_end_quote, 0);
        assert!( quote_available_2 == user_2_end_quote, 0);
        assert!( base_collateral_3 == user_3_end_base, 0);
        assert!(      base_total_3 == user_3_end_base, 0);
        assert!(  base_available_3 == user_3_end_base, 0);
        assert!(quote_collateral_3 == user_3_end_quote, 0);
        assert!(     quote_total_3 == user_3_end_quote, 0);
        assert!( quote_available_3 == user_3_end_quote, 0);
        // Assert user orders popped
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_1, USER_1_CUSTODIAN_ID, side, order_id_1), 0);
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_2, USER_2_CUSTODIAN_ID, side, order_id_2), 0);
        assert!(!user::has_order_test<BC, QC, E1>(
                @user_3, USER_3_CUSTODIAN_ID, side, order_id_3), 0);
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

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting to re-init under Econia account
    fun test_init_econia_capability_store_exists(
        econia: &signer
    ) {
        init_econia_capability_store(econia); // Initialize store
        init_econia_capability_store(econia); // Attempt invalid re-init
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to init under non-Econia account
    fun test_init_econia_capability_store_not_econia(
        account: &signer
    ) {
        init_econia_capability_store(account); // Attempt invalid init
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