// Matching engine function signature planning
module econia::signatures {

    fun match_from_market_account<
        BaseType,
        QuoteType
    >(
        host_ref: &address,
        market_id_ref: &address,
        market_account_id_ref: &u128,
        direction_ref: &bool,
        min_lots_ref: &u64,
        max_base_ref: &u64,
        min_base_ref: &u64,
        max_quote_ref: &u64,
        limit_price_ref: &u64,
    ): (
        u64, // Lots filled
        u64 // Ticks filled
    ) acquires OrderBooks {

        // This could be a helper func

        // Determine if base asset is coin
        let base_is_coin = coin::is_coin_initialized<BaseType>();
        // Determine if quote asset is coin
        let quote_is_coin = coin::is_coin_initialized<QuoteType>();
        // Get option-wrapped coins if base is coin, else empty option
        let optional_base_coins = if (base_is_coin)
            user::withdraw_coins_as_option_internal<BaseType>(
                user, market_account_id, amount) else option::none();
        // Get option-wrapped coins if quote is coin, else empty option
        let optional_quote_coins = if (quote_is_coin)
            user::withdraw_coins_as_option_internal<QuoteType>(
                user, market_account_id, amount) else option::none();
        let optional_quote_coins =
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

