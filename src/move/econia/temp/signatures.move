// Matching engine function signature planning
module econia::signatures {

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
        fill_or_abort: bool, // Passes base_amount
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

    #[cmd]
    /// Place a limit order as a signing user.
    ///
    /// See wrapped function `place_limit_order()`.
    public entry fun place_limit_order_user(
        user: &signer,
        host: address,
        market_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool
    ) acquires OrderBooks {
        place_limit_order(
            address_of(user),
            host,
            market_id,
            NO_CUSTODIAN,
            side,
            size,
            price,
            post_or_abort
        );
    }

    /// Place a limit order on behalf of user, via
    /// `general_custodian_capability_ref`.
    ///
    /// See wrapped function `place_limit_order()`.
    public fun place_limit_order_custodian(
        user: address,
        host: address,
        market_id: u64,
        side: bool,
        size: u64,
        price: u64,
        post_or_abort: bool,
        general_custodian_capability_ref: &CustodianCapability
    ) acquires OrderBooks {
        place_limit_order(
            user,
            host,
            market_id,
            registry::custodian_id(general_custodian_capability_ref),
            side,
            size,
            price,
            post_or_abort
        );
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful placement and cancellation for multiple orders
    ///
    /// 1. Place order
    /// 2. Place order with same price as first order
    /// 3. Place order with price further away from spread
    /// 4. Cancel order from (1)
    /// 5. Cancel order from (3)
    /// 6. Cancel order from (2)
    fun test_place_cancel_limit_orders_ask(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Get market account ID
        let market_account_id =
            user::get_market_account_id(MARKET_ID, general_custodian_id);
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let base_fill_1 = size_1 * LOT_SIZE;
        let quote_fill_1 = size_1 * price_1 * TICK_SIZE;
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let base_fill_2 = size_2 * LOT_SIZE;
        let quote_fill_2 = size_2 * price_2 * TICK_SIZE;
        let size_3 = 987;
        let price_3 = price_1 + 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        let base_fill_3 = size_3 * LOT_SIZE;
        let quote_fill_3 = size_3 * price_3 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        let order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_1);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE - base_fill_1, 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE + quote_fill_1, 0);
        assert!(order_size      == size_1, 0);
        // Get book state
        let (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_1, side);
        let spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_1, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place order at same price, not setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_2, price_2, post_or_abort_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_2);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
                                   (base_fill_1 + base_fill_2), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
                                   (quote_fill_1 + quote_fill_2), 0);
        assert!(order_size      == size_2, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_2, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_2, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place new order further away from spread
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_3, price_3, post_or_abort_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_3);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
            (base_fill_1 + base_fill_2 + base_fill_3), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
            (quote_fill_1 + quote_fill_2 + quote_fill_3), 0);
        assert!(order_size      == size_3, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_3, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_3, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_1);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE -
                                   (base_fill_2 + base_fill_3), 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE +
                                   (quote_fill_2 + quote_fill_3), 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_1), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        // Cancel order that is not spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE - base_fill_2, 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE + quote_fill_2, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_3), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel only remaining order
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_2), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == MIN_ASK_DEFAULT, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful placement and cancellation for multiple orders
    ///
    /// 1. Place order
    /// 2. Place order with same price as first order
    /// 3. Place order with price further away from spread
    /// 4. Cancel order from (1)
    /// 5. Cancel order from (3)
    /// 6. Cancel order from (2)
    fun test_place_cancel_limit_orders_bid(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Get market account ID
        let market_account_id =
            user::get_market_account_id(MARKET_ID, general_custodian_id);
        // Declare market parameters
        let side = BID;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let base_fill_1 = size_1 * LOT_SIZE;
        let quote_fill_1 = size_1 * price_1 * TICK_SIZE;
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let base_fill_2 = size_2 * LOT_SIZE;
        let quote_fill_2 = size_2 * price_2 * TICK_SIZE;
        let size_3 = 987;
        let price_3 = price_1 - 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        let base_fill_3 = size_3 * LOT_SIZE;
        let quote_fill_3 = size_3 * price_3 * TICK_SIZE;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place order, setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_1, price_1, post_or_abort_1);
        // Get user state
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        let order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_1);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE + base_fill_1, 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE - quote_fill_1, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_1, 0);
        // Get book state
        let (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_1, side);
        let spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_1, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place order at same price, not setting a new spread maker
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_2, price_2, post_or_abort_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_2);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
                                   (base_fill_1 + base_fill_2), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
                                   (quote_fill_1 + quote_fill_2), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_2, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_2, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_2, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Place new order further away from spread
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size_3, price_3, post_or_abort_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        order_size = user::get_order_size_test(@user, market_account_id,
            side, order_id_3);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
            (base_fill_1 + base_fill_2 + base_fill_3), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
            (quote_fill_1 + quote_fill_2 + quote_fill_3), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(order_size      == size_3, 0);
        // Get book state
        (order_size, order_user, order_general_custodian_id) =
            get_order_fields_test(@econia, MARKET_ID, order_id_3, side);
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(order_size                 == size_3, 0);
        assert!(order_user                 == @user, 0);
        assert!(order_general_custodian_id == general_custodian_id, 0);
        assert!(spread_maker               == order_id_1, 0);
        // Cancel spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_1);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE +
                                   (base_fill_2 + base_fill_3), 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE -
                                   (quote_fill_2 + quote_fill_3), 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_1), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        // Cancel order that is not spread maker
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_3);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE + base_fill_2, 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE - quote_fill_2, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_3), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == order_id_2, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel only remaining order
        cancel_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, order_id_2);
        // Get user state
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            user::get_asset_counts_test(@user, market_account_id);
        // Assert user state
        assert!(base_total      == USER_START_BASE , 0);
        assert!(base_available  == USER_START_BASE , 0);
        assert!(base_ceiling    == USER_START_BASE , 0);
        assert!(quote_total     == USER_START_QUOTE, 0);
        assert!(quote_available == USER_START_QUOTE, 0);
        assert!(quote_ceiling   == USER_START_QUOTE, 0);
        assert!(!user::has_order_test(
            @user, market_account_id, side, order_id_2), 0);
        // Get book state
        spread_maker = get_spread_maker_test(@econia, MARKET_ID, side);
        // Assert book state
        assert!(spread_maker == MAX_BID_DEFAULT, 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Test order placement and cancellation as a general custodian
    fun test_place_cancel_limit_orders_custodian(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = true;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let size_3 = 987;
        let price_3 = price_1 + 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        // Get general custodian capability
        let general_custodian_capability =
            registry::get_custodian_capability_test(GENERAL_CUSTODIAN_ID);
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place limit orders
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_1,
            price_1, post_or_abort_1, &general_custodian_capability);
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_2,
            price_2, post_or_abort_2, &general_custodian_capability);
        place_limit_order_custodian(@user, @econia, MARKET_ID, side, size_3,
            price_3, post_or_abort_3, &general_custodian_capability);
        // Assert orders on book
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel single order
        cancel_limit_order_custodian(@user, @econia, MARKET_ID, side,
            order_id_2, &general_custodian_capability);
        // Assert order off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        // Cancel all orders
        cancel_all_limit_orders_custodian(@user, @econia, MARKET_ID, side,
            &general_custodian_capability);
        // Assert orders off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Attempt to cancel all orders, silently returning since none
        cancel_all_limit_orders_custodian(@user, @econia, MARKET_ID, side,
            &general_custodian_capability);
        // Destroy general custodian capability
        registry::destroy_custodian_capability_test(
            general_custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Test order placement and cancellation as signing user
    fun test_place_cancel_limit_orders_user(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare market parameters
        let side = BID;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = false;
        // Declare order parameters
        let size_1 = 123;
        let price_1 = 456;
        let post_or_abort_1 = false;
        let order_id_1 = order_id::order_id(price_1, 0, side);
        let size_2 = 789;
        let price_2 = price_1; // Same price as first order
        let post_or_abort_2 = false;
        let order_id_2 = order_id::order_id(price_2, 1, side);
        let size_3 = 987;
        let price_3 = price_1 - 1; // Further away from spread
        let post_or_abort_3 = false;
        let order_id_3 = order_id::order_id(price_3, 2, side);
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Place limit orders
        place_limit_order_user(user, @econia, MARKET_ID, side, size_1,
            price_1, post_or_abort_1);
        place_limit_order_user(user, @econia, MARKET_ID, side, size_2,
            price_2, post_or_abort_2);
        place_limit_order_user(user, @econia, MARKET_ID, side, size_3,
            price_3, post_or_abort_3);
        // Assert orders on book
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        assert!(has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Cancel single order
        cancel_limit_order_user(user, @econia, MARKET_ID, side, order_id_2);
        // Assert order off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_2), 0);
        // Cancel all orders
        cancel_all_limit_orders_user(user, @econia, MARKET_ID, side);
        // Assert orders off book
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_1), 0);
        assert!(!has_order_test(@econia, MARKET_ID, side, order_id_3), 0);
        // Attempt to cancel all orders, silently returning since none
        cancel_all_limit_orders_user(user, @econia, MARKET_ID, side);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for post-or-abort crossed spread
    fun test_place_limit_order_crossed_spread_ask(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Register market and user
        register_market_funded_user_test(econia, user, true, true, false);
        // Place a bid
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, BID, 10,
            5, false);
        // Place a post-or-abort limit order that crosses spread
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, ASK, 10,
            4, true);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for post-or-abort crossed spread
    fun test_place_limit_order_crossed_spread_bid(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Register market and user
        register_market_funded_user_test(econia, user, true, true, false);
        // Place a bid
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, ASK, 10,
            5, false);
        // Place a post-or-abort limit order that crosses spread
        place_limit_order(@user, @econia, MARKET_ID, NO_CUSTODIAN, BID, 10,
            6, true);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for invalid custodian cancelling order
    fun test_cancel_limit_order_invalid_custodian(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Declare invalid custodian ID
        let invalid_custodian_id = general_custodian_id + 1;
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Declare order parameters
        let size = 123;
        let price = 456;
        let post_or_abort = false;
        let order_id = order_id::order_id(price, 0, side);
        // Place order
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size, price, post_or_abort);
        // Attempt invalid cancellation
        cancel_limit_order(@user, @econia, MARKET_ID, invalid_custodian_id,
            side, order_id);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid user cancelling order
    fun test_cancel_limit_order_invalid_user(
        econia: &signer,
        user: &signer
    ) acquires OrderBooks {
        // Declare signing user for transactions
        let general_custodian_id = NO_CUSTODIAN;
        // Declare market parameters
        let side = ASK;
        let base_is_coin = true;
        let quote_is_coin = true;
        let has_general_custodian = general_custodian_id != NO_CUSTODIAN;
        // Register market and funded user
        register_market_funded_user_test(econia, user, base_is_coin,
            quote_is_coin, has_general_custodian);
        // Declare order parameters
        let size = 123;
        let price = 456;
        let post_or_abort = false;
        let order_id = order_id::order_id(price, 0, side);
        // Place order
        place_limit_order(@user, @econia, MARKET_ID, general_custodian_id,
            side, size, price, post_or_abort);
        // Attempt invalid cancellation
        cancel_limit_order(@econia, @econia, MARKET_ID, general_custodian_id,
            side, order_id);
    }

}