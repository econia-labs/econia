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
    /// Minimum base asset trade amount not met.
    const E_MIN_BASE_NOT_TRADED: u64 = 9;
    /// Minimum quote coin trade amount not met.
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
    /// Underwriter is not valid for indicated market.
    const E_INVALID_UNDERWRITER: u64 = 21;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending AVL queue flag, for asks AVL queue.
    const ASCENDING: bool = true;
    /// Flag for ask side. Equal to `BUY`, since taker buys fill against
    /// maker asks.
    const ASK: bool = true;
    /// Flag for bid side. Equal to `SELL` since taker sells fill
    /// against maker bids.
    const BID: bool = false;
    /// Flag for buy direction. Equal to `ASK`, since taker buys fill
    /// against maker asks.
    const BUY: bool = true;
    /// Flag for `MakerEvent.type` when order is cancelled.
    const CANCEL: u8 = 0;
    /// Flag for `MakerEvent.type` when order size is changed.
    const CHANGE: u8 = 1;
    /// Critical tree height above which evictions may take place.
    const CRITICAL_HEIGHT: u8 = 9;
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
    /// Flag for maximum base/quote amount to trade max possible.
    const MAX_POSSIBLE: u64 = 0;
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
    /// Flag for sell direction. Equal to `BID`, since taker sells fill
    /// against maker bids.
    const SELL: bool = false;
    /// Number of bits maker order counter is shifted in a market order
    /// ID.
    const SHIFT_COUNTER: u8 = 64;
    /// Taker address flag for when taker is unknown.
    const UNKNOWN_TAKER: address = @0x0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Public entry function wrapper for `place_limit_order_user()`.
    public entry fun place_limit_order_user_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64, // In lots
        price: u64, // In ticks per lot
        restriction: u8,
    ) acquires OrderBooks {
        place_limit_order_user<BaseType, QuoteType>(
            user, market_id, integrator, side, size, price, restriction);
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
    public entry fun swap_between_coinstores_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64, // Can be MAX_POSSIBLE.
        min_quote: u64,
        max_quote: u64, // Can be MAX_POSSIBLE.
        limit_price: u64
    ) acquires OrderBooks {
        swap_between_coinstores<BaseType, QuoteType>(
            user, market_id, integrator, direction, min_base, max_base,
            min_quote, max_quote, limit_price);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    public fun place_limit_order_custodian<
        BaseType,
        QuoteType
    >(
        user_address: address,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64, // In lots
        price: u64, // In ticks per lot
        restriction: u8,
        custodian_capability_ref: &CustodianCapability
    ): (
        u128, // Market order ID, if any.
        u64, // Base traded by user as a taker, if any.
        u64, // Quote traded by user as a taker, if any.
        u64 // Fees paid as a taker, if any.
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
            CRITICAL_HEIGHT
        )
    }

    public fun place_limit_order_user<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64, // In lots
        price: u64, // In ticks per lot
        restriction: u8,
    ): (
        u128, // Market order ID, if any.
        u64, // Base traded by user as a taker, if any.
        u64, // Quote traded by user as a taker, if any.
        u64 // Fees paid as a taker, if any.
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
            CRITICAL_HEIGHT
        )
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

    public fun swap_between_coinstores<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64, // Can be MAX_POSSIBLE.
        min_quote: u64,
        max_quote: u64, // Can be MAX_POSSIBLE.
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
            (HI_64 - base_value) else (base_value);
        // If max quote to trade flagged as max possible, update it:
        if (max_quote == MAX_POSSIBLE) max_quote = if (direction == BUY)
            // If a buy, max to trade is amount in coin store, else is
            // the amount that could fit in the coin store.
            (quote_value) else (HI_64 - quote_value);
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

    /// # Terminology
    ///
    /// * "Inbound" and "outbound"
    public fun swap_coins<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64, // Ignored if a sell. Can be MAX_POSSIBLE if a buy.
        min_quote: u64,
        max_quote: u64, // Ignored if a buy. Can be MAX_POSSIBLE if a sell.
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
        // If a sell, max base to trade is amount passed in.
        if (direction == SELL) max_base = base_value else
            // Otherwise if a buy and max base amount passed as max
            // possible flag, update to max that can be bought.
            if (max_base == MAX_POSSIBLE) max_base = HI_64 - base_value;
        // If a buy, max quote to trade is amount passed in.
        if (direction == BUY) max_quote = quote_value else
            // Otherwise if a sell and max quote amount passed as max
            // possible flag, update to max that can be received.
            if (max_quote == MAX_POSSIBLE) max_quote = HI_64 - quote_value;
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_value, base_value, quote_value, quote_value);
        // Swap against order book, storing modified coin inputs, base
        // and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
            = swap(market_id, NO_UNDERWRITER, UNKNOWN_TAKER, integrator,
                   direction, min_base, max_base, min_quote, max_quote,
                   limit_price, option::some(base_coins), quote_coins);
        // Unpack base coins from option, return remaining match values.
        (option::destroy_some(optional_base_coins), quote_coins, base_traded,
         quote_traded, fees)
    }

    public fun swap_generic<
        QuoteType
    >(
        market_id: u64,
        integrator: address,
        direction: bool,
        min_base: u64,
        max_base: u64, // Can be MAX posible.
        min_quote: u64,
        max_quote: u64, // Ignored if a buy. Can be MAX_POSSIBLE if a sell.
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
        // If max base to trade flagged as max possible, update it to
        // the max amount that can fit in a u64.
        if (max_base == MAX_POSSIBLE) max_base = HI_64;
        // Effective base value on hand is 0 if buying, else max base to
        // trade if sellf.
        let base_value = if (direction == BUY) 0 else max_base;
        // If a buy, max quote to trade is amount passed in.
        if (direction == BUY) max_quote = quote_value else
            // Otherwise if a sell and max quote amount passed as max
            // possible flag, update to max that can be received.
            if (max_quote == MAX_POSSIBLE) max_quote = HI_64 - quote_value;
        range_check_trade( // Range check trade amounts.
            direction, min_base, max_base, min_quote, max_quote,
            base_value, base_value, quote_value, quote_value);
        // Swap against order book, storing modified quote coin input,
        // base and quote trade amounts, and quote fees paid.
        let (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
            = swap(market_id, underwriter_id, UNKNOWN_TAKER, integrator,
                   direction, min_base, max_base, min_quote, max_quote,
                   limit_price, option::none(), quote_coins);
        // Destroy empty base coin option.
        option::destroy_none<Coin<GenericAsset>>(optional_base_coins);
        // Return quote coins, amount of base traded, amount of quote
        // traded, and quote fees paid.
        (quote_coins, base_traded, quote_traded, fees)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize the order books map upon module publication.
    fun init_module() {
        // Get Econia resource account signer.
        let resource_account = resource_account::get_signer();
        // Initialize order books map under resource account.
        move_to(&resource_account, OrderBooks{map: tablist::new()})
    }

    /// # Type Parameters
    ///
    /// # Parameters
    ///
    /// # Emits
    ///
    /// # Aborts
    ///
    /// # Returns
    ///
    /// Taker address may be passed as `UNKNOWN_TAKER` when a
    /// swap from a coin on hand or generic swap.
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
        u64, // Base traded by taker.
        u64, // Quote traded by taker.
        u64 // Fees paid
    ) {
        // Assert price is not too high.
        assert!(limit_price <= MAX_PRICE, E_PRICE_TOO_HIGH);
        let side = direction; // Get corresponding side bool flag.
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
        let market_order_id; // Declare market order ID, assigned later.
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
        let quote_traded = if (direction == BUY) quote_fill + fees_paid
            else quote_fill - fees_paid;
        // Assert minimum base asset trade amount met.
        assert!(base_fill >= min_base, E_MIN_BASE_NOT_TRADED);
        // Assert minimum quote coin trade amount met.
        assert!(quote_traded >= min_quote, E_MIN_QUOTE_NOT_TRADED);
        (optional_base_coins, quote_coins, base_fill, quote_traded, fees_paid)
    }

    fun place_limit_order<
        BaseType,
        QuoteType,
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        integrator: address,
        side: bool,
        size: u64, // In lots
        price: u64, // In ticks per lot
        restriction: u8,
        critical_height: u8
    ): (
        u128, // Market order ID, if any.
        u64, // Base traded by user as a taker, if any.
        u64, // Quote traded by user as a taker, if any.
        u64 // Fees paid as a taker, if any.
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
        // Assert order does not cross spread if post-or-abort.
        assert!(!((restriction == POST_OR_ABORT) && crosses_spread),
                E_POST_OR_ABORT_CROSSES_SPREAD);
        // Calculate base asset amount corresponding to size in lots.
        let base = (size as u128) * (order_book_ref_mut.lot_size as u128);
        // Assert corresponding base asset amount fits in a u64.
        assert!(base <= (HI_64 as u128), E_SIZE_BASE_OVERFLOW);
        // Calculate tick amount corresonding to size in lots.
        let ticks = (size as u128) * (price as u128);
        // Assert corresponding tick amount fits in a u64.
        assert!(ticks <= (HI_64 as u128), E_SIZE_PRICE_TICKS_OVERFLOW);
        // Calculate amount of quote required to fill size at price.
        let quote = ticks * (order_book_ref_mut.tick_size as u128);
        // Assert corresponding quote amount fits in a u64.
        assert!(quote <= (HI_64 as u128), E_SIZE_PRICE_QUOTE_OVERFLOW);
        // Max base to trade during taker match against book is
        // calculated amount.
        let max_base = (base as u64);
        // Min base to trade during taker match against book is
        // calculated amount if a fill-or-abort order, otherwise there
        // is no minimum.
        let min_base = if (restriction == FILL_OR_ABORT) (base as u64) else 0;
        let min_quote = 0; // Not need min quote since have min base.
        // If an ask that crosses the spread, max quote to trade during
        // taker match is max amount that can fit in market account.
        let max_quote = if (ASK && crosses_spread) (HI_64 - quote_ceiling) else
            (quote as u64); // Else is amount from size and price.
        // If order side is bid, fills across spread against asks as a
        // taker buy, else against bids as a taker sell.
        let direction = if (side == BID) BUY else SELL;
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
                    direction, min_base, max_base, min_quote, max_quote, price,
                    optional_base_coins, quote_coins);
        // Calculate amount of base deposited back to market account.
        let base_deposit = if (direction == BUY) base_traded else
            base_withdraw - base_traded;
        // Deposit assets back to user's market account.
        user::deposit_assets_internal<BaseType, QuoteType>(
            user_address, market_id, custodian_id, base_deposit,
            optional_base_coins, quote_coins, underwriter_id);
        // Return without market order ID if no size left as a maker.
        if ((restriction == IMMEDIATE_OR_CANCEL) || (base_traded == min_base))
            return ((NIL as u128), base_traded, quote_traded, fees);
        // Update size to amount left to fill after matching as taker.
        size = size - (base_traded / order_book_ref_mut.lot_size);
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
        max_base: u64, // Pass as MAX_POSSIBLE to trade max possible.
        min_quote: u64,
        max_quote: u64, // Pass as MAX_POSSIBLE to trade max possible.
        limit_price: u64,
    ): (
        u64, // Base traded by user.
        u64, // Quote traded by user.
        u64 // Fees paid
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
            (HI_64 - base_ceiling) else (base_available);
        // If max quote to trade flagged as max possible and a buy,
        // update to max amount that can spend. If a sell, update
        // to max amount that can receive when selling.
        if (max_quote == MAX_POSSIBLE) max_base = if (direction == BUY)
            (quote_available) else (HI_64 - quote_ceiling);
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
            base_withdraw - base_traded;
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
    /// * "Inbound asset" is asset received by taker during a match:
    ///   base if a buy (filling against asks), quote if a sell (filling
    ///   against bids).
    /// * "Outbound asset" is asset traded away by taker during a match:
    ///   quote if a buy (filling against asks), base if a sell (filling
    ///   against bids).
    /// * "Available asset" is the amount the taker already has on hand
    ///   for either base or quote (`user::MarketAccount.base_available`
    ///   or `user::MarketAccount.quote_available` when matching from a
    ///   taker's market account).
    /// * "Asset ceiling" is the amount that the available asset amount
    ///   could increase to beyond its present amount, even if the
    ///   indicated match were not filled. When matching from a taker's
    ///   market account, corresponds to either
    ///   `user::MarketAccount.base_ceiling` or
    ///   `user::MarketAccount.quote_ceiling`. When matching from a
    ///   taker's `aptos_framework::coin::CoinStore` or from standalone
    ///   assets, is the same as the available amount.
    ///
    /// # Parameters
    ///
    /// * `side`: `ASK` or `SELL`, the side against which a taker order
    ///   would match.
    /// * `min_base`: Minimum number of base units to trade.
    /// * `max_base`: Maximum number of base units to trade.
    /// * `min_quote`: Minimum number of quote units to trade.
    /// * `max_quote`: Maximum number of quote units to trade.
    /// * `base_available`: Taker's available base asset amount.
    /// * `base_ceiling`: Taker's base asset ceiling, only checked when
    ///   `SIDE` is `ASK` (a taker buy).
    /// * `quote_available`: Taker's available quote asset amount.
    /// * `quote_ceiling`: Taker's quote asset ceiling, only checked
    ///   when `SIDE` is `BID` (a taker sell).
    ///
    /// # Aborts
    ///
    /// * `E_MAX_BASE_0`: Maximum base trade amount specified as 0.
    /// * `E_MAX_QUOTE_0`: Maximum quote trade amount specified as 0.
    /// * `E_MIN_BASE_EXCEEDS_MAX`: Minimum base trade amount is larger
    ///   than maximum base trade amount.
    /// * `E_MIN_QUOTE_EXCEEDS_MAX`: Minimum quote trade amount is
    ///   larger than maximum quote tade amount.
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
        side: bool,
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
        // asset available and max trade amount. If buying (asks side):
        let (in_ceiling, in_max, out_available, out_max) = if (side == ASK)
            // A market buy, so getting base and trading away quote.
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

    fun swap<
        BaseType,
        QuoteType
    >(
        market_id: u64,
        underwriter_id: u64, // Pass NO_UNDERWRITER if no check needed
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

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize module for testing.
    public fun init_test() {
        // Init registry, storing Econia account signer.
        registry::init_test();
        init_module(); // Init module.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Custodian ID for market with delegated custodian.
    const CUSTODIAN_ID: u64 = 123;
    #[test_only]
    /// Market ID for pure coin test market.
    const MARKET_ID_COIN: u64 = 1;
    #[test_only]
    /// Market ID for generic test market.
    const MARKET_ID_GENERIC: u64 = 2;
    #[test_only]
    /// Underwriter ID for generic test market.
    const UNDERWRITER_ID: u64 = 321;

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
    #[test_only]
    /// Underwriter ID for generic test market.
    const UNDERWRITER_ID_GENERIC: u64 = 7;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for overflowing asset in for a buy.
    fun test_range_check_trade_asset_in_buy() {
        // Declare inputs.
        let side = BUY;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for overflowing asset in for a sell.
    fun test_range_check_trade_asset_in_sell() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for underflowing asset out for a buy.
    fun test_range_check_trade_asset_out_buy() {
        // Declare inputs.
        let side = BUY;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for underflowing asset out for a sell.
    fun test_range_check_trade_asset_out_sell() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for max base specified as 0.
    fun test_range_check_trade_base_0() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for min base exceeds max
    fun test_range_check_trade_min_base_exceeds_max() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for min quote exceeds max
    fun test_range_check_trade_min_quote_exceeds_max() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for max quote specified as 0.
    fun test_range_check_trade_quote_0() {
        // Declare inputs.
        let side = SELL;
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
            side, min_base, max_base, min_quote, max_quote, base_available,
            base_ceiling, quote_available, quote_ceiling);
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

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}