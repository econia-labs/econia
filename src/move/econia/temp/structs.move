/// Data structure planning for core modules
module econia::structs {

    // registry.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian capability required to approve assorted operations,
    /// administered to third-party registrants who may store it as they
    /// wish.
    struct CustodianCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as a
        /// custodian.
        custodian_id: u64
    }

    /// Emitted when a custodian is registered.
    struct CustodianRegistrationEvent has drop, store {
        /// ID of custodian just registered.
        custodian_id: u64
    }

    /// Type flag for generic asset, provided for ease of generic market
    /// registration: market registrants do not need to declare or
    /// identify a novel type prior to registering a market, and can
    /// instead simply indicate `GenericAsset`.
    struct GenericAsset{}

    /// Information about a market.
    struct MarketInfo has copy, drop, store {
        /// Base asset type info. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`), and
        /// `generic_asset_transfer_custodian_id` is marked
        /// `PURE_COIN_PAIR`. When base asset is a generic asset, can be
        /// any type info, including that of an
        /// `aptos_framework::coin::Coin` phantom `CoinType` (e.g. to
        /// denote that the generic asset is a derivative of the
        /// indicated coin type), and
        /// `generic_asset_transfer_custodian_id` is not marked
        /// `PURE_COIN_PAIR`. `GenericAsset` type flag provided above
        /// for ease of generic asset market registration, such
        /// that market registrants do not need to declare or identify a
        /// novel type prior to registering a market, and can instead
        /// simply indicate `GenericAsset`.
        base_type_info: type_info::TypeInfo,
        /// Quote asset coin type info. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        lot_size: u64,
        /// Number of quote coin units exchanged per tick (corresponds
        /// to `aptos_framework::coin::Coin.value`).
        tick_size: u64,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins. A
        /// market-wide custodian ID that only applies to markets having
        /// a generic base asset. Marked `PURE_COIN_PAIR` when base and
        /// quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
        /// `PURE_COIN_PAIR` when base and quote types are both coins,
        /// otherwise the serial ID of the corresponding market. Used to
        /// disambiguate between markets having identical values for all
        /// of the above fields, without which such markets would
        /// collide as key entries in `Registry.markets`.
        agnostic_disambiguator: u64,
    }

    /// Emitted when a market is registered.
    struct MarketRegistrationEvent has drop, store {
        /// Market ID of the market just registered.
        market_id: u64,
        /// Base asset type info.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info.
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins.
        /// `PURE_COIN_PAIR` when base and quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
        /// `PURE_COIN_PAIR` when base and quote types are both coins,
        /// otherwise the serial ID of the corresponding market.
        agnostic_disambiguator: u64
    }

    /// Global registration information.
    struct Registry has key {
        /// Map from `MarketInfo` to corresponding market ID, enabling
        /// duplicate checks on pure-coin markets and iterated indexing.
        markets: iterable_table::IterableTable<TradingPairInfo, u64>,
        /// Event handle for market registration events.
        market_registration_events: EventHandle<MarketRegistrationEvent>,
        /// Number of registered custodians.
        n_custodians: u64,
        /// Event handle for custodian registration events.
        custodian_registration_events: EventHandle<CustodianRegistrationEvent>
    }

    // registry.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // user.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Collateral map for given coin type, across all `MarketAccount`s.
    struct Collateral<phantom CoinType> has key {
        /// Map from market account ID to coins held as collateral for
        /// given `MarketAccount`. Separated into different table
        /// entries to reduce transaction collisions across markets,
        /// with iterated indexing support.
        map: iterable_table::IterableTable<u128, Coin<CoinType>>
    }

    /// Represents a user's open orders and available assets for a given
    /// market account ID.
    struct MarketAccount has store {
        /// Base asset type info. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`), and
        /// `generic_asset_transfer_custodian_id` is marked
        /// `PURE_COIN_PAIR`. When base asset is a generic asset, can be
        /// any type info, including that of an
        /// `aptos_framework::coin::Coin` phantom `CoinType` (e.g. to
        /// denote that the generic asset is a derivative of the
        /// indicated coin type), and
        /// `generic_asset_transfer_custodian_id` is not marked
        /// `PURE_COIN_PAIR`.
        base_type_info: type_info::TypeInfo,
        /// Quote asset coin type info. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type_info: type_info::TypeInfo,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins. A
        /// market-wide custodian ID that only applies to markets having
        /// a generic base asset. Marked `PURE_COIN_PAIR` when base and
        /// quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill.
        asks: CritBitTree<u64>,
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill.
        bids: CritBitTree<u64>,
        /// Total base asset units held as collateral (when base asset
        /// is a coin, corresponds to
        /// `aptos_framework::coin::Coin.value`).
        base_total: u64,
        /// Base asset units available for withdraw (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        base_available: u64,
        /// Amount `base_total` will increase to if all open bids fill
        /// (when base asset is a coin, corresponds to
        /// `aptos_framework::coin::Coin.value`).
        base_ceiling: u64,
        /// Total quote asset units held as collateral (corresponds to
        /// `aptos_framework::coin::Coin.value`).
        quote_total: u64,
        /// Quote asset units available for withdraw (corresponds to
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
        map: iterable_table::IterableTable<u128, MarketAccount>,
        /// Event handle for registration events.
        registration_events: EventHandle<MarketAccountRegistrationEvent>
    }

    // user.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // market.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Emitted when a maker order is placed or cancelled.
    struct MakerEvent has drop, store {
        /// `CANCEL` or `PLACE`.
        type: bool,
        /// `ASK` or `BID`.
        side: bool,
        /// Size, in lots, of the order at the time of placement or
        /// cancellation.
        size: u64,
        /// Price of order, in ticks per lot.
        price: u64,
        /// `OrderBook.counter` for corresponding order, which
        /// determines priority among orders with the same `price`.
        counter: u64,
        /// Address of corresponding user.
        user: address,
        /// For given `user`, ID of the custodian required to approve
        /// order placement, order cancellation, and coin withdrawals.
        general_custodian_id: u64
    }

    /// An order on the order book.
    struct Order has store {
        /// Number of lots to be filled.
        size: u64,
        /// Address of corresponding user.
        user: address,
        /// For given user, the ID of the custodian required to approve
        /// orders, order cancellations, and coin withdrawals.
        general_custodian_id: u64
    }

    /// An order book for a given market.
    struct OrderBook has store {
        /// Base asset type info. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`), and
        /// `generic_asset_transfer_custodian_id` is marked
        /// `PURE_COIN_PAIR`. When base asset is a generic asset, can be
        /// any type info, including that of an
        /// `aptos_framework::coin::Coin` phantom `CoinType` (e.g. to
        /// denote that the generic asset is a derivative of the
        /// indicated coin type), and
        /// `generic_asset_transfer_custodian_id` is not marked
        /// `PURE_COIN_PAIR`.
        base_type_info: type_info::TypeInfo,
        /// Quote asset coin type info. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins. A
        /// market-wide custodian ID that only applies to markets having
        /// a generic base asset. Marked `PURE_COIN_PAIR` when base and
        /// quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
        /// Asks tree.
        asks: CritBitTree<Order>,
        /// Bids tree.
        bids: CritBitTree<Order>,
        /// Order ID of minimum ask, per price-time priority. The ask
        /// side "spread maker".
        min_ask: u128,
        /// Order ID of maximum bid, per price-time priority. The bid
        /// side "spread maker".
        max_bid: u128,
        /// Number of maker orders placed on book.
        counter: u64
        /// Event handle for maker events.
        maker_events: EventHandle<MakerEvent>,
        /// Event handle for taker events.
        taker_events: EventHandle<TakerEvent>
    }

    /// Order book map for all `OrderBook`s
    struct OrderBooks has key {
        /// Map from market ID to `OrderBook`. Separated into different
        /// table entries to reduce transaction collisions across
        /// markets, with iterated indexing support.
        map: iterable_table::IterableTable<u64, OrderBook>
    }

    /// Emitted when a taker order fills against the book. If a taker
    /// order fills against multiple orders, an event is emitted for
    /// each one.
    struct TakerEvent has drop, store {
        /// `BUY` or `SELL`, the direction of the taker order.
        direction: bool,
        /// Fill size, in lots.
        size: u64,
        /// Price of order filled against, in ticks per lot.
        price: u64,
        /// `OrderBook.counter` for corresponding order, which
        /// determines priority among orders with the same `price`.
        counter: u64
        /// Address of user holding maker order just filled against.
        user: address,
        /// For given `user`, ID of the custodian required to approve
        /// order placement, order cancellation, and coin withdrawals.
        general_custodian_id: u64
    }

    // market.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}