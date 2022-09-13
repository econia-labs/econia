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

    /// Emitted when a maker order is added to or cancelled from an
    /// `OrderBook`.
    struct MakerEvent has drop, store {
        /// `CANCEL` or `PLACE`.
        type: bool,
        /// `ASK` or `BID`.
        side: bool,
        /// Size, in lots, of the order at the time of cancellation or
        /// placement.
        size: u64,
        /// Price, in ticks per lot, of the order.
        price: u64
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
        /// `ASK` or `BID`, the side of the maker order that was filled
        /// against.
        side: bool,
        /// Fill size, in lots.
        size: u64
        /// Price, in ticks per lot, of the order filled against.
        price: u64
    }

    // market.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // incentives.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Container for taker fees not claimed by an integrator, which are
    /// reserved for Econia.
    struct EconiaFeeStore<QuoteCoinType> has key {
        /// Map from market ID to fees collected for given market,
        /// enabling duplicate checks and interable indexing.
        map: iterable_table::IterableTable<u64, Coin<QuoteCoinType>>
    }

    /// Incentive parameters for assorted operations.
    struct IncentiveParameters has key {
        /// Utility coin type info. Corresponds to a phantom `CoinType`
        /// (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`) for
        /// the coin required for utility purposes. Set to `APT` at
        /// mainnet launch, later the Econia coin.
        utility_coin_type_info: type_info::TypeInfo,
        /// `Coin.value` required to register a market.
        market_registration_fee: u64,
        /// `Coin.value` required to register as a custodian.
        custodian_registration_fee: u64,
        /// 0-indexed list from tier number to corresponding parameters.
        integrator_fee_store_tiers: vector<IntegratorFeeStoreTierParameters>,
        /// Nominal amount divisor for quote coin fee charged to takers.
        /// For example, if a transaction involves a quote coin fill of
        /// 1000000 units and the taker fee divisor is 2000, takers pay
        /// 1/2000th (0.05%) of the nominal amount (500 quote coin
        /// units) in fees. Instituted as a divisor for optimized
        /// calculations.
        taker_fee_divisor: u64
    }

    /// Fee store for a given integrator, on a given market.
    struct IntegratorFeeStore<QuoteCoinType> has store {
        /// Activation tier, incremented by paying utility coins.
        tier: u8,
        /// Collected fees, in quote coins for given market.
        coins: Coin<QuoteCoinType>
    }

    /// All of an integrator's `IntregratorFeeStore`s for given
    /// `QuoteCoinType`.
    struct IntegratorFeeStores<QuoteCoinType> has key {
        /// Map from market ID to `IntegratorFeeStore`, enabling
        /// duplicate checks and iterable indexing.
        map: iterable_table::IterableTable<
            u64, IntegratorFeeStore<QuoteCoinType>>
    }

    /// Integrator fee store tier parameters for a given tier.
    struct IntegratorFeeStoreTierParameters has store {
        /// Nominal amount divisor for taker quote coin fee reserved for
        /// integrators having activated their fee store to the given
        /// tier. For example, if a transaction involves a quote coin
        /// fill of 1000000 units and the fee share divisor at the given
        /// tier is 4000, integrators get 1/4000th (0.025%) of the
        /// nominal amount (250 quote coin units) in fees at the given
        /// tier. Instituted as a divisor for optimized calculations.
        /// May not be larger than the
        /// `IncentiveParameters.taker_fee_divisor`, since the
        /// integrator fee share is deducted from the taker fee (with
        /// the remaining proceeds going to an `EconiaFeeStore` for the
        /// given market).
        fee_share_divisor: u64,
        /// Cumulative cost, in utility coin units, to activate to the
        /// current tier. For example, if an integrator has already
        /// activated to tier 3, which has a tier activation fee of 1000
        /// units, and tier 4 has a tier activation fee of 10000 units,
        /// the integrator only has to pay 9000 units to activate to
        /// tier 4.
        tier_activation_fee: u64,
        /// Cost, in utility coin units, to withdraw from an integrator
        /// fee store. Shall never be nonzero, since a disincentive is
        /// required to prevent excessively-frequent withdrawals and
        /// thus transaction collisions with the matching engine.
        withdrawal_fee: u64
    }

    /// Container for utility coin fees charged by Econia.
    struct UtilityCoinStore<CoinType> has key {
        /// Coins collected as utility fees.
        utility_coins: Coin<CoinType>
    }

    // incentives.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}