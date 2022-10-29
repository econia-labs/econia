/// Data structure planning for core modules
module econia::structs {

    // user.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    struct Collateral<phantom CoinType> has key {
        map: Tablist<u128, Coin<CoinType>>
    }

    struct MarketAccount has store {
        base_type: TypeInfo,
        base_name_generic: String,
        quote_type: TypeInfo,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_id: u64
        asks: Tablist<u64, OpenOrder>,
        asks_stack_top: u64,
        bids: Tablist<u64, OpenOrder>,
        bids_stack_top: u64,
        base_total: u64,
        base_available: u64,
        base_ceiling: u64,
        quote_total: u64,
        quote_available: u64,
        quote_ceiling: u64
    }

    struct MarketAccounts has key {
        map: Table<u128, MarketAccount>,
        /// Map from market ID to vector of custodian IDs registered.
        custodians: Tablist<u64, vector<u64>>
    }

    struct OpenOrder has store {
        market_order_id: u128,
        /// When inactive, next order access key in inactive stack.
        size: u64
    }

    // user.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // market.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    struct MakerEvent has drop, store {
        market_id: u64
        side: bool
        order_id: u128,
        maker: address,
        custodian_id: u64
        /// `ADD`, `CHANGE`, `CANCEL`
        type: u8
        size_delta: u64,
    }

    struct Order has store {
        size: u64,
        user: address,
        custodian_id: u64
        order_access_key: u64
    }

    struct OrderBook has store {
        base_type: TypeInfo,
        base_name_generic: String,
        quote_type: TypeInfo,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_id: u64,
        asks: AVLqueue<Order>,
        bids: CritQueue<Order>,
        /// Concatenate with AVLqueue access key for market order ID.
        n_orders: u64,
        maker_events: EventHandle<MakerAddEvent>,
        taker_events: EventHandle<TakerEvent>,
    }

    struct OrderBooks has key {
        map: TableList<u64, OrderBook>
    }

    struct TakerEvent has drop, store {
        market_id: u64
        side: bool
        order_id: u128,
        maker: address,
        /// Of maker
        custodian_id: u64
        size: u64
    }

    // market.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}