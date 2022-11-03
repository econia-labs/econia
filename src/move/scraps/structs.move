/// Data structure planning for core modules
module econia::structs {

    // market.move >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    // market.move <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}