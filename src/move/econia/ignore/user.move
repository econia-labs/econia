module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use econia::capability::EconiaCapability;
    use econia::order_id;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Get a `MarketInfo` for type arguments, pack with `custodian_id`
    /// into a `MarketAccountInfo` and return
    public fun market_account_info<B, Q, E>(
        custodian_id: u64
    ): MarketAccountInfo {
        MarketAccountInfo{
            market_info: registry::market_info<B, Q, E>(),
            custodian_id
        }
    }

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    /// Reserved for internal cross-module calls, and requires a
    /// reference to an `EconiaCapability`.
    public fun withdraw_collateral_internal<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        _econia_capability: &EconiaCapability
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Withdraw collateral from user's market account
        withdraw_collateral<CoinType>(user, market_account_info, amount)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful state update for asks
    fun test_fill_order_internal_ask(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare ask parameters
        let (custodian_id, side, order_id, order_base_parcels, price) = (
             NO_CUSTODIAN,  ASK,      123,                456,   789);
        // Declare base coins at start
        let base_coins_start = 12345678;
        // Declare scale factor
        let scale_factor = registry::scale_factor<E1>();
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit base coins
        deposit_collateral<BC>(@user, market_account_info,
            coins::mint<BC>(econia, base_coins_start));
        // Add ask
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            order_base_parcels, price, &get_econia_capability_test());
        // Declare number of quote coins held by matching engine
        let engine_quote_coins_start = 654321;
        let (engine_base_coins, engine_quote_coins) = (
            coin::zero<BC>(),
            coins::mint<QC>(econia, engine_quote_coins_start)
        ); // Initialize matching engine side of route with coins
        // Declare partial fill parameters relative to user
        let base_parcels_filled_1 = 100;
        let base_to_route_1 = base_parcels_filled_1 * scale_factor;
        let quote_to_route_1 = base_parcels_filled_1 * price;
        // Process a partial fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            false, base_parcels_filled_1, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_1, quote_to_route_1,
            &get_econia_capability_test());
        // Assert base coin counts
        let (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_coins_start - base_to_route_1, 0);
        assert!(base_coins_available == base_coins_start -
            order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        let (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_to_route_1, 0);
        assert!(quote_coins_available == quote_to_route_1, 0);
        // Assert order base parcel size updates
        assert!(order_base_parcels_test<BC, QC, E1>(@user, custodian_id, side,
            order_id) == order_base_parcels - base_parcels_filled_1, 0);
        // Get collateral amounts
        let (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_coins_start - base_to_route_1, 0);
        assert!(quote_collateral == quote_to_route_1, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) == base_to_route_1, 0);
        assert!(coin::value(&engine_quote_coins) == engine_quote_coins_start -
            quote_to_route_1, 0);
        // Declare complete fill parameters relative to user
        let base_parcels_filled_2 = order_base_parcels - base_parcels_filled_1;
        let base_to_route_2 = base_parcels_filled_2 * scale_factor;
        let quote_to_route_2 = base_parcels_filled_2 * price;
        // Process a complete fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            true, base_parcels_filled_2, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_2, quote_to_route_2,
            &get_econia_capability_test());
        // Assert base coin counts
        (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_coins_start -
            order_base_parcels * scale_factor, 0);
        assert!(base_coins_available == base_coins_start -
            order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == order_base_parcels * price, 0);
        assert!(quote_coins_available == order_base_parcels * price, 0);
        // Assert order popped of user's open orders
        assert!(!has_order_test<BC, QC, E1>(@user, custodian_id, side,
            order_id), 0);
        // Get collateral amounts
        (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_coins_start -
            base_to_route_1 - base_to_route_2, 0);
        assert!(quote_collateral == quote_to_route_1 + quote_to_route_2, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) ==
            base_to_route_1 + base_to_route_2, 0);
        assert!(coin::value(&engine_quote_coins) ==
            engine_quote_coins_start - quote_to_route_1 - quote_to_route_2, 0);
        // Burn matching engine's coins
        coins::burn(engine_base_coins); coins::burn(engine_quote_coins);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful state update for bids
    fun test_fill_order_internal_bids(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare ask parameters
        let (custodian_id, side, order_id, order_base_parcels, price) = (
             NO_CUSTODIAN,  BID,      123,                456,   789);
        // Declare quote coins at start
        let quote_coins_start = 12345678;
        // Declare scale factor
        let scale_factor = registry::scale_factor<E1>();
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit quote coins
        deposit_collateral<QC>(@user, market_account_info,
            coins::mint<QC>(econia, quote_coins_start));
        // Add bid
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            order_base_parcels, price, &get_econia_capability_test());
        // Declare number of base coins held by matching engine
        let engine_base_coins_start = 654321;
        let (engine_base_coins, engine_quote_coins) = (
            coins::mint<BC>(econia, engine_base_coins_start),
            coin::zero<QC>()
        ); // Initialize matching engine side of route with coins
        // Declare partial fill parameters relative to user
        let base_parcels_filled_1 = 100;
        let base_to_route_1 = base_parcels_filled_1 * scale_factor;
        let quote_to_route_1 = base_parcels_filled_1 * price;
        // Process a partial fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            false, base_parcels_filled_1, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_1, quote_to_route_1,
            &get_econia_capability_test());
        // Assert base coin counts
        let (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_to_route_1, 0);
        assert!(base_coins_available == base_to_route_1, 0);
        // Assert quote coin counts
        let (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_coins_start - quote_to_route_1, 0);
        assert!(quote_coins_available == quote_coins_start -
            order_base_parcels * price, 0);
        // Assert order base parcel size updates
        assert!(order_base_parcels_test<BC, QC, E1>(@user, custodian_id, side,
            order_id) == order_base_parcels - base_parcels_filled_1, 0);
        // Get collateral amounts
        let (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_to_route_1, 0);
        assert!(quote_collateral == quote_coins_start - quote_to_route_1, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) == engine_base_coins_start -
            base_to_route_1, 0);
        assert!(coin::value(&engine_quote_coins) == quote_to_route_1, 0);
        // Declare complete fill parameters relative to user
        let base_parcels_filled_2 = order_base_parcels - base_parcels_filled_1;
        let base_to_route_2 = base_parcels_filled_2 * scale_factor;
        let quote_to_route_2 = base_parcels_filled_2 * price;
        // Process a complete fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            true, base_parcels_filled_2, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_2, quote_to_route_2,
            &get_econia_capability_test());
        // Assert base coin counts
        (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == order_base_parcels * scale_factor, 0);
        assert!(base_coins_available == order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_coins_start -
            order_base_parcels * price, 0);
        assert!(quote_coins_available == quote_coins_start -
            order_base_parcels * price, 0);
        // Assert order popped of user's open orders
        assert!(!has_order_test<BC, QC, E1>(@user, custodian_id, side,
            order_id), 0);
        // Get collateral amounts
        (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_to_route_1 + base_to_route_2, 0);
        assert!(quote_collateral ==
            quote_coins_start - quote_to_route_1 - quote_to_route_2, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) ==
            engine_base_coins_start - base_to_route_1 - base_to_route_2, 0);
        assert!(coin::value(&engine_quote_coins) ==
            quote_to_route_1 + quote_to_route_2, 0);
        // Burn matching engine's coins
        coins::burn(engine_base_coins); coins::burn(engine_quote_coins);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}