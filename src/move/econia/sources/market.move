/// Market functionality for order book operations.
///
/// For each registered market, Econia has an order book stored under a
/// global resource account. When someone registers a market, a new
/// order book entry is added under the resource account at a new market
/// ID.
///
/// Once a market is registered, signing users and delegated custodians
/// can place limit orders on the book as makers, takers can place
/// market orders or swaps against the order book, and makers can cancel
/// or change the size of any outstanding orders they have on the book.
///
/// Econia implements an atomic matching engine for processing taker
/// fills against maker orders on the book, and emits events in response
/// to changes in order book state. Notably, Econia evicts the ask or
/// bid with the lowest price-time priority when inserting a limit order
/// to a binary search tree that exceeds a critical height.
///
/// Multiple API variants are supported for market registration and
/// order management function, to enable diagnostic function returns,
/// public entry calls, etc.
///
/// # General overview sections
///
/// [Public function index](#public-function-index)
///
/// * [Market registration](#market-registration)
/// * [Limit orders](#limit-orders)
/// * [Market orders](#market-orders)
/// * [Swaps](#swaps)
/// * [Change order size](#change-order-size)
/// * [Cancel orders](#cancel-orders)
///
/// [Indexing](#indexing)
///
/// [Dependency charts](#dependency-charts)
///
/// * [Internal dependencies](#internal-dependencies)
/// * [External module dependencies](#external-module-dependencies)
///
/// [Order management testing](#order-management-testing)
///
/// * [Functions with aborts](#functions-with-aborts)
/// * [Return proxies](#return-proxies)
/// * [Invocation proxies](#invocation-proxies)
/// * [Branching functions](#branching-functions)
///
/// [Complete DocGen index](#complete-docgen-index)
///
/// # Public function index
///
/// See the [dependency charts](#dependency-charts) for a visual map of
/// associated function wrappers.
///
/// ## Market registration
///
/// * `register_market_base_coin()`
/// * `register_market_base_coin_from_coinstore()`
/// * `register_market_base_generic()`
///
/// ## Limit orders
///
/// * `place_limit_order_custodian()`
/// * `place_limit_order_user()`
/// * `place_limit_order_user_entry()`
///
/// ## Market orders
///
/// * `place_market_order_custodian()`
/// * `place_market_order_user()`
/// * `place_market_order_user_entry()`
///
/// ## Swaps
///
/// * `swap_between_coinstores()`
/// * `swap_between_coinstores_entry()`
/// * `swap_coins()`
/// * `swap_generic()`
///
/// ## Change order size
///
/// * `change_order_size_custodian()`
/// * `change_order_size_user()`
///
/// ## Cancel orders
///
/// * `cancel_order_custodian()`
/// * `cancel_order_user()`
/// * `cancel_all_orders_custodian()`
/// * `cancel_all_orders_user()`
///
/// # Indexing
///
/// An order book can be indexed off-chain via `index_orders()`, an
/// SDK-generative function for use as a `move-to-ts` method attribute
/// on an `OrderBook`.
///
/// Once an order book has been indexed, the off-chain copy can be kept
/// current by monitoring `MakerEvent` and `TakerEvent` emissions from
/// the following functions:
///
/// * `cancel_order()`
/// * `change_order_size()`
/// * `match()`
/// * `place_limit_order()`
///
/// # Dependency charts
///
/// The below dependency charts use `mermaid.js` syntax, which can be
/// automatically rendered into a diagram (depending on the browser)
/// when viewing the documentation file generated from source code. If
/// a browser renders the diagrams with coloring that makes it difficult
/// to read, try a different browser.
///
/// ## Internal dependencies
///
/// These charts describe dependencies between `market` functions.
///
/// Market registration:
///
/// ```mermaid
///
/// flowchart LR
///
/// register_market_base_coin --> register_market
///
/// register_market_base_generic --> register_market
///
/// register_market_base_coin_from_coinstore -->
///     register_market_base_coin
///
/// ```
///
/// Placing orders:
///
/// ```mermaid
///
/// flowchart LR
///
/// subgraph Limit orders
///
/// place_limit_order_user_entry --> place_limit_order_user
///
/// place_limit_order_user --> place_limit_order
///
/// place_limit_order_custodian --> place_limit_order
///
/// end
///
/// place_limit_order ---> match
///
/// place_limit_order --> range_check_trade
///
/// subgraph Market orders
///
/// place_market_order_user_entry --> place_market_order_user
///
/// place_market_order_user --> place_market_order
///
/// place_market_order_custodian --> place_market_order
///
/// end
///
/// place_market_order ---> match
///
/// place_market_order --> range_check_trade
///
/// swap_between_coinstores ---> range_check_trade
///
/// subgraph Swaps
///
/// swap_between_coinstores_entry --> swap_between_coinstores
///
/// swap_between_coinstores --> swap
///
/// swap_coins --> swap
///
/// swap_generic --> swap
///
/// end
///
/// swap_generic --> range_check_trade
///
/// swap_coins ---> range_check_trade
///
/// swap ---> match
///
/// ```
///
/// Changing order size:
///
/// ```mermaid
///
/// flowchart LR
///
/// change_order_size_custodian --> change_order_size
///
/// change_order_size_user --> change_order_size
///
/// ```
///
/// Cancelling orders:
///
/// ```mermaid
///
/// flowchart LR
///
/// cancel_all_orders_custodian --> cancel_all_orders
///
/// cancel_order_custodian --> cancel_order
///
/// cancel_all_orders_user --> cancel_all_orders
///
/// cancel_order_user --> cancel_order
///
/// cancel_all_orders --> cancel_order
///
/// ```
///
/// ## External module dependencies
///
/// These charts describe `market` function dependencies on functions
/// from other Econia modules, other than `avl_queue` and `tablist`,
/// which are essentially data structure libraries.
///
/// `incentives`:
///
/// ``` mermaid
///
/// flowchart LR
///
/// register_market_base_coin_from_coinstore -->
///     incentives::get_market_registration_fee
///
/// register_market --> incentives::register_econia_fee_store_entry
///
/// match --> incentives::get_taker_fee_divisor
/// match --> incentives::calculate_max_quote_match
/// match --> incentives::assess_taker_fees
///
/// ```
///
/// `registry`:
///
/// ``` mermaid
///
/// flowchart LR
///
/// register_market_base_coin -->
///     registry::register_market_base_coin_internal
///
/// register_market_base_generic -->
///     registry::register_market_base_generic_internal
/// register_market_base_generic -->
///     registry::get_underwriter_id
///
/// place_limit_order_custodian --> registry::get_custodian_id
///
/// place_market_order_custodian --> registry::get_custodian_id
///
/// swap_generic --> registry::get_underwriter_id
///
/// change_order_size_custodian --> registry::get_custodian_id
///
/// cancel_order_custodian --> registry::get_custodian_id
///
/// cancel_all_orders_custodian --> registry::get_custodian_id
///
/// ```
///
/// `resource_account`:
///
/// ``` mermaid
///
/// flowchart LR
///
/// init_module --> resource_account::get_signer
///
/// register_market --> resource_account::get_signer
///
/// place_limit_order --> resource_account::get_address
///
/// place_market_order --> resource_account::get_address
///
/// swap --> resource_account::get_address
///
/// change_order_size --> resource_account::get_address
///
/// cancel_order --> resource_account::get_address
///
/// ```
///
/// `user`:
///
/// ``` mermaid
///
/// flowchart LR
///
/// place_limit_order --> user::get_asset_counts_internal
/// place_limit_order --> user::withdraw_assets_internal
/// place_limit_order --> user::deposit_assets_internal
/// place_limit_order --> user::get_next_order_access_key_internal
/// place_limit_order --> user::place_order_internal
/// place_limit_order --> user::cancel_order_internal
///
/// place_market_order --> user::get_asset_counts_internal
/// place_market_order --> user::withdraw_assets_internal
/// place_market_order --> user::deposit_assets_internal
///
/// match --> user::fill_order_internal
///
/// change_order_size --> user::change_order_size_internal
///
/// cancel_order --> user::cancel_order_internal
///
/// cancel_all_orders --> user::get_active_market_order_ids_internal
///
/// ```
///
/// # Order management testing
///
/// While market registration functions can be simply verified with
/// straightforward tests, order management functions are more
/// comprehensively tested through integrated tests that verify multiple
/// logical branches, returns, and state updates. Aborts are tested
/// individually for each function.
///
/// ## Functions with aborts
///
/// Function aborts to test:
///
/// * [x] `cancel_order()`
/// * [x] `change_order_size()`
/// * [x] `match()`
/// * [x] `place_limit_order()`
/// * [x] `range_check_trade()`
/// * [x] `swap()`
///
/// ## Return proxies
///
/// Various order management functions have returns, and verifying the
/// returns of some functions verifies the returns of associated inner
/// functions. For example, the collective verification of the returns
/// of `swap_coins()` and `swap_generic()` verifies the returns of both
/// `swap()` and `match()`, such that the combination of `swap_coins()`
/// and `swap_generic()` can be considered a "return proxy" of both
/// `swap()` and of `match()`. Hence the most efficient test suite
/// involves return verification for the minimal return proxy set:
///
/// | Function                         | Return proxy                |
/// |----------------------------------|-----------------------------|
/// | `match()`                   | `swap_coins()`, `swap_generic()` |
/// | `place_limit_order()`            | `place_limit_order_user()`  |
/// | `place_limit_order_custodian()`  | None                        |
/// | `place_limit_order_user()`       | None                        |
/// | `place_market_order()`           | `place_market_order_user()` |
/// | `place_market_order_custodian()` | None                        |
/// | `place_market_order_user()`      | None                        |
/// | `swap()`                    | `swap_coins()`, `swap_generic()` |
/// | `swap_between_coinstores()`      | None                        |
/// | `swap_coins()`                   | None                        |
/// | `swap_generic()`                 | None                        |
///
/// Function returns to test:
///
/// * [x] `place_limit_order_custodian()`
/// * [x] `place_limit_order_user()`
/// * [x] `place_market_order_custodian()`
/// * [x] `place_market_order_user()`
/// * [x] `swap_between_coinstores()`
/// * [x] `swap_coins()`
/// * [x] `swap_generic()`
///
/// ## Invocation proxies
///
/// Similarly, verifying the invocation of some functions verifies the
/// invocation of associated inner functions. For example,
/// `cancel_all_orders_user()` can be considered an invocation proxy
/// of `cancel_all_orders()` and of `cancel_order()`. Here, to provide
/// 100% invocation coverage, only functions at the top of the
/// dependency stack must be verified.
///
/// Function invocations to test:
///
/// * [x] `cancel_all_orders_custodian()`
/// * [x] `cancel_all_orders_user()`
/// * [x] `cancel_order_custodian()`
/// * [x] `cancel_order_user()`
/// * [x] `change_order_size_custodian()`
/// * [x] `change_order_size_user()`
/// * [x] `place_limit_order_user_entry()`
/// * [x] `place_limit_order_custodian()`
/// * [x] `place_market_order_user_entry()`
/// * [x] `place_market_order_custodian()`
/// * [x] `swap_between_coinstores_entry()`
/// * [x] `swap_coins()`
/// * [x] `swap_generic()`
///
/// ## Branching functions
///
/// Functions with logical branches to test:
///
/// * [x] `cancel_all_orders()`
/// * [x] `cancel_order()`
/// * [x] `change_order_size()`
/// * [x] `match()`
/// * [x] `place_limit_order()`
/// * [x] `place_market_order()`
/// * [x] `range_check_trade()`
/// * [x] `swap_between_coinstores()`
/// * [x] `swap_coins()`
/// * [x] `swap_generic()`
/// * [x] `swap()`
///
/// See each function for its logical branches.
///
/// # Complete DocGen index
///
/// The below index is automatically generated from source code:
module econia::market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::type_info::{Self, TypeInfo};
    use econia::avl_queue::{Self, AVLqueue};
    use econia::incentives;
    use econia::registry::{
        Self, CustodianCapability, GenericAsset, UnderwriterCapability};
    use econia::resource_account;
    use econia::tablist::{Self, Tablist};
    use econia::user;
    use std::option::{Self, Option};
    use std::signer::address_of;
    use std::string::{Self, String};
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, BC, QC, UC};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Emitted when a maker order is placed, cancelled, evicted, or its
    /// size is manually changed.
    struct MakerEvent has drop, store {
        /// Market ID of corresponding market.
        market_id: u64,
        /// `ASK` or `BID`, the side of the maker order.
        side: bool,
        /// Market order ID, unique within given market.
        market_order_id: u128,
        /// Address of user holding maker order.
        user: address,
        /// For given maker, ID of custodian required to approve order
        /// operations and withdrawals on given market account.
        custodian_id: u64,
        /// `CANCEL`, `CHANGE`, `EVICT`, or `PLACE`, the event type.
        type: u8,
        /// The size, in lots, on the book after an order has been
        /// placed or its size has been manually changed. Else the size
        /// on the book before the order was cancelled or evicted.
        size: u64
    }

    /// An order on the order book.
    struct Order has store {
        /// Number of lots to be filled.
        size: u64,
        /// Address of user holding order.
        user: address,
        /// For given user, ID of custodian required to approve order
        /// operations and withdrawals on given market account.
        custodian_id: u64,
        /// User-side access key for storage-optimized lookup.
        order_access_key: u64
    }

    #[method(index_orders)]
    /// An order book for a given market. Contains
    /// `registry::MarketInfo` field duplicates to reduce global storage
    /// item queries against the registry.
    struct OrderBook has store {
        /// `registry::MarketInfo.base_type`.
        base_type: TypeInfo,
        /// `registry::MarketInfo.base_name_generic`.
        base_name_generic: String,
        /// `registry::MarketInfo.quote_type`.
        quote_type: TypeInfo,
        /// `registry::MarketInfo.lot_size`.
        lot_size: u64,
        /// `registry::MarketInfo.tick_size`.
        tick_size: u64,
        /// `registry::MarketInfo.min_size`.
        min_size: u64,
        /// `registry::MarketInfo.underwriter_id`.
        underwriter_id: u64,
        /// Asks AVL queue.
        asks: AVLqueue<Order>,
        /// Bids AVL queue.
        bids: AVLqueue<Order>,
        /// Cumulative number of maker orders placed on book.
        counter: u64,
        /// Event handle for maker events.
        maker_events: EventHandle<MakerEvent>,
        /// Event handle for taker events.
        taker_events: EventHandle<TakerEvent>
    }

    /// Order book map for all Econia order books.
    struct OrderBooks has key {
        /// Map from market ID to corresponding order book. Enables
        /// off-chain iterated indexing by market ID.
        map: Tablist<u64, OrderBook>
    }

    /// Emitted when a taker order fills against a maker order. If a
    /// taker order fills against multiple maker orders, a separate
    /// event is emitted for each one.
    struct TakerEvent has drop, store {
        /// Market ID of corresponding market.
        market_id: u64,
        /// `ASK` or `BID`, the side of the maker order.
        side: bool,
        /// Order ID, unique within given market, of maker order just
        /// filled against.
        market_order_id: u128,
        /// Address of user holding maker order.
        maker: address,
        /// For given maker, ID of custodian required to approve order
        /// operations and withdrawals on given market account.
        custodian_id: u64,
        /// The size filled, in lots.
        size: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Maximum base trade amount specified as 0.
    const E_MAX_BASE_0: u64 = 0;
    /// Maximum quote trade amount specified as 0.
    const E_MAX_QUOTE_0: u64 = 1;
    /// Minimum base trade amount exceeds maximum base trade amount.
    const E_MIN_BASE_EXCEEDS_MAX: u64 = 2;
    /// Minimum quote trade amount exceeds maximum quote trade amount.
    const E_MIN_QUOTE_EXCEEDS_MAX: u64 = 3;
    /// Filling order would overflow asset received from trade.
    const E_OVERFLOW_ASSET_IN: u64 = 4;
    /// Not enough asset to trade away.
    const E_NOT_ENOUGH_ASSET_OUT: u64 = 5;
    /// No market with given ID.
    const E_INVALID_MARKET_ID: u64 = 6;
    /// Base asset type is invalid.
    const E_INVALID_BASE: u64 = 7;
    /// Quote asset type is invalid.
    const E_INVALID_QUOTE: u64 = 8;
    /// Minimum base asset trade amount requirement not met.
    const E_MIN_BASE_NOT_TRADED: u64 = 9;
    /// Minimum quote coin trade amount requirement not met.
    const E_MIN_QUOTE_NOT_TRADED: u64 = 10;
    /// Order price specified as 0.
    const E_PRICE_0: u64 = 11;
    /// Order price exceeds maximum allowable price.
    const E_PRICE_TOO_HIGH: u64 = 12;
    /// Post-or-abort limit order price crosses spread.
    const E_POST_OR_ABORT_CROSSES_SPREAD: u64 = 13;
    /// Limit order size does not meet minimum size for market.
    const E_SIZE_TOO_SMALL: u64 = 14;
    /// Limit order size results in base asset amount overflow.
    const E_SIZE_BASE_OVERFLOW: u64 = 15;
    /// Limit order size and price results in ticks amount overflow.
    const E_SIZE_PRICE_TICKS_OVERFLOW: u64 = 16;
    /// Limit order size and price results in quote amount overflow.
    const E_SIZE_PRICE_QUOTE_OVERFLOW: u64 = 17;
    /// Invalid restriction flag.
    const E_INVALID_RESTRICTION: u64 = 18;
    /// Taker and maker have same address.
    const E_SELF_MATCH: u64 = 19;
    /// No room to insert order with such low price-time priority.
    const E_PRICE_TIME_PRIORITY_TOO_LOW: u64 = 20;
    /// Underwriter invalid for given market.
    const E_INVALID_UNDERWRITER: u64 = 21;
    /// Market order ID invalid.
    const E_INVALID_MARKET_ORDER_ID: u64 = 22;
    /// Custodian not authorized for operation.
    const E_INVALID_CUSTODIAN: u64 = 23;
    /// Invalid user indicated for operation.
    const E_INVALID_USER: u64 = 24;
    /// Fill-or-abort price does not cross the spread.
    const E_FILL_OR_ABORT_NOT_CROSS_SPREAD: u64 = 25;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending AVL queue flag, for asks AVL queue.
    const ASCENDING: bool = true;
    /// Flag for ask side.
    const ASK: bool = true;
    /// Flag for bid side.
    const BID: bool = false;
    /// Flag for buy direction.
    const BUY: bool = true;
    /// Flag for `MakerEvent.type` when order is cancelled.
    const CANCEL: u8 = 0;
    /// Flag for `MakerEvent.type` when order size is changed.
    const CHANGE: u8 = 1;
    /// Critical tree height above which evictions may take place.
    const CRITICAL_HEIGHT: u8 = 10;
    /// Descending AVL queue flag, for bids AVL queue.
    const DESCENDING: bool = false;
    /// Flag for `MakerEvent.type` when order is evicted.
    const EVICT: u8 = 2;
    /// Flag for fill-or-abort order restriction.
    const FILL_OR_ABORT: u8 = 1;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// All bits set in integer of width required to encode price.
    /// Generated in Python via `hex(int('1' * 32, 2))`.
    const HI_PRICE: u64 = 0xffffffff;
    /// Flag for immediate-or-cancel order restriction.
    const IMMEDIATE_OR_CANCEL: u8 = 2;
    /// Flag to trade max possible asset amount: `u64` bitmask with all
    /// bits set, generated in Python via `hex(int('1' * 64, 2))`.
    const MAX_POSSIBLE: u64 = 0xffffffffffffffff;
    /// Maximum possible price that can be encoded in 32 bits. Generated
    /// in Python via `hex(int('1' * 32, 2))`.
    const MAX_PRICE: u64 = 0xffffffff;
    /// Number of restriction flags.
    const N_RESTRICTIONS: u8 = 3;
    /// Flag for null value when null defined as 0.
    const NIL: u64 = 0;
    /// Custodian ID flag for no custodian.
    const NO_CUSTODIAN: u64 = 0;
    /// Flag for no order restriction.
    const NO_RESTRICTION: u8 = 0;
    /// Underwriter ID flag for no underwriter.
    const NO_UNDERWRITER: u64 = 0;
    /// Flag for `MakerEvent.type` when order is placed.
    const PLACE: u8 = 3;
    /// Flag for post-or-abort order restriction.
    const POST_OR_ABORT: u8 = 3;
    /// Flag for sell direction.
    const SELL: bool = false;
    /// Number of bits maker order counter is shifted in a market order
    /// ID.
    const SHIFT_COUNTER: u8 = 64;
    /// Taker address flag for when taker is unknown.
    const UNKNOWN_TAKER: address = @0x0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Public function wrapper for `cancel_all_orders()` for cancelling
    /// orders under authority of delegated custodian.
    ///
    /// # Invocation testing
    ///
    /// * `test_cancel_all_orders_ask_custodian()`
    public fun cancel_all_orders_custodian(
        user_address: address,
        market_id: u64,
        side: bool,
        custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        cancel_all_orders(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            side);
    }

    /// Public function wrapper for `cancel_order()` for cancelling
    /// order under authority of delegated custodian.
    ///
    /// # Invocation testing
    ///
    /// * `test_cancel_order_ask_custodian()`
    public fun cancel_order_custodian(
        user_address: address,
        market_id: u64,
        side: bool,
        market_order_id: u128,
        custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        cancel_order(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            side,
            market_order_id);
    }

    /// Public function wrapper for `change_order_size()` for changing
    /// order size under authority of delegated custodian.
    ///
    /// # Invocation testing
    ///
    /// * `test_change_order_size_ask_custodian()`
    public fun change_order_size_custodian(
        user_address: address,
        market_id: u64,
        side: bool,
        market_order_id: u128,
        new_size: u64,
        custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        change_order_size(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            side,
            market_order_id,
            new_size);
    }

    /// Public function wrapper for `place_limit_order()` for placing
    /// order under authority of delegated custodian.
    ///
    /// # Invocation and return testing
    ///
    /// * `test_place_limit_order_no_cross_bid_custodian()`
    public fun place_limit_order_custodian<
        BaseType,
        QuoteType
    >(
        user_address: address,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
        custodian_capability_ref: &CustodianCapability
    ): (
        u128,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        place_limit_order<
            BaseType,
            QuoteType
        >(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            integrator,
            side,
            size,
            price,
            restriction,
            CRITICAL_HEIGHT)
    }

    /// Public function wrapper for `place_limit_order()` for placing
    /// order under authority of signing user.
    ///
    /// # Invocation and return testing
    ///
    /// * `test_place_limit_order_crosses_ask_exact()`
    /// * `test_place_limit_order_crosses_ask_partial()`
    /// * `test_place_limit_order_crosses_ask_partial_cancel()`
    /// * `test_place_limit_order_crosses_bid_exact()`
    /// * `test_place_limit_order_crosses_bid_partial()`
    /// * `test_place_limit_order_evict()`
    /// * `test_place_limit_order_no_cross_ask_user()`
    public fun place_limit_order_user<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
    ): (
        u128,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        place_limit_order<
            BaseType,
            QuoteType
        >(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            integrator,
            side,
            size,
            price,
            restriction,
            CRITICAL_HEIGHT)
    }

    /// Public function wrapper for `place_market_order()` for placing
    /// order under authority of delegated custodian.
    ///
    /// # Invocation and return testing
    ///
    /// * `test_place_market_order_max_base_sell_custodian()`
    /// * `test_place_market_order_max_quote_buy_custodian()`
    public fun place_market_order_custodian<
        BaseType,
        QuoteType
    >(
        user_address: address,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
        custodian_capability_ref: &CustodianCapability
    ): (
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        place_market_order<BaseType, QuoteType>(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            integrator,
            direction,
            min_base,
            max_base,
            min_quote,
            max_quote,
            limit_price)
    }

    /// Public function wrapper for `place_market_order()` for placing
    /// order under authority of signing user.
    ///
    /// # Invocation and return testing
    ///
    /// * `test_place_market_order_max_base_buy_user()`
    /// * `test_place_market_order_max_quote_sell_user()`
    public fun place_market_order_user<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
    ): (
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        place_market_order<BaseType, QuoteType>(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            integrator,
            direction,
            min_base,
            max_base,
            min_quote,
            max_quote,
            limit_price)
    }

    /// Register pure coin market, return resultant market ID.
    ///
    /// See inner function `register_market()`.
    ///
    /// # Type parameters
    ///
    /// * `BaseType`: Base coin type for market.
    /// * `QuoteType`: Quote coin type for market.
    /// * `UtilityType`: Utility coin type, specified at
    ///   `incentives::IncentiveParameters.utility_coin_type_info`.
    ///
    /// # Parameters
    ///
    /// * `lot_size`: `registry::MarketInfo.lot_size` for market.
    /// * `tick_size`: `registry::MarketInfo.tick_size` for market.
    /// * `min_size`: `registry::MarketInfo.min_size` for market.
    /// * `utility_coins`: Utility coins paid to register a market. See
    ///   `incentives::IncentiveParameters.market_registration_fee`.
    ///
    /// # Returns
    ///
    /// * `u64`: Market ID for new market.
    ///
    /// # Testing
    ///
    /// * `test_register_markets()`
    public fun register_market_base_coin<
        BaseType,
        QuoteType,
        UtilityType
    >(
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        utility_coins: Coin<UtilityType>
    ): u64
    acquires OrderBooks {
        // Register market in global registry, storing market ID.
        let market_id = registry::register_market_base_coin_internal<
            BaseType, QuoteType, UtilityType>(lot_size, tick_size, min_size,
            utility_coins);
        // Register order book and quote coin fee store, return market
        // ID.
        register_market<BaseType, QuoteType>(
            market_id, string::utf8(b""), lot_size, tick_size, min_size,
            NO_UNDERWRITER)
    }

    /// Register generic market, return resultant market ID.
    ///
    /// See inner function `register_market()`.
    ///
    /// Generic base name restrictions described at
    /// `registry::register_market_base_generic_internal()`.
    ///
    /// # Type parameters
    ///
    /// * `QuoteType`: Quote coin type for market.
    /// * `UtilityType`: Utility coin type, specified at
    ///   `incentives::IncentiveParameters.utility_coin_type_info`.
    ///
    /// # Parameters
    ///
    /// * `base_name_generic`: `registry::MarketInfo.base_name_generic`
    ///   for market.
    /// * `lot_size`: `registry::MarketInfo.lot_size` for market.
    /// * `tick_size`: `registry::MarketInfo.tick_size` for market.
    /// * `min_size`: `registry::MarketInfo.min_size` for market.
    /// * `utility_coins`: Utility coins paid to register a market. See
    ///   `incentives::IncentiveParameters.market_registration_fee`.
    /// * `underwriter_capability_ref`: Immutable reference to market
    ///   underwriter capability.
    ///
    /// # Returns
    ///
    /// * `u64`: Market ID for new market.
    ///
    /// # Testing
    ///
    /// * `test_register_markets()`
    public fun register_market_base_generic<
        QuoteType,
        UtilityType
    >(
        base_name_generic: String,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        utility_coins: Coin<UtilityType>,
        underwriter_capability_ref: &UnderwriterCapability
    ): u64
    acquires OrderBooks {
        // Register market in global registry, storing market ID.
        let market_id = registry::register_market_base_generic_internal<
            QuoteType, UtilityType>(base_name_generic, lot_size, tick_size,
            min_size, underwriter_capability_ref, utility_coins);
        // Register order book and quote coin fee store, return market
        // ID.
        register_market<GenericAsset, QuoteType>(
            market_id, base_name_generic, lot_size, tick_size, min_size,
            registry::get_underwriter_id(underwriter_capability_ref))
    }

    /// Swap against the order book between a user's coin stores.
    ///
    /// Initializes an `aptos_framework::coin::CoinStore` for each coin
    /// type that does not yet have one.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Same as for `match()`.
    /// * `QuoteType`: Same as for `match()`.
    ///
    /// # Parameters
    ///
    /// * `user`: Account of swapping user.
    /// * `market_id`: Same as for `match()`.
    /// * `integrator`: Same as for `match()`.
    /// * `direction`: Same as for `match()`.
    /// * `min_base`: Same as for `match()`.
    /// * `max_base`: Same as for `match()`. If passed as `MAX_POSSIBLE`
    ///   will attempt to trade maximum possible amount for coin store.
    /// * `min_quote`: Same as for `match()`.
    /// * `max_quote`: Same as for `match()`. If passed as
    ///   `MAX_POSSIBLE` will attempt to trade maximum possible amount
    ///   for coin store.
    /// * `limit_price`: Same as for `match()`.
    ///
    /// # Returns
    ///
    /// * `u64`: Base asset trade amount, same as for `match()`.
    /// * `u64`: Quote coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin fees paid, same as for `match()`.
    ///
    /// # Testing
    ///
    /// * `test_swap_between_coinstores_max_possible_base_buy()`
    /// * `test_swap_between_coinstores_max_possible_base_sell()`
    /// * `test_swap_between_coinstores_max_possible_quote_buy()`
    /// * `test_swap_between_coinstores_max_possible_quote_sell()`
    /// * `test_swap_between_coinstores_register_base_store()`
    /// * `test_swap_between_coinstores_register_quote_store()`
    public fun swap_between_coinstores<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64
    ): (
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        let user_address = address_of(user); // Get user address.
        // Register base coin store if user does not have one.
        if (!coin::is_account_registered<BaseType>(user_address))
            coin::register<BaseType>(user);
        // Register quote coin store if user does not have one.
        if (!coin::is_account_registered<QuoteType>(user_address))
            coin::register<QuoteType>(user);
        let (base_value, quote_value) = // Get coin value amounts.
            (coin::balance<BaseType>(user_address),
             coin::balance<QuoteType>(user_address));
        // If max base to trade flagged as max possible, update it:
        if (max_base == MAX_POSSIBLE) max_base = if (direction == BUY)
            // If a buy, max to trade is amount that can fit in
            // coin store, else is the amount in the coin store.
            (HI_64 - base_value) else base_value;
        // If max quote to trade flagged as max possible, update it:
        if (max_quote == MAX_POSSIBLE) max_quote = if (direction == BUY)
            // If a buy, max to trade is amount in coin store, else is
            // the amount that could fit in the coin store.
            quote_value else (HI_64 - quote_value);
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_value, base_value, quote_value, quote_value);
        // Get option-wrapped base coins and quote coins for matching:
        let (optional_base_coins, quote_coins) = if (direction == BUY)
            // If a buy, need no base but need max quote.
            (option::some(coin::zero<BaseType>()),
             coin::withdraw<QuoteType>(user, max_quote)) else
            // If a sell, need max base but not quote.
            (option::some(coin::withdraw<BaseType>(user, max_base)),
             coin::zero<QuoteType>());
        // Swap against order book, storing modified coin inputs, base
        // and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
            = swap(market_id, NO_UNDERWRITER, user_address, integrator,
                   direction, min_base, max_base, min_quote, max_quote,
                   limit_price, optional_base_coins, quote_coins);
        // Deposit base coins back to user's coin store.
        coin::deposit(user_address, option::destroy_some(optional_base_coins));
        // Deposit quote coins back to user's coin store.
        coin::deposit(user_address, quote_coins);
        (base_traded, quote_traded, fees) // Return match results.
    }

    /// Swap standalone coins against the order book.
    ///
    /// If a buy, attempts to spend all quote coins. If a sell, attempts
    /// to sell all base coins.
    ///
    /// Passes all base coins to matching engine if a buy or a sell, and
    /// passes all quote coins to matching engine if a buy. If a sell,
    /// does not pass any quote coins to matching engine, to avoid
    /// intermediate quote match overflow that could occur prior to fee
    /// assessment.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Same as for `match()`.
    /// * `QuoteType`: Same as for `match()`.
    ///
    /// # Parameters
    ///
    /// * `market_id`: Same as for `match()`.
    /// * `integrator`: Same as for `match()`.
    /// * `direction`: Same as for `match()`.
    /// * `min_base`: Same as for `match()`.
    /// * `max_base`: Same as for `match()`. Ignored if a sell. Else if
    ///   passed as `MAX_POSSIBLE` will attempt to trade maximum
    ///   possible amount for passed coin holdings.
    /// * `min_quote`: Same as for `match()`.
    /// * `max_quote`: Same as for `match()`. Ignored if a buy. Else if
    ///   passed as `MAX_POSSIBLE` will attempt to trade maximum
    ///   possible amount for passed coin holdings.
    /// * `limit_price`: Same as for `match()`.
    /// * `base_coins`: Same as `optional_base_coins` for `match()`, but
    ///   unpacked.
    /// * `quote_coins`: Same as for `match()`.
    ///
    /// # Returns
    ///
    /// * `Coin<BaseType>`: Updated base coin holdings, same as for
    ///   `match()` but unpacked.
    /// * `Coin<QuoteType>`: Updated quote coin holdings, same as for
    ///   `match()`.
    /// * `u64`: Base coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin fees paid, same as for `match()`.
    ///
    /// # Terminology
    ///
    /// * The "inbound" asset is the asset received from a trade: base
    ///   coins in the case of a buy, quote coins in the case of a sell.
    /// * The "outbound" asset is the asset traded away: quote coins in
    ///   the case of a buy, base coins in the case of a sell.
    ///
    /// # Testing
    ///
    /// * `test_swap_coins_buy_max_base_limiting()`
    /// * `test_swap_coins_buy_no_max_quote_limiting()`
    /// * `test_swap_coins_buy_no_max_base_limiting()`
    /// * `test_swap_coins_sell_max_quote_limiting()`
    /// * `test_swap_coins_sell_no_max_base_limiting()`
    /// * `test_swap_coins_sell_no_max_quote_limiting()`
    public fun swap_coins<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
        base_coins: Coin<BaseType>,
        quote_coins: Coin<QuoteType>
    ): (
        Coin<BaseType>,
        Coin<QuoteType>,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        let (base_value, quote_value) = // Get coin value amounts.
            (coin::value(&base_coins), coin::value(&quote_coins));
        // Get option wrapped base coins.
        let optional_base_coins = option::some(base_coins);
        // Get quote coins to route through matching engine and update
        // max match amounts based on side. If a swap buy:
        let quote_coins_to_match = if (direction == BUY) {
            // Max quote to trade is amount passed in.
            max_quote = quote_value;
            // If max base amount to trade is max possible flag, update
            // to max amount that can be received.
            if (max_base == MAX_POSSIBLE) max_base = (HI_64 - base_value);
            // Pass all quote coins to matching engine.
            coin::extract(&mut quote_coins, max_quote)
        } else { // If a swap sell:
            // Max base to trade is amount passed in.
            max_base = base_value;
            // If max quote amount to trade is max possible flag, update
            // to max amount that can be received.
            if (max_quote == MAX_POSSIBLE) max_quote = (HI_64 - quote_value);
            // Do not pass any quote coins to matching engine.
            coin::zero()
        };
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_value, base_value, quote_value, quote_value);
        // Swap against order book, storing modified coin inputs, base
        // and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins_matched, base_traded,
             quote_traded, fees) = swap(
                market_id, NO_UNDERWRITER, UNKNOWN_TAKER, integrator,
                direction, min_base, max_base, min_quote, max_quote,
                limit_price, optional_base_coins, quote_coins_to_match);
        // Merge matched quote coins back into holdings.
        coin::merge(&mut quote_coins, quote_coins_matched);
        // Get base coins from option.
        let base_coins = option::destroy_some(optional_base_coins);
        // Return all coins.
        (base_coins, quote_coins, base_traded, quote_traded, fees)
    }

    /// Swap against the order book for a generic market, under
    /// authority of market underwriter.
    ///
    /// Passes all quote coins to matching engine if a buy. If a sell,
    /// does not pass any quote coins to matching engine, to avoid
    /// intermediate quote match overflow that could occur prior to fee
    /// assessment.
    ///
    /// # Type Parameters
    ///
    /// * `QuoteType`: Same as for `match()`.
    ///
    /// # Parameters
    ///
    /// * `market_id`: Same as for `match()`.
    /// * `integrator`: Same as for `match()`.
    /// * `direction`: Same as for `match()`.
    /// * `min_base`: Same as for `match()`.
    /// * `max_base`: Same as for `match()`.
    /// * `min_quote`: Same as for `match()`.
    /// * `max_quote`: Same as for `match()`. Ignored if a buy. Else if
    ///   passed as `MAX_POSSIBLE` will attempt to trade maximum
    ///   possible amount for passed coin holdings.
    /// * `limit_price`: Same as for `match()`.
    /// * `quote_coins`: Same as for `match()`.
    /// * `underwriter_capability_ref`: Immutable reference to
    ///   underwriter capability for given market.
    ///
    /// # Returns
    ///
    /// * `Coin<QuoteType>`: Updated quote coin holdings, same as for
    ///   `match()`.
    /// * `u64`: Base asset trade amount, same as for `match()`.
    /// * `u64`: Quote coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin fees paid, same as for `match()`.
    ///
    /// # Testing
    ///
    /// * `test_swap_generic_buy_base_limiting()`
    /// * `test_swap_generic_buy_quote_limiting()`
    /// * `test_swap_generic_sell_max_quote_limiting()`
    /// * `test_swap_generic_sell_no_max_base_limiting()`
    /// * `test_swap_generic_sell_no_max_quote_limiting()`
    public fun swap_generic<
        QuoteType
    >(
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
        quote_coins: Coin<QuoteType>,
        underwriter_capability_ref: &UnderwriterCapability
    ): (
        Coin<QuoteType>,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        let underwriter_id = // Get underwriter ID.
            registry::get_underwriter_id(underwriter_capability_ref);
        // Get quote coin value.
        let quote_value = coin::value(&quote_coins);
        // Get base asset value holdings and quote coins to route
        // through matching engine, and update max match amounts based
        // on side. If a swap buy:
        let (base_value, quote_coins_to_match) = if (direction == BUY) {
            // Max quote to trade is amount passed in.
            max_quote = quote_value;
            // Do not pass in base asset, and pass all quote coins to
            // matching engine.
            (0, coin::extract(&mut quote_coins, max_quote))
        } else { // If a swap sell:
            // If max quote amount to trade is max possible flag, update
            // to max amount that can be received.
            if (max_quote == MAX_POSSIBLE) max_quote = (HI_64 - quote_value);
            // Effective base asset holdings are max trade amount, do
            // not pass and quote coins to matching engine.
            (max_base, coin::zero())
        };
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_value, base_value, quote_value, quote_value);
        // Swap against order book, storing modified quote coin input,
        // base and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins_matched, base_traded,
             quote_traded, fees) = swap(
                market_id, underwriter_id, UNKNOWN_TAKER, integrator,
                direction, min_base, max_base, min_quote, max_quote,
                limit_price, option::none(), quote_coins_to_match);
        // Destroy empty base coin option.
        option::destroy_none<Coin<GenericAsset>>(optional_base_coins);
        // Merge matched quote coins back into holdings.
        coin::merge(&mut quote_coins, quote_coins_matched);
        // Return quote coins, amount of base traded, amount of quote
        // traded, and quote fees paid.
        (quote_coins, base_traded, quote_traded, fees)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Public entry function wrapper for `cancel_all_orders()` for
    /// cancelling orders under authority of signing user.
    ///
    /// # Invocation testing
    ///
    /// * `test_cancel_all_orders_bid_user()`
    public entry fun cancel_all_orders_user(
        user: &signer,
        market_id: u64,
        side: bool,
    ) acquires OrderBooks {
        cancel_all_orders(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            side);
    }

    #[cmd]
    /// Public entry function wrapper for `cancel_order()` for
    /// cancelling order under authority of signing user.
    ///
    /// # Invocation testing
    ///
    /// * `test_cancel_order_bid_user()`
    public entry fun cancel_order_user(
        user: &signer,
        market_id: u64,
        side: bool,
        market_order_id: u128
    ) acquires OrderBooks {
        cancel_order(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            side,
            market_order_id);
    }

    #[cmd]
    /// Public entry function wrapper for `change_order_size()` for
    /// changing order size under authority of signing user.
    ///
    /// # Invocation testing
    ///
    /// * `test_change_order_size_bid_user()`
    public entry fun change_order_size_user(
        user: &signer,
        market_id: u64,
        side: bool,
        market_order_id: u128,
        new_size: u64
    ) acquires OrderBooks {
        change_order_size(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            side,
            market_order_id,
            new_size);
    }

    #[cmd]
    /// Public entry function wrapper for `place_limit_order_user()`.
    ///
    /// # Invocation testing
    ///
    /// * `test_place_limit_order_user_entry()`
    public entry fun place_limit_order_user_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
    ) acquires OrderBooks {
        place_limit_order_user<BaseType, QuoteType>(
            user, market_id, integrator, side, size, price, restriction);
    }

    #[cmd]
    /// Public entry function wrapper for `place_market_order_user()`.
    ///
    /// # Invocation testing
    ///
    /// * `test_place_market_order_user_entry()`
    public entry fun place_market_order_user_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
    ) acquires OrderBooks {
        place_market_order_user<BaseType, QuoteType>(
            user, market_id, integrator, direction, min_base, max_base,
            min_quote, max_quote, limit_price);
    }

    #[cmd]
    /// Wrapped call to `register_market_base_coin()` for paying utility
    /// coins from an `aptos_framework::coin::CoinStore`.
    ///
    /// # Testing
    ///
    /// * `test_register_markets()`
    public entry fun register_market_base_coin_from_coinstore<
        BaseType,
        QuoteType,
        UtilityType
    >(
        user: &signer,
        lot_size: u64,
        tick_size: u64,
        min_size: u64
    ) acquires OrderBooks {
        // Get market registration fee, denominated in utility coins.
        let fee = incentives::get_market_registration_fee();
        // Register market with base coin, paying fees from coin store.
        register_market_base_coin<BaseType, QuoteType, UtilityType>(
            lot_size, tick_size, min_size, coin::withdraw(user, fee));
    }

    #[cmd]
    /// Public entry function wrapper for `swap_between_coinstores()`.
    ///
    /// # Invocation testing
    ///
    /// * `test_swap_between_coinstores_register_base_store()`
    /// * `test_swap_between_coinstores_register_quote_store()`
    public entry fun swap_between_coinstores_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64
    ) acquires OrderBooks {
        swap_between_coinstores<BaseType, QuoteType>(
            user, market_id, integrator, direction, min_base, max_base,
            min_quote, max_quote, limit_price);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel all of a user's open maker orders.
    ///
    /// # Parameters
    ///
    /// * `user`: Same as for `cancel_order()`.
    /// * `market_id`: Same as for `cancel_order()`.
    /// * `custodian_id`: Same as for `cancel_order()`.
    /// * `side`: Same as for `cancel_order()`.
    ///
    /// # Expected value testing
    ///
    /// * `test_cancel_all_orders_ask_custodian()`
    /// * `test_cancel_all_orders_bid_user()`
    fun cancel_all_orders(
        user: address,
        market_id: u64,
        custodian_id: u64,
        side: bool
    ) acquires OrderBooks {
        // Get user's active market order IDs.
        let market_order_ids = user::get_active_market_order_ids_internal(
            user, market_id, custodian_id, side);
        // Get number of market order IDs, init loop index variable.
        let (n_orders, i) = (vector::length(&market_order_ids), 0);
        while (i < n_orders) { // Loop over all active orders.
            // Cancel market order for current iteration.
            cancel_order(user, market_id, custodian_id, side,
                         *vector::borrow(&market_order_ids, i));
            i = i + 1; // Increment loop counter.
        }
    }

    /// Cancel maker order on order book and in user's market account.
    ///
    /// # Parameters
    ///
    /// * `user`: Address of user holding maker order.
    /// * `market_id`: Market ID of market.
    /// * `custodian_id`: Market account custodian ID.
    /// * `side`: `ASK` or `BID`, the maker order side.
    /// * `market_order_id`: Market order ID of order on order book.
    ///
    /// # Aborts
    ///
    /// * `E_INVALID_MARKET_ORDER_ID`: Market order ID passed as `NIL`.
    /// * `E_INVALID_MARKET_ID`: No market with given ID.
    /// * `E_INVALID_USER`: Mismatch between `user` and user for order
    ///   on book having given market order ID.
    /// * `E_INVALID_CUSTODIAN`: Mismatch between `custodian_id` and
    ///   custodian ID of order on order book having market order ID.
    ///
    /// # Emits
    ///
    /// * `MakerEvent`: Information about the maker order cancelled.
    ///
    /// # Expected value testing
    ///
    /// * `test_cancel_order_ask_custodian()`
    /// * `test_cancel_order_bid_user()`
    ///
    /// # Failure testing
    ///
    /// * `test_cancel_order_invalid_custodian()`
    /// * `test_cancel_order_invalid_market_id()`
    /// * `test_cancel_order_invalid_market_order_id()`
    /// * `test_cancel_order_invalid_user()`
    fun cancel_order(
        user: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        market_order_id: u128
    ) acquires OrderBooks {
        // Assert market order ID not passed as reserved null flag.
        assert!(market_order_id != (NIL as u128), E_INVALID_MARKET_ORDER_ID);
        // Get address of resource account where order books are stored.
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        // Assert order books map has order book with given market ID.
        assert!(tablist::contains(order_books_map_ref_mut, market_id),
                E_INVALID_MARKET_ID);
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // Mutably borrow corresponding orders AVL queue.
        let orders_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks
            else &mut order_book_ref_mut.bids;
        // Get AVL queue access key from market order ID.
        let avlq_access_key = ((market_order_id & (HI_64 as u128)) as u64);
        // Remove order from AVL queue, storing its fields.
        let Order{size, user: order_user, custodian_id: order_custodian_id,
                  order_access_key} = avl_queue::remove(orders_ref_mut,
                                                        avlq_access_key);
        // Assert passed maker address is user holding order.
        assert!(user == order_user, E_INVALID_USER);
        // Assert passed custodian ID matches that from order.
        assert!(custodian_id == order_custodian_id, E_INVALID_CUSTODIAN);
        let price = avlq_access_key & HI_PRICE; // Get order price.
        // Cancel order user-side, thus verifying market order ID.
        user::cancel_order_internal(user, market_id, custodian_id, side,
                                    price, order_access_key, market_order_id);
        let type = CANCEL; // Declare maker event type.
        // Emit a maker cancel event.
        event::emit_event(&mut order_book_ref_mut.maker_events, MakerEvent{
            market_id, side, market_order_id, user, custodian_id, type, size});
    }

    /// Change maker order size on book and in user's market account.
    ///
    /// # Parameters
    ///
    /// * `user`: Address of user holding maker order.
    /// * `market_id`: Market ID of market.
    /// * `custodian_id`: Market account custodian ID.
    /// * `side`: `ASK` or `BID`, the maker order side.
    /// * `market_order_id`: Market order ID of order on order book.
    /// * `new_size`: The new order size to change to.
    ///
    /// # Aborts
    ///
    /// * `E_INVALID_MARKET_ORDER_ID`: Market order ID passed as `NIL`.
    /// * `E_INVALID_MARKET_ID`: No market with given ID.
    /// * `E_INVALID_USER`: Mismatch between `user` and user for order
    ///   on book having given market order ID.
    /// * `E_INVALID_CUSTODIAN`: Mismatch between `custodian_id` and
    ///   custodian ID of order on order book having market order ID.
    ///
    /// # Emits
    ///
    /// * `MakerEvent`: Information about the changed maker order.
    ///
    /// # Expected value testing
    ///
    /// * `test_change_order_size_ask_custodian()`
    /// * `test_change_order_size_bid_user()`
    ///
    /// # Failure testing
    ///
    /// * `test_change_order_size_invalid_custodian()`
    /// * `test_change_order_size_invalid_market_id()`
    /// * `test_change_order_size_invalid_market_order_id()`
    /// * `test_change_order_size_invalid_user()`
    fun change_order_size(
        user: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        market_order_id: u128,
        new_size: u64
    ) acquires OrderBooks {
        // Assert market order ID not passed as reserved null flag.
        assert!(market_order_id != (NIL as u128), E_INVALID_MARKET_ORDER_ID);
        // Get address of resource account where order books are stored.
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        // Assert order books map has order book with given market ID.
        assert!(tablist::contains(order_books_map_ref_mut, market_id),
                E_INVALID_MARKET_ID);
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // Mutably borrow corresponding orders AVL queue.
        let orders_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks
            else &mut order_book_ref_mut.bids;
        // Get AVL queue access key from market order ID.
        let avlq_access_key = ((market_order_id & (HI_64 as u128)) as u64);
        let order_ref_mut = // Mutably borrow order on order book.
            avl_queue::borrow_mut(orders_ref_mut, avlq_access_key);
        // Assert passed user address is user holding order.
        assert!(user == order_ref_mut.user, E_INVALID_USER);
        // Assert passed custodian ID matches that from order.
        assert!(custodian_id == order_ref_mut.custodian_id,
                E_INVALID_CUSTODIAN);
        let price = avlq_access_key & HI_PRICE; // Get order price.
        // Change order size user-side, thus verifying market order ID
        // and new size.
        user::change_order_size_internal(
            user, market_id, custodian_id, side, new_size, price,
            order_ref_mut.order_access_key, market_order_id);
        // Update order on book with new size.
        order_ref_mut.size = new_size;
        // Declare order size, maker event type.
        let (size, type) = (order_ref_mut.size, CHANGE);
        // Emit a maker change event.
        event::emit_event(&mut order_book_ref_mut.maker_events, MakerEvent{
            market_id, side, market_order_id, user, custodian_id, type, size});
    }

    /// Initialize the order books map upon module publication.
    fun init_module(
        _econia: &signer
    ) {
        // Get Econia resource account signer.
        let resource_account = resource_account::get_signer();
        // Initialize order books map under resource account.
        move_to(&resource_account, OrderBooks{map: tablist::new()})
    }

    /// Match a taker order against the order book.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Base asset type for market.
    ///   `registry::GenericAsset` if a generic market.
    /// * `QuoteType`: Quote coin type for market.
    ///
    /// # Parameters
    ///
    /// * `market_id`: Market ID of market.
    /// * `order_book_ref_mut`: Mutable reference to market order book.
    /// * `taker`: Address of taker whose order is matched. May be
    ///   passed as `UNKNOWN_TAKER` when taker order originates from
    ///   a standalone coin swap or a generic swap.
    /// * `integrator`: The integrator for the taker order, who collects
    ///   a portion of taker fees at their
    ///   `incentives::IntegratorFeeStore` for the given market. May be
    ///   passed as an address known not to be an integrator, for
    ///   example `@0x0` or `@econia`, in the service of diverting all
    ///   fees to Econia.
    /// * `direction`: `BUY` or `SELL`, from the taker's perspective. If
    ///   a `BUY`, fills against asks, else against bids.
    /// * `min_base`: Minimum base asset units to be traded by taker,
    ///   either received or traded away.
    /// * `max_base`: Maximum base asset units to be traded by taker,
    ///   either received or traded away.
    /// * `min_quote`: Minimum quote asset units to be traded by taker,
    ///   either received or traded away. Exclusive of fees: refers to
    ///   the net change in taker's quote holdings after the match.
    /// * `max_quote`: Maximum quote asset units to be traded by taker,
    ///   either received or traded away. Exclusive of fees: refers to
    ///   the net change in taker's quote holdings after the match.
    /// * `limit_price`: If direction is `BUY`, the price above which
    ///   matching should halt. If direction is `SELL`, the price below
    ///   which matching should halt. Can be passed as `HI_PRICE` if a
    ///   `BUY` or `0` if a `SELL` to approve matching at any price.
    /// * `optional_base_coins`: None if `BaseType` is
    ///   `registry::GenericAsset` (market is generic), else base coin
    ///   holdings for pure coin market, which are incremented if
    ///   `direction` is `BUY` and decremented if `direction` is `SELL`.
    /// * `quote_coins`: Quote coin holdings for market, which are
    ///   decremented if `direction` is `BUY` and incremented if
    ///   `direction` is `SELL`.
    ///
    /// # Returns
    ///
    /// * `Option<Coin<BaseType>>`: None if `BaseType` is
    ///   `registry::GenericAsset`, else updated `optional_base_coins`
    ///   holdings after matching.
    /// * `Coin<QuoteType>`: Updated `quote_coins` holdings after
    ///   matching.
    /// * `u64`: Base asset amount traded by taker: net change in
    ///   taker's base holdings.
    /// * `u64`: Quote coin amount traded by taker, inclusive of fees:
    ///   net change in taker's quote coin holdings.
    /// * `u64`: Amount of quote coin fees paid.
    ///
    /// # Emits
    ///
    /// * `TakerEvent`: Information about a fill against a maker order,
    ///   emitted for each separate maker order that is filled against.
    ///
    /// # Aborts
    ///
    /// * `E_PRICE_TOO_HIGH`: Order price exceeds maximum allowable
    ///   price.
    /// * `E_SELF_MATCH`: Taker and a matched maker have same address.
    /// * `E_MIN_BASE_NOT_TRADED`: Minimum base asset trade amount
    ///   requirement not met.
    /// * `E_MIN_QUOTE_NOT_TRADED`: Minimum quote asset trade amount
    ///   requirement not met.
    ///
    /// # Algorithm description
    ///
    /// After checking price, lot size, and tick size, the taker fee
    /// divisor is used to calculate the max quote coin match amount
    /// for the given direction. Max lot and tick fill amounts are
    /// calculated, and counters are initiated for the number of lots
    /// and ticks to fill until reaching the max permitted amount. The
    /// corresponding AVL queue is borrowed, and loopwise matching
    /// executes against the head of the queue as long as it is empty:
    ///
    /// The price of the order at the head of the AVL queue is compared
    /// against the limit price, and the loop breaks if the limit price
    /// condition is not met. Then the max fill size is calculated based
    /// on the number of ticks left to fill until max and the price for
    /// the given order, and compared against the number of lots to fill
    /// until max. The lesser of the two is taken as the max fill size,
    /// and compared against the order size to determine the fill size
    /// and if a complete fill takes place. If no size can be filled the
    /// loop breaks, otherwise the number of ticks is calculated, and
    /// lots and ticks until max counters are updated. The self-match
    /// condition is checked, then the order is filled user side and a
    /// taker event is emitted. If there was a complete fill, the maker
    /// order is removed from the head of the AVL queue and the loop
    /// breaks if there are not lots or ticks left to fill. If the
    /// order was not completely filled, the order size on the order
    /// book is updated, and the loop breaks.
    ///
    /// After loopwise matching, base and quote fill amounts are
    /// calculated, then taker fees are assessed. If a buy, the traded
    /// quote amount is calculated as the quote fill amount plus fees
    /// paid, and if a sell, the traded quote amount is calculated as
    /// the quote fill amount minus fees paid. Min base and quote trade
    /// conditions are then checked.
    ///
    /// # Expected value testing
    ///
    /// * `test_match_complete_fill_no_lots_buy()`
    /// * `test_match_complete_fill_no_ticks_sell()`
    /// * `test_match_empty()`
    /// * `test_match_fill_size_0()`
    /// * `test_match_loop_twice()`
    /// * `test_match_partial_fill_lot_limited_sell()`
    /// * `test_match_partial_fill_tick_limited_buy()`
    /// * `test_match_price_break_buy()`
    /// * `test_match_price_break_sell()`
    ///
    /// # Failure testing
    ///
    /// * `test_match_min_base_not_traded()`
    /// * `test_match_min_quote_not_traded()`
    /// * `test_match_price_too_high()`
    /// * `test_match_self_match()`
    fun match<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        order_book_ref_mut: &mut OrderBook,
        taker: address,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
        optional_base_coins: Option<Coin<BaseType>>,
        quote_coins: Coin<QuoteType>,
    ): (
        Option<Coin<BaseType>>,
        Coin<QuoteType>,
        u64,
        u64,
        u64
    ) {
        // Assert price is not too high.
        assert!(limit_price <= MAX_PRICE, E_PRICE_TOO_HIGH);
        // Taker buy fills against asks, sell against bids.
        let side = if (direction == BUY) ASK else BID;
        let (lot_size, tick_size) = (order_book_ref_mut.lot_size,
            order_book_ref_mut.tick_size); // Get lot and tick sizes.
        // Get taker fee divisor.
        let taker_fee_divisor = incentives::get_taker_fee_divisor();
        // Get max quote coins to match.
        let max_quote_match = incentives::calculate_max_quote_match(
            direction, taker_fee_divisor, max_quote);
        // Calculate max amounts of lots and ticks to fill.
        let (max_lots, max_ticks) =
            (max_base / lot_size, max_quote_match / tick_size);
        // Initialize counters for number of lots and ticks to fill.
        let (lots_until_max, ticks_until_max) = (max_lots, max_ticks);
        // Mutably borrow corresponding orders AVL queue.
        let orders_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks
            else &mut order_book_ref_mut.bids;
        // While there are orders to match against:
        while (!avl_queue::is_empty(orders_ref_mut)) {
            let price = // Get price of order at head of AVL queue.
                *option::borrow(&avl_queue::get_head_key(orders_ref_mut));
            // Break if price too high to buy at or too low to sell at.
            if (((direction == BUY ) && (price > limit_price)) ||
                ((direction == SELL) && (price < limit_price))) break;
            // Calculate max number of lots that could be filled
            // at order price, limited by ticks left to fill until max.
            let max_fill_size_ticks = ticks_until_max / price;
            // Max fill size is lesser of tick-limited fill size and
            // lot-limited fill size.
            let max_fill_size = if (max_fill_size_ticks < lots_until_max)
                max_fill_size_ticks else lots_until_max;
            // Mutably borrow order at head of AVL queue.
            let order_ref_mut = avl_queue::borrow_head_mut(orders_ref_mut);
            // Get fill size and if a complete fill against book.
            let (fill_size, complete_fill) =
                // If max fill size is less than order size, fill size
                // is max fill size and is an incomplete fill. Else
                // order gets completely filled.
                if (max_fill_size < order_ref_mut.size)
                   (max_fill_size, false) else (order_ref_mut.size, true);
            if (fill_size == 0) break; // Break if no lots to fill.
            let ticks_filled = fill_size * price; // Get ticks filled.
            // Decrement counter for lots to fill until max reached.
            lots_until_max = lots_until_max - fill_size;
            // Decrement counter for ticks to fill until max reached.
            ticks_until_max = ticks_until_max - ticks_filled;
            // Get order maker, maker's custodian ID, and event size.
            let (maker, custodian_id, size) =
                (order_ref_mut.user, order_ref_mut.custodian_id, fill_size);
            // Assert no self match.
            assert!(maker != taker, E_SELF_MATCH);
            let market_order_id; // Declare return assignment variable.
            // Fill matched order user side, storing market order ID.
            (optional_base_coins, quote_coins, market_order_id) =
                user::fill_order_internal<BaseType, QuoteType>(
                    maker, market_id, custodian_id, side,
                    order_ref_mut.order_access_key, fill_size,
                    complete_fill, optional_base_coins, quote_coins,
                    fill_size * lot_size, ticks_filled * tick_size);
            // Emit corresponding taker event.
            event::emit_event(&mut order_book_ref_mut.taker_events, TakerEvent{
                market_id, side, market_order_id, maker, custodian_id, size});
            if (complete_fill) { // If order on book completely filled:
                let avlq_access_key = // Get AVL queue access key.
                    ((market_order_id & (HI_64 as u128)) as u64);
                // Remove order from AVL queue.
                let order = avl_queue::remove(orders_ref_mut, avlq_access_key);
                let Order{size: _, user: _, custodian_id: _,
                          order_access_key: _} = order; // Unpack order.
                // Break out of loop if no more lots or ticks to fill.
                if ((lots_until_max == 0) || (ticks_until_max == 0)) break
            } else { // If order on book not completely filled:
                // Decrement order size by amount filled.
                order_ref_mut.size = order_ref_mut.size - fill_size;
                break // Stop matching.
            }
        }; // Done looping over head of AVL queue for given side.
        let (base_fill, quote_fill) = // Calculate base and quote fills.
            (((max_lots  - lots_until_max ) * lot_size),
             ((max_ticks - ticks_until_max) * tick_size));
        // Assess taker fees, storing taker fees paid.
        let (quote_coins, fees_paid) = incentives::assess_taker_fees<
            QuoteType>(market_id, integrator, taker_fee_divisor, quote_fill,
            quote_coins);
        // If a buy, taker pays quote required for fills, and additional
        // fee assessed after matching. If a sell, taker receives quote
        // from fills, then has a portion assessed as fees.
        let quote_traded = if (direction == BUY) (quote_fill + fees_paid)
            else (quote_fill - fees_paid);
        // Assert minimum base asset trade amount met.
        assert!(base_fill >= min_base, E_MIN_BASE_NOT_TRADED);
        // Assert minimum quote coin trade amount met.
        assert!(quote_traded >= min_quote, E_MIN_QUOTE_NOT_TRADED);
        // Return optional base coin, quote coins, trade amounts.
        (optional_base_coins, quote_coins, base_fill, quote_traded, fees_paid)
    }

    /// Place limit order against order book from user market account.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Same as for `match()`. Ignored unless order fills
    ///   across the spread as a taker.
    /// * `QuoteType`: Same as for `match()`. Ignored unless order fills
    ///   across the spread as a taker.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Same as for `match()`.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `integrator`: Same as for `match()`, only receives fees if
    ///   order fills across the spread.
    /// * `side`: `ASK` or `BID`, the side on which to place an order as
    ///   a maker.
    /// * `size`: The size, in lots, to fill.
    /// * `price`: The limit order price, in ticks per lot.
    /// * `restriction`: `FILL_OR_ABORT`, `IMMEDIATE_OR_CANCEL`,
    ///   `POST_OR_ABORT`, or `NO_RESTRICTION`.
    /// * `critical_height`: The AVL queue height above which evictions
    ///   may take place. Should only be passed as `CRITICAL_HEIGHT`.
    ///   Accepted as an argument to simplify testing.
    ///
    /// # Returns
    ///
    /// * `u128`: Market order ID of limit order placed on book, if one
    ///   was placed. Else `NIL`.
    /// * `u64`: Base asset trade amount as a taker, same as for
    ///   `match()`, if order fills across the spread.
    /// * `u64`: Quote asset trade amount as a taker, same as for
    ///   `match()`, if order fills across the spread.
    /// * `u64`: Quote coin fees paid as a taker, same as for `match()`,
    ///   if order fills across the spread.
    ///
    /// # Aborts
    ///
    /// * `E_INVALID_RESTRICTION`: Invalid restriction flag.
    /// * `E_PRICE_0`: Order price specified as 0.
    /// * `E_PRICE_TOO_HIGH`: Order price exceeds maximum allowed
    ///   price.
    /// * `E_SIZE_TOO_SMALL`: Limit order size does not meet minimum
    ///   size for market.
    /// * `E_FILL_OR_ABORT_NOT_CROSS_SPREAD`: Fill-or-abort price does
    ///   not cross the spread.
    /// * `E_POST_OR_ABORT_CROSSES_SPREAD`: Post-or-abort price crosses
    ///   the spread.
    /// * `E_SIZE_BASE_OVERFLOW`: The product of order size and market
    ///   lot size results in a base asset unit overflow.
    /// * `E_SIZE_PRICE_TICKS_OVERFLOW`: The product of order size and
    ///   price results in a tick amount overflow.
    /// * `E_SIZE_PRICE_QUOTE_OVERFLOW`: The product of order size,
    ///   price, and market tick size results in a quote asset unit
    ///   overflow.
    /// * `E_PRICE_TIME_PRIORITY_TOO_LOW`: Order would result in lowest
    ///   price-time priority if inserted to AVL queue, but AVL queue
    ///   does not have room for any more orders.
    ///
    /// # Emits
    ///
    /// * `MakerEvent`: Information about the user's maker order placed
    ///   on the order book, if one was placed.
    /// * `MakerEvent`: Information about the maker order evicted from
    ///   the order book, if required to fit user's maker order on the
    ///   book.
    ///
    /// # Restrictions
    ///
    /// * A post-or-abort order aborts if its price crosses the spread.
    /// * A fill-or-abort order aborts if it is not completely filled
    ///   as a taker order. Here, a corresponding minimum base trade
    ///   amount is passed to `match()`, which aborts if the minimum
    ///   amount is not filled.
    /// * An immediate-or-cancel order fills as a taker if possible,
    ///   then returns.
    ///
    /// # Minimum size
    ///
    /// * If order partially fills as a taker and there is still size
    ///   left as a maker, minimum order size condition must be met
    ///   again for the maker portion.
    ///
    /// # Algorithm description
    ///
    /// Order restriction and price are checked, then user's available
    /// and ceiling asset counts are checked, verifying that the given
    /// market exists. The corresponding order book is borrowed, the
    /// order size is checked against the min size for the market, and
    /// the market underwriter ID is checked. The price is checked for
    /// the given order side to determine if the spread is crossed, and
    /// if not, order aborts if restriction is fill-or-abort. If spread
    /// is not crossed, order aborts if restriction is post-or-abort.
    ///
    /// The amount of base units, ticks, and quote units required to
    /// fill the order size are checked for overflow conditions, and
    /// corresponding trade amounts are calculated for range checking.
    /// If the order crosses the spread, base and quote assets are
    /// withdrawn from the user's market account and passed through the
    /// matching engine, deposited back to the user's market account,
    /// and remaining order size to fill is updated. If restriction is
    /// immediate-or-cancel or if no size left to fill after optional
    /// matching as a taker, returns without placing a maker order.
    ///
    /// The user's next order access key is checked, and a corresponding
    /// order is inserted to the order book. If the order's price time
    /// priority is too low to fit on the book, the order aborts. Else
    /// a market order ID is constructed from the AVL queue access key
    /// just generated upon insertion, and the order book counter is
    /// updated. An order is placed user-side, and a taker event is
    /// emitted for the new order on the book.
    ///
    /// If insertion did not result in an eviction, the empty optional
    /// evictee value is destroyed. Otherwise, the evicted order is
    /// unpacked and its price is extracted, then it is cancelled from
    /// the corresponding user's market account, and its market order
    /// ID is emitted in a maker evict event.
    ///
    /// # Expected value testing
    ///
    /// * `test_place_limit_order_crosses_ask_exact()`
    /// * `test_place_limit_order_crosses_ask_partial()`
    /// * `test_place_limit_order_crosses_ask_partial_cancel()`
    /// * `test_place_limit_order_crosses_bid_exact()`
    /// * `test_place_limit_order_crosses_bid_partial()`
    /// * `test_place_limit_order_evict()`
    /// * `test_place_limit_order_no_cross_ask_user()`
    /// * `test_place_limit_order_no_cross_bid_custodian()`
    ///
    /// # Failure testing
    ///
    /// * `test_place_limit_order_base_overflow()`
    /// * `test_place_limit_order_fill_or_abort_not_cross()`
    /// * `test_place_limit_order_fill_or_abort_partial()`
    /// * `test_place_limit_order_invalid_restriction()`
    /// * `test_place_limit_order_no_price()`
    /// * `test_place_limit_order_post_or_abort_crosses()`
    /// * `test_place_limit_order_price_hi()`
    /// * `test_place_limit_order_price_time_priority_low()`
    /// * `test_place_limit_order_quote_overflow()`
    /// * `test_place_limit_order_size_lo()`
    /// * `test_place_limit_order_ticks_overflow()`
    fun place_limit_order<
        BaseType,
        QuoteType,
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        integrator: address,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
        critical_height: u8
    ): (
        u128,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        // Assert valid order restriction flag.
        assert!(restriction <= N_RESTRICTIONS, E_INVALID_RESTRICTION);
        assert!(price != 0, E_PRICE_0); // Assert nonzero price.
        // Assert price is not too high.
        assert!(price <= MAX_PRICE, E_PRICE_TOO_HIGH);
        // Get user's available and ceiling asset counts.
        let (_, base_available, base_ceiling, _, quote_available,
             quote_ceiling) = user::get_asset_counts_internal(
                user_address, market_id, custodian_id);
        // If asset count check does not abort, then market exists, so
        // get address of resource account for borrowing order book.
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // Assert order size is at least minimum size for market.
        assert!(size >= order_book_ref_mut.min_size, E_SIZE_TOO_SMALL);
        // Get market underwriter ID.
        let underwriter_id = order_book_ref_mut.underwriter_id;
        // Order crosses spread if an ask and would trail behind bids
        // AVL queue head, or if a bid and would trail behind asks AVL
        // queue head.
        let crosses_spread = if (side == ASK)
            !avl_queue::would_update_head(&order_book_ref_mut.bids, price) else
            !avl_queue::would_update_head(&order_book_ref_mut.asks, price);
        // Assert order crosses spread if fill-or-abort.
        assert!(!((restriction == FILL_OR_ABORT) && !crosses_spread),
                E_FILL_OR_ABORT_NOT_CROSS_SPREAD);
        // Assert order does not cross spread if post-or-abort.
        assert!(!((restriction == POST_OR_ABORT) && crosses_spread),
                E_POST_OR_ABORT_CROSSES_SPREAD);
        // Calculate base asset amount corresponding to size in lots.
        let base = (size as u128) * (order_book_ref_mut.lot_size as u128);
        // Assert corresponding base asset amount fits in a u64.
        assert!(base <= (HI_64 as u128), E_SIZE_BASE_OVERFLOW);
        // Calculate tick amount corresponding to size in lots.
        let ticks = (size as u128) * (price as u128);
        // Assert corresponding tick amount fits in a u64.
        assert!(ticks <= (HI_64 as u128), E_SIZE_PRICE_TICKS_OVERFLOW);
        // Calculate amount of quote required to fill size at price.
        let quote = ticks * (order_book_ref_mut.tick_size as u128);
        // Assert corresponding quote amount fits in a u64.
        assert!(quote <= (HI_64 as u128), E_SIZE_PRICE_QUOTE_OVERFLOW);
        // Max base to trade is amount calculated from size, lot size.
        let max_base = (base as u64);
        // If a fill-or-abort order, must fill as a taker order with
        // a minimum trade amount equal to max base. Else no min.
        let min_base = if (restriction == FILL_OR_ABORT) max_base else 0;
        // No need to specify min quote if filling as a taker order
        // since min base is specified.
        let min_quote = 0;
        // Get max quote to trade. If price crosses spread:
        let max_quote = if (crosses_spread) { // If fills as taker:
            if (side == ASK) { // If an ask, filling as taker sell:
                // Order will fill at prices that are at least as high
                // as specified order price, and user will receive more
                // quote than calculated from order size and price.
                // Hence max quote to trade is amount that will fit in
                // market account.
                (HI_64 - quote_ceiling)
            // If a bid, filling as a taker buy, will have to pay at
            // least as much as from order size and price, plus fees.
            } else {
                // Get taker fee divisor
                let taker_fee_divisor = incentives::get_taker_fee_divisor();
                // Max quote is amount from size and price, with fees.
                ((quote as u64) + ((quote as u64) / taker_fee_divisor))
            }
        } else { // If no portion of order fills as a taker:
            (quote as u64) // Max quote is amount from size and price.
        };
        // If an ask, trade direction to range check is sell, else buy.
        let direction = if (side == ASK) SELL else BUY;
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
        // Assume no assets traded as a taker.
        let (base_traded, quote_traded, fees) = (0, 0, 0);
        if (crosses_spread) { // If order price crosses spread:
            // Calculate max base and quote to withdraw. If a buy:
            let (base_withdraw, quote_withdraw) = if (direction == BUY)
                // Withdraw quote to buy base, else sell base for quote.
                (0, max_quote) else (max_base, 0);
            // Withdraw optional base coins and quote coins for match,
            // verifying base type and quote type for market.
            let (optional_base_coins, quote_coins) =
                user::withdraw_assets_internal<BaseType, QuoteType>(
                    user_address, market_id, custodian_id, base_withdraw,
                    quote_withdraw, underwriter_id);
            // Match against order book, storing modified asset inputs,
            // base and quote trade amounts, and quote fees paid.
            (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
                = match(market_id, order_book_ref_mut, user_address,
                        integrator, direction, min_base, max_base, min_quote,
                        max_quote, price, optional_base_coins, quote_coins);
            // Calculate amount of base deposited back to market account.
            let base_deposit = if (direction == BUY) base_traded else
                base_withdraw - base_traded;
            // Deposit assets back to user's market account.
            user::deposit_assets_internal<BaseType, QuoteType>(
                user_address, market_id, custodian_id, base_deposit,
                optional_base_coins, quote_coins, underwriter_id);
            // Update size to amount left to fill after taker match.
            size = size - (base_traded / order_book_ref_mut.lot_size);
        }; // Done with optional matching as a taker across the spread.
        // Return without market order ID if no size left to fill.
        if ((restriction == IMMEDIATE_OR_CANCEL) || (size == 0))
            return ((NIL as u128), base_traded, quote_traded, fees);
        // Get next order access key for user-side order placement.
        let order_access_key = user::get_next_order_access_key_internal(
            user_address, market_id, custodian_id, side);
        // Get orders AVL queue for maker side.
        let orders_ref_mut = if (side == ASK) &mut order_book_ref_mut.asks else
            &mut order_book_ref_mut.bids;
        // Declare order to insert to book.
        let order = Order{size, user: user_address, custodian_id,
                          order_access_key};
        // Get new AVL queue access key, evictee access key, and evictee
        // value by attempting to insert for given critical height.
        let (avlq_access_key, evictee_access_key, evictee_value) =
            avl_queue::insert_check_eviction(
                orders_ref_mut, price, order, critical_height);
        // Assert that order could be inserted to AVL queue.
        assert!(avlq_access_key != NIL, E_PRICE_TIME_PRIORITY_TOO_LOW);
        // Get market order ID from AVL queue access key, counter.
        let market_order_id = (avlq_access_key as u128) |
            ((order_book_ref_mut.counter as u128) << SHIFT_COUNTER);
        // Increment maker counter.
        order_book_ref_mut.counter = order_book_ref_mut.counter + 1;
        user::place_order_internal( // Place order user-side.
            user_address, market_id, custodian_id, side, size, price,
            market_order_id);
        // Emit a maker place event.
        event::emit_event(&mut order_book_ref_mut.maker_events, MakerEvent{
            market_id, side, market_order_id, user: user_address,
            custodian_id, type: PLACE, size});
        if (evictee_access_key == NIL) { // If no eviction required:
            // Destroy empty evictee value option.
            option::destroy_none(evictee_value);
        } else { // If had to evict order at AVL queue tail:
            // Unpack evicted order, storing fields for event.
            let Order{size, user, custodian_id, order_access_key} =
                option::destroy_some(evictee_value);
            // Get price of cancelled order.
            let price_cancel = evictee_access_key & HI_PRICE;
            // Cancel order user-side, storing its market order ID.
            let market_order_id_cancel = user::cancel_order_internal(
                user, market_id, custodian_id, side, price_cancel,
                order_access_key, (NIL as u128));
            // Emit a maker evict event.
            event::emit_event(&mut order_book_ref_mut.maker_events, MakerEvent{
                market_id, side, market_order_id: market_order_id_cancel, user,
                custodian_id, type: EVICT, size});
        };
        // Return market order ID and taker trade amounts.
        return (market_order_id, base_traded, quote_traded, fees)
    }

    /// Place market order against order book from user market account.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Same as for `match()`.
    /// * `QuoteType`: Same as for `match()`.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Same as for `match()`.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `integrator`: Same as for `match()`.
    /// * `direction`: Same as for `match()`.
    /// * `min_base`: Same as for `match()`.
    /// * `max_base`: Same as for `match()`. If passed as `MAX_POSSIBLE`
    ///   will attempt to trade maximum possible amount for market
    ///   account.
    /// * `min_quote`: Same as for `match()`.
    /// * `max_quote`: Same as for `match()`. If passed as
    ///   `MAX_POSSIBLE` will attempt to trade maximum possible amount
    ///   for market account.
    /// * `limit_price`: Same as for `match()`.
    ///
    /// # Returns
    ///
    /// * `u64`: Base asset trade amount, same as for `match()`.
    /// * `u64`: Quote coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin fees paid, same as for `match()`.
    ///
    /// # Algorithm description
    ///
    /// Checks user's available and ceiling asset counts, thus verifying
    /// that market exists for given market ID. Mutably borrows order
    /// book for market and gets underwriter ID, then checks max base
    /// and quote trade amount inputs. If flagged as max possible, max
    /// base is updated to max amount possible for market account state,
    /// as for max quote. Trade amounts are range checked, and withdraw
    /// amounts are calculated based on the direction: if a buy, max
    /// quote is withdrawn but no base, and if a sell, max base but no
    /// quote is withdrawn from user's market account.
    ///
    /// Assets are withdrawn from the user's market account, thus
    /// verifying the base and quote type for the market. The amount of
    /// base asset to deposit back to the user's market account is
    /// calculated, then base and quote assets are deposited back to the
    /// user's market account.
    ///
    /// # Expected value testing
    ///
    /// * `test_place_market_order_max_base_buy_user()`
    /// * `test_place_market_order_max_base_sell_custodian()`
    /// * `test_place_market_order_max_quote_buy_custodian()`
    /// * `test_place_market_order_max_quote_sell_user()`
    fun place_market_order<
        BaseType,
        QuoteType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
    ): (
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        // Get user's available and ceiling asset counts.
        let (_, base_available, base_ceiling, _, quote_available,
             quote_ceiling) = user::get_asset_counts_internal(
                user_address, market_id, custodian_id);
        // If asset count check does not abort, then market exists, so
        // get address of resource account for borrowing order book.
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // Get market underwriter ID.
        let underwriter_id = order_book_ref_mut.underwriter_id;
        // If max base to trade flagged as max possible and a buy,
        // update to max amount that can be bought. If a sell, update
        // to all available to sell.
        if (max_base == MAX_POSSIBLE) max_base = if (direction == BUY)
            (HI_64 - base_ceiling) else base_available;
        // If max quote to trade flagged as max possible and a buy,
        // update to max amount that can spend. If a sell, update
        // to max amount that can receive when selling.
        if (max_quote == MAX_POSSIBLE) max_quote = if (direction == BUY)
            quote_available else (HI_64 - quote_ceiling);
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
        // Calculate max base and quote to withdraw. If a buy:
        let (base_withdraw, quote_withdraw) = if (direction == BUY)
            // Withdraw quote to buy base, else sell base for quote.
            (0, max_quote) else (max_base, 0);
        // Withdraw optional base coins and quote coins for match,
        // verifying base type and quote type for market.
        let (optional_base_coins, quote_coins) =
            user::withdraw_assets_internal<BaseType, QuoteType>(
                user_address, market_id, custodian_id, base_withdraw,
                quote_withdraw, underwriter_id);
        // Match against order book, storing modified asset inputs,
        // base and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
            = match(market_id, order_book_ref_mut, user_address, integrator,
                    direction, min_base, max_base, min_quote, max_quote,
                    limit_price, optional_base_coins, quote_coins);
        // Calculate amount of base deposited back to market account.
        let base_deposit = if (direction == BUY) base_traded else
            (base_withdraw - base_traded);
        // Deposit assets back to user's market account.
        user::deposit_assets_internal<BaseType, QuoteType>(
            user_address, market_id, custodian_id, base_deposit,
            optional_base_coins, quote_coins, underwriter_id);
        // Return base and quote traded by user, fees paid.
        (base_traded, quote_traded, fees)
    }

    /// Range check minimum and maximum asset trade amounts.
    ///
    /// Should be called before `match()`.
    ///
    /// # Terminology
    ///
    /// * "Inbound asset" is asset received by user.
    /// * "Outbound asset" is asset traded away by by user.
    /// * "Available asset" is the the user's holdings for either base
    ///   or quote. When trading from a user's market account,
    ///   corresponds to either `user::MarketAccount.base_available` or
    ///   `user::MarketAccount.quote_available`. When trading from a
    ///   user's `aptos_framework::coin::CoinStore` or from standalone
    ///   coins, corresponds to coin value.
    /// * "Asset ceiling" is the amount that the available asset amount
    ///   could increase to beyond its present amount, even if the
    ///   indicated trade were not executed. When trading from a user's
    ///   market account, corresponds to either
    ///   `user::MarketAccount.base_ceiling` or
    ///   `user::MarketAccount.quote_ceiling`. When trading from a
    ///   user's `aptos_framework::coin::CoinStore` or from standalone
    ///   coins, is the same as available amount.
    ///
    /// # Parameters
    ///
    /// * `direction`: `BUY` or `SELL`.
    /// * `min_base`: Minimum amount of change in base holdings after
    ///   trade.
    /// * `max_base`: Maximum amount of change in base holdings after
    ///   trade.
    /// * `min_quote`: Minimum amount of change in quote holdings after
    ///   trade.
    /// * `max_quote`: Maximum amount of change in quote holdings after
    ///   trade.
    /// * `base_available`: Available base asset amount.
    /// * `base_ceiling`: Base asset ceiling, only checked when a `BUY`.
    /// * `quote_available`: Available quote asset amount.
    /// * `quote_ceiling`: Quote asset ceiling, only checked when a
    ///   `SELL`.
    ///
    /// # Aborts
    ///
    /// * `E_MAX_BASE_0`: Maximum base trade amount specified as 0.
    /// * `E_MAX_QUOTE_0`: Maximum quote trade amount specified as 0.
    /// * `E_MIN_BASE_EXCEEDS_MAX`: Minimum base trade amount is larger
    ///   than maximum base trade amount.
    /// * `E_MIN_QUOTE_EXCEEDS_MAX`: Minimum quote trade amount is
    ///   larger than maximum quote trade amount.
    /// * `E_OVERFLOW_ASSET_IN`: Filling order would overflow asset
    ///   received from trade.
    /// * `E_NOT_ENOUGH_ASSET_OUT`: Not enough asset to trade away.
    ///
    /// # Failure testing
    ///
    /// * `test_range_check_trade_asset_in_buy()`
    /// * `test_range_check_trade_asset_in_sell()`
    /// * `test_range_check_trade_asset_out_buy()`
    /// * `test_range_check_trade_asset_out_sell()`
    /// * `test_range_check_trade_base_0()`
    /// * `test_range_check_trade_min_base_exceeds_max()`
    /// * `test_range_check_trade_min_quote_exceeds_max()`
    /// * `test_range_check_trade_quote_0()`
    fun range_check_trade(
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        base_available: u64,
        base_ceiling: u64,
        quote_available: u64,
        quote_ceiling: u64
    ) {
        // Assert nonzero max base trade amount.
        assert!(max_base > 0, E_MAX_BASE_0);
        // Assert nonzero max quote trade amount.
        assert!(max_quote > 0, E_MAX_QUOTE_0);
        // Assert minimum base less than or equal to maximum.
        assert!(min_base <= max_base, E_MIN_BASE_EXCEEDS_MAX);
        // Assert minimum quote less than or equal to maximum.
        assert!(min_quote <= max_quote, E_MIN_QUOTE_EXCEEDS_MAX);
        // Get inbound asset ceiling and max trade amount, outbound
        // asset available and max trade amount.
        let (in_ceiling, in_max, out_available, out_max) =
            if (direction == BUY) // If trade is in buy direction:
                // Getting base and trading away quote.
                (base_ceiling, max_base, quote_available, max_quote) else
                // Else a sell, so getting quote and trading away base.
                (quote_ceiling, max_quote, base_available, max_base);
        // Calculate maximum possible inbound asset ceiling post-match.
        let in_ceiling_max = (in_ceiling as u128) + (in_max as u128);
        // Assert max possible inbound asset ceiling does not overflow.
        assert!(in_ceiling_max <= (HI_64 as u128), E_OVERFLOW_ASSET_IN);
        // Assert enough outbound asset to cover max trade amount.
        assert!(out_max <= out_available, E_NOT_ENOUGH_ASSET_OUT);
    }

    /// Register order book, fee store under Econia resource account.
    ///
    /// Should only be called by `register_market_base_coin()` or
    /// `register_market_base_generic()`.
    ///
    /// See `registry::MarketInfo` for commentary on lot size, tick
    /// size, minimum size, and 32-bit prices.
    ///
    /// # Type parameters
    ///
    /// * `BaseType`: Base type for market.
    /// * `QuoteType`: Quote coin type for market.
    ///
    /// # Parameters
    ///
    /// * `market_id`: Market ID for new market.
    /// * `base_name_generic`: `registry::MarketInfo.base_name_generic`
    ///   for market.
    /// * `lot_size`: `registry::MarketInfo.lot_size` for market.
    /// * `tick_size`: `registry::MarketInfo.tick_size` for market.
    /// * `min_size`: `registry::MarketInfo.min_size` for market.
    /// * `underwriter_id`: `registry::MarketInfo.min_size` for market.
    ///
    /// # Returns
    ///
    /// * `u64`: Market ID for new market.
    ///
    /// # Testing
    ///
    /// * `test_register_markets()`
    fun register_market<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        base_name_generic: String,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_id: u64
    ): u64
    acquires OrderBooks {
        // Get Econia resource account signer.
        let resource_account = resource_account::get_signer();
        // Get resource account address.
        let resource_address = address_of(&resource_account);
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        // Add order book entry to order books map.
        tablist::add(order_books_map_ref_mut, market_id, OrderBook{
            base_type: type_info::type_of<BaseType>(),
            base_name_generic,
            quote_type: type_info::type_of<QuoteType>(),
            lot_size,
            tick_size,
            min_size,
            underwriter_id,
            asks: avl_queue::new<Order>(ASCENDING, 0, 0),
            bids: avl_queue::new<Order>(DESCENDING, 0, 0),
            counter: 0,
            maker_events:
                account::new_event_handle<MakerEvent>(&resource_account),
            taker_events:
                account::new_event_handle<TakerEvent>(&resource_account)});
        // Register an Econia fee store entry for market quote coin.
        incentives::register_econia_fee_store_entry<QuoteType>(market_id);
        market_id // Return market ID.
    }

    /// Match a taker's swap order against order book for given market.
    ///
    /// # Type Parameters
    ///
    /// * `BaseType`: Same as for `match()`.
    /// * `QuoteType`: Same as for `match()`.
    ///
    /// # Parameters
    ///
    /// * `market_id`: Same as for `match()`.
    /// * `underwriter_id`: ID of underwriter to verify if `BaseType`
    ///   is `registry::GenericAsset`, else may be passed as
    ///   `NO_UNDERWRITER`.
    /// * `taker`: Same as for `match()`.
    /// * `integrator`: Same as for `match()`.
    /// * `direction`: Same as for `match()`.
    /// * `min_base`: Same as for `match()`.
    /// * `max_base`: Same as for `match()`.
    /// * `min_quote`: Same as for `match()`.
    /// * `max_quote`: Same as for `match()`.
    /// * `limit_price`: Same as for `match()`.
    /// * `optional_base_coins`: Same as for `match()`.
    /// * `quote_coins`: Same as for `match()`.
    ///
    /// # Returns
    ///
    /// * `Option<Coin<BaseType>>`: Optional updated base coin holdings,
    ///   same as for `match()`.
    /// * `Coin<QuoteType>`: Updated quote coin holdings, same as for
    ///   `match()`.
    /// * `u64`: Base asset trade amount, same as for `match()`.
    /// * `u64`: Quote coin trade amount, same as for `match()`.
    /// * `u64`: Quote coin fees paid, same as for `match()`.
    ///
    /// # Aborts
    ///
    /// * `E_INVALID_MARKET_ID`: No market with given ID.
    /// * `E_INVALID_UNDERWRITER`: Underwriter invalid for given market.
    /// * `E_INVALID_BASE`: Base asset type is invalid.
    /// * `E_INVALID_QUOTE`: Quote asset type is invalid.
    ///
    /// # Expected value testing
    ///
    /// * Covered by `swap_between_coinstores()`, `swap_coins()`, and
    ///   `swap_generic()` testing.
    ///
    /// # Failure testing
    ///
    /// * `test_swap_invalid_base()`
    /// * `test_swap_invalid_market_id()`
    /// * `test_swap_invalid_quote()`
    /// * `test_swap_invalid_underwriter()`
    fun swap<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        underwriter_id: u64,
        taker: address,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
        optional_base_coins: Option<Coin<BaseType>>,
        quote_coins: Coin<QuoteType>
    ): (
        Option<Coin<BaseType>>,
        Coin<QuoteType>,
        u64,
        u64,
        u64
    ) acquires OrderBooks {
        // Get address of resource account where order books are stored.
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        // Assert order books map has order book with given market ID.
        assert!(tablist::contains(order_books_map_ref_mut, market_id),
                E_INVALID_MARKET_ID);
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // If passed an underwriter ID, verify it matches market.
        if (underwriter_id != NO_UNDERWRITER)
            assert!(underwriter_id == order_book_ref_mut.underwriter_id,
                    E_INVALID_UNDERWRITER);
        assert!(type_info::type_of<BaseType>() // Assert base type.
                == order_book_ref_mut.base_type, E_INVALID_BASE);
        assert!(type_info::type_of<QuoteType>() // Assert quote type.
                == order_book_ref_mut.quote_type, E_INVALID_QUOTE);
        match<BaseType, QuoteType>( // Match against order book.
            market_id, order_book_ref_mut, taker, integrator, direction,
            min_base, max_base, min_quote, max_quote, limit_price,
            optional_base_coins, quote_coins)
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // SDK generation >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// An order with price. Only for SDK generation.
    struct PricedOrder has store {
        /// Price of order from order book AVL queue.
        price: u64,
        /// Order from order book AVL queue.
        order: Order
    }

    /// Index order book into ask and bids vectors.
    ///
    /// Only for SDK generation.
    ///
    /// # Returns
    ///
    /// * `vector<PricedOrder>`: Asks, sorted by ascending price.
    /// * `vector<PricedOrder>`: Bids, sorted by descending price.
    ///
    /// # Testing
    ///
    /// * `test_index_orders()`
    fun index_orders(
        order_book_ref_mut: &mut OrderBook
    ): (
        vector<PricedOrder>,
        vector<PricedOrder>
    ) {
        // Initialize asks and bids vectors.
        let (asks, bids) = (vector[], vector[]);
        // Mutably borrow asks AVL queue.
        let orders_ref_mut = &mut order_book_ref_mut.asks;
        // While asks to process:
        while(!avl_queue::is_empty(orders_ref_mut)) {
            let price = // Get price of minimum ask in AVL queue.
                *option::borrow(&avl_queue::get_head_key(orders_ref_mut));
            // Remove order from AVL queue.
            let order = avl_queue::pop_head(orders_ref_mut);
            // Push back priced order onto asks vector.
            vector::push_back(&mut asks, PricedOrder{price, order});
        };
        // Mutably borrow bids AVL queue.
        let orders_ref_mut = &mut order_book_ref_mut.bids;
        // While bids to process:
        while(!avl_queue::is_empty(orders_ref_mut)) {
            let price = // Get price of maximum bid in AVL queue.
                *option::borrow(&avl_queue::get_head_key(orders_ref_mut));
            // Remove order from AVL queue.
            let order = avl_queue::pop_head(orders_ref_mut);
            // Push back priced order onto bids vector.
            vector::push_back(&mut bids, PricedOrder{price, order});
        };
        (asks, bids) // Return indexed asks and bids.
    }

    // SDK generation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return fields of indicated `Order`.
    public fun get_order_fields_test(
        market_id: u64,
        side: bool,
        market_order_id: u128
    ): (
        u64,
        address,
        u64,
        u64
    ) acquires OrderBooks {
        let resource_address = resource_account::get_address();
        let order_books_map_ref = // Immutably borrow order books map.
            &borrow_global<OrderBooks>(resource_address).map;
        let order_book_ref = // Immutably borrow market order book.
            tablist::borrow(order_books_map_ref, market_id);
        // Immutably borrow corresponding orders AVL queue.
        let orders_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Get AVL queue access key from market order ID.
        let avlq_access_key = ((market_order_id & (HI_64 as u128)) as u64);
        // Immutably borrow order.
        let order_ref = avl_queue::borrow(orders_ref, avlq_access_key);
        // Return its fields.
        (order_ref.size,
         order_ref.user,
         order_ref.custodian_id,
         order_ref.order_access_key)
    }

    #[test_only]
    /// Return order book counter.
    public fun get_order_book_counter(
        market_id: u64
    ): u64
    acquires OrderBooks {
        // Get address of resource account having order books.
        let resource_address = resource_account::get_address();
        let order_books_map_ref = // Immutably borrow order books map.
            &borrow_global<OrderBooks>(resource_address).map;
        let order_book_ref = // Immutably borrow market order book.
            tablist::borrow(order_books_map_ref, market_id);
        order_book_ref.counter
    }

    #[test_only]
    /// Initialize module for testing.
    public fun init_test() {
        let econia = registry::init_test(); // Init registry.
        init_module(&econia); // Init module.
    }

    #[test_only]
    /// Initialize test markets, users, and an integrator, returning
    /// user signers.
    public fun init_markets_users_integrator_test(): (
        signer,
        signer
    ) acquires OrderBooks {
        init_test(); // Init for testing.
        // Get market registration fee.
        let fee = incentives::get_market_registration_fee();
        // Register pure coin market.
        register_market_base_coin<BC, QC, UC>(
            LOT_SIZE_COIN, TICK_SIZE_COIN, MIN_SIZE_COIN,
            assets::mint_test(fee));
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get market underwriter capability.
        // Register generic market.
        register_market_base_generic<QC, UC>(
            string::utf8(BASE_NAME_GENERIC), LOT_SIZE_GENERIC,
            TICK_SIZE_GENERIC, MIN_SIZE_GENERIC, assets::mint_test(fee),
            &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Set custodian IDs to be valid.
        registry::set_registered_custodian_test(CUSTODIAN_ID_USER_0);
        registry::set_registered_custodian_test(CUSTODIAN_ID_USER_1);
        // Initialize two users, each with delegated and self-custodied
        // market accounts for each market.
        let user_0 = account::create_account_for_test(@user_0);
        let user_1 = account::create_account_for_test(@user_1);
        user::register_market_account<BC, QC>(
            &user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        user::register_market_account<BC, QC>(
            &user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0);
        user::register_market_account_generic_base<QC>(
            &user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        user::register_market_account_generic_base<QC>(
            &user_0, MARKET_ID_GENERIC, CUSTODIAN_ID_USER_0);
        user::register_market_account<BC, QC>(
            &user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        user::register_market_account<BC, QC>(
            &user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1);
        user::register_market_account_generic_base<QC>(
            &user_1, MARKET_ID_GENERIC, NO_CUSTODIAN);
        user::register_market_account_generic_base<QC>(
            &user_1, MARKET_ID_GENERIC, CUSTODIAN_ID_USER_1);
        // Register integrator to base fee store tier on each market.
        let integrator = account::create_account_for_test(@integrator);
        registry::register_integrator_fee_store_base_tier<QC, UC>(
            &integrator, MARKET_ID_COIN);
        registry::register_integrator_fee_store_base_tier<QC, UC>(
            &integrator, MARKET_ID_GENERIC);
        (user_0, user_1) // Return account signers.
    }

    #[test_only]
    /// Return true if AVL list node having list node ID enocded in
    /// market order ID is active
    public fun is_list_node_order_active(
        market_id: u64,
        side: bool,
        market_order_id: u128
    ): bool
    acquires OrderBooks {
        // Get address of resource account having order books.
        let resource_address = resource_account::get_address();
        let order_books_map_ref = // Immutably borrow order books map.
            &borrow_global<OrderBooks>(resource_address).map;
        let order_book_ref = // Immutably borrow market order book.
            tablist::borrow(order_books_map_ref, market_id);
        // Immutably borrow corresponding orders AVL queue.
        let orders_ref = if (side == ASK) &order_book_ref.asks else
            &order_book_ref.bids;
        // Get AVL queue access key from market order ID.
        let avlq_access_key = ((market_order_id & (HI_64 as u128)) as u64);
        // Get list node ID from AVL queue acces key.
        let list_node_id = avl_queue::get_access_key_list_node_id_test(
            avlq_access_key);
        // Immutably borrow order value option.
        let value_option_ref = avl_queue::borrow_value_option_test(
            orders_ref, list_node_id);
        // Return if is some.
        option::is_some(value_option_ref)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Custodian ID for market account with delegated custodian.
    const CUSTODIAN_ID_USER_0: u64 = 123;
    #[test_only]
    /// Custodian ID for market account with delegated custodian.
    const CUSTODIAN_ID_USER_1: u64 = 234;
    #[test_only]
    /// Integrator fee store tier for test market.
    const INTEGRATOR_TIER: u8 = 0;
    #[test_only]
    /// Market ID for pure coin test market.
    const MARKET_ID_COIN: u64 = 1;
    #[test_only]
    /// Market ID for generic test market.
    const MARKET_ID_GENERIC: u64 = 2;
    #[test_only]
    /// Underwriter ID for generic test market.
    const UNDERWRITER_ID: u64 = 345;

    #[test_only]
    /// Lot size for pure coin test market.
    const LOT_SIZE_COIN: u64 = 2;
    #[test_only]
    /// Tick size for pure coin test market.
    const TICK_SIZE_COIN: u64 = 3;
    #[test_only]
    /// Minimum size for pure coin test market.
    const MIN_SIZE_COIN: u64 = 4;
    #[test_only]
    /// Base name for generic test market.
    const BASE_NAME_GENERIC: vector<u8> = b"Generic asset";
    #[test_only]
    /// Lot size for generic test market.
    const LOT_SIZE_GENERIC: u64 = 5;
    #[test_only]
    /// Tick size for generic test market.
    const TICK_SIZE_GENERIC: u64 = 6;
    #[test_only]
    /// Minimum size for generic test market.
    const MIN_SIZE_GENERIC: u64 = 7;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify state updates for cancelling three asks under authority
    /// of custodian.
    fun test_cancel_all_orders_ask_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = ASK;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = CUSTODIAN_ID_USER_0;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = 3 * base_maker;
        let deposit_quote = HI_64 - 3 * quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        let custodian_capability = registry::get_custodian_capability_test(
            custodian_id); // Get custodian capability.
        // Place maker orders, storing market order IDs for lookup.
        let (market_order_id_0, _, _, _) = place_limit_order_custodian<BC, QC>(
            maker_address, market_id, integrator, side, size,
            price, restriction, &custodian_capability);
        let (market_order_id_1, _, _, _) = place_limit_order_custodian<BC, QC>(
            maker_address, market_id, integrator, side, size,
            price, restriction, &custodian_capability);
        let (market_order_id_2, _, _, _) = place_limit_order_custodian<BC, QC>(
            maker_address, market_id, integrator, side, size,
            price, restriction, &custodian_capability);
        // Assert list node orders active.
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_0), 0);
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_1), 0);
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_2), 0);
        cancel_all_orders_custodian( // Cancel orders.
            maker_address, market_id, side, &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Assert list node orders inactive.
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_0), 0);
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_1), 0);
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_2), 0);
    }

    #[test]
    /// Verify state updates for cancelling three bids under authority
    /// of signing user.
    fun test_cancel_all_orders_bid_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = BID;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - 3 * base_maker;
        let deposit_quote = 3 * quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker orders, storing market order IDs for lookup.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size, price, restriction);
        let (market_order_id_1, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size, price, restriction);
        let (market_order_id_2, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size, price, restriction);
        // Assert list node orders active.
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_0), 0);
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_1), 0);
        assert!(is_list_node_order_active(
            market_id, side, market_order_id_2), 0);
        // Cancel orders.
        cancel_all_orders_user(&maker, market_id, side);
        // Assert list node orders inactive.
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_0), 0);
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_1), 0);
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id_2), 0);
    }

    #[test]
    /// Verify state updates for cancelling ask under authority of
    /// custodian.
    fun test_cancel_order_ask_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = ASK;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = CUSTODIAN_ID_USER_0;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Declare expected maker asset counts after cancel.
        let base_total_end      = deposit_base;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = base_total_end;
        let quote_total_end     = deposit_quote;
        let quote_available_end = quote_total_end;
        let quote_ceiling_end   = quote_total_end;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        let custodian_capability = registry::get_custodian_capability_test(
            custodian_id); // Get custodian capability.
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_custodian<BC, QC>(
            maker_address, market_id, integrator, side, size,
            price, restriction, &custodian_capability);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key) =
            get_order_fields_test(market_id, side, market_order_id);
        cancel_order_custodian( // Cancel order.
            maker_address, market_id, side, market_order_id,
            &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Assert list node order inactive.
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id), 0);
        // Assert user-side order fields for cancelled order
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side,
            order_access_key);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    /// Verify state updates for cancelling bid under authority of
    /// signing user.
    fun test_cancel_order_bid_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = BID;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after cancel.
        let base_total_end      = deposit_base;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = base_total_end;
        let quote_total_end     = deposit_quote;
        let quote_available_end = quote_total_end;
        let quote_ceiling_end   = quote_total_end;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size, price, restriction);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key) =
            get_order_fields_test(market_id, side, market_order_id);
        // Cancel order.
        cancel_order_user( &maker, market_id, side, market_order_id);
        // Assert list node order inactive.
        assert!(!is_list_node_order_active(
            market_id, side, market_order_id), 0);
        // Assert user-side order fields for cancelled order
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side,
            order_access_key);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    #[expected_failure(abort_code = 23)]
    /// Verify failure for invalid custodian.
    fun test_cancel_order_invalid_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = ASK;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        let custodian_capability = registry::get_custodian_capability_test(
            custodian_id + 1); // Get invalid custodian capability.
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size,
            price, restriction);
        cancel_order_custodian( // Attempt invalid cancel.
            maker_address, market_id, side, market_order_id,
            &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid market ID.
    fun test_cancel_order_invalid_market_id()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order change parameters.
        let market_id       = HI_64;
        let side            = ASK;
        let market_order_id = (NIL as u128) + 1;
        cancel_order_user( // Attempt invalid cancel.
            &maker, market_id, side, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 22)]
    /// Verify failure for invalid market order ID.
    fun test_cancel_order_invalid_market_order_id()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order change parameters.
        let market_id       = MARKET_ID_COIN;
        let side            = ASK;
        let market_order_id = (NIL as u128);
        cancel_order_user( // Attempt invalid cancel.
            &maker, market_id, side, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 24)]
    /// Verify failure for invalid user.
    fun test_cancel_order_invalid_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, attacker) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = ASK;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size          = MIN_SIZE_COIN;
        // Declare base/quote posted for order.
        let base_maker  = size * LOT_SIZE_COIN;
        let quote_maker = size * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size,
            price, restriction);
        cancel_order_user( // Attempt invalid cancel.
            &attacker, market_id, side, market_order_id);
    }

    #[test]
    /// Verify state updates for changing ask under authority of
    /// custodian.
    fun test_change_order_size_ask_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = ASK;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = CUSTODIAN_ID_USER_0;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size_start    = MIN_SIZE_COIN;
        let size_end      = size_start * 2;
        // Declare base/quote posted with final order.
        let base_maker  = size_end * LOT_SIZE_COIN;
        let quote_maker = size_end * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Declare expected maker asset counts after size change.
        let base_total_end      = deposit_base;
        let base_available_end  = 0;
        let base_ceiling_end    = base_total_end;
        let quote_total_end     = deposit_quote;
        let quote_available_end = quote_total_end;
        let quote_ceiling_end   = HI_64;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        let custodian_capability = registry::get_custodian_capability_test(
            custodian_id); // Get custodian capability.
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_custodian<BC, QC>(
            maker_address, market_id, integrator, side, size_start,
            price, restriction, &custodian_capability);
        change_order_size_custodian( // Change order size.
            maker_address, market_id, side, market_order_id, size_end,
            &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side, order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    /// Verify state updates for changing bid under authority of signing
    /// user.
    fun test_change_order_size_bid_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = BID;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size_start    = MIN_SIZE_COIN;
        let size_end      = size_start * 2;
        // Declare base/quote posted with final order.
        let base_maker  = size_end * LOT_SIZE_COIN;
        let quote_maker = size_end * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after size change.
        let base_total_end      = deposit_base;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = deposit_quote;
        let quote_available_end = 0;
        let quote_ceiling_end   = deposit_quote;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size_start,
            price, restriction);
        change_order_size_user( // Change order size.
            &maker, market_id, side, market_order_id, size_end);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side, order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    #[expected_failure(abort_code = 23)]
    /// Verify failure for invalid custodian.
    fun test_change_order_size_invalid_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = BID;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size_start    = MIN_SIZE_COIN;
        let size_end      = size_start * 2;
        // Declare base/quote posted with final order.
        let base_maker  = size_end * LOT_SIZE_COIN;
        let quote_maker = size_end * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size_start,
            price, restriction);
        let custodian_capability = registry::get_custodian_capability_test(
            custodian_id + 1); // Get invalid custodian capability.
        change_order_size_custodian( // Attempt invalid order change.
            maker_address, market_id, side, market_order_id, size_end,
            &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid market ID.
    fun test_change_order_size_invalid_market_id()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order change parameters.
        let market_id       = HI_64;
        let side            = ASK;
        let market_order_id = (NIL as u128) + 1;
        let size_end        = MIN_SIZE_COIN;
        change_order_size_user( // Attempt invalid order change.
            &maker, market_id, side, market_order_id, size_end);
    }

    #[test]
    #[expected_failure(abort_code = 22)]
    /// Verify failure for invalid market order ID.
    fun test_change_order_size_invalid_market_order_id()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare order change parameters.
        let market_id       = MARKET_ID_COIN;
        let side            = ASK;
        let market_order_id = (NIL as u128);
        let size_end        = MIN_SIZE_COIN;
        change_order_size_user( // Attempt invalid order change.
            &maker, market_id, side, market_order_id, size_end);
    }

    #[test]
    #[expected_failure(abort_code = 24)]
    /// Verify failure for invalid user.
    fun test_change_order_size_invalid_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, attacker) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side          = BID;
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let price         = 10;
        let size_start    = MIN_SIZE_COIN;
        let size_end      = size_start * 2;
        // Declare base/quote posted with final order.
        let base_maker  = size_end * LOT_SIZE_COIN;
        let quote_maker = size_end * price * TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, side, size_start,
            price, restriction);
        change_order_size_user( // Attempt invalid order change.
            &attacker, market_id, side, market_order_id, size_end);
    }

    #[test]
    /// Verify indexing results.
    fun test_index_orders():
    (
        vector<PricedOrder>,
        vector<PricedOrder>
    ) acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare common order parameters.
        let market_id     = MARKET_ID_COIN;
        let integrator    = @integrator;
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare ask and bid parameters.
        let bid_1_size = MIN_SIZE_COIN + 1;
        let bid_0_size = bid_1_size + 1;
        let ask_0_size = bid_0_size + 1;
        let ask_1_size = ask_0_size + 1;
        let bid_1_price = 1;
        let bid_0_price = bid_1_price + 1;
        let ask_0_price = bid_0_price + 1;
        let ask_1_price = ask_0_price + 1;
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(HI_64 / 2));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(HI_64 / 2));
        // Place maker orders, storing market order IDs for lookup.
        place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, BID, bid_1_size, bid_1_price,
            restriction);
        place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, BID, bid_0_size, bid_0_price,
            restriction);
        place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, ASK, ask_0_size, ask_0_price,
            restriction);
        place_limit_order_user<BC, QC>(
            &maker, market_id, integrator, ASK, ask_1_size, ask_1_price,
            restriction);
        let resource_address = resource_account::get_address();
        let order_books_map_ref_mut = // Mutably borrow order books map.
            &mut borrow_global_mut<OrderBooks>(resource_address).map;
        let order_book_ref_mut = // Mutably borrow market order book.
            tablist::borrow_mut(order_books_map_ref_mut, market_id);
        // Index orders.
        let (asks, bids) = index_orders(order_book_ref_mut);
        // Assert priced order state.
        let priced_order_ref = vector::borrow(&asks, 0);
        assert!(priced_order_ref.price      == ask_0_price, 0);
        assert!(priced_order_ref.order.size == ask_0_size, 0);
        priced_order_ref = vector::borrow(&asks, 1);
        assert!(priced_order_ref.price      == ask_1_price, 0);
        assert!(priced_order_ref.order.size == ask_1_size, 0);
        priced_order_ref = vector::borrow(&bids, 0);
        assert!(priced_order_ref.price      == bid_0_price, 0);
        assert!(priced_order_ref.order.size == bid_0_size, 0);
        priced_order_ref = vector::borrow(&bids, 1);
        assert!(priced_order_ref.price      == bid_1_price, 0);
        assert!(priced_order_ref.order.size == bid_1_size, 0);
        (asks, bids) // Return, rather than destroy.
    }

    #[test]
    /// Verify returns, state updates for complete buy fill with no lots
    /// left to fill on matched order.
    fun test_match_complete_fill_no_lots_buy()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = BUY;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare price set to product of fee divisors, to eliminate
        // truncation when predicting fee amounts.
        let price = integrator_divisor * taker_divisor;
        // Declare order size posted by maker, filled by taker.
        let size_maker = MIN_SIZE_COIN;
        let size_taker = size_maker;
        // Declare base/quote posted/filled by maker/taker.
        let base_maker  = size_maker * LOT_SIZE_COIN;
        let quote_maker = size_maker * price * TICK_SIZE_COIN;
        let base_taker  = size_taker * LOT_SIZE_COIN;
        let quote_taker = size_taker * price * TICK_SIZE_COIN;
        // Declare fee and trade amounts, from taker's perspective.
        let base_trade       = base_taker;
        let integrator_share = quote_taker / integrator_divisor;
        let econia_share     = quote_taker / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = if (direction_taker == BUY)
            (quote_taker + fee) else (quote_taker - fee);
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = 0;
        let base_available_end  = 0;
        let base_ceiling_end    = 0;
        let quote_total_end     = HI_64;
        let quote_available_end = HI_64;
        let quote_ceiling_end   = HI_64;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = base_trade;
        let min_quote = 0;
        let max_quote = quote_trade * 2;
        // Declare swap coin input starting amounts.
        let base_coin_start = HI_64 - base_trade;
        let quote_coin_start = max_quote;
        // Declare swap coin end amounts.
        let base_coin_end = HI_64;
        let quote_coin_end = quote_coin_start - quote_trade;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker, price,
            restriction);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == base_trade, 0);
        assert!(quote_trade_r             == quote_trade, 0);
        assert!(fee_r                     == fee, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Assert list node order inactive.
        assert!(!is_list_node_order_active(
            market_id, side_maker, market_order_id), 0);
        // Assert user-side order fields for filled maker order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, market_id) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            market_id) == econia_share, 0);
    }

    #[test]
    /// Verify returns, state updates for complete sell fill with no
    /// ticks left to fill on matched order.
    fun test_match_complete_fill_no_ticks_sell()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare price set to product of fee divisors, to eliminate
        // truncation when predicting fee amounts.
        let price = integrator_divisor * taker_divisor;
        // Declare order size posted by maker, filled by taker.
        let size_maker = MIN_SIZE_COIN;
        let size_taker = size_maker;
        // Declare base/quote posted/filled by maker/taker.
        let base_maker  = size_maker * LOT_SIZE_COIN;
        let quote_maker = size_maker * price * TICK_SIZE_COIN;
        let base_taker  = size_taker * LOT_SIZE_COIN;
        let quote_taker = size_taker * price * TICK_SIZE_COIN;
        // Declare fee and trade amounts, from taker's perspective.
        let base_trade       = base_taker;
        let integrator_share = quote_taker / integrator_divisor;
        let econia_share     = quote_taker / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = if (direction_taker == BUY)
            (quote_taker + fee) else (quote_taker - fee);
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = HI_64;
        let base_available_end  = HI_64;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = 0;
        let quote_available_end = 0;
        let quote_ceiling_end   = 0;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = base_trade * 2;
        let min_quote = 0;
        let max_quote = quote_trade;
        // Declare swap coin input starting amounts.
        let base_coin_start = max_base;
        let quote_coin_start = HI_64 - max_quote;
        // Declare swap coin end amounts.
        let base_coin_end = max_base - base_trade;
        let quote_coin_end = HI_64;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker, price,
            restriction);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == base_trade, 0);
        assert!(quote_trade_r             == quote_trade, 0);
        assert!(fee_r                     == fee, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Assert list node order inactive.
        assert!(!is_list_node_order_active(
            market_id, side_maker, market_order_id), 0);
        // Assert user-side order fields for filled maker order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, market_id) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            market_id) == econia_share, 0);
    }

    #[test]
    /// Verify returns for no orders to match against.
    fun test_match_empty()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Declare swap arguments.
        let market_id   = MARKET_ID_COIN;
        let integrator  = @integrator;
        let direction   = BUY;
        let min_base    = 0;
        let max_base    = LOT_SIZE_COIN;
        let min_quote   = 0;
        let max_quote   = TICK_SIZE_COIN;
        let limit_price = 1;
        let base_coins  = coin::zero<BC>();
        let quote_coins = assets::mint_test<QC>(max_quote);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade, quote_trade, fee) =
            swap_coins(market_id, integrator, direction, min_base, max_base,
                       min_quote, max_quote, limit_price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == 0, 0);
        assert!(coin::value(&quote_coins) == max_quote, 0);
        assert!(base_trade                == 0, 0);
        assert!(quote_trade               == 0, 0);
        assert!(fee                       == 0, 0);
        // Destroy coins.
        coin::destroy_zero(base_coins);
        assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns for not enough size to fill.
    fun test_match_fill_size_0()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare price set to product of fee divisors, to eliminate
        // truncation when predicting fee amounts.
        let price = integrator_divisor * taker_divisor;
        // Declare order size posted by maker, filled by taker.
        let size_maker = MIN_SIZE_COIN + 10;
        // Declare base and quote required to fill maker.
        let base_maker = size_maker * LOT_SIZE_COIN;
        let quote_maker = size_maker * price* TICK_SIZE_COIN;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = deposit_quote;
        let quote_available_end = 0;
        let quote_ceiling_end   = quote_total_end;
        // Declare maker order size after matching.
        let size_maker_end = size_maker;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = LOT_SIZE_COIN - 1;
        let min_quote = 0;
        let max_quote = MAX_POSSIBLE;
        // Declare swap coin input starting amounts.
        let base_coin_start = max_base;
        let quote_coin_start = 0;
        // Declare swap coin end amounts.
        let base_coin_end = base_coin_start;
        let quote_coin_end = quote_coin_start;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker, price,
            restriction);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == 0, 0);
        assert!(quote_trade_r             == 0, 0);
        assert!(fee_r                     == 0, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_maker_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    /// Verify returns, state updates for complete fill on first order,
    /// partial fill on second order during match loop. A taker sell
    /// where one maker has two bids at different prices.
    fun test_match_loop_twice()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare lower price set to product of fee divisors, to
        // eliminate truncation when predicting fee amounts.
        let price_lo = integrator_divisor * taker_divisor;
        // Declare higher price for an order closer to the spread.
        let price_hi = integrator_divisor * taker_divisor * 2;
        // Declare order size posted by maker on order with high and
        // with low price.
        let size_maker_hi = MIN_SIZE_COIN + 123;
        let size_maker_lo = MIN_SIZE_COIN + 321;
        // Declare base and quote posted by maker.
        let base_maker_hi  = size_maker_hi * LOT_SIZE_COIN;
        let base_maker_lo  = size_maker_lo * LOT_SIZE_COIN;
        let base_maker     = base_maker_hi + base_maker_lo;
        let quote_maker_hi = size_maker_hi * price_hi * TICK_SIZE_COIN;
        let quote_maker_lo = size_maker_lo * price_lo * TICK_SIZE_COIN;
        let quote_maker    = quote_maker_hi + quote_maker_lo;
        // Declare taker match amounts.
        let size_taker_hi  = size_maker_hi;
        let size_taker_lo  = size_maker_lo - MIN_SIZE_COIN;
        let size_taker     = size_taker_hi + size_taker_lo;
        let base_taker     = size_taker * LOT_SIZE_COIN;
        let quote_taker_hi = quote_maker_hi;
        let quote_taker_lo = size_taker_lo * price_lo * TICK_SIZE_COIN;
        let quote_taker    = quote_taker_hi + quote_taker_lo;
        // Declare trade and fee amounts.
        let base_trade       = base_taker;
        let integrator_share = quote_taker / integrator_divisor;
        let econia_share     = quote_taker / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = if (direction_taker == BUY)
            (quote_taker + fee) else (quote_taker - fee);
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base + base_taker;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = deposit_quote - quote_taker;
        let quote_available_end = 0;
        let quote_ceiling_end   = quote_total_end;
        // Declare maker order size after matching, for partially filled
        // order
        let size_maker_lo_end = size_maker_lo - size_taker_lo;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = base_trade;
        let min_quote = 0;
        let max_quote = quote_trade * 2;
        // Swap price is that of second order to loop against.
        let price = price_lo;
        // Declare swap coin input starting amounts.
        let base_coin_start = max_base;
        let quote_coin_start = 0;
        // Declare swap coin end amounts.
        let base_coin_end = 0;
        let quote_coin_end = quote_trade;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker orders, storing market order IDs for lookup.
        let (market_order_id_hi, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker_hi,
            price_hi, restriction);
        let (market_order_id_lo, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker_lo,
            price_lo, restriction);
        // Get user-side high-price order access key for later.
        let (_, _, _, order_access_key_hi) =
            get_order_fields_test(market_id, side_maker, market_order_id_hi);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == base_trade, 0);
        assert!(quote_trade_r             == quote_trade, 0);
        assert!(fee_r                     == fee, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, market_id) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            market_id) == econia_share, 0);
        // Assert no order book-side and user-side for full fill.
        // Assert list node order inactive for higher price.
        assert!(!is_list_node_order_active(
            market_id, side_maker, market_order_id_hi), 0);
        // Assert user-side order fields for filled maker order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key_hi);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Get fields for maker order still on book.
        let (size_r, user_r, custodian_id_r, order_access_key_lo) =
            get_order_fields_test(market_id, side_maker, market_order_id_lo);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_lo_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key_lo);
        assert!(market_order_id_r == market_order_id_lo, 0);
        assert!(size_r            == size_maker_lo_end, 0);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for minimum base amount not traded.
    fun test_match_min_base_not_traded()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Declare swap arguments.
        let market_id   = MARKET_ID_COIN;
        let integrator  = @integrator;
        let direction   = BUY;
        let min_base    = 1;
        let max_base    = MAX_POSSIBLE;
        let min_quote   = 0;
        let max_quote   = MAX_POSSIBLE;
        let limit_price = 1;
        let base_coins  = coin::zero<BC>();
        let quote_coins = assets::mint_test<QC>(HI_64);
        // Invoke matching engine via coin swap against empty book.
        let (base_coins, quote_coins, _, _, _) = swap_coins(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        if (coin::value(&base_coins) == 0) coin::destroy_zero(base_coins)
            else assets::burn(base_coins);
        if (coin::value(&quote_coins) == 0) coin::destroy_zero(quote_coins)
            else assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for minimum quote amount not traded.
    fun test_match_min_quote_not_traded()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Declare swap arguments.
        let market_id   = MARKET_ID_COIN;
        let integrator  = @integrator;
        let direction   = SELL;
        let min_base    = 0;
        let max_base    = MAX_POSSIBLE;
        let min_quote   = 1;
        let max_quote   = MAX_POSSIBLE;
        let limit_price = 1;
        let base_coins = assets::mint_test<BC>(HI_64);
        let quote_coins  = coin::zero<QC>();
        // Invoke matching engine via coin swap against empty book.
        let (base_coins, quote_coins, _, _, _) = swap_coins(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        if (coin::value(&base_coins) == 0) coin::destroy_zero(base_coins)
            else assets::burn(base_coins);
        if (coin::value(&quote_coins) == 0) coin::destroy_zero(quote_coins)
            else assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns for partial sell fill with lot-limited fill size.
    fun test_match_partial_fill_lot_limited_sell()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare price set to product of fee divisors, to eliminate
        // truncation when predicting fee amounts.
        let price = integrator_divisor * taker_divisor;
        // Declare order size posted by maker, filled by taker.
        let size_maker = MIN_SIZE_COIN + 10;
        let size_taker = 5;
        // Declare base/quote posted/filled by maker/taker.
        let base_maker  = size_maker * LOT_SIZE_COIN;
        let quote_maker = size_maker * price * TICK_SIZE_COIN;
        let base_taker  = size_taker * LOT_SIZE_COIN;
        let quote_taker = size_taker * price * TICK_SIZE_COIN;
        // Declare fee and trade amounts, from taker's perspective.
        let base_trade       = base_taker;
        let integrator_share = quote_taker / integrator_divisor;
        let econia_share     = quote_taker / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = if (direction_taker == BUY)
            (quote_taker + fee) else (quote_taker - fee);
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base + base_taker;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = deposit_quote - quote_taker;
        let quote_available_end = 0;
        let quote_ceiling_end   = quote_total_end;
        // Declare maker order size after matching.
        let size_maker_end = size_maker - size_taker;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = base_trade;
        let min_quote = 0;
        let max_quote = quote_trade * 2;
        // Declare swap coin input starting amounts.
        let base_coin_start = max_base;
        let quote_coin_start = 0;
        // Declare swap coin end amounts.
        let base_coin_end = 0;
        let quote_coin_end = quote_trade;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker, price,
            restriction);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == base_trade, 0);
        assert!(quote_trade_r             == quote_trade, 0);
        assert!(fee_r                     == fee, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_maker_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, market_id) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            market_id) == econia_share, 0);
    }

    #[test]
    /// Verify returns for partial buy fill with tick-limited fill size.
    fun test_match_partial_fill_tick_limited_buy()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare shared/dependent market parameters.
        let direction_taker = BUY;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        // Declare price set to product of fee divisors, to eliminate
        // truncation when predicting fee amounts.
        let price = integrator_divisor * taker_divisor;
        // Declare order size posted by maker, filled by taker.
        let size_maker = MIN_SIZE_COIN + 10;
        let size_taker = 5;
        // Declare base/quote posted/filled by maker/taker.
        let base_maker  = size_maker * LOT_SIZE_COIN;
        let quote_maker = size_maker * price * TICK_SIZE_COIN;
        let base_taker  = size_taker * LOT_SIZE_COIN;
        let quote_taker = size_taker * price * TICK_SIZE_COIN;
        // Declare fee and trade amounts, from taker's perspective.
        let base_trade       = base_taker;
        let integrator_share = quote_taker / integrator_divisor;
        let econia_share     = quote_taker / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = if (direction_taker == BUY)
            (quote_taker + fee) else (quote_taker - fee);
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base - base_taker;
        let base_available_end  = 0;
        let base_ceiling_end    = base_total_end;
        let quote_total_end     = deposit_quote + quote_taker;
        let quote_available_end = quote_total_end;
        let quote_ceiling_end   = HI_64;
        // Declare maker order size after matching.
        let size_maker_end = size_maker - size_taker;
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = (size_taker + 2) * LOT_SIZE_COIN;
        let min_quote = 0;
        let max_quote = quote_trade;
        // Declare swap coin input starting amounts.
        let base_coin_start = 0;
        let quote_coin_start = max_quote;
        // Declare swap coin end amounts.
        let base_coin_end = base_trade;
        let quote_coin_end = 0;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker, price,
            restriction);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade_r              == base_trade, 0);
        assert!(quote_trade_r             == quote_trade, 0);
        assert!(fee_r                     == fee, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_maker_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, market_id) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            market_id) == econia_share, 0);
    }

    #[test]
    /// Verify returns for limit price violation on buy.
    fun test_match_price_break_buy()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare shared/dependent market parameters.
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        let direction_taker = BUY;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let price_taker     = 1;
        let price_maker     = price_taker + 1;
        // Declare maker order parameters.
        let maker_address = address_of(&maker);
        let custodian_id  = NO_CUSTODIAN;
        let size_maker    = MIN_SIZE_COIN;
        let base_maker    = size_maker * LOT_SIZE_COIN;
        let quote_maker   = size_maker * price_maker * TICK_SIZE_COIN;
        let restriction   = NO_RESTRICTION;
        // Declare maker deposit amounts.
        let deposit_base  = base_maker;
        let deposit_quote = HI_64 - quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base;
        let base_available_end  = 0;
        let base_ceiling_end    = base_total_end;
        let quote_total_end     = deposit_quote;
        let quote_available_end = quote_total_end;
        let quote_ceiling_end   = HI_64;
        // Declare maker order size after matching.
        let size_maker_end = size_maker;
        // Declare taker coin starting and ending amounts.
        let base_coin_start  = 0;
        let quote_coin_start = HI_64 / 2;
        let base_coin_end    = base_coin_start;
        let quote_coin_end   = quote_coin_start;
        // Declare swap arguments.
        let min_base    = 0;
        let max_base    = MAX_POSSIBLE;
        let min_quote   = 0;
        let max_quote   = 0;
        let limit_price = price_taker;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker,
            price_maker, restriction);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade, quote_trade, fee) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, limit_price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade                == 0, 0);
        assert!(quote_trade               == 0, 0);
        assert!(fee                       == 0, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_maker_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    /// Verify returns for limit price violation on sell.
    fun test_match_price_break_sell()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare shared/dependent market parameters.
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let price_maker     = 1;
        let price_taker     = price_maker + 1;
        // Declare maker order parameters.
        let maker_address = address_of(&maker);
        let custodian_id  = NO_CUSTODIAN;
        let size_maker    = MIN_SIZE_COIN;
        let base_maker    = size_maker * LOT_SIZE_COIN;
        let quote_maker   = size_maker * price_maker * TICK_SIZE_COIN;
        let restriction   = NO_RESTRICTION;
        // Declare maker deposit amounts.
        let deposit_base  = HI_64 - base_maker;
        let deposit_quote = quote_maker;
        // Declare expected maker asset counts after matching.
        let base_total_end      = deposit_base;
        let base_available_end  = base_total_end;
        let base_ceiling_end    = HI_64;
        let quote_total_end     = deposit_quote;
        let quote_available_end = 0;
        let quote_ceiling_end   = quote_total_end;
        // Declare maker order size after matching.
        let size_maker_end = size_maker;
        // Declare taker coin starting and ending amounts.
        let base_coin_start  = HI_64 / 2;
        let quote_coin_start = 0;
        let base_coin_end    = base_coin_start;
        let quote_coin_end   = quote_coin_start;
        // Declare swap arguments.
        let min_base    = 0;
        let max_base    = 0;
        let min_quote   = 0;
        let max_quote   = MAX_POSSIBLE;
        let limit_price = price_taker;
        // Create swap coin inputs.
        let base_coins  = assets::mint_test<BC>(base_coin_start);
        let quote_coins = assets::mint_test<QC>(quote_coin_start);
        // Deposit maker coins.
        user::deposit_coins<BC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_base));
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(deposit_quote));
        // Place maker order, storing market order ID for lookup.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &maker, market_id, @integrator, side_maker, size_maker,
            price_maker, restriction);
        // Invoke matching engine via coin swap.
        let (base_coins, quote_coins, base_trade, quote_trade, fee) =
            swap_coins(market_id, integrator, direction_taker, min_base,
                       max_base, min_quote, max_quote, limit_price, base_coins,
                       quote_coins);
        // Assert returns.
        assert!(coin::value(&base_coins)  == base_coin_end, 0);
        assert!(coin::value(&quote_coins) == quote_coin_end, 0);
        assert!(base_trade                == 0, 0);
        assert!(quote_trade               == 0, 0);
        assert!(fee                       == 0, 0);
        // Burn coins.
        if (base_coin_end == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_coin_end == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(market_id, side_maker, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r         == size_maker_end, 0);
        assert!(user_r         == maker_address, 0);
        assert!(custodian_id_r == custodian_id, 0);
        // Assert user-side maker order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            maker_address, market_id, custodian_id, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r            == size_maker_end, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                maker_address, market_id, custodian_id);
        assert!(base_total      == base_total_end, 0);
        assert!(base_available  == base_available_end, 0);
        assert!(base_ceiling    == base_ceiling_end, 0);
        assert!(quote_total     == quote_total_end, 0);
        assert!(quote_available == quote_available_end, 0);
        assert!(quote_ceiling   == quote_ceiling_end, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            maker_address, market_id, custodian_id) == base_total_end, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            maker_address, market_id, custodian_id) == quote_total_end, 0);
    }

    #[test]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for price too high.
    fun test_match_price_too_high()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Declare swap arguments.
        let market_id   = MARKET_ID_COIN;
        let integrator  = @integrator;
        let direction   = SELL;
        let min_base    = 0;
        let max_base    = MAX_POSSIBLE;
        let min_quote   = 0;
        let max_quote   = MAX_POSSIBLE;
        let limit_price = MAX_PRICE + 1;
        let base_coins = assets::mint_test<BC>(HI_64);
        let quote_coins  = coin::zero<QC>();
        // Invoke matching engine via coin swap against empty book.
        let (base_coins, quote_coins, _, _, _) = swap_coins(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        if (coin::value(&base_coins) == 0) coin::destroy_zero(base_coins)
            else assets::burn(base_coins);
        if (coin::value(&quote_coins) == 0) coin::destroy_zero(quote_coins)
            else assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 19)]
    /// Verify failure for self match.
    fun test_match_self_match()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (maker, _) = init_markets_users_integrator_test();
        // Declare shared/dependent market parameters.
        let direction_taker = SELL;
        let side_maker      = if (direction_taker == BUY) ASK else BID;
        let market_id       = MARKET_ID_COIN;
        let integrator      = @integrator;
        let price           = 1;
        // Declare additional maker order parameters.
        let custodian_id  = NO_CUSTODIAN;
        let maker_address = address_of(&maker);
        let restriction   = NO_RESTRICTION;
        let size_maker    = MIN_SIZE_COIN;
        // Deposit maker coins.
        user::deposit_coins<QC>(maker_address, market_id, custodian_id,
                                assets::mint_test(HI_64));
        // Deposit taker coins.
        coin::register<BC>(&maker);
        coin::deposit<BC>(maker_address, assets::mint_test<BC>(HI_64));
        // Assign min/max base/quote swap input amounts for taker.
        let min_base  = 0;
        let max_base  = MAX_POSSIBLE;
        let min_quote = 0;
        let max_quote = MAX_POSSIBLE;
        place_limit_order_user<BC, QC>( // Place maker order.
            &maker, market_id, integrator, side_maker, size_maker, price,
            restriction);
        swap_between_coinstores_entry<BC, QC>( // Attempt self match.
            &maker, market_id, integrator, direction_taker, min_base, max_base,
            min_quote, max_quote, price);
    }

    #[test]
    #[expected_failure(abort_code = 15)]
    /// Verify failure for base overflow.
    fun test_place_limit_order_base_overflow()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = HI_64 / LOT_SIZE_COIN + 1;
        let price = MAX_PRICE;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    /// Verify state updates, returns, for placing ask that fills
    /// completely and exactly across the spread, under authority of
    /// signing user.
    fun test_place_limit_order_crosses_ask_exact()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters from taker's perspective, with
        // price set to product of divisors to prevent truncation
        // effects on estimates.
        let side             = ASK; // Taker sell.
        let size             = MIN_SIZE_COIN;
        let base             = size * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote            = size * price * TICK_SIZE_COIN;
        let integrator_share = quote / integrator_divisor;
        let econia_share     = quote / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote - fee;
        let restriction      = FILL_OR_ABORT;
        // Deposit to user's accounts asset amounts that fill them just
        // up to max or down to min after the trade, for user 0 holding
        // maker order.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_trade));
        // Place maker order.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size, price,
            POST_OR_ABORT);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key_0) = get_order_fields_test(
            MARKET_ID_COIN, !side, market_order_id_0);
        assert!(is_list_node_order_active( // Assert order is active.
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Place taker order.
        let (market_order_id_1, base_trade_r, quote_trade_r, fee_r) =
            place_limit_order_user<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert returns.
        assert!(market_order_id_1 == (NIL as u128), 0);
        assert!(base_trade_r      == base, 0);
        assert!(quote_trade_r     == quote_trade, 0);
        assert!(fee_r             == fee, 0);
        // Assert order is inactive on the order book.
        assert!(!is_list_node_order_active(
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Assert user-side order fields for filled maker order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, !side, order_access_key_0);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64, 0);
        assert!(base_available  == HI_64, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        // Assert takers's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == HI_64, 0);
        assert!(quote_available == HI_64, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, MARKET_ID_COIN) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            MARKET_ID_COIN) == econia_share, 0);
    }

    #[test]
    /// Verify state updates, returns for placing ask that fills
    /// partially across the spread, under authority of signing user.
    /// Based on `test_place_limit_order_crosses_ask_exact()`
    fun test_place_limit_order_crosses_ask_partial()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = ASK; // Taker sell.
        let size_match       = MIN_SIZE_COIN + 123;
        let size_post        = MIN_SIZE_COIN + 456;
        let size             = size_match + size_post;
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post * LOT_SIZE_COIN;
        let base             = base_match + base_post;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match - fee;
        let quote_total      = quote_trade + quote_post;
        let restriction      = NO_RESTRICTION;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_match));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_match));
        // Deposit to second maker's account similarly, for meeting
        // range checks.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_total));
        // Place first maker order.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size_match, price,
            restriction);
        assert!(is_list_node_order_active( // Assert order is active.
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Place partial maker, partial taker order.
        let (market_order_id_1, base_trade_r, quote_trade_r, fee_r) =
            place_limit_order_user<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert returns
        assert!(base_trade_r      == base_match, 0);
        assert!(quote_trade_r     == quote_trade, 0);
        assert!(fee_r             == fee, 0);
        // Assert filled order inactive.
        assert!(!is_list_node_order_active(
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Get fields for new order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_1);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post, 0);
        assert!(user_r == @user_1, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert first maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64, 0);
        assert!(base_available  == HI_64, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        // Assert asset counts of partial maker/taker.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_post, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_post, 0);
        assert!(quote_total     == HI_64 - quote_post, 0);
        assert!(quote_available == HI_64 - quote_post, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == base_post, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64 - quote_post, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_1, 0);
        assert!(size_r == size_post, 0);
    }

    #[test]
    /// Verify state updates, returns for placing immediate-or-cancel
    /// ask that fills partially across the spread, under authority of
    /// signing user. Based on
    /// `test_place_limit_order_crosses_ask_partial()`.
    fun test_place_limit_order_crosses_ask_partial_cancel()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = ASK; // Taker sell.
        let size_match       = MIN_SIZE_COIN + 123;
        let size_post        = MIN_SIZE_COIN + 456;
        let size             = size_match + size_post;
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post * LOT_SIZE_COIN;
        let base             = base_match + base_post;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match - fee;
        let quote_total      = quote_trade + quote_post;
        let restriction      = IMMEDIATE_OR_CANCEL;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_match));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_match));
        // Deposit to second maker's account similarly.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_total));
        // Place first maker order.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size_match, price,
            POST_OR_ABORT);
        // Place immediate-or-cancel order.
        let (market_order_id_1, base_trade_r, quote_trade_r, fee_r) =
            place_limit_order_user<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert returns
        assert!(market_order_id_1 == (NIL as u128), 0);
        assert!(base_trade_r      == base_match, 0);
        assert!(quote_trade_r     == quote_trade, 0);
        assert!(fee_r             == fee, 0);
        // Assert filled order inactive.
        assert!(!is_list_node_order_active(
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Assert asset counts of taker.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_post, 0);
        assert!(base_available  == base_post, 0);
        assert!(base_ceiling    == base_post, 0);
        assert!(quote_total     == HI_64 - quote_post, 0);
        assert!(quote_available == HI_64 - quote_post, 0);
        assert!(quote_ceiling   == HI_64 - quote_post, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == base_post, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64 - quote_post, 0);
    }

    #[test]
    /// Verify state updates, returns, for placing bid that fills
    /// completely and exactly across the spread, under authority of
    /// signing user. Mirror of
    /// `test_place_limit_order_crosses_ask_exact()`.
    fun test_place_limit_order_crosses_bid_exact()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters from taker's perspective, with
        // price set to product of divisors to prevent truncation
        // effects on estimates.
        let side             = BID; // Taker buy.
        let size             = MIN_SIZE_COIN;
        let base             = size * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote            = size * price * TICK_SIZE_COIN;
        let integrator_share = quote / integrator_divisor;
        let econia_share     = quote / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote + fee;
        let restriction      = NO_RESTRICTION;
        // Deposit to user's accounts asset amounts that fill them just
        // up to max or down to min after the trade, for user 0 holding
        // maker order.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_trade));
        // Place maker order.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size, price,
            restriction);
        // Get user-side order access key for later.
        let (_, _, _, order_access_key_0) = get_order_fields_test(
            MARKET_ID_COIN, !side, market_order_id_0);
        assert!(is_list_node_order_active( // Assert order is active.
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Place taker order.
        let (market_order_id_1, base_trade_r, quote_trade_r, fee_r) =
            place_limit_order_user<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert returns.
        assert!(market_order_id_1 == (NIL as u128), 0);
        assert!(base_trade_r      == base, 0);
        assert!(quote_trade_r     == quote_trade, 0);
        assert!(fee_r             == fee, 0);
        // Assert order is inactive on the order book.
        assert!(!is_list_node_order_active(
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Assert user-side order fields for filled maker order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, !side, order_access_key_0);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == HI_64, 0);
        assert!(quote_available == HI_64, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        // Assert takers's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64, 0);
        assert!(base_available  == HI_64, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        // Assert integrator fee share.
        assert!(incentives::get_integrator_fee_store_balance_test<QC>(
            @integrator, MARKET_ID_COIN) == integrator_share, 0);
        // Assert Econia fee share.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            MARKET_ID_COIN) == econia_share, 0);
    }

    #[test]
    /// Verify state updates, returns for placing bid that fills
    /// partially across the spread, under authority of signing user.
    /// Mirror of `test_place_limit_order_crosses_ask_partial()`
    fun test_place_limit_order_crosses_bid_partial()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = BID; // Taker buy.
        let size_match       = MIN_SIZE_COIN + 123;
        let size_post        = MIN_SIZE_COIN + 456;
        let size             = size_match + size_post;
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post * LOT_SIZE_COIN;
        let base             = base_match + base_post;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post * price * TICK_SIZE_COIN;
        let quote            = quote_match + quote_post;
        let quote_max        = quote + quote / taker_divisor;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match + fee;
        let restriction      = NO_RESTRICTION;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_match));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_match));
        // Deposit to second maker's account minimum amount to pass
        // range checking for taker fill.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_max));
        // Place first maker order.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size_match, price,
            restriction);
        assert!(is_list_node_order_active( // Assert order is active.
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Place partial maker, partial taker order.
        let (market_order_id_1, base_trade_r, quote_trade_r, fee_r) =
            place_limit_order_user<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert returns
        assert!(base_trade_r      == base_match, 0);
        assert!(quote_trade_r     == quote_trade, 0);
        assert!(fee_r             == fee, 0);
        // Assert filled order inactive.
        assert!(!is_list_node_order_active(
            MARKET_ID_COIN, !side, market_order_id_0), 0);
        // Get fields for new order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_1);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post, 0);
        assert!(user_r == @user_1, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert first maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == HI_64, 0);
        assert!(quote_available == HI_64, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == 0, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        // Assert asset counts of partial maker/taker.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64 - base_post, 0);
        assert!(base_available  == HI_64 - base_post, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == quote_max - quote_trade, 0);
        assert!(quote_available == quote_max - quote_trade - quote_post, 0);
        assert!(quote_ceiling   == quote_max - quote_trade, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64 - base_post, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN)
            == quote_max - quote_trade, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_1, 0);
        assert!(size_r == size_post, 0);
    }

    #[test]
    /// Verify state updates, returns, for placing limit order that
    /// evicts another user's order.
    fun test_place_limit_order_evict()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side        = ASK;
        let size_0      = MIN_SIZE_COIN;
        let size_1      = size_0 + 1;
        let size_2      = size_1 + 1;
        let price_0     = 123;
        let price_1     = price_0 - 1;
        let price_2     = price_1 - 1;
        let restriction = NO_RESTRICTION;
        // Declare min base and max quote to deposit.
        let base_deposit  = HI_64 / 2;
        let quote_deposit = HI_64 / 2;
        // Declare critical height.
        let critical_height = 0;
        // Deposit base and quote coins to each user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        // Place a single order by user 0.
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_0, price_0,
            restriction);
        // Place a single order by user 1, with better price-time
        // priority, taking tree height to 1.
        let (market_order_id_1, _, _, _) = place_limit_order_user<BC, QC>(
            &user_1, MARKET_ID_COIN, @integrator, side, size_1, price_1,
            restriction);
        // Assert order fields for first placed order.
        let (size_r, user_r, custodian_id_r, order_access_key_0) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_0, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key_0);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r == size_0, 0);
        // Assert order fields for second placed order.
        let (size_r, user_r, custodian_id_r, order_access_key_1) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_1);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_1, 0);
        assert!(user_r == @user_1, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key_1);
        assert!(market_order_id_r == market_order_id_1, 0);
        assert!(size_r == size_1, 0);
        // Place another order by user 1, with better price-time
        // priority, evicting user 0's order for low critical height.
        let (market_order_id_2, _, _, _) = place_limit_order<BC, QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size_2,
            price_2, restriction, critical_height);
        // Assert order fields for third placed order.
        let (size_r, user_r, custodian_id_r, order_access_key_2) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_2);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_2, 0);
        assert!(user_r == @user_1, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key_2);
        assert!(market_order_id_r == market_order_id_2, 0);
        assert!(size_r == size_2, 0);
        // Assert order fields returned the same when attempting to
        // look up using the evicted order ID, since the same AVL queue
        // list node ID is re-used.
        let (size_r, user_r, custodian_id_r, order_access_key_r) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        assert!(size_r == size_2, 0);
        assert!(user_r == @user_1, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        assert!(order_access_key_r == order_access_key_2, 0);
        // Assert user-side order fields for inactive evicted order.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key_0);
        // No market order ID.
        assert!(market_order_id_r == (NIL as u128), 0);
        assert!(size_r == NIL, 0); // Bottom of inactive stack.
        // Assert evictee's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_deposit , 0);
        assert!(base_available  == base_deposit , 0);
        assert!(base_ceiling    == base_deposit , 0);
        assert!(quote_total     == quote_deposit, 0);
        assert!(quote_available == quote_deposit, 0);
        assert!(quote_ceiling   == quote_deposit, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_deposit, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_deposit, 0);
    }

    #[test]
    #[expected_failure(abort_code = 25)]
    /// Verify failure for not crossing spread when fill-or-abort.
    fun test_place_limit_order_fill_or_abort_not_cross()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = MIN_SIZE_COIN;
        let price = MAX_PRICE;
        let restriction = FILL_OR_ABORT;
        let critical_height = CRITICAL_HEIGHT;
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Deposit base and quote coins to maker's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(HI_64));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(HI_64));
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for not filling completely across spread when
    /// fill-or-abort.
    fun test_place_limit_order_fill_or_abort_partial()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Declare order paramaters.
        let side             = ASK; // Taker sell.
        let size             = MIN_SIZE_COIN;
        let price            = 789;
        let restriction      = FILL_OR_ABORT;
        // Deposit sufficient coins as collateral.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(0));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(0));
        // Place maker order.
        place_limit_order_user_entry<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size, price,
            POST_OR_ABORT);
        // Place limit order that can not fill.
        place_limit_order_user<BC, QC>(
            &user_1, MARKET_ID_COIN, @integrator, side, size + 1, price,
            restriction);
    }

    #[test]
    #[expected_failure(abort_code = 18)]
    /// Verify failure for invalid restriction.
    fun test_place_limit_order_invalid_restriction()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = 123;
        let price = 123;
        let restriction = N_RESTRICTIONS + 1;
        let critical_height = CRITICAL_HEIGHT;
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    /// Verify state updates, returns, for placing ask that does not
    /// cross the spread, under authority of signing user.
    fun test_place_limit_order_no_cross_ask_user()
    acquires OrderBooks {
        // Declare order parameters.
        let side          = ASK;
        let size          = MIN_SIZE_COIN;
        let price         = 123;
        let restriction   = NO_RESTRICTION;
        // Declare change in base and quote seen by maker.
        let base_delta    = size * LOT_SIZE_COIN;
        let quote_delta   = size * price * TICK_SIZE_COIN;
        // Declare min base and max quote to deposit.
        let base_deposit  = base_delta;
        let quote_deposit = HI_64 - quote_delta;
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Deposit base and quote coins to user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        // Assert order book counter.
        assert!(get_order_book_counter(MARKET_ID_COIN) == 0, 0);
        let (market_order_id, base_trade, quote_trade, fees) =
            place_limit_order_user<BC, QC>( // Place limit order.
                &user_0, MARKET_ID_COIN, @integrator, side, size, price,
                restriction);
        // Assert trade amount returns.
        assert!(base_trade == 0, 0);
        assert!(quote_trade == 0, 0);
        assert!(fees == 0, 0);
        // Assert counter encoded in order ID.
        assert!(market_order_id >> SHIFT_COUNTER == 0, 0);
        // Assert order book counter.
        assert!(get_order_book_counter(MARKET_ID_COIN) == 1, 0);
        // Get order fields.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_deposit , 0);
        assert!(base_available  == 0            , 0);
        assert!(base_ceiling    == base_deposit , 0);
        assert!(quote_total     == quote_deposit, 0);
        assert!(quote_available == quote_deposit, 0);
        assert!(quote_ceiling   == HI_64        , 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_deposit, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_deposit, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r == size, 0);
        // Place another order, asserting counter in market order ID.
        let (market_order_id, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size, price - 1,
            restriction);
        assert!(market_order_id >> SHIFT_COUNTER == 1, 0);
        // Assert order book counter.
        assert!(get_order_book_counter(MARKET_ID_COIN) == 2, 0);
    }

    #[test]
    /// Verify state updates, returns, for placing bid that does not
    /// cross the spread, under authority of custodian.
    fun test_place_limit_order_no_cross_bid_custodian()
    acquires OrderBooks {
        // Declare order parameters.
        let side          = BID;
        let size          = MIN_SIZE_COIN;
        let price         = 123;
        let restriction   = NO_RESTRICTION;
        // Declare change in base and quote seen by maker.
        let base_delta    = size * LOT_SIZE_COIN;
        let quote_delta   = size * price * TICK_SIZE_COIN;
        // Declare max base and min quote to deposit.
        let base_deposit  = HI_64 - base_delta;
        let quote_deposit = quote_delta;
        // Initialize markets, users, and an integrator.
        let (_, _) = init_markets_users_integrator_test();
        // Deposit base and quote coins to user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(quote_deposit));
        let custodian_capability = registry::get_custodian_capability_test(
            CUSTODIAN_ID_USER_0); // Get custodian capability.
        let (market_order_id, base_trade, quote_trade, fees) =
            place_limit_order_custodian<BC, QC>( // Place limit order.
                @user_0, MARKET_ID_COIN, @integrator, side, size, price,
                restriction, &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Assert trade amount returns.
        assert!(base_trade == 0, 0);
        assert!(quote_trade == 0, 0);
        assert!(fees == 0, 0);
        // Get order fields.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == CUSTODIAN_ID_USER_0, 0);
        // Assert user's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0);
        assert!(base_total      == base_deposit , 0);
        assert!(base_available  == base_deposit , 0);
        assert!(base_ceiling    == HI_64        , 0);
        assert!(quote_total     == quote_deposit, 0);
        assert!(quote_available == 0            , 0);
        assert!(quote_ceiling   == quote_deposit, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0) == base_deposit, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0) == quote_deposit, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0, side,
            order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r == size, 0);
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for invalid price.
    fun test_place_limit_order_no_price()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = 123;
        let price = 0;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 13)]
    /// Verify failure for not crossing spread as post-or-abort.
    fun test_place_limit_order_post_or_abort_crosses()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Declare order paramaters.
        let side             = ASK; // Taker sell.
        let size             = MIN_SIZE_COIN;
        let price            = 789;
        let restriction      = POST_OR_ABORT;
        // Deposit sufficient coins as collateral.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(0));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(0));
        // Place maker order.
        place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, !side, size, price,
            POST_OR_ABORT);
        // Place limit order that can not fill.
        place_limit_order_user<BC, QC>(
            &user_1, MARKET_ID_COIN, @integrator, side, size, price,
            restriction);
    }

    #[test]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for invalid price.
    fun test_place_limit_order_price_hi()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = 123;
        let price = MAX_PRICE + 1;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 20)]
    /// Verify failure for unable to insert to AVL queue. Modeled off
    /// `test_place_limit_order_evict()`.
    fun test_place_limit_order_price_time_priority_low()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Declare order parameters.
        let side        = ASK;
        let size_0      = MIN_SIZE_COIN;
        let size_1      = size_0 + 1;
        let size_2      = size_1 + 1;
        let price_0     = 123;
        let price_1     = price_0 - 1;
        let price_2     = price_0;
        let restriction = NO_RESTRICTION;
        // Declare min base and max quote to deposit.
        let base_deposit  = HI_64 / 2;
        let quote_deposit = HI_64 / 2;
        // Declare critical height.
        let critical_height = 0;
        // Deposit base and quote coins to each user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        // Place a single order by user 0.
        place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_0, price_0,
            restriction);
        // Place a single order by user 1, with better price-time
        // priority, taking tree height to 1.
        place_limit_order_user<BC, QC>(
            &user_1, MARKET_ID_COIN, @integrator, side, size_1, price_1,
            restriction);
        // Place another order by user 1, with worse price-time than
        // AVL queue tail.
        place_limit_order<BC, QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size_2,
            price_2, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 17)]
    /// Verify failure for quote overflow.
    fun test_place_limit_order_quote_overflow()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = HI_64 / LOT_SIZE_COIN;
        let price = HI_64 / size;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 14)]
    /// Verify failure for invalid size.
    fun test_place_limit_order_size_lo()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = MIN_SIZE_COIN - 1;
        let price = MAX_PRICE;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Deposit base and quote coins to user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(HI_64));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, CUSTODIAN_ID_USER_0,
                                assets::mint_test(HI_64));
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    #[expected_failure(abort_code = 16)]
    /// Verify failure for ticks overflow.
    fun test_place_limit_order_ticks_overflow()
    acquires OrderBooks {
        // Declare order parameters.
        let side = ASK;
        let size = HI_64 / LOT_SIZE_COIN;
        let price = HI_64 / size + 1;
        let restriction = NO_RESTRICTION;
        let critical_height = CRITICAL_HEIGHT;
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        place_limit_order<BC, QC>( // Attempt invalid invocation.
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, @integrator, side, size,
            price, restriction, critical_height);
    }

    #[test]
    /// Verify state updates for public entry wrapper invocation. Based
    /// on `test_place_limit_order_no_cross_ask_user()`.
    fun test_place_limit_order_user_entry()
    acquires OrderBooks {
        // Declare order parameters.
        let side          = ASK;
        let size          = MIN_SIZE_COIN;
        let price         = 123;
        let restriction   = NO_RESTRICTION;
        // Declare change in base and quote seen by maker.
        let base_delta    = size * LOT_SIZE_COIN;
        let quote_delta   = size * price * TICK_SIZE_COIN;
        // Declare min base and max quote to deposit.
        let base_deposit  = base_delta;
        let quote_deposit = HI_64 - quote_delta;
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Deposit base and quote coins to user's account.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        // Get order access key for order about to be placed.
        let order_access_key = user::get_next_order_access_key_internal(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side);
        place_limit_order_user_entry<BC, QC>( // Place limit order.
            &user_0, MARKET_ID_COIN, @integrator, side, size, price,
            restriction);
        // Assert user's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_deposit , 0);
        assert!(base_available  == 0            , 0);
        assert!(base_ceiling    == base_deposit , 0);
        assert!(quote_total     == quote_deposit, 0);
        assert!(quote_available == quote_deposit, 0);
        assert!(quote_ceiling   == HI_64        , 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_deposit, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_deposit, 0);
        // Check user-side order fields.
        let (market_order_id, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(size_r == size, 0);
        // Get order fields.
        let (size_r, user_r, custodian_id_r, order_access_key_r) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        assert!(order_access_key_r == order_access_key, 0);
    }

    #[test]
    /// Verify state updates, returns for market buy when user specifies
    /// max possible base trade amount, under authority of signing
    /// user.
    fun test_place_market_order_max_base_buy_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = ASK; // Maker sell.
        let size_match       = 1; // Only one lot ends up filling.
        let size_post        = MIN_SIZE_COIN; // Maker order size.
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post  * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post  * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match + fee; // A posteriori fees.
        let quote_deposit    = quote_trade + TICK_SIZE_COIN;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_post));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_post));
        // Deposit to maker's account similarly, for base match amount
        // as limiting factor in matching engine.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_match));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_post, price,
            NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) = place_market_order_user<
            BC, QC>(&user_1, MARKET_ID_COIN, @integrator, BUY, 0, MAX_POSSIBLE,
            0, quote_deposit, price); // Place taker order.
        // Assert returns.
        assert!(base_trade_r  == base_match, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post - size_match, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_post - size_match, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_post - base_match, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_post - base_match, 0);
        assert!(quote_total     == HI_64 - quote_post + quote_match, 0);
        assert!(quote_available == HI_64 - quote_post + quote_match, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == base_post - base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == HI_64 - quote_post + quote_match, 0);
        // Assert taker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64, 0);
        assert!(base_available  == HI_64, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == quote_deposit - quote_trade, 0);
        assert!(quote_available == quote_deposit - quote_trade, 0);
        assert!(quote_ceiling   == quote_deposit - quote_trade, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN)
            == quote_deposit - quote_trade, 0);
    }

    #[test]
    /// Verify state updates, returns for market sell when max possible
    /// base trade amount specified, under authority of custodian.
    fun test_place_market_order_max_base_sell_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = BID; // Maker buy.
        let size_match       = 1; // Only one lot ends up filling.
        let size_post        = MIN_SIZE_COIN; // Maker order size.
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post  * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post  * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match - fee; // A posteriori fees.
        let max_quote        = quote_trade + TICK_SIZE_COIN;
        let quote_deposit    = HI_64 - max_quote;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_post));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_post));
        // Deposit to maker's account similarly, for base match amount
        // as limiting factor in matching engine.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1,
                                assets::mint_test(base_match));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1,
                                assets::mint_test(quote_deposit));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_post, price,
            NO_RESTRICTION); // Place maker order.
        let custodian_capability = registry::get_custodian_capability_test(
            CUSTODIAN_ID_USER_1); // Get custodian capability.
        let (base_trade_r, quote_trade_r, fee_r) =
            place_market_order_custodian<BC, QC>( // Place taker order.
                @user_1, MARKET_ID_COIN, @integrator, SELL, 0, MAX_POSSIBLE,
                0, max_quote, price, &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Assert returns.
        assert!(base_trade_r  == base_match, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post - size_match, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_post - size_match, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64 - base_post + base_match, 0);
        assert!(base_available  == HI_64 - base_post + base_match, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == quote_post - quote_match, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_post - quote_match, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == HI_64 - base_post + base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == quote_post - quote_match, 0);
        // Assert taker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1);
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_deposit + quote_trade, 0);
        assert!(quote_available == quote_deposit + quote_trade, 0);
        assert!(quote_ceiling   == quote_deposit + quote_trade, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1) == 0, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1)
            == quote_deposit + quote_trade, 0);
    }

    #[test]
    /// Verify state updates, returns for market buy when max possible
    /// quote trade amount specified, under authority of custodian.
    fun test_place_market_order_max_quote_buy_custodian()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = ASK; // Maker sell.
        let size_match       = 1; // Only one lot ends up filling.
        let size_post        = MIN_SIZE_COIN; // Maker order size.
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post  * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post  * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match + fee; // A posteriori fees.
        let max_base         = base_match + LOT_SIZE_COIN;
        let base_deposit     = HI_64 - max_base;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_post));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_post));
        // Deposit to maker's account similarly, for quote match amount
        // as limiting factor in matching engine.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1,
                                assets::mint_test(quote_trade));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_post, price,
            NO_RESTRICTION); // Place maker order.
        let custodian_capability = registry::get_custodian_capability_test(
            CUSTODIAN_ID_USER_1); // Get custodian capability.
        let (base_trade_r, quote_trade_r, fee_r) =
            place_market_order_custodian<BC, QC>( // Place taker order.
                @user_1, MARKET_ID_COIN, @integrator, BUY, 0, max_base, 0,
                MAX_POSSIBLE, price, &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Assert returns.
        assert!(base_trade_r  == base_match, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post - size_match, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_post - size_match, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_post - base_match, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_post - base_match, 0);
        assert!(quote_total     == HI_64 - quote_post + quote_match, 0);
        assert!(quote_available == HI_64 - quote_post + quote_match, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == base_post - base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == HI_64 - quote_post + quote_match, 0);
        // Assert taker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1);
        assert!(base_total      == base_deposit + base_match, 0);
        assert!(base_available  == base_deposit + base_match, 0);
        assert!(base_ceiling    == base_deposit + base_match, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1)
            == base_deposit + base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, CUSTODIAN_ID_USER_1) == 0, 0);
    }

    #[test]
    /// Verify state updates, returns for market sell when max possible
    /// quote trade amount specified, under authority of signing user.
    fun test_place_market_order_max_quote_sell_user()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = BID; // Maker buy.
        let size_match       = 1; // Only one lot ends up filling.
        let size_post        = MIN_SIZE_COIN; // Maker order size.
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post  * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post  * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match - fee; // A posteriori fees.
        let max_base         = base_match + LOT_SIZE_COIN;
        let base_deposit     = max_base;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_post));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_post));
        // Deposit to maker's account similarly, for quote match amount
        // as limiting factor in matching engine.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_trade));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_post, price,
            NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) =
            place_market_order_user<BC, QC>( // Place taker order.
                &user_1, MARKET_ID_COIN, @integrator, SELL, 0, max_base, 0,
                MAX_POSSIBLE, price);
        // Assert returns.
        assert!(base_trade_r  == base_match, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post - size_match, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_post - size_match, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64 - base_post + base_match, 0);
        assert!(base_available  == HI_64 - base_post + base_match, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == quote_post - quote_match, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_post - quote_match, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == HI_64 - base_post + base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == quote_post - quote_match, 0);
        // Assert taker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_deposit - base_match, 0);
        assert!(base_available  == base_deposit - base_match, 0);
        assert!(base_ceiling    == base_deposit - base_match, 0);
        assert!(quote_total     == HI_64, 0);
        assert!(quote_available == HI_64, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN)
            == base_deposit - base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
    }

    #[test]
    /// Verify state updates for public entry wrapper invocation. Based
    /// on `test_place_market_order_max_base_buy_user()`.
    fun test_place_market_order_user_entry()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get fee divisors.
        let (taker_divisor, integrator_divisor) =
            (incentives::get_taker_fee_divisor(),
             incentives::get_fee_share_divisor(INTEGRATOR_TIER));
        // Declare order paramaters with price set to product of
        // divisors, to prevent truncation effects on estimates.
        let side             = ASK; // Maker sell.
        let size_match       = 1; // Only one lot ends up filling.
        let size_post        = MIN_SIZE_COIN; // Maker order size.
        let base_match       = size_match * LOT_SIZE_COIN;
        let base_post        = size_post  * LOT_SIZE_COIN;
        let price            = integrator_divisor * taker_divisor;
        let quote_match      = size_match * price * TICK_SIZE_COIN;
        let quote_post       = size_post  * price * TICK_SIZE_COIN;
        let integrator_share = quote_match / integrator_divisor;
        let econia_share     = quote_match / taker_divisor - integrator_share;
        let fee              = integrator_share + econia_share;
        let quote_trade      = quote_match + fee; // A posteriori fees.
        let quote_deposit    = quote_trade + TICK_SIZE_COIN;
        // Deposit to first maker's account enough to impinge on min
        // and max amounts after fill.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_post));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - quote_post));
        // Deposit to maker's account similarly, for base match amount
        // as limiting factor in matching engine.
        user::deposit_coins<BC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(HI_64 - base_match));
        user::deposit_coins<QC>(@user_1, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side, size_post, price,
            NO_RESTRICTION); // Place maker order.
        place_market_order_user_entry<BC, QC>(
            &user_1, MARKET_ID_COIN, @integrator, BUY, 0, MAX_POSSIBLE,
            0, quote_deposit, price); // Place taker order.
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(MARKET_ID_COIN, side, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_post - size_match, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_post - size_match, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_post - base_match, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_post - base_match, 0);
        assert!(quote_total     == HI_64 - quote_post + quote_match, 0);
        assert!(quote_available == HI_64 - quote_post + quote_match, 0);
        assert!(quote_ceiling   == HI_64, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == base_post - base_match, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN)
            == HI_64 - quote_post + quote_match, 0);
        // Assert taker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_1, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == HI_64, 0);
        assert!(base_available  == HI_64, 0);
        assert!(base_ceiling    == HI_64, 0);
        assert!(quote_total     == quote_deposit - quote_trade, 0);
        assert!(quote_available == quote_deposit - quote_trade, 0);
        assert!(quote_ceiling   == quote_deposit - quote_trade, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN) == HI_64, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_1, MARKET_ID_COIN, NO_CUSTODIAN)
            == quote_deposit - quote_trade, 0);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for overflowing asset in for a buy.
    fun test_range_check_trade_asset_in_buy() {
        // Declare inputs.
        let direction = BUY;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = HI_64;
        let quote_available = 0;
        let quote_ceiling = HI_64;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for overflowing asset in for a sell.
    fun test_range_check_trade_asset_in_sell() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = HI_64;
        let quote_available = 0;
        let quote_ceiling = HI_64;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for underflowing asset out for a buy.
    fun test_range_check_trade_asset_out_buy() {
        // Declare inputs.
        let direction = BUY;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = 1;
        let quote_available = 0;
        let quote_ceiling = 1;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for underflowing asset out for a sell.
    fun test_range_check_trade_asset_out_sell() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = 1;
        let quote_available = 0;
        let quote_ceiling = 1;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for max base specified as 0.
    fun test_range_check_trade_base_0() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 0;
        let max_base = 0;
        let min_quote = 0;
        let max_quote = 0;
        let base_available = 0;
        let base_ceiling = 0;
        let quote_available = 0;
        let quote_ceiling = 0;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for min base exceeds max
    fun test_range_check_trade_min_base_exceeds_max() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 2;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = 0;
        let quote_available = 0;
        let quote_ceiling = 0;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for min quote exceeds max
    fun test_range_check_trade_min_quote_exceeds_max() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 2;
        let max_quote = 1;
        let base_available = 0;
        let base_ceiling = 0;
        let quote_available = 0;
        let quote_ceiling = 0;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for max quote specified as 0.
    fun test_range_check_trade_quote_0() {
        // Declare inputs.
        let direction = SELL;
        let min_base = 0;
        let max_base = 1;
        let min_quote = 0;
        let max_quote = 0;
        let base_available = 0;
        let base_ceiling = 0;
        let quote_available = 0;
        let quote_ceiling = 0;
        // Attempt invalid invocation.
        range_check_trade(
            direction, min_base, max_base, min_quote, max_quote,
            base_available, base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    /// Assert state updates and returns for:
    ///
    /// 1. Registering pure coin market from coin store.
    /// 2. Registering generic market.
    /// 3. Registering pure coin market, not from coin store.
    fun test_register_markets()
    acquires OrderBooks {
        init_test(); // Init for testing.
        // Get market registration fee, denominated in utility coins.
        let fee = incentives::get_market_registration_fee();
        // Create user account.
        let user = account::create_account_for_test(@user);
        coin::register<UC>(&user); // Register user coin store.
        // Deposit utility coins required to cover fee.
        coin::deposit<UC>(@user, assets::mint_test(fee));
        // Register pure coin market from coinstore.
        register_market_base_coin_from_coinstore<BC, QC, UC>(
            &user, LOT_SIZE_COIN, TICK_SIZE_COIN, MIN_SIZE_COIN);
        // Get market info returns from registry.
        let (base_name_generic_r, lot_size_r, tick_size_r, min_size_r,
             underwriter_id_r) = registry::get_market_info_for_market_account(
                MARKET_ID_COIN, type_info::type_of<BC>(),
                type_info::type_of<QC>());
        // Assert registry market info returns.
        assert!(base_name_generic_r == string::utf8(b""), 0);
        assert!(lot_size_r          == LOT_SIZE_COIN, 0);
        assert!(tick_size_r         == TICK_SIZE_COIN, 0);
        assert!(min_size_r          == MIN_SIZE_COIN, 0);
        assert!(underwriter_id_r    == NO_UNDERWRITER, 0);
        // Assert fee store with corresponding market ID is empty.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            MARKET_ID_COIN) == 0, 0);
        let order_books_map_ref = // Immutably borrow order books map.
            &borrow_global<OrderBooks>(resource_account::get_address()).map;
        let order_book_ref = // Immutably borrow order book.
            tablist::borrow(order_books_map_ref, MARKET_ID_COIN);
        // Assert order book state.
        assert!(order_book_ref.base_type == type_info::type_of<BC>(), 0);
        assert!(order_book_ref.base_name_generic == string::utf8(b""), 0);
        assert!(order_book_ref.quote_type == type_info::type_of<QC>(), 0);
        assert!(order_book_ref.lot_size == LOT_SIZE_COIN, 0);
        assert!(order_book_ref.tick_size == TICK_SIZE_COIN, 0);
        assert!(order_book_ref.min_size == MIN_SIZE_COIN, 0);
        assert!(order_book_ref.underwriter_id == NO_UNDERWRITER, 0);
        assert!(avl_queue::is_empty(&order_book_ref.asks), 0);
        assert!(avl_queue::is_ascending(&order_book_ref.asks), 0);
        assert!(avl_queue::is_empty(&order_book_ref.bids), 0);
        assert!(!avl_queue::is_ascending(&order_book_ref.bids), 0);
        assert!(order_book_ref.counter == 0, 0);
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get market underwriter capability.
        // Register generic market, storing market ID.
        let market_id = register_market_base_generic<QC, UC>(
            string::utf8(BASE_NAME_GENERIC), LOT_SIZE_GENERIC,
            TICK_SIZE_GENERIC, MIN_SIZE_GENERIC, assets::mint_test<UC>(fee),
            &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert market ID.
        assert!(market_id == MARKET_ID_GENERIC, 0);
        // Get market info returns from registry.
        (base_name_generic_r, lot_size_r, tick_size_r, min_size_r,
         underwriter_id_r) = registry::get_market_info_for_market_account(
            MARKET_ID_GENERIC, type_info::type_of<GenericAsset>(),
            type_info::type_of<QC>());
        // Assert registry market info returns.
        assert!(base_name_generic_r == string::utf8(BASE_NAME_GENERIC), 0);
        assert!(lot_size_r          == LOT_SIZE_GENERIC, 0);
        assert!(tick_size_r         == TICK_SIZE_GENERIC, 0);
        assert!(min_size_r          == MIN_SIZE_GENERIC, 0);
        assert!(underwriter_id_r    == UNDERWRITER_ID, 0);
        // Assert fee store with corresponding market ID is empty.
        assert!(incentives::get_econia_fee_store_balance_test<QC>(
            MARKET_ID_GENERIC) == 0, 0);
        order_books_map_ref = // Immutably borrow order books map.
            &borrow_global<OrderBooks>(resource_account::get_address()).map;
        order_book_ref = // Immutably borrow order book.
            tablist::borrow(order_books_map_ref, MARKET_ID_GENERIC);
        // Assert order book state.
        assert!(order_book_ref.base_type ==
                type_info::type_of<GenericAsset>(), 0);
        assert!(order_book_ref.base_name_generic ==
                string::utf8(BASE_NAME_GENERIC), 0);
        assert!(order_book_ref.quote_type == type_info::type_of<QC>(), 0);
        assert!(order_book_ref.lot_size == LOT_SIZE_GENERIC, 0);
        assert!(order_book_ref.tick_size == TICK_SIZE_GENERIC, 0);
        assert!(order_book_ref.min_size == MIN_SIZE_GENERIC, 0);
        assert!(order_book_ref.underwriter_id == UNDERWRITER_ID, 0);
        assert!(avl_queue::is_empty(&order_book_ref.asks), 0);
        assert!(avl_queue::is_ascending(&order_book_ref.asks), 0);
        assert!(avl_queue::is_empty(&order_book_ref.bids), 0);
        assert!(!avl_queue::is_ascending(&order_book_ref.bids), 0);
        assert!(order_book_ref.counter == 0, 0);
        // Assert market ID return for registering pure coin market not
        // from coin store.
        assert!(register_market_base_coin<QC, BC, UC>(
            1, 1, 1, assets::mint_test<UC>(fee)) == 3, 0);
    }

    #[test]
    /// Verify returns, state updates for specifying max possible base
    /// during a buy.
    fun test_swap_between_coinstores_max_possible_base_buy()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = MAX_POSSIBLE;
        let min_quote        = 0;
        let max_quote        = quote_trade + TICK_SIZE_COIN;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let base_deposit_taker  = HI_64 - base_taker;
        let quote_deposit_taker = max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = HI_64;
        let quote_total_taker = quote_deposit_taker - quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<BC>(&user_1);
        coin::register<QC>(&user_1);
        coin::deposit<BC>(@user_1, assets::mint_test(base_deposit_taker));
        coin::deposit<QC>(@user_1, assets::mint_test(quote_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) = // Place taker order.
            swap_between_coinstores<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
                max_base, min_quote, max_quote, price);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for specifying max possible base
    /// during a sell.
    fun test_swap_between_coinstores_max_possible_base_sell()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = MAX_POSSIBLE;
        let min_quote        = 0;
        let max_quote        = quote_trade + TICK_SIZE_COIN;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = base_taker;
        let quote_deposit_taker = HI_64 - max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = 0;
        let quote_total_taker = quote_deposit_taker + quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<BC>(&user_1);
        coin::register<QC>(&user_1);
        coin::deposit<BC>(@user_1, assets::mint_test(base_deposit_taker));
        coin::deposit<QC>(@user_1, assets::mint_test(quote_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) = // Place taker order.
            swap_between_coinstores<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
                max_base, min_quote, max_quote, price);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for specifying max possible quote
    /// during a buy.
    fun test_swap_between_coinstores_max_possible_quote_buy()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_COIN;
        let min_quote        = 0;
        let max_quote        = MAX_POSSIBLE;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let base_deposit_taker  = HI_64 - max_base;
        let quote_deposit_taker = quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker + base_taker;
        let quote_total_taker = 0;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<BC>(&user_1);
        coin::register<QC>(&user_1);
        coin::deposit<BC>(@user_1, assets::mint_test(base_deposit_taker));
        coin::deposit<QC>(@user_1, assets::mint_test(quote_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) = // Place taker order.
            swap_between_coinstores<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
                max_base, min_quote, max_quote, price);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for specifying max possible quote
    /// during a sell.
    fun test_swap_between_coinstores_max_possible_quote_sell()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_COIN;
        let min_quote        = 0;
        let max_quote        = MAX_POSSIBLE;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = max_base;
        let quote_deposit_taker = HI_64 - quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker - base_taker;
        let quote_total_taker = HI_64;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<BC>(&user_1);
        coin::register<QC>(&user_1);
        coin::deposit<BC>(@user_1, assets::mint_test(base_deposit_taker));
        coin::deposit<QC>(@user_1, assets::mint_test(quote_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_trade_r, quote_trade_r, fee_r) = // Place taker order.
            swap_between_coinstores<BC, QC>(
                &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
                max_base, min_quote, max_quote, price);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for registering base coin store.
    fun test_swap_between_coinstores_register_base_store()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker;
        let min_quote        = 0;
        let max_quote        = MAX_POSSIBLE;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let quote_deposit_taker = quote_trade + TICK_SIZE_COIN;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_taker;
        let quote_total_taker = quote_deposit_taker - quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<QC>(&user_1);
        coin::deposit<QC>(@user_1, assets::mint_test(quote_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        swap_between_coinstores_entry<BC, QC>( // Place taker order.
            &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
            max_base, min_quote, max_quote, price);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for registering quote coin store.
    fun test_swap_between_coinstores_register_quote_store()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, user_1) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = MAX_POSSIBLE;
        let min_quote        = 0;
        let max_quote        = quote_trade;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = base_taker + LOT_SIZE_COIN;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker - base_taker;
        let quote_total_taker = quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Deposit taker coins.
        coin::register<BC>(&user_1);
        coin::deposit<BC>(@user_1, assets::mint_test(base_deposit_taker));
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        swap_between_coinstores_entry<BC, QC>( // Place taker order.
            &user_1, MARKET_ID_COIN, @integrator, direction, min_base,
            max_base, min_quote, max_quote, price);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::balance<BC>(@user_1) == base_total_taker, 0);
        assert!(coin::balance<QC>(@user_1) == quote_total_taker, 0);
    }

    #[test]
    /// Verify returns, state updates for swap buy for max possible
    /// base amount specified, with base amount as limiting factor.
    fun test_swap_coins_buy_max_base_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = MAX_POSSIBLE;
        let min_quote        = 0;
        let max_quote        = 0;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let base_deposit_taker  = HI_64 - base_taker;
        let quote_deposit_taker = quote_trade + TICK_SIZE_COIN;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = HI_64;
        let quote_total_taker = quote_deposit_taker - quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap buy for max possible
    /// base amount not specified, with base amount as limiting factor.
    fun test_swap_coins_buy_no_max_base_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker;
        let min_quote        = 0;
        let max_quote        = 0;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let base_deposit_taker  = HI_64 - max_base;
        let quote_deposit_taker = quote_trade + TICK_SIZE_COIN;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = HI_64;
        let quote_total_taker = quote_deposit_taker - quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap buy for max possible
    /// base amount not specified, with quote amount as limiting factor.
    fun test_swap_coins_buy_no_max_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_COIN;
        let min_quote        = 0;
        let max_quote        = 0;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let base_deposit_taker  = HI_64 - max_base;
        let quote_deposit_taker = quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker + base_taker;
        let quote_total_taker = 0;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker, order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell for max possible
    /// quote amount specified, with quote amount as limiting factor.
    fun test_swap_coins_sell_max_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = 0;
        let min_quote        = 0;
        let max_quote        = MAX_POSSIBLE;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = base_taker + LOT_SIZE_COIN;
        let quote_deposit_taker = HI_64 - quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker - base_taker;
        let quote_total_taker = HI_64;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell for no max possible
    /// quote amount specified, with base amount as limiting factor.
    fun test_swap_coins_sell_no_max_base_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = 0;
        let min_quote        = 0;
        let max_quote        = quote_trade + TICK_SIZE_COIN;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = base_taker;
        let quote_deposit_taker = HI_64 - max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = 0;
        let quote_total_taker = quote_deposit_taker + quote_trade;
        // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell for no max possible
    /// quote amount specified, with quote amount as limiting factor.
    fun test_swap_coins_sell_no_max_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_COIN;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_COIN;
        let base_taker       = size_taker * LOT_SIZE_COIN;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_COIN;
        let quote_match      = size_taker * price * TICK_SIZE_COIN;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = 0;
        let min_quote        = 0;
        let max_quote        = quote_trade;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let base_deposit_taker  = base_taker + LOT_SIZE_COIN;
        let quote_deposit_taker = HI_64 - max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let base_total_taker  = base_deposit_taker - base_taker;
        let quote_total_taker = HI_64; // Deposit maker coins.
        user::deposit_coins<BC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(base_deposit_maker));
        user::deposit_coins<QC>(@user_0, MARKET_ID_COIN, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let base_coins  = assets::mint_test<BC>(base_deposit_taker);
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<BC, QC>(
            &user_0, MARKET_ID_COIN, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (base_coins, quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_coins<BC, QC>( // Place taker order.
                MARKET_ID_COIN, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, base_coins, quote_coins);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_COIN, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_COIN, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amounts.
        assert!(user::get_collateral_value_simple_test<BC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == base_total_maker, 0);
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_COIN, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<BC>(&base_coins)  == base_total_taker, 0);
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (base_total_taker == 0) coin::destroy_zero(base_coins) else
            assets::burn(base_coins);
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap buy with base amount as
    /// limiting factor.
    fun test_swap_generic_buy_base_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_GENERIC;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_GENERIC;
        let base_taker       = size_taker * LOT_SIZE_GENERIC;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_GENERIC;
        let quote_match      = size_taker * price * TICK_SIZE_GENERIC;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker;
        let min_quote        = 0;
        let max_quote        = 0;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let quote_deposit_taker = quote_trade + TICK_SIZE_GENERIC;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let quote_total_taker = quote_deposit_taker - quote_trade;
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get underwriter capability.
        // Deposit maker assets.
        user::deposit_generic_asset(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, base_deposit_maker,
            &underwriter_capability);
        user::deposit_coins<QC>(@user_0, MARKET_ID_GENERIC, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<QC, QC>(
            &user_0, MARKET_ID_GENERIC, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_generic<QC>( // Place taker order.
                MARKET_ID_GENERIC, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, quote_coins,
                &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_GENERIC, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amount.
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap buy with quote amount as
    /// limiting factor.
    fun test_swap_generic_buy_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = BUY;
        let side_maker       = ASK; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_GENERIC;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_GENERIC;
        let base_taker       = size_taker * LOT_SIZE_GENERIC;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_GENERIC;
        let quote_match      = size_taker * price * TICK_SIZE_GENERIC;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_GENERIC;
        let min_quote        = 0;
        let max_quote        = 0;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = base_maker;
        let quote_deposit_maker = HI_64 - quote_maker;
        let quote_deposit_taker = quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker - base_taker;
        let base_available_maker  = 0;
        let base_ceiling_maker    = base_total_maker;
        let quote_total_maker     = quote_deposit_maker + quote_match;
        let quote_available_maker = quote_total_maker;
        let quote_ceiling_maker   = HI_64;
        // Declare expected asset amounts after the match, for taker.
        let quote_total_taker = 0;
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get underwriter capability.
        // Deposit maker assets.
        user::deposit_generic_asset(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, base_deposit_maker,
            &underwriter_capability);
        user::deposit_coins<QC>(@user_0, MARKET_ID_GENERIC, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<QC, QC>(
            &user_0, MARKET_ID_GENERIC, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_generic<QC>( // Place taker order.
                MARKET_ID_GENERIC, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, quote_coins,
                &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_GENERIC, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amount.
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell with max possible
    /// quote flag specified, with quote amount as limiting factor.
    fun test_swap_generic_sell_max_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_GENERIC;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_GENERIC;
        let base_taker       = size_taker * LOT_SIZE_GENERIC;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_GENERIC;
        let quote_match      = size_taker * price * TICK_SIZE_GENERIC;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_GENERIC;
        let min_quote        = 0;
        let max_quote        = MAX_POSSIBLE;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let quote_deposit_taker = HI_64 - quote_trade;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let quote_total_taker = HI_64;
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get underwriter capability.
        // Deposit maker assets.
        user::deposit_generic_asset(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, base_deposit_maker,
            &underwriter_capability);
        user::deposit_coins<QC>(@user_0, MARKET_ID_GENERIC, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<QC, QC>(
            &user_0, MARKET_ID_GENERIC, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_generic<QC>( // Place taker order.
                MARKET_ID_GENERIC, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, quote_coins,
                &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_GENERIC, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amount.
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell without max possible
    /// quote flag specified, with base amount as limiting factor.
    fun test_swap_generic_sell_no_max_base_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_GENERIC;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_GENERIC;
        let base_taker       = size_taker * LOT_SIZE_GENERIC;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_GENERIC;
        let quote_match      = size_taker * price * TICK_SIZE_GENERIC;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker;
        let min_quote        = 0;
        let max_quote        = quote_trade + TICK_SIZE_GENERIC;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let quote_deposit_taker = HI_64 - max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let quote_total_taker = quote_deposit_taker + quote_trade;
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get underwriter capability.
        // Deposit maker assets.
        user::deposit_generic_asset(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, base_deposit_maker,
            &underwriter_capability);
        user::deposit_coins<QC>(@user_0, MARKET_ID_GENERIC, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<QC, QC>(
            &user_0, MARKET_ID_GENERIC, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_generic<QC>( // Place taker order.
                MARKET_ID_GENERIC, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, quote_coins,
                &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_GENERIC, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amount.
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    /// Verify returns, state updates for swap sell without max possible
    /// quote flag specified, with quote amount as limiting factor.
    fun test_swap_generic_sell_no_max_quote_limiting()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        let (user_0, _) = init_markets_users_integrator_test();
        // Get taker fee divisor.
        let taker_divisor = incentives::get_taker_fee_divisor();
        // Declare order setup parameters, with price set to taker fee
        // divisor, to prevent truncation effects on estimates.
        let direction        = SELL;
        let side_maker       = BID; // If buy then ask, else bid.
        let size_maker       = MIN_SIZE_GENERIC;
        let size_taker       = 1;
        let base_maker       = size_maker * LOT_SIZE_GENERIC;
        let base_taker       = size_taker * LOT_SIZE_GENERIC;
        let price            = taker_divisor;
        let quote_maker      = size_maker * price * TICK_SIZE_GENERIC;
        let quote_match      = size_taker * price * TICK_SIZE_GENERIC;
        let fee              = quote_match / taker_divisor;
        let quote_trade      = if (direction == BUY) quote_match + fee else
                                                     quote_match - fee;
        let min_base         = 0;
        let max_base         = base_taker + LOT_SIZE_GENERIC;
        let min_quote        = 0;
        let max_quote        = quote_trade;
        // Declare deposit amounts so as to impinge on available/ceiling
        // boundaries.
        let base_deposit_maker  = HI_64 - base_maker;
        let quote_deposit_maker = quote_maker;
        let quote_deposit_taker = HI_64 - max_quote;
        // Declare expected asset amounts after the match, for maker.
        let base_total_maker      = base_deposit_maker + base_taker;
        let base_available_maker  = base_total_maker;
        let base_ceiling_maker    = HI_64;
        let quote_total_maker     = quote_deposit_maker - quote_match;
        let quote_available_maker = 0;
        let quote_ceiling_maker   = quote_total_maker;
        // Declare expected asset amounts after the match, for taker.
        let quote_total_taker = HI_64;
        let underwriter_capability = registry::get_underwriter_capability_test(
            UNDERWRITER_ID); // Get underwriter capability.
        // Deposit maker assets.
        user::deposit_generic_asset(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, base_deposit_maker,
            &underwriter_capability);
        user::deposit_coins<QC>(@user_0, MARKET_ID_GENERIC, NO_CUSTODIAN,
                                assets::mint_test(quote_deposit_maker));
        // Create taker coins.
        let quote_coins = assets::mint_test<QC>(quote_deposit_taker);
        let (market_order_id_0, _, _, _) = place_limit_order_user<QC, QC>(
            &user_0, MARKET_ID_GENERIC, @integrator, side_maker, size_maker,
            price, NO_RESTRICTION); // Place maker order.
        let (quote_coins, base_trade_r, quote_trade_r, fee_r) =
            swap_generic<QC>( // Place taker order.
                MARKET_ID_GENERIC, @integrator, direction, min_base, max_base,
                min_quote, max_quote, price, quote_coins,
                &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        // Assert returns.
        assert!(base_trade_r  == base_taker, 0);
        assert!(quote_trade_r == quote_trade, 0);
        assert!(fee_r         == fee, 0);
        // Get fields for maker order on book.
        let (size_r, user_r, custodian_id_r, order_access_key) =
            get_order_fields_test(
                MARKET_ID_GENERIC, side_maker, market_order_id_0);
        // Assert field returns except access key, used for user lookup.
        assert!(size_r == size_maker - size_taker, 0);
        assert!(user_r == @user_0, 0);
        assert!(custodian_id_r == NO_CUSTODIAN, 0);
        // Assert user-side order fields.
        let (market_order_id_r, size_r) = user::get_order_fields_simple_test(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN, side_maker,
            order_access_key);
        assert!(market_order_id_r == market_order_id_0, 0);
        assert!(size_r            == size_maker - size_taker, 0);
        // Assert maker's asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_internal(
                @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN);
        assert!(base_total      == base_total_maker, 0);
        assert!(base_available  == base_available_maker, 0);
        assert!(base_ceiling    == base_ceiling_maker, 0);
        assert!(quote_total     == quote_total_maker, 0);
        assert!(quote_available == quote_available_maker, 0);
        assert!(quote_ceiling   == quote_ceiling_maker, 0);
        // Assert collateral amount.
        assert!(user::get_collateral_value_simple_test<QC>(
            @user_0, MARKET_ID_GENERIC, NO_CUSTODIAN) == quote_total_maker, 0);
        // Assert taker's asset counts.
        assert!(coin::value<QC>(&quote_coins) == quote_total_taker, 0);
        // Burn coins.
        if (quote_total_taker == 0) coin::destroy_zero(quote_coins) else
            assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for invalid base type.
    fun test_swap_invalid_base()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Define swap parameters.
        let market_id = MARKET_ID_COIN;
        let integrator = @integrator;
        let direction = BUY;
        let min_base = 0;
        let max_base = LOT_SIZE_COIN;
        let min_quote = 0;
        let max_quote = TICK_SIZE_COIN;
        let limit_price = 1;
        let base_coins = coin::zero();
        let quote_coins = assets::mint_test(max_quote);
        // Attempt invalid invocation.
        let (base_coins, quote_coins, _, _, _) = swap_coins<QC, QC>(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        assets::burn(base_coins);
        assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid market ID.
    fun test_swap_invalid_market_id()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Define swap parameters.
        let market_id = HI_64;
        let integrator = @integrator;
        let direction = BUY;
        let min_base = 0;
        let max_base = LOT_SIZE_COIN;
        let min_quote = 0;
        let max_quote = TICK_SIZE_COIN;
        let limit_price = 1;
        let base_coins = coin::zero();
        let quote_coins = assets::mint_test(max_quote);
        // Attempt invalid invocation.
        let (base_coins, quote_coins, _, _, _) = swap_coins<BC, QC>(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        assets::burn(base_coins);
        assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for invalid quote type.
    fun test_swap_invalid_quote()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Define swap parameters.
        let market_id = MARKET_ID_COIN;
        let integrator = @integrator;
        let direction = BUY;
        let min_base = 0;
        let max_base = LOT_SIZE_COIN;
        let min_quote = 0;
        let max_quote = TICK_SIZE_COIN;
        let limit_price = 1;
        let base_coins = coin::zero();
        let quote_coins = assets::mint_test(max_quote);
        // Attempt invalid invocation.
        let (base_coins, quote_coins, _, _, _) = swap_coins<BC, BC>(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, base_coins, quote_coins);
        // Burn coins.
        assets::burn(base_coins);
        assets::burn(quote_coins);
    }

    #[test]
    #[expected_failure(abort_code = 21)]
    /// Verify failure for invalid underwriter.
    fun test_swap_invalid_underwriter()
    acquires OrderBooks {
        // Initialize markets, users, and an integrator.
        init_markets_users_integrator_test();
        // Define swap parameters.
        let market_id = MARKET_ID_GENERIC;
        let integrator = @integrator;
        let direction = BUY;
        let min_base = 0;
        let max_base = LOT_SIZE_GENERIC;
        let min_quote = 0;
        let max_quote = TICK_SIZE_GENERIC;
        let limit_price = 1;
        let quote_coins = assets::mint_test(max_quote);
        let underwriter_capability = registry::get_underwriter_capability_test(
                HI_64); // Get invalid market underwriter capability.
        // Attempt invalid invocation.
        let (quote_coins, _, _, _) = swap_generic<QC>(
            market_id, integrator, direction, min_base, max_base, min_quote,
            max_quote, limit_price, quote_coins, &underwriter_capability);
        // Burn coins.
        assets::burn(quote_coins);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}