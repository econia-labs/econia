/// Market-level book keeping functionality, with matching engine.
module econia::market {
    use econia::registry;
    use econia::user;
    fun invoke_registry() {registry::is_registered_custodian_id(0);}
    fun invoke_user() {user::return_0();}

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// An order on the order book
    struct Order has store {
        /// Number of lots to be filled
        size: u64,
        /// Address of corresponding user
        user: address,
        /// For given user, the ID of the custodian required to approve
        /// transactions other than generic asset transfers
        general_custodian_id: u64
    }

    /// An order book for a given market
    struct OrderBook has store {
        /// Base asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to a non-coin asset
        /// indicated by the market host.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds a non-coin asset
        /// indicated by the market host.
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot
        lot_size: u64,
        /// Number of quote units exchanged per lot
        tick_size: u64,
        /// Asks tree
        asks: CritBitTree<Order>,
        /// Bids tree
        bids: CritBitTree<Order>,
        /// Order ID of minimum ask, per price-time priority. The ask
        /// side "spread maker".
        min_ask: u128,
        /// Order ID of maximum bid, per price-time priority. The bid
        /// side "spread maker".
        max_bid: u128,
        /// Number of limit orders placed on book
        counter: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}