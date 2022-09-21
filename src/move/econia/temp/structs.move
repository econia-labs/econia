/// Data structure planning for core modules
module econia::structs {

    // registry.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian capability required to approve order placement, order
    /// cancellation, and coin withdrawals. Administered to third-party
    /// registrants who may store it as they wish.
    struct CustodianCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as a
        /// custodian.
        custodian_id: u64
    }

    /// Emitted when a capability is registered.
    struct CapabilityRegistrationEvent has drop, store {
        /// Either `CUSTODIAN` or `UNDERWRITER`, the capability type
        /// just registered.
        capability_type: bool,
        /// ID of capability just registered.
        capability_id: u64
    }

    /// Type flag for generic asset. Must be passed as base asset type
    /// argument for generic market operations.
    struct GenericAsset{}

    /// Information about a market.
    struct MarketInfo has copy, drop, store {
        /// Base asset type name. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`), and
        /// `underwriter_id` is none. Otherwise can be any value, and
        /// `underwriter` is some.
        base_type: String,
        /// Quote asset coin type name. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type: String,
        /// Number of base units exchanged per lot (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        lot_size: u64,
        /// Number of quote coin units exchanged per tick (corresponds
        /// to `aptos_framework::coin::Coin.value`).
        tick_size: u64,
        /// ID of underwriter capability to verify generic asset
        /// amounts. A market-wide ID that only applies to markets
        /// having a generic base asset. None when base and quote types
        /// are both coins.
        underwriter_id: Option<u64>
    }

    /// Emitted when a market is registered.
    struct MarketRegistrationEvent has drop, store {
        /// Market ID of the market just registered.
        market_id: u64,
        /// Base asset type name.
        base_type: String,
        /// Quote asset type name.
        quote_type: String,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of `UnderwriterCapability` required to verify generic
        /// asset amounts. None when base and quote types are both
        /// coins.
        underwriter_id: Option<u64>,
    }

    /// Emitted when a recognized market is added, removed, or updated.
    struct RecognizedMarketEvent has store {
        /// The associated trading pair.
        trading_pair: TradingPair,
        /// The recognized market info for the given trading pair after
        /// an addition or update. None if a removal.
        recognized_market_info: Option<RecognizedMarketInfo>,
    }

    /// Recognized market info for a given trading pair.
    struct RecognizedMarketInfo has store {
        /// Market ID of recognized market.
        market_id: u64,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of underwriter capability required to verify generic
        /// asset amounts. A market-wide ID that only applies to
        /// markets having a generic base asset. None when base and
        /// quote types are both coins.
        underwriter_id: Option<u64>,
    }

    /// Recognized markets for specific trading pairs.
    struct RecognizedMarkets has key {
        /// Map from trading pair info to market information for the
        /// recognized market, if any, for given trading pair.
        map: TableList<TradingPair, RecognizedMarketInfo>,
        /// Event handle for recognized market events.
        recognized_market_event: EventHandle<RecognizedMarketEvent>
    }

    /// Global registration information.
    struct Registry has key {
        /// Map from `MarketInfo` to corresponding market ID, enabling
        /// duplicate checks and iterated indexing.
        markets: TableList<MarketInfo, u64>,
        /// The number of registered custodians.
        n_custodians: u64,
        /// The number of registered underwriters.
        n_underwriters: u64,
        /// Event handle for market registration events.
        market_registration_events: EventHandle<MarketRegistrationEvent>,
        /// Event handle for capability registration events.
        capability_registration_events:
            EventHandle<CapabilityRegistrationEvent>
    }

    /// A combination of a base asset and a quote asset.
    struct TradingPair has store {
        /// Base type name.
        base_type: String,
        /// Quote type name.
        quote_type: String
    }

    /// Underwriter capability required to verify generic asset
    /// amounts. Administered to third-party registrants who may store
    /// it as they wish.
    struct UnderwriterCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as an
        /// underwriter.
        custodian_id: u64
    }

    // registry.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
        /// Base asset units locked up due to open orders (when base
        /// asset is a coin, corresponds
        /// to `aptos_framework::coin::Coin.value`).
        base_locked: u64,
        /// Amount `base_total` will increase to if all open bids fill
        /// (when base asset is a coin, corresponds to
        /// `aptos_framework::coin::Coin.value`).
        base_ceiling: u64,
        /// Total quote asset units held as collateral (corresponds to
        /// `aptos_framework::coin::Coin.value`).
        quote_total: u64,
        /// Quote asset units locked up due to open orders (
        /// corresponds to `aptos_framework::coin::Coin.value`).
        quote_locked: u64,
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

    /// Emitted when a maker order is added to or removed from the order
    /// book.
    struct MakerEvent has drop, store {
        /// `ADD` or `REMOVE`.
        type: bool,
        /// Order ID, containing encoded price, side, and insertion
        /// count for the given price level.
        order_id: u128,
        /// Size, in lots, of the order at the time of placement or
        /// cancellation.
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
        /// Event handle for ask events.
        ask_events: EventHandle<MakerEvent>,
        /// Event handle for bid events.
        bid_events: EventHandle<MakerEvent>,
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