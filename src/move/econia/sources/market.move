module econia::market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::event::EventHandle;
    use aptos_framework::type_info::TypeInfo;
    use econia::avl_queue::AVLqueue;
    use econia::tablist::{Self, Tablist};
    use std::string::String;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::registry;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Emitted when a maker order is placed, cancelled, or its size is
    /// manually changed.
    struct MakerEvent has drop, store {
        /// Market ID of corresponding market.
        market_id: u64,
        /// `ASK` or `BID`, the side of the maker order.
        side: bool,
        /// Order ID, unique to given market.
        order_id: u128,
        /// Address of user holding maker order.
        user: address,
        /// For given maker, ID of custodian required to approve order
        /// operations and withdrawals on given market account.
        custodian_id: u64,
        /// `CANCEL`, `CHANGE`, or `PLACE`, the maker operation.
        type: u8,
        /// The size, in lots, on the book after an order has been
        /// placed or its size has been manually changed. Else the size
        /// on the book before the order was cancelled.
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
        /// Order ID, unique to given market, of maker order just filled
        /// against.
        order_id: u128,
        /// Address of user holding maker order.
        maker: address,
        /// For given maker, ID of custodian required to approve order
        /// operations and withdrawals on given market account.
        custodian_id: u64,
        /// The size filled, in lots.
        size: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Maximum possible price that can be encoded in 32 bits. Generated
    /// in Python via `hex(int('1' * 32, 2))`.
    const MAX_PRICE: u64 = 0xffffffff;
    /// Flag for ask side
    const ASK: bool = true;
    /// Flag for bid side
    const BID: bool = false;
    /// Flag for `MakerEvent.type` when order is cancelled.
    const CANCEL: u8 = 0;
    /// Flag for `MakerEvent.type` when order size is changed.
    const CHANGE: u8 = 1;
    /// Flag for `MakerEvent.type` when order is placed.
    const PLACE: u8 = 2;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize the order books map upon module publication.
    fun init_module(
        econia: &signer
    ) {
        // Initialize order books map.
        move_to(econia, OrderBooks{map: tablist::new()})
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize module for testing.
    public fun init_test() {
        // Init registry, storing Econia account signer.
        let econia = registry::init_test();
        init_module(&econia); // Init module.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}