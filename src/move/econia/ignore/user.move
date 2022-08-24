module econia::user {

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Fill a user's order, routing coin collateral as needed.
    ///
    /// Only to be called by the matching engine, which has already
    /// calculated the corresponding amount of assets to fill. If the
    /// matching engine gets to this stage, then it is assumed that
    /// given user has the indicated open order and sufficient assets
    /// to fill it. Hence no error checking.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `size_filled`: Number of lots filled
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base asset
    ///   units routed from `user`, else to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote asset
    ///   units routed to `user`, else from `user`
    public(friend) fun fill_order_internal<
        BaseType,
        QuoteType
    >(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        size_filled: u64,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Update user's market account
        fill_order_update_market_account(user, market_account_info, side,
            order_id, complete_fill, size_filled, base_to_route,
            quote_to_route);
        // Route collateral accordingly, as needed
        fill_order_route_collateral<BaseType, QuoteType>(user,
            market_account_info, side, optional_base_coins_ref_mut,
            optional_quote_coins_ref_mut, base_to_route, quote_to_route);
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Route collateral when filling an order, for coin assets.
    ///
    /// Inner function for `fill_order_internal()`.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base coins to
    ///   route from `user` to `base_coins_ref_mut`, else from
    ///   `base_coins_ref_mut` to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote coins to
    ///   route from `quote_coins_ref_mut` to `user`, else from `user`
    ///   to `quote_coins_ref_mut`
    fun fill_order_route_collateral<
        BaseType,
        QuoteType
    >(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires Collateral {
        // Determine route direction for base and quote relative to user
        let (base_direction, quote_direction) =
            if (side == ASK) (OUT, IN) else (IN, OUT);
        // If base asset is coin type then route base coins
        if (option::is_some(optional_base_coins_ref_mut))
            fill_order_route_collateral_single<BaseType>(
                user, market_account_info,
                option::borrow_mut(optional_base_coins_ref_mut),
                base_to_route, base_direction);
        // If quote asset is coin type then route quote coins
        if (option::is_some(optional_quote_coins_ref_mut))
            fill_order_route_collateral_single<QuoteType>(
                user, market_account_info,
                option::borrow_mut(optional_quote_coins_ref_mut),
                quote_to_route, quote_direction);
    }

    /// Route `amount` of `Collateral` in `direction` either `IN` or
    /// `OUT`, relative to `user` with `market_account_info`, either
    /// from or to, respectively, coins at `external_coins_ref_mut`.
    ///
    /// Inner function for `fill_order_route_collateral()`.
    ///
    /// # Assumes
    /// * User has a `Collateral` entry for given `market_account_info`
    ///   with range-checked coin amount for given operation: should
    ///   only be called after a user has successfully placed an order
    ///   in the first place.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `external_coins_ref_mut`: Effectively a counterparty to `user`
    /// * `amount`: Amount of coins to route
    /// * `direction`: `IN` or `OUT`
    fun fill_order_route_collateral_single<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        external_coins_ref_mut: &mut coin::Coin<CoinType>,
        amount: u64,
        direction: bool
    ) acquires Collateral {
        // Borrow mutable reference to user's collateral map
        let collateral_map_ref_mut =
            &mut borrow_global_mut<Collateral<CoinType>>(user).map;
        // Borrow mutable reference to user's collateral
        let collateral_ref_mut = open_table::borrow_mut(collateral_map_ref_mut,
            market_account_info);
        // If inbound collateral to user
        if (direction == IN)
            // Merge to their collateral the extracted external coins
            coin::merge(collateral_ref_mut,
                coin::extract(external_coins_ref_mut, amount)) else
            // If outbound collateral from user, merge to external coins
            // those extracted from user's collateral
            coin::merge(external_coins_ref_mut,
                coin::extract(collateral_ref_mut, amount));
    }

    /// Update a user's market account when filling an order.
    ///
    /// Inner function for `fill_order_internal()`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `size_filled`: Number of lots filled
    /// * `base_to_route`: If `side` is `ASK`, number of base asset
    ///   units routed from `user`, else to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote asset
    ///   units routed to `user`, else from `user`
    ///
    /// # Assumes
    /// * User has an open order as specified: should only be called
    ///   after a user has successfully placed an order in the first
    ///   place.
    fun fill_order_update_market_account(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        size_filled: u64,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires MarketAccounts {
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_info);
        let ( // Get mutable reference to corresponding orders tree,
            tree_ref_mut,
            asset_in, // Amount of inbound asset
            asset_in_total_ref_mut, // Inbound asset total field
            asset_in_available_ref_mut, // Available field
            asset_out, // Amount of outbound asset
            asset_out_total_ref_mut, // Outbound asset total field
            asset_out_ceiling_ref_mut, // Ceiling field
        ) = if (side == ASK) ( // If an ask is matched
            &mut market_account_ref_mut.asks,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_available,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_ceiling,
        ) else ( // If a bid is matched
            &mut market_account_ref_mut.bids,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_available,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_ceiling,
        );
        if (complete_fill) { // If completely filling the order
            critbit::pop(tree_ref_mut, order_id); // Pop order
        } else { // If only partially filling the order
            // Get mutable reference to size left to fill on order
            let order_size_ref_mut =
                critbit::borrow_mut(tree_ref_mut, order_id);
            // Decrement amount still unfilled
            *order_size_ref_mut = *order_size_ref_mut - size_filled;
        };
        // Update asset counts for incoming and outgoing assets
        *asset_in_total_ref_mut     = *asset_in_total_ref_mut     + asset_in;
        *asset_in_available_ref_mut = *asset_in_available_ref_mut + asset_in;
        *asset_out_total_ref_mut    = *asset_out_total_ref_mut    - asset_out;
        *asset_out_ceiling_ref_mut  = *asset_out_ceiling_ref_mut  - asset_out;
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling asks for a market with base coin/quote generic
    fun test_fill_order_internal_asks_base_coin_quote_generic(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
        let optional_base_coins = option::some<Coin<BC>>(coin::zero<BC>());
        let optional_quote_coins = option::none<Coin<QG>>();
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BC, QG>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BC, QG>(user, market_id, general_custodian_id);
        // Deposit coin asset to user's market account
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint(econia, base_start));
        // Register user with order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has base collateral deposited
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) == base_start, 0);
        // Assert has no quote collateral structure
        assert!(!has_collateral_test<QG>(
            @user, market_id, general_custodian_id), 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BC, QG>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_to_route_1, 0);
        // Assert base collateral withdrawn
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) ==
            base_start - base_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BC, QG>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_start, 0);
        // Assert all base collateral withdrawn
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
        // Destroy optional coin structures
        assets::burn(option::destroy_some(optional_base_coins));
        option::destroy_none(optional_quote_coins);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling asks for a market with base generic/quote coin
    fun test_fill_order_internal_asks_base_generic_quote_coin(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
        let optional_base_coins = option::none<Coin<BG>>();
        let optional_quote_coins = option::some<Coin<QC>>(
            assets::mint<QC>(econia, quote_filled_total));
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BG, QC>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Deposit generic asset to user's market account
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            base_start, &generic_asset_transfer_custodian_capability);
        // Register user with order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        // Assert has no quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_filled_total - quote_to_route_1, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) == 0, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_filled_total, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
        // Destroy optional coin structures
        option::destroy_none(optional_base_coins);
        coin::destroy_zero(option::destroy_some(optional_quote_coins));
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling bids for a market with base generic/quote coin
    fun test_fill_order_internal_bids_base_generic_quote_coin(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = BID;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let quote_start = size * price * tick_size;
        let base_filled_total = size * lot_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
        let optional_base_coins = option::none<Coin<BG>>();
        let optional_quote_coins = option::some<Coin<QC>>(coin::zero<QC>());
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BG, QC>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Deposit coin asset to user's market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint(econia, quote_start));
        // Register user with order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        // Assert has quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_start, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1, 0);
        // Assert quote collateral withdrawn
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) ==
            quote_start - quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_to_route_1, 0);
        assert!(base_available  == base_to_route_1, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start - quote_to_route_1, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start - quote_to_route_1, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1 + quote_to_route_2, 0);
        // Assert no more quote collateral
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_filled_total, 0);
        assert!(base_available  == base_filled_total, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
        // Destroy optional coin structures
        option::destroy_none(optional_base_coins);
        assets::burn(option::destroy_some(optional_quote_coins));
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}
