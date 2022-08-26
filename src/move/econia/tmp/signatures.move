// Matching engine function signature planning
module econia::signatures {

    fun swap<
        BaseType,
        QuoteType
    >(
        host: address,
        market_id: u64,
        direction: bool, // BUY or SELL
        min_lots: u64, // Abort if unable to fill
        max_lots: u64, // Return before exceeding
        min_ticks: u64, // Abort if unable to fill
        max_ticks: u64, // Return before exceeding
        limit_price: u64, // Can rail to 0 or HI_64
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>
    ) {
        // Input coins over to match()
    }

    fun match<
        BaseType,
        QuoteType
    >(
        order_book_ref_mut: &mut OrderBook,
        lot_size: u64,
        tick_size: bool,
        direction: bool, // BUY or SELL
        min_lots: u64, // Abort if unable to fill
        max_lots: u64, // Return before exceeding
        min_ticks: u64, // Abort if unable to fill
        max_ticks: u64, // Return before exceeding
        limit_price: u64, // Can rail to 0 or HI_64
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>,
    ): (
        u64, // Lots unfilled
        u64 // Ticks unfilled
    ) {
        // Init to max amounts
        let (lots_until_max, ticks_until_max) = (max_lots, max_ticks);
        // Init to 0
        let (lots_filled, ticks_filled) = (0, 0);
        // Could just return max_lots - lots-filled at end
    }


    fun place_limit_order<
        BaseType,
        QuoteType
    >(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool, // Maker only
        fill_or_abort: bool, // Passes size as min_lots
        immediate_or_cancel: bool // Return after match(), taker only
    ) acquires OrderBooks {
        // When calling match, calculate max_lots and max_ticks to
        // exhaust at same time, then just inspect size_unfilled upon return
    }

    fun match_from_market_account<
        BaseType,
        QuoteType
    >(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        direction: bool, // BUY or SELL
        min_lots: u64, // Abort if unable to fill
        max_lots: u64, // Return before exceeding
        min_ticks: u64, // Abort if unable to fill
        max_ticks: u64, // Return before exceeding
        limit_price: u64, // Can rail to 0 or HI_64
    ) acquires OrderBooks {

    }

    fun place_market_order<
        BaseType,
        QuoteType
    >(
        user: address,
        host: address,
        market_id: u64,
        general_custodian_id: u64,
        direction: bool, // BUY or SELL
        min_lots: u64, // Abort if unable to fill
        max_lots: u64, // Return before exceeding
        min_ticks: u64, // Abort if unable to fill
        max_ticks: u64, // Return before exceeding
        limit_price: u64, // Can rail to 0 or HI_64
    ) acquires OrderBooks {

    }

}

