// Matching engine function signature planning
module econia::signatures {


    fun match_from_market_account<
        BaseType,
        QuoteType
    >(
        user_ref: &address,
        host_ref: &address,
        market_id_ref: &u64,
        market_account_id_ref: &u128,
        direction_ref: &bool,
        min_base_ref: &u64,
        max_base_ref: &u64,
        min_quote_ref: &u64,
        max_quote_ref: &u64,
        limit_price_ref: &u64,
    ): (
        u64, // Lots filled
        u64 // Ticks filled
    ) acquires OrderBooks {
        // Verify order book exists
        verify_order_book_exists(*host_ref, *market_id_ref);
        // Borrow mutable reference to order books map
        let order_books_map_ref_mut =
            &mut borrow_global_mut<OrderBooks>(*host_ref).map;
        // Borrow mutable reference to order book
        let order_book_ref_mut =
            open_table::borrow_mut(order_books_map_ref_mut, *market_id_ref);
        let lot_size = order_book_ref_mut.lot_size; // Get lot size
        let tick_size = order_book_ref_mut.tick_size; // Get tick size
        // Get user's available and ceiling asset counts
        let (base_available, _, base_ceiling, quote_available, _,
             quote_ceiling) = user::get_asset_counts_internal(*user_ref,
                *market_account_id_ref);
        // Range check fill amounts
        match_range_check_fills(direction_ref, min_base_ref, max_base_ref,
            min_quote_ref, max_quote_ref, &base_available, &base_ceiling,
            &quote_available, &quote_ceiling);
        // Calculate base and quote to withdraw from market account
        let (base_to_withdraw, quote_to_withdraw) = if (direction == BUY)
            // If a buy, buy base with quote, so need max quote on hand
            // If a sell, sell base for quote, so need max base on hand
            (0, *max_quote_ref) else (*max_base_ref, 0);
        // Withdraw base and quote assets from user's market account
        // as optional coins (verifies type arguments)
        let (optional_base_coins, optional_quote_coins) =  (
            user::withdraw_asset_as_option_internal<BaseType>(
                *user, *market_account_id, base_to_withdraw,
                order_book_ref_mut. generic_asset_transfer_custodian_id),
            user::withdraw_asset_as_option_internal<QuoteType>(
                *user, *market_account_id, quote_to_withdraw,
                order_book_ref_mut. generic_asset_transfer_custodian_id),
            );
        // Declare variables to track lots and ticks filled
        let (lots_filled, ticks_filled) = (0, 0);
        // Match against order book
        match<BaseType, QuoteType>(market_id_ref, order_book_ref_mut,
            &lot_size, &tick_size, direction_ref,
            &(*min_base_ref / lot_size), &(*max_base_ref / lot_size),
            &(*min_quote_ref / tick_size), &(*max_quote_ref / tick_size),
            limit_price_ref, optional_base_coins_ref_mut,
            optional_quote_coins_ref_mut, &mut lots_filled, &mut ticks_filled);
        // Need to calculate how many generic to deposit
        if (option::is_some(optional_base_coins)) user::deposit<
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
        size: u64, // Need to assert base units doesn't overflow a u64
        price: u64,
        post_or_abort: bool, // Maker only
        fill_or_abort: bool, // Passes size as min_lots
        immediate_or_cancel: bool // Return after match(), taker only
    ) acquires OrderBooks {
        // When calling match, calculate max_lots and max_ticks to
        // exhaust at same time, then just inspect size_unfilled upon return
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
        min_base: u64, // Abort if unable to fill
        max_base: u64, // Return before exceeding
        min_quote: u64, // Abort if unable to fill
        max_quote: u64, // Return before exceeding
        limit_price: u64, // Can rail to 0 or HI_64
    ) acquires OrderBooks {

    }

}

