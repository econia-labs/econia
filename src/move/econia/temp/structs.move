/// Data structure planning for core modules
module econia::structs {

    // user.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Collateral map for given coin type, across all `MarketAccount`s.
    struct Collateral<phantom CoinType> has key {
        /// Map from market account ID to coins held as collateral for
        /// given `MarketAccount`. Separated into different table
        /// entries to reduce transaction collisions across markets,
        /// with iterated indexing support.
        map: TableList<u128, Coin<CoinType>>
    }

    /// Represents a user's open orders and available assets for a given
    /// market account ID.
    struct MarketAccount has store {
        /// Should match registry.
        base_type: String,
        /// Should match registry.
        quote_type: String,
        /// ID of underwriter capability required to verify generic
        /// asset amounts. A market-wide ID that only applies to
        /// markets having a generic base asset. None when base and
        /// quote types are both coins.
        underwriter_id: Option<u64>,
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill.
        asks: TableList<u128, u64>,
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill.
        bids: TableList<u128, u64>,
        /// Total base asset units held as collateral (when base asset
        /// is a coin, corresponds to
        /// `aptos_framework::coin::Coin.value`).
        base_total: u64,
        /// Base asset units available to withdraw (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        base_available: u64,
        /// Amount `base_total` will increase to if all open bids fill
        /// (when base asset is a coin, corresponds to
        /// `aptos_framework::coin::Coin.value`).
        base_ceiling: u64,
        /// Total quote asset units held as collateral (corresponds to
        /// `aptos_framework::coin::Coin.value`).
        quote_total: u64,
        /// Quote asset units available to withdraw (corresponds to
        /// `aptos_framework::coin::Coin.value`).
        quote_available: u64,
        /// Amount `quote_total` will increase to if all open asks fill
        /// (corresponds to `aptos_framework::coin::Coin.value`).
        quote_ceiling: u64
    }

    /// Event emitted when user registers a `MarketAccount`.
    struct MarketAccountRegistrationEvent has drop, store {
        /// Market account ID of `MarketAccount` just registered.
        market_account_id: u128
    }

    /// Market account map for all of a user's `MarketAccount`s.
    struct MarketAccounts has key {
        /// Map from market account ID to `MarketAccount`. Separated
        /// into different table entries to reduce transaction
        /// collisions across markets, with iterated indexing support.
        map: TableList<u128, MarketAccount>,
        /// Event handle for registration events.
        registration_events: EventHandle<MarketAccountRegistrationEvent>
    }

    // user.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // market.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Emitted when a maker order is added to the order book.
    struct MakerAddEvent has drop, store {
        /// Order ID, containing encoded price, side, and insertion
        /// count for the given price level.
        order_id: u128,
        /// Size, in lots, of the order at the time of placement.
        size: u64,
        /// Address of corresponding user.
        user: address,
        /// For given `user`, ID of the custodian required to approve
        /// order placement, order cancellation, and coin withdrawals.
        custodian_id: u64
    }

    /// Emitted when a maker order is removed from the order book.
    struct MakerRemoveEvent has drop, store {
        /// Order ID, containing encoded price, side, and insertion
        /// count for the given price level.
        order_id: u128,
        /// Size, in lots, of the order at the time it was removed.
        size: u64,
        /// Address of corresponding user.
        user: address,
        /// For given `user`, ID of the custodian required to approve
        /// order placement, order cancellation, and coin withdrawals.
        custodian_id: u64
    }

    /// An order on the order book.
    struct Order has store {
        /// Number of lots to be filled.
        size: u64,
        /// Address of corresponding user.
        user: address,
        /// For given user, the ID of the custodian required to approve
        /// orders, order cancellations, and coin withdrawals.
        custodian_id: u64
    }

    /// An order book for a given market. Events are separated for asks
    /// and bids, buys and sells, for parallelism across the two sides.
    /// Moreover, since a `CritQueue` offers parallelism across enqueues
    /// and removals, maker events are further parallelized into adds
    /// and removals.
    struct OrderBook has store {
        /// Should match registry.
        base_type: TypeInfo,
        /// Should match registry.
        quote_type: TypeInfo,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of underwriter capability required to verify generic
        /// asset amounts. A market-wide ID that only applies to
        /// markets having a generic base asset. None when base and
        /// quote types are both coins.
        underwriter_id: Option<u64>,
        /// Open asks.
        asks: CritQueue<Order>,
        /// Open bids.
        bids: CritQueue<Order>,
        /// Event handle for ask add events.
        ask_add_events: EventHandle<MakerAddEvent>,
        /// Event handle for ask remove events.
        ask_remove_events: EventHandle<MakerRemoveEvent>,
        /// Event handle for bid add events.
        bid_add_events: EventHandle<MakerAddEvent>,
        /// Event handle for bid remove events.
        bid_remove_events: EventHandle<MakerRemoveEvent>,
        /// Event handle for buy events.
        buy_events: EventHandle<TakerEvent>,
        /// Event handle for sell events.
        sell_events: EventHandle<TakerEvent>
    }

    /// Order book map for all `OrderBook`s.
    struct OrderBooks has key {
        /// Map from market ID to `OrderBook`. Separated into different
        /// table entries to reduce transaction collisions across
        /// markets, with iterated indexing support.
        map: TableList<u64, OrderBook>
    }

    /// Emitted when a taker order fills against the book. If a taker
    /// order fills against multiple orders, an event is emitted for
    /// each one.
    struct TakerEvent has drop, store {
        /// Order ID of the maker order just filled against, containing
        /// its encoded price, side, and insertion count for the given
        /// price level.
        order_id: u128,
        /// Fill size, in lots.
        size: u64,
        /// Address of user holding maker order just filled against.
        maker: address,
        /// For given `user`, ID of the custodian required to approve
        /// order placement, order cancellation, and coin withdrawals.
        custodian_id: u64
    }

    // market.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}