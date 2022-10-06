/// Data structure planning for core modules
module econia::structs {

    // critqueue.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Pure-table

    /// When a node has no edge.
    const NO_TREE_NODE: u8 = 0xff;
    /// When no accessor node indicated.
    const NO_ACCESSOR_NODE: u64 = 0xffff;

    struct Inner has store {
        /// * Bits 0-31 insertion key critical bitmask.
        /// * Bits 32-39 parent key, if any.
        /// * Bits 40-47 left key, if any.
        /// * Bits 48-55 right key, if any.
        /// * Bits 56-63 next inactive inner node key, if any.
        data: u64,
    }

    struct Outer has store {
        /// Key of next inactive outer node, if any.
        next_inactive: u8,
        /// Key of parent inner node, if any.
        parent: u8,
        /// Head accessor key (only needs u16).
        head: u64,
        /// Tail accessor key (only needs u16).
        tail: u64,
        /// Insertion key (only needs u32).
        insertion_key: u64
    }

    /// If parent pointers eliminated, worst case insertion writes to
    /// crit-queue, parent to inner node inserted, inner node inserted,
    /// outer node inserted, accessor inserted, and has to walk from
    /// root.
    /// Best case insertion writes to crit-queue, modified leaf,
    /// sub-queue tail, and sub-queue, after walking from root.
    struct CritQueue<V: drop> has store {
        /// Map from inner key to inner node.
        inners: Table<u8, Inner>,
        /// Map from outer key to outer node.
        outers: Table<u8, Outer>,
        /// Map from accessor key, cast as `u64`, to accessor node.
        accessors: Table<u64, Accessor<V>>,
        /// * 8 MSBs root node key, if any, then
        /// * 32 bits insertion key of head, if any, then
        /// * 16 bits accessor key of head, if any, then
        /// * 32 bits insertion key of tail, if any, then
        /// * 16 bits insertion key of tail, if any.
        edges: u128,
        /// * 16 MSBs number of accessors allocated, then
        /// * 16 bits next inactive accessor key, then
        /// * 8 bits number of inners allocated, then
        /// * 8 bits next inactive inner key, if any, then
        /// * 8 bits number of outers allocated, then
        /// * 8 bits next inactive outer key, if any.
        allocations: u64,
    }

    struct Accessor<V: drop> has store {
        /// * 16 MSBs previous active accessor key, if any, then
        /// * 16 bits next active accessor key, if any, then
        /// * 8 bits parent outer key, if any, then
        /// * 16 bits next inactive accessor key, if any.
        data: u64,
        /// Insertion value from key-value insertion pair.
        insertion_value: V
    }

    // Hybrid vector/table

    struct CritQueue<V: drop> has store {
        inners: vector<Inner>,
        outers: vector<Outers>
        head: u64,
        tail: u64,
        root: u64,
        height: u8,
        direction: bool,
        band_divisor: u8
        next_inactive_accessor: option<u64>
    }


    /// 8 bytes.
    struct Inner has store {
        /// 8 bits critical bit, 24 bits left child ID, 24 bits right
        /// child ID.
        data: u64,
    }

    /// 16 bytes.
    struct Outer has store {
        key: u64,
        //// 24 bits left child ID, 24 bits right child ID.
        head_tail: u64

    }

    /// Pure table pure critbit
    /// Lookup key 128 bits:
    /// 64-bit insertion key, 64-bit sequence number.
    /// Insertion writes to crit-queue, the inner node just inserted,
    /// the outer node just inserted, parent of inner node just
    /// inserted, and needs to walk from root.
    /// Dequeuing writes to crit-queue, inner node removed, parent to
    /// inner node just removed, outer node removed, and needs to walk
    /// from root.
    /// If add parent pointers, need to write one more for each
    /// operation: displaced child or removed leaf sibling.
    /// Hence parent pointers allow potential O(1) lookup, but make
    /// insertion and removal more expensive.
    /// Here, traversal is just adding one or subtracting one to the
    /// start node
    struct CritQueue<V> has store {
        // Node ID to node. Node ID set at bit 63.
        inners: Table<u64, Inner>,
        // Node ID to node. Node ID unset at bit 63.
        outers: Table<u64, Outer>,
        root: Option<u64> // Node ID
        // Insertion key concatenated with node ID, for priority
        // comparison and O(1) node lookup.
        head: Option<u64>,
        // Insertion key concatenated with node ID, for priority
        // comparison and O(1) node lookup.
        tail: Option<u64,
        direction: bool,
        critical_ratio: u64,
        critical_height: u8,
        next_inactive_inner: Option<u64>,
        next_inactive_outer: Option<u64>,
        sequence_number: u64,
    }

    struct Inner has store {
        critical_bit: u8,
        left: u64,
        right: u64,
        next_inactive: u64
    }

    struct Outer<V> has store {
        // Insertion key and optional complement to sequence number.
        access_key: u128,
        value: option<V>,
        next_inactive: u64
    }

    // Insertions

    // With cache

    struct CritQueue<V> has store {
        // Node ID to node. Node ID set at bit 63.
        inners: TableWithLength<u64, Inner>,
        // Node ID to node. Node ID unset at bit 63.
        outers: TableWithLength<u64, Outer>,
        // Tree node ID, if there is one.
        root: Option<u64>
        // Root critical bit, if there is one.
        root_critical_bit: Option<u8>
        // Head access key.
        head: Option<u128>,
        // Tail access key.
        tail: Option<u128>,
        // `ASCENDING` or `DESCENDING`.
        sort_order: bool,
        // ID of last deactivated inner node, if any.
        next_inactive_inner: Option<u64>,
        // ID of last deactivated outer node, if any.
        next_inactive_outer: Option<u64>,
        // Number of insertions.
        insertion_count: u64,
        // Node ID, if any, of leading inner node having critical bit at
        // vector index.
        leading_inners: vector<Option<u64>>
    }

    struct Inner has store {
        critical_bit: u8,
        left: u64,
        right: u64,
        next_inactive: u64
    }

    struct Outer<V> has store {
        // Insertion key and optional complement to sequence number.
        access_key: u128,
        value: option<V>,
        next_inactive: u64
    }

    // critqueue.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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